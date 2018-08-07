if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_plversion_to_work') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_project_plversion_to_work
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_project_plversion_to_work
  (@i_copy_projectkey     integer,
  @i_new_projectkey       integer,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_project_plversion_to_work
**  Desc: This stored procedure copies the details of the selected version
**        or all versions if no selected version exists for a stage.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Alan Katzen
**  Date: 12 April 2011
*****************************************************************************************************************
**  Change History
*****************************************************************************************************************
**  Date:        Author:     Description:
*   ----------   --------    ------------------------------------------------------------------------
**  12/09/2016   Colman      Case 42106 Stage PL summary items are not copied over to the Work from TAQ
**  12/16/2016	 Uday		 Case 42243 Approving title acquisition generates error
****************************************************************************************/

DECLARE
  @v_check_selver INT,
  @v_copy_plstage INT,
  @v_copy_plversion INT,
  @v_count  INT,
  @v_error  INT,
  @v_first_plstage  INT,
  @v_first_plversion INT,
  @v_new_itemtype INT,
  @v_new_plstage  INT,
  @v_new_plversion  INT,
  @v_new_usageclass INT,
  @v_new_usageclassdesc VARCHAR(255),
  @v_plsubtype  INT,
  @v_pltype INT,
  @v_relstrategy  INT,
  @v_stagedesc  VARCHAR(40),
  @v_userkey  INT,
  @v_versiondesc  VARCHAR(40),
  @v_selectedversionkey INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Copy projectkey not passed to copy P&L Version.'
    RETURN
  END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'New projectkey not passed to copy P&L Version: copy_projectkey=' + CAST(@i_copy_projectkey AS VARCHAR)   
    RETURN
  END
  
  -- Get the userkey for the passed User ID
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @i_userid
  
  IF @v_userkey is null BEGIN
    SELECT @v_userkey = clientdefaultvalue
      FROM clientdefaults
     WHERE clientdefaultid = 48
  END
    
  SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
  IF @v_error <> 0 OR @v_userkey is null
  BEGIN
    SET @v_userkey = -1
  END

  -- Get the Item Type and Usage Class for the NEW project
  SELECT @v_new_itemtype = searchitemcode, @v_new_usageclass = COALESCE(usageclasscode,0), @v_new_usageclassdesc = COALESCE(usageclasscodedesc,'')
  FROM coreprojectinfo 
  WHERE projectkey = @i_new_projectkey

  -- Loop through all P&L Stage rows on the source project to attempt to copy either the selected version 
  -- or all versions for each stage on this project
  DECLARE stage_cur CURSOR FOR 
   SELECT g.datacode, g.datadesc, s.selectedversionkey
    FROM taqplstage s, gentables g
    WHERE s.plstagecode = g.datacode 
      AND g.tableid = 562 
      AND s.taqprojectkey = @i_copy_projectkey
    ORDER BY g.sortorder
      
  OPEN stage_cur 

  FETCH stage_cur INTO @v_copy_plstage, @v_stagedesc, @v_check_selver

  WHILE @@fetch_status = 0
  BEGIN      
  
    IF @v_check_selver > 0 BEGIN
      -- Copy the selected version for this stage
      DECLARE stage_version_cur CURSOR FOR 
        SELECT @v_check_selver, 1, @v_check_selver
    END
    ELSE BEGIN
      -- Copy all versions for this stage
      DECLARE stage_version_cur CURSOR FOR 
        SELECT v.taqversionkey, v.taqversionkey, 0
        FROM taqversion v
        WHERE v.taqprojectkey = @i_copy_projectkey AND
          v.plstagecode = @v_copy_plstage AND
          v.taqversionkey > 0
    END
 
    OPEN stage_version_cur

    FETCH stage_version_cur INTO @v_copy_plversion, @v_new_plversion, @v_selectedversionkey

    WHILE @@fetch_status = 0
    BEGIN      
      SET @v_new_plstage = @v_copy_plstage
            
      -- Get the P&L Type, Sub-Type and Release Strategy on the original version
      SELECT @v_pltype = pltypecode, @v_plsubtype = pltypesubcode, @v_relstrategy = releasestrategycode, @v_versiondesc = taqversiondesc
      FROM taqversion
      WHERE taqprojectkey = @i_copy_projectkey AND
        plstagecode = @v_copy_plstage AND
        taqversionkey = @v_copy_plversion
      
      SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
      IF @v_error <> 0 OR @v_count = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not get copy version details: copy_projectkey=' + CAST(@i_copy_projectkey AS VARCHAR) + 
          ', copy_plstage=' + CAST(@v_copy_plstage AS VARCHAR) + ', copy_plversion=' + CAST(@v_copy_plversion AS VARCHAR)
        RETURN
      END

      -- Check if the P&L Type and Release Strategy are valid values for the NEW project
      -- If they are not, use a default value determined by item type and sortorder (see spec on case 27688 - section 13)
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype
      WHERE tableid = 566 AND datacode = @v_pltype 
        AND itemtypecode = @v_new_itemtype AND (itemtypesubcode = @v_new_usageclass OR itemtypesubcode = 0)

      IF @v_count = 0
      BEGIN
        SELECT @v_pltype = gi.datacode
        FROM gentablesitemtype gi, gentables g
        WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
          AND gi.tableid = 566 AND gi.itemtypecode = @v_new_itemtype
          AND (gi.itemtypesubcode = @v_new_usageclass OR gi.itemtypesubcode = 0)
        ORDER BY gi.sortorder ASC, g.sortorder ASC

        SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
        IF @v_error <> 0 OR @v_count = 0
        BEGIN
          SET @o_error_code = 100
          SET @o_error_desc = 'Could not copy version - missing default P&L Type value for ' + @v_new_usageclassdesc + '.'
          RETURN
        END
  
        SELECT TOP (1) @v_plsubtype = datasubcode
        FROM subgentables
        WHERE tableid = 566 AND datacode = @v_pltype
        ORDER BY sortorder ASC, datasubcode ASC

        IF @v_plsubtype IS NULL
          SET @v_plsubtype = 0
      END

      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype
      WHERE tableid = 567 AND datacode = @v_relstrategy 
        AND itemtypecode = @v_new_itemtype AND (itemtypesubcode = @v_new_usageclass OR itemtypesubcode = 0)

      IF @v_count = 0
      BEGIN
        SELECT @v_relstrategy = gi.datacode
        FROM gentablesitemtype gi, gentables g
        WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
          AND gi.tableid = 567 AND gi.itemtypecode = @v_new_itemtype
          AND (gi.itemtypesubcode = @v_new_usageclass OR gi.itemtypesubcode = 0)
        ORDER BY gi.sortorder ASC, g.sortorder ASC

        SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
        IF @v_error <> 0 OR @v_count = 0
        BEGIN
          SET @o_error_code = 100
          SET @o_error_desc = 'Could not copy version - missing default Release Strategy value for ' + @v_new_usageclassdesc + '.'
          RETURN
        END
      END

      /***** Create the new P&L version for the new project ****/        
      EXEC qpl_create_new_version @i_copy_projectkey, @v_copy_plstage, @v_copy_plversion, @i_new_projectkey, @v_new_plstage, @v_new_plversion,
        @v_pltype, @v_plsubtype, @v_relstrategy, @v_userkey, @v_versiondesc, 0, @o_error_code, @o_error_desc

	    IF @o_error_code <> 0 BEGIN
		    SET @o_error_desc = 'Copy P&L Version failed (' + cast(@o_error_code AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)  + 
          ', copy_plstage=' + CAST(@v_copy_plstage AS VARCHAR) + ', copy_plversion=' + CAST(@v_copy_plversion AS VARCHAR)  
		    RETURN
	    END 
    
      IF @v_selectedversionkey > 0 BEGIN
        UPDATE taqplstage
           SET selectedversionkey = @v_new_plversion
         WHERE taqprojectkey = @i_new_projectkey
           AND plstagecode = @v_new_plstage

        SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
        IF @v_error <> 0
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not set selected version: projectkey=' + CAST(@i_new_projectkey AS VARCHAR) + 
            ', plstage=' + CAST(@v_new_plstage AS VARCHAR) + ', selected_plversion=' + CAST(@v_selectedversionkey AS VARCHAR)
          RETURN
        END

	    -- This procedure will immediately recalculate all summary items for p&l levels set up on plsummaryitemrecalcorder table
	    -- to procecess immediately (recalcorder=0) and push remaining summary items to background recalc
      
      -- COMMENTED OUT: doesn't work for approved versions. Recalc is not necessary anyway.
	    -- EXEC qpl_process_immediate_recalc @i_new_projectkey, @v_new_plstage, @v_new_plversion, @i_userid, @o_error_code, @o_error_desc        
      
        SELECT @v_count = COUNT(*)
        FROM taqplsummaryitems
        WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @v_copy_plstage AND taqversionkey = 0

        IF @v_count = 0
        BEGIN
            INSERT INTO taqplsummaryitems
              (taqprojectkey, plsummaryitemkey, plstagecode, taqversionkey, yearcode, longvalue, textvalue, decimalvalue, lastuserid, lastmaintdate)
            SELECT @i_new_projectkey, plsummaryitemkey, plstagecode, taqversionkey, yearcode, longvalue, textvalue, decimalvalue, @v_userkey, getdate()
            FROM taqplsummaryitems
            WHERE taqprojectkey = @i_copy_projectkey AND plstagecode = @v_copy_plstage AND taqversionkey = 0
        END

        IF @o_error_code <> 0
        BEGIN
          SET @o_error_desc = 'Could not recalculate P&L stage-level summary items (new projectkey=' + CONVERT(VARCHAR, @i_new_projectkey)
          RETURN
        END

      END

      FETCH stage_version_cur INTO @v_copy_plversion, @v_new_plversion, @v_selectedversionkey
    END

    CLOSE stage_version_cur 
    DEALLOCATE stage_version_cur 
       
    FETCH stage_cur INTO @v_copy_plstage, @v_stagedesc, @v_check_selver
  END

  CLOSE stage_cur 
  DEALLOCATE stage_cur

END
go
