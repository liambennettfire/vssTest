if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_pl_items') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_pl_items
GO

CREATE PROCEDURE qpl_recalc_pl_items (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @i_summarylevel   integer,
  @i_jointacctgind  tinyint,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************************
**  Name: qpl_recalc_pl_items
**  Desc: This stored procedure recalculates all p&l summary items for the given summarylevel/jointacctgind.
**
**  Auth: Kate
**  Date: October 4 2012
*****************************************************************************************************************
**  Change History
*****************************************************************************************************************
*   Date:     Author:   Description:
*   --------  -------   ------------------------------------------------------------------------
*   03/20/16  Kate      Case 35197 - P&L Summary Item filter by Item Type/Usage Class
*   03/31/16  Kate      Case 35972 - Rewritten to process specific P&L Summary Level only.
*   06/13/16  Kate      Case 38583 - PL summary lines not re-calculating when item type filtering is turned on
*   06/18/16  Kate      Take out the error out for P&L Report level - handled now.
******************************************************************************************************************/

DECLARE
  @v_calcvalue  DECIMAL(18,4),
  @v_cur_veryear_open TINYINT,
  @v_cur_items_open TINYINT,
  @v_count  INT,
  @v_display_currency	INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),
  @v_final_approval_status  INT,
  @v_itemcode INT,
  @v_itemkey  INT,
  @v_is_master_project  INT,
  @v_max_stage  INT,
  @v_maxyear  INT,
  @v_option_lock_stage TINYINT,
  @v_option_synch TINYINT,
  @v_rowcount INT,
  @v_selected_ver INT,
  @v_usageclass INT,
  @v_userkey  INT,
  @v_versionkey  INT,
  @v_yearcode INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO ERROR
  END

  -- Check if this is a Master relationship project
  SELECT @v_is_master_project = dbo.qpl_is_master_pl_project(@i_projectkey)

  -- Do not calculate Consolidated Stage level P&L Summary Items unless it is a Master project
  IF @i_summarylevel = 5 AND @v_is_master_project = 0
    RETURN
   
  -- Do not calculate any level P&L Summary Items for a Locked Stage
  SET @v_final_approval_status = 0 
  SELECT @v_option_lock_stage = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
  IF @v_option_lock_stage = 1 BEGIN
    SELECT @v_final_approval_status = COALESCE(CAST(clientdefaultvalue AS INT), 0) FROM clientdefaults where clientdefaultid = 61 
  END 
  IF @v_final_approval_status > 0 BEGIN
    IF EXISTS(SELECT * FROM taqversion WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND plstatuscode = @v_final_approval_status)
      RETURN
  END  

  -- Use input currency as the display currency (default to US Dollars).
  SELECT @v_display_currency = COALESCE(plenteredcurrency,0), @v_itemcode = searchitemcode, @v_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey

  IF @v_display_currency = 0
    SELECT @v_display_currency = datacode 
    FROM gentables 
    WHERE tableid = 122 AND qsicode = 2	--US Dollars
 
  -- The veryear_cur loop drives the Version and Year parameters to the qpl_run_pl_calcsql stored procedure:
  -- zero Version and Year for Stage-level, zero Year for Version-level, and specific multiple years for Year-level
  IF @i_summarylevel = 1 OR @i_summarylevel = 5  --Stage or Consolidated Stage
    DECLARE veryear_cur CURSOR FOR
      SELECT 0, 0
  ELSE IF @i_summarylevel = 2 --Version
    DECLARE veryear_cur CURSOR FOR
      SELECT @i_plversion, 0
  ELSE  --Year (@i_summarylevel = 3)
  BEGIN
    -- Get the number of years for this version
    SELECT @v_maxyear = maxyearcode
    FROM taqversion
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
    
    -- Loop throuch each year on this version, including Pre-Pub year
    DECLARE veryear_cur CURSOR FOR
      SELECT @i_plversion, datacode
      FROM gentables 
      WHERE tableid = 563 AND sortorder <= (SELECT sortorder FROM gentables WHERE tableid = 563 AND datacode = @v_maxyear)
      ORDER BY sortorder
  END
      
  OPEN veryear_cur

  SET @v_cur_veryear_open = 1
    
  FETCH veryear_cur INTO @v_versionkey, @v_yearcode
    
  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- Loop through all active calculated summary items for the specific passed summary level and recalculate each
    -- Note: First part of the union will return values when filering is not required for a summary level, second part when it is.
    IF @i_jointacctgind = 1
      DECLARE summaryitems_cur CURSOR FOR    
      SELECT d.plsummaryitemkey -- , d.summarylevelcode
      FROM plsummaryitemdefinition d, gentables g
      WHERE g.tableid = 561 AND d.summarylevelcode = g.datacode AND COALESCE(g.gen1ind, 0) = 0 
        AND d.summarylevelcode = @i_summarylevel AND d.activeind = 1 AND d.itemtype = 6 AND d.alwaysrecalcind = 0 AND jointacctgind = 1
      UNION
      SELECT d.plsummaryitemkey -- , d.summarylevelcode
      FROM plsummaryitemdefinition d, gentables g, plsummaryitemtype t
      WHERE g.tableid = 561 AND d.summarylevelcode = g.datacode AND g.gen1ind = 1
        AND d.summarylevelcode = @i_summarylevel AND d.activeind = 1 AND d.itemtype = 6 AND d.alwaysrecalcind = 0 AND jointacctgind = 1
        AND t.plsummaryitemkey = d.plsummaryitemkey AND t.itemtypecode = @v_itemcode AND t.itemtypesubcode IN (@v_usageclass,0)
    ELSE
      DECLARE summaryitems_cur CURSOR FOR    
      SELECT d.plsummaryitemkey -- , d.summarylevelcode
      FROM plsummaryitemdefinition d, gentables g
      WHERE g.tableid = 561 AND d.summarylevelcode = g.datacode AND COALESCE(g.gen1ind, 0) = 0
        AND d.summarylevelcode = @i_summarylevel AND d.activeind = 1 AND d.itemtype = 6 AND d.alwaysrecalcind = 0
      UNION
      SELECT d.plsummaryitemkey -- , d.summarylevelcode
      FROM plsummaryitemdefinition d, gentables g, plsummaryitemtype t
      WHERE g.tableid = 561 AND d.summarylevelcode = g.datacode AND g.gen1ind = 1
        AND d.summarylevelcode = @i_summarylevel AND d.activeind = 1 AND d.itemtype = 6 AND d.alwaysrecalcind = 0
        AND t.plsummaryitemkey = d.plsummaryitemkey AND t.itemtypecode = @v_itemcode AND t.itemtypesubcode IN (@v_usageclass,0)
        
    OPEN summaryitems_cur

    SET @v_cur_items_open = 1

    FETCH summaryitems_cur INTO @v_itemkey

    WHILE (@@FETCH_STATUS=0)
    BEGIN
        
      PRINT 'running calculation for P&L Item ' + CONVERT(VARCHAR, @v_itemkey)
      
      EXEC qpl_run_pl_calcsql @i_projectkey, @i_plstage, @v_versionkey, @v_yearcode, @v_itemkey, @v_display_currency,
        @v_calcvalue OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
          
      IF @v_errorcode <> 0
        GOTO ERROR
          
      SELECT @v_count = COUNT(*)
      FROM taqplsummaryitems
      WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @v_versionkey AND
        yearcode = @v_yearcode AND
        plsummaryitemkey = @v_itemkey
          
      IF @v_count > 0
      BEGIN
        DECLARE @v_cur_calcvalue DECIMAL(18,4)

        SELECT @v_cur_calcvalue = decimalvalue
        FROM taqplsummaryitems
        WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @v_versionkey AND
          yearcode = @v_yearcode AND
          plsummaryitemkey = @v_itemkey

        PRINT 'taqplsummaryitems UPDATE: ' + CONVERT(VARCHAR, @i_projectkey) + ', ' + CONVERT(VARCHAR, @i_plstage) + ', '
          + CONVERT(VARCHAR, @v_versionkey) + ', ' + CONVERT(VARCHAR, @v_yearcode) + ' /' + CONVERT(VARCHAR, @v_itemkey)

        IF @v_cur_calcvalue = @v_calcvalue OR (@v_cur_calcvalue IS NULL AND @v_calcvalue IS NULL)
          PRINT 'no update - same value'
        ELSE
        BEGIN
          IF @v_cur_calcvalue IS NULL
            PRINT 'FROM NULL TO ' + CONVERT(VARCHAR, @v_calcvalue)
          ELSE IF @v_calcvalue IS NULL
            PRINT 'FROM ' + CONVERT(VARCHAR, @v_cur_calcvalue) + ' TO NULL'
          ELSE
            PRINT 'FROM ' + CONVERT(VARCHAR, @v_cur_calcvalue) + ' TO ' + CONVERT(VARCHAR, @v_calcvalue)

          UPDATE taqplsummaryitems
          SET decimalvalue = @v_calcvalue, lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @v_versionkey AND
            yearcode = @v_yearcode AND
            plsummaryitemkey = @v_itemkey
        END
      END
      ELSE
      BEGIN
        PRINT 'NEW taqplsummaryitems INSERT: ' + CONVERT(VARCHAR, @i_projectkey) + ', ' + CONVERT(VARCHAR, @i_plstage) + ', '
          + CONVERT(VARCHAR, @v_versionkey) + ', ' + CONVERT(VARCHAR, @v_yearcode) + ' /' + CONVERT(VARCHAR, @v_itemkey)

        INSERT INTO taqplsummaryitems
          (taqprojectkey, plstagecode, taqversionkey, yearcode, plsummaryitemkey, decimalvalue, lastuserid, lastmaintdate)
        VALUES
          (@i_projectkey, @i_plstage, @v_versionkey, @v_yearcode, @v_itemkey, @v_calcvalue, @i_userid, getdate())
      END

      SELECT @v_errorcode = @@ERROR
      IF @v_errorcode <> 0
        GOTO ERROR
      
      FETCH summaryitems_cur INTO @v_itemkey
    END

    CLOSE summaryitems_cur
    DEALLOCATE summaryitems_cur
    
    SET @v_cur_items_open = 0
        
    FETCH veryear_cur INTO @v_versionkey, @v_yearcode
  END
    
  CLOSE veryear_cur
  DEALLOCATE veryear_cur

  SET @v_cur_veryear_open = 0

  -- When calculating Version-level summary items, may need to sync the P&L to work titles or to TAQ Pub Plan
  IF @i_summarylevel = 2  --Version
  BEGIN
    -- Check if this is the most recent stage on the project
    SELECT @v_max_stage = dbo.qpl_get_most_recent_stage(@i_projectkey)
    IF @v_max_stage > 0 AND @i_plstage = @v_max_stage
    BEGIN
      -- Check if this is the selected version on the most recent stage of the project
      SELECT @v_selected_ver = selectedversionkey
      FROM taqplstage
      WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @v_max_stage

      IF @i_plversion = @v_selected_ver
      BEGIN
        SELECT @v_userkey = userkey
        FROM qsiusers
        WHERE userid = @i_userid

        SELECT @v_itemcode = searchitemcode, @v_usageclass = usageclasscode
        FROM taqproject
        WHERE taqprojectkey = @i_projectkey
 
        SELECT @v_errorcode = @@ERROR, @v_rowcount = @@ROWCOUNT
        IF @v_errorcode <> 0 OR @v_rowcount <= 0 BEGIN
          SET @o_error_desc = 'Could not access taqproject to get itemtype and usageclass.'
          GOTO ERROR
        END

        SET @v_errorcode = 0

        IF @v_itemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) BEGIN --Work
          SELECT @v_option_synch = optionvalue
          FROM clientoptions
          WHERE optionid = 104  --P&L Sel.Ver. - Titles

          IF @v_option_synch = 1
            EXEC qpl_sync_version_to_work_titles @i_projectkey, @i_plstage, @v_selected_ver, @v_userkey, 1, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        END
        ELSE IF @v_itemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 3) AND 
                @v_usageclass = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1) BEGIN  --Title Acquisition
          SELECT @v_option_synch = optionvalue
          FROM clientoptions
          WHERE optionid = 101  --P&L Sel.Ver. - Acq. Project

          IF @v_option_synch = 1
            EXEC qpl_sync_version_to_acq_project @i_projectkey, @i_plstage, @v_selected_ver, @v_userkey, 1, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        END
          
        IF @v_errorcode <> 0
          GOTO ERROR
      END
    END
  END

  RETURN

  ERROR:
  IF @v_cur_items_open = 1 BEGIN
    CLOSE summaryitems_cur
    DEALLOCATE summaryitems_cur
  END
  IF @v_cur_veryear_open = 1 BEGIN
    CLOSE veryear_cur
    DEALLOCATE veryear_cur
  END  
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@i_projectkey AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN
   
END
GO

GRANT EXEC ON qpl_recalc_pl_items TO PUBLIC
GO
