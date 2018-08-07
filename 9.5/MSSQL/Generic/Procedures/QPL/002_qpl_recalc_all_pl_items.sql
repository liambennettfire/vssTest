if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_all_pl_items') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_all_pl_items
GO

CREATE PROCEDURE qpl_recalc_all_pl_items (
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: qpl_recalc_all_pl_items
**  Desc: This stored procedure recalculates all saved p&l summary items for every unlocked project and unlocked
**        version for all active p&l levels.
**
**  Auth: Kate
**  Date: February 19 2016
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date    Author  Description
**	------  ------  -----------
**	
**********************************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_final_approval_status  INT,
  @v_is_master INT,
  @v_jointacctgind TINYINT,
  @v_option_lock_stage  INT,
  @v_num_active_items INT,
  @v_plstage  INT,
  @v_plversion  INT,
  @v_projectkey INT,
  @v_recalcgroup INT,
  @v_selected_version INT,
  @v_selected_ver_status  INT,
  @v_summarylevel INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Get the final approval version status when version would be locked
  SET @v_final_approval_status = 0 
  SELECT @v_option_lock_stage = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
  IF @v_option_lock_stage = 1 BEGIN
    SELECT @v_final_approval_status = COALESCE(CAST(clientdefaultvalue AS INT), 0) FROM clientdefaults where clientdefaultid = 61 
  END 

  -- Loop through all unlocked non-template projects that have at at least one taqplstage record
  DECLARE projects_cur CURSOR FOR
    SELECT taqprojectkey, dbo.qpl_is_master_pl_project(taqprojectkey) is_master
    FROM taqproject p
    WHERE templateind = 0
      AND taqprojectstatuscode NOT IN (SELECT datacode FROM gentables WHERE tableid = 522 AND gen2ind = 1)  --Locked status indicator
      AND EXISTS (SELECT * FROM taqplstage s WHERE s.taqprojectkey = p.taqprojectkey)
    ORDER BY is_master ASC
      
  OPEN projects_cur 

  FETCH projects_cur INTO @v_projectkey, @v_is_master

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- Loop through all active P&L Summary Levels
    DECLARE recalcorder_cur CURSOR FOR
      SELECT o.recalcgroup, o.summarylevelcode, o.jointacctgind 
      FROM plsummaryitemrecalcorder o, gentables g
      WHERE o.summarylevelcode = g.datacode 
        AND g.tableid = 561
        AND g.deletestatus = 'N' 
      ORDER BY o.recalcgroup, o.sortwithingroup
      
    OPEN recalcorder_cur 

    FETCH recalcorder_cur INTO @v_recalcgroup, @v_summarylevel, @v_jointacctgind

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- At least one active saved summary item must exist for the given summary level to be processed
      IF @v_jointacctgind = 1
        SELECT @v_num_active_items = COUNT(*)
        FROM plsummaryitemdefinition 
        WHERE summarylevelcode = @v_summarylevel AND activeind = 1 AND alwaysrecalcind = 0 AND jointacctgind = 1
      ELSE
        SELECT @v_num_active_items = COUNT(*)
        FROM plsummaryitemdefinition 
        WHERE summarylevelcode = @v_summarylevel AND activeind = 1 AND alwaysrecalcind = 0

      IF @v_num_active_items = 0
        GOTO NEXT_RECALCORDER_FETCH

      -- Loop through all Stages on this project
      DECLARE stages_cur CURSOR FOR
        SELECT plstagecode, selectedversionkey
        FROM taqplstage
        WHERE taqprojectkey = @v_projectkey
        ORDER BY plstagecode ASC
	      
      OPEN stages_cur 

      FETCH stages_cur INTO @v_plstage, @v_selected_version

      WHILE (@@FETCH_STATUS=0)
      BEGIN

        -- Check the selected version status
        SELECT @v_selected_ver_status = plstatuscode
        FROM taqversion
        WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_plstage AND taqversionkey = @v_selected_version

        -- Do not recalculate any versions for this stage if the selected version status is locked.
        IF @v_selected_ver_status = @v_final_approval_status
          GOTO NEXT_STAGE_FETCH

        -- For Stage or Consolidated Stage levels, pass 0 versionkey; otherwise loop through all versions to recalculate each
        IF @v_summarylevel = 1 OR @v_summarylevel = 5
          DECLARE versions_cur CURSOR FOR
            SELECT 0
        ELSE
          DECLARE versions_cur CURSOR FOR
            SELECT taqversionkey
            FROM taqversion
            WHERE taqprojectkey = @v_projectkey AND plstagecode = @v_plstage
            ORDER BY taqversionkey ASC

        OPEN versions_cur 

        FETCH versions_cur INTO @v_plversion

        WHILE (@@FETCH_STATUS=0)
        BEGIN

          -- Call the recalc stored procedure to process this specific passed P&L Summary Level/Joint Accounting row
          EXEC qpl_recalc_pl_items @v_projectkey, @v_plstage, @v_plversion, @v_summarylevel, @v_jointacctgind, 
	          'ALLRECALC', @o_error_code OUTPUT, @o_error_desc OUTPUT

          IF @o_error_code <> 0
            GOTO ERROR

          FETCH versions_cur INTO @v_plversion
        END

        CLOSE versions_cur
        DEALLOCATE versions_cur

        NEXT_STAGE_FETCH:
        FETCH stages_cur INTO @v_plstage, @v_selected_version
      END

      CLOSE stages_cur
      DEALLOCATE stages_cur

      NEXT_RECALCORDER_FETCH:
      FETCH recalcorder_cur INTO @v_recalcgroup, @v_summarylevel, @v_jointacctgind
    END

    CLOSE recalcorder_cur
    DEALLOCATE recalcorder_cur

    FETCH projects_cur INTO @v_projectkey, @v_is_master
  END

  CLOSE projects_cur
  DEALLOCATE projects_cur

  RETURN

  ERROR:
  CLOSE versions_cur
  DEALLOCATE versions_cur
  CLOSE stages_cur
  DEALLOCATE stages_cur
  CLOSE recalcorder_cur
  DEALLOCATE recalcorder_cur
  CLOSE projects_cur
  DEALLOCATE projects_cur
END
GO

GRANT EXEC ON qpl_recalc_all_pl_items TO PUBLIC
GO
