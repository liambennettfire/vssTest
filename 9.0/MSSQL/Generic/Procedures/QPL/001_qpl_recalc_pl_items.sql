if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_pl_items') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_pl_items
GO

CREATE PROCEDURE qpl_recalc_pl_items (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************
**  Name: qpl_recalc_pl_items
**  Desc: This stored procedure recalculates all p&l summary items for the given level:
**        If @i_plversion > 0, it recalculates all Version and Year items for the given version
**        If @i_plversion = 0, it recalculates all Stage level summary items
**
**  Auth: Kate
**  Date: October 4 2012
*************************************************************************************************/

DECLARE
  @v_calc_stage_items TINYINT,
  @v_calcvalue  DECIMAL(18,4),
  @v_count  INT,
  @v_display_currency	INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),
  @v_itemcode INT,
  @v_itemkey  INT,
  @v_itemlevel  INT,
  @v_max_non_actual_stage INT,
  @v_maxyear  INT,
  @v_related_projectkey INT,
  @v_selected_ver INT,
  @v_usageclass INT,
  @v_userkey  INT,
  @v_yearcode INT,
  @v_rowcount INT,
  @v_Is_Master_Project INT,
  @v_is_stage_locked INT,
  @v_PL_Final_Approved_Status INT   

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_Is_Master_Project = 0
  SET @v_PL_Final_Approved_Status = 0
  
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
	SET @o_error_desc = 'Invalid projectkey.'
	GOTO ERROR
  END  
  
  SELECT @v_itemcode = searchitemcode, @v_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey
 
  SELECT @v_errorcode = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_errorcode <> 0 OR @v_rowcount <= 0 BEGIN
	SET @o_error_desc = 'Could not access taqproject to get itemtype and usageclass.'
	GOTO ERROR
  END  	  
    
  SELECT @v_Is_Master_Project = dbo.qpl_is_master_pl_project(@i_projectkey)
 
  SELECT @v_is_stage_locked = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
    
  IF @v_is_stage_locked = 1 BEGIN
     SELECT @v_PL_Final_Approved_Status = COALESCE(CAST(clientdefaultvalue AS INT), 0) FROM clientdefaults where clientdefaultid = 61 
  END 
  
  IF @v_Is_Master_Project = 1 AND @v_PL_Final_Approved_Status > 0  BEGIN  -- NOT calculating the PL items & Consolidated for a Locked Stage.
	IF EXISTS(SELECT * FROM taqversion WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND plstatuscode = @v_PL_Final_Approved_Status)
	BEGIN
	   RETURN
	END
  END  

  SELECT @v_display_currency = COALESCE(plenteredcurrency,0)
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey

  IF @v_display_currency = 0
    SELECT @v_display_currency = datacode 
    FROM gentables 
    WHERE tableid = 122 AND qsicode = 2	--US Dollars
  
  IF @i_plversion = 0 --calculate Stage level summary items
    SET @v_calc_stage_items = 1
    
  ELSE  --calculate both the Version and Year level summary items
  BEGIN
    -- First loop through all calculated version items and recalculate each
    DECLARE versionitems_cur CURSOR FOR
      SELECT plsummaryitemkey
      FROM plsummaryitemdefinition
      WHERE summarylevelcode = 2 AND activeind = 1 AND itemtype = 6 AND alwaysrecalcind = 0
      ORDER BY summarylevelcode, summaryheadingcode, position
      
    OPEN versionitems_cur 

    FETCH versionitems_cur INTO @v_itemkey

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      
      EXEC qpl_run_pl_calcsql @i_projectkey, @i_plstage, @i_plversion, 0, @v_itemkey, @v_display_currency,
        @v_calcvalue OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        
      IF @v_errorcode <> 0
        GOTO ERROR
       
      SELECT @v_count = COUNT(*)
      FROM taqplsummaryitems
      WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = @i_plversion AND
        yearcode = 0 AND
        plsummaryitemkey = @v_itemkey
        
      IF @v_count > 0
        UPDATE taqplsummaryitems
        SET decimalvalue = @v_calcvalue, lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @i_plversion AND
          yearcode = 0 AND
          plsummaryitemkey = @v_itemkey
      ELSE
        INSERT INTO taqplsummaryitems
          (taqprojectkey, plstagecode, taqversionkey, yearcode, plsummaryitemkey, decimalvalue, lastuserid, lastmaintdate)
        VALUES
          (@i_projectkey, @i_plstage, @i_plversion, 0, @v_itemkey, @v_calcvalue, @i_userid, getdate())
          
      SELECT @v_errorcode = @@ERROR
      IF @v_errorcode <> 0
        GOTO ERROR
      
      FETCH versionitems_cur INTO @v_itemkey
    END

    CLOSE versionitems_cur
    DEALLOCATE versionitems_cur
    
    -- Get the number of years for this version
    SELECT @v_maxyear = maxyearcode
    FROM taqversion
    WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
    
    -- Loop throuch each year on this version, including Pre-Pub year
    DECLARE years_cur CURSOR FOR
      SELECT datacode
      FROM gentables 
      WHERE tableid = 563 AND sortorder <= @v_maxyear
      ORDER BY sortorder
      
    OPEN years_cur
    
    FETCH years_cur INTO @v_yearcode
    
    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      -- Loop through all calculated year-level summary items and recalculate each
      DECLARE yearitems_cur CURSOR FOR
        SELECT plsummaryitemkey
        FROM plsummaryitemdefinition
        WHERE summarylevelcode = 3 AND activeind = 1 AND itemtype = 6 AND alwaysrecalcind = 0
        ORDER BY summarylevelcode, summaryheadingcode, position
        
      OPEN yearitems_cur 

      FETCH yearitems_cur INTO @v_itemkey

      WHILE (@@FETCH_STATUS=0)
      BEGIN
        
        EXEC qpl_run_pl_calcsql @i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_itemkey, @v_display_currency,
          @v_calcvalue OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
          
        IF @v_errorcode <> 0
          GOTO ERROR
          
        SELECT @v_count = COUNT(*)
        FROM taqplsummaryitems
        WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = @i_plversion AND
          yearcode = @v_yearcode AND
          plsummaryitemkey = @v_itemkey
          
        IF @v_count > 0
          UPDATE taqplsummaryitems
          SET decimalvalue = @v_calcvalue, lastuserid = @i_userid, lastmaintdate = getdate()
          WHERE taqprojectkey = @i_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = @i_plversion AND
            yearcode = @v_yearcode AND
            plsummaryitemkey = @v_itemkey
        ELSE
          INSERT INTO taqplsummaryitems
            (taqprojectkey, plstagecode, taqversionkey, yearcode, plsummaryitemkey, decimalvalue, lastuserid, lastmaintdate)
          VALUES
            (@i_projectkey, @i_plstage, @i_plversion, @v_yearcode, @v_itemkey, @v_calcvalue, @i_userid, getdate())
      
        FETCH yearitems_cur INTO @v_itemkey
      END

      CLOSE yearitems_cur
      DEALLOCATE yearitems_cur
        
      FETCH years_cur INTO @v_yearcode
    END
    
    CLOSE years_cur
    DEALLOCATE years_cur
    
    -- If the modified version is the selected version for this stage, must also recalculate Stage-level items
    SELECT @v_selected_ver = selectedversionkey
    FROM taqplstage
    WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage
    
    IF @i_plversion = @v_selected_ver
      SET @v_calc_stage_items = 1
    ELSE
      SET @v_calc_stage_items = 0        
  END

  -- Calculate the Stage and Consolidated Stage level items for this project and stage
  IF @v_calc_stage_items = 1
  BEGIN
    DECLARE stageitems_cur CURSOR FOR
      SELECT plsummaryitemkey, summarylevelcode
      FROM plsummaryitemdefinition
      WHERE summarylevelcode IN (1,5) AND activeind = 1 AND itemtype = 6 AND alwaysrecalcind = 0
      ORDER BY summaryheadingcode, position
      
    OPEN stageitems_cur 

    FETCH stageitems_cur INTO @v_itemkey, @v_itemlevel

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      
      -- Calculate current p&l summary item for this project and stage
      EXEC qpl_run_pl_calcsql @i_projectkey, @i_plstage, 0, 0, @v_itemkey, @v_display_currency,
        @v_calcvalue OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        
      IF @v_errorcode <> 0
        GOTO ERROR
        
      SELECT @v_count = COUNT(*)
      FROM taqplsummaryitems
      WHERE taqprojectkey = @i_projectkey AND
        plstagecode = @i_plstage AND
        taqversionkey = 0 AND
        yearcode = 0 AND
        plsummaryitemkey = @v_itemkey
        
      IF @v_count > 0 BEGIN
        UPDATE taqplsummaryitems
        SET decimalvalue = @v_calcvalue, lastuserid = @i_userid, lastmaintdate = getdate()
        WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @i_plstage AND
          taqversionkey = 0 AND
          yearcode = 0 AND
          plsummaryitemkey = @v_itemkey
      END    
      ELSE BEGIN
        IF @v_itemlevel <> 5 OR (@v_itemlevel = 5 AND @v_Is_Master_Project = 1) BEGIN      
           INSERT INTO taqplsummaryitems
             (taqprojectkey, plstagecode, taqversionkey, yearcode, plsummaryitemkey, decimalvalue, lastuserid, lastmaintdate)
           VALUES
             (@i_projectkey, @i_plstage, 0, 0, @v_itemkey, @v_calcvalue, @i_userid, getdate())
        END  
      END
          
      SELECT @v_errorcode = @@ERROR
      IF @v_errorcode <> 0
        GOTO ERROR
        
      -- If the current item is consolidated stage item, we must also update the newly calculated Consolidated Stage value
      -- on all related projects
      IF @v_itemlevel = 5 AND @v_Is_Master_Project = 0--consolidated stage level
      BEGIN
        DECLARE relatedprojects_cur CURSOR FOR
          SELECT taqprojectkey2 projectkey
          FROM taqprojectrelationship r, coreprojectinfo c 
          WHERE r.taqprojectkey2 = c.projectkey
	          AND r.taqprojectkey1 = @i_projectkey
              AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)	          
	          AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
          UNION
          SELECT taqprojectkey1 projectkey
          FROM taqprojectrelationship r, coreprojectinfo c 
          WHERE r.taqprojectkey1 = c.projectkey
	          AND r.taqprojectkey2 = @i_projectkey
	          AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
	          AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	          
        OPEN relatedprojects_cur 

        FETCH relatedprojects_cur INTO @v_related_projectkey

        WHILE (@@FETCH_STATUS=0)
        BEGIN
        
		  IF @v_PL_Final_Approved_Status > 0  BEGIN  -- NOT calculating the PL items & Consolidated for a Locked Stage.
			IF EXISTS(SELECT * FROM taqversion WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @i_plstage AND plstatuscode = @v_PL_Final_Approved_Status)
			BEGIN
				FETCH relatedprojects_cur INTO @v_related_projectkey
				CONTINUE
			END
		  END
		          
          -- Calculate current p&l summary item for this project and stage
          EXEC qpl_run_pl_calcsql @v_related_projectkey, @i_plstage, 0, 0, @v_itemkey, @v_display_currency,
            @v_calcvalue OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT
            
          IF @v_errorcode <> 0
            GOTO ERROR
            
          SELECT @v_count = COUNT(*)
          FROM taqplsummaryitems
          WHERE taqprojectkey = @v_related_projectkey AND
            plstagecode = @i_plstage AND
            taqversionkey = 0 AND
            yearcode = 0 AND
            plsummaryitemkey = @v_itemkey
            
          IF @v_count > 0 BEGIN
            UPDATE taqplsummaryitems
            SET decimalvalue = @v_calcvalue, lastuserid = @i_userid, lastmaintdate = getdate()
            WHERE taqprojectkey = @v_related_projectkey AND
              plstagecode = @i_plstage AND
              taqversionkey = 0 AND
              yearcode = 0 AND
              plsummaryitemkey = @v_itemkey
          END    
          ELSE BEGIN
            INSERT INTO taqplsummaryitems
              (taqprojectkey, plstagecode, taqversionkey, yearcode, plsummaryitemkey, decimalvalue, lastuserid, lastmaintdate)
            VALUES
              (@v_related_projectkey, @i_plstage, 0, 0, @v_itemkey, @v_calcvalue, @i_userid, getdate())
          END    
          SELECT @v_errorcode = @@ERROR
          IF @v_errorcode <> 0
            GOTO ERROR
                
          FETCH relatedprojects_cur INTO @v_related_projectkey
        END
        
        CLOSE relatedprojects_cur
        DEALLOCATE relatedprojects_cur        
        
      END --@v_itemlevel = 5           
      
      FETCH stageitems_cur INTO @v_itemkey, @v_itemlevel
    END

    CLOSE stageitems_cur
    DEALLOCATE stageitems_cur
    
    /*** When the stage is the most recent non-actual stage on the project, may need to sync the P&L to work titles of to TAQ Pub Plan ***/
    -- Get the last non-actual stage on the project
    SELECT @v_max_non_actual_stage = MAX(plstagecode)
    FROM taqplstage 
    WHERE taqprojectkey = @i_projectkey 
      AND plstagecode < (SELECT  sortorder FROM gentables WHERE tableid = 562 and qsicode = 1)

    IF @v_max_non_actual_stage > 0
    BEGIN
      SELECT @v_selected_ver = selectedversionkey
      FROM taqplstage
      WHERE taqprojectkey = @i_projectkey AND
          plstagecode = @v_max_non_actual_stage
          
      IF @v_selected_ver > 0
      BEGIN
        SELECT @v_userkey = userkey
        FROM qsiusers
        WHERE userid = @i_userid       
        
        IF @v_itemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) --Work
          EXEC qpl_sync_version_to_work_titles @i_projectkey, @i_plstage, @v_selected_ver, @v_userkey, 1, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        ELSE IF @v_itemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 3) AND 
            @v_usageclass = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1)  --Title Acquisition
          EXEC qpl_sync_version_to_acq_project @i_projectkey, @i_plstage, @v_selected_ver, @v_userkey, 1, @v_errorcode OUTPUT, @v_errordesc OUTPUT
        ELSE
          SET @v_errorcode = 0
                    
        IF @v_errorcode <> 0
          GOTO ERROR
      END    
    END
  END
  
  DELETE FROM taqversionrecalcneeded
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion  
    
  RETURN

  ERROR:
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@i_projectkey AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN
   
END
GO

GRANT EXEC ON qpl_recalc_pl_items TO PUBLIC
GO

