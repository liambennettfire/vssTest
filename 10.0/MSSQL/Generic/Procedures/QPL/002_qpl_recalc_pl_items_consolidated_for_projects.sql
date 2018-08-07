if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_pl_items_consolidated_for_projects') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_pl_items_consolidated_for_projects
GO

CREATE PROCEDURE qpl_recalc_pl_items_consolidated_for_projects (  
  @i_projectkey   integer,
  @i_userid       varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/************************************************************************************************************************************************
**  Name: qpl_recalc_pl_items_consolidated_for_projects
**  Desc: This stored procedure recalculates all p&l consolidated summary items for All non-locked levels of the Projects.
**        NOTE: Passed in projectkey must be Master.
**
**  Auth: Uday A. Khisty
**  Date: March 13 2015
************************************************************************************************************************************************
**	Change History
************************************************************************************************************************************************
**  Date      Author  Description
**  ----      ------  -----------
**  03/31/16  Kate	  Case 35972 - Completely rewritten to utilize background processing and to fix for scenarios where multiple Master projects
**                    exist for a given secondary project (in which case we also need to account for all Master's secondary projects).
*************************************************************************************************************************************************/

DECLARE
  @v_approved_project_status INT,
  @v_count  INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),
  @v_is_master_project INT,
  @v_jointacctgind  TINYINT,
  @v_num_active_items INT,
  @v_option_lock_stage INT, 
  @v_plstage  INT,
  @v_plversion  INT,
  @v_projectkey INT,
  @v_project_status INT,
  @v_recalcgroup  INT,
  @v_recalc_current_project  TINYINT,
  @v_stage_recalcgroup  INT,
  @v_summarylevel INT,
  @v_using_jointacctg TINYINT,
  @v_version_status INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Check if this is a Master P&L project
  SELECT @v_is_master_project = dbo.qpl_is_master_pl_project(@i_projectkey)
  
  PRINT '@v_is_master_project=' + CONVERT(VARCHAR, @v_is_master_project)

  CREATE TABLE #TEMP_REL_PROJECTS (projectkey INT, projectstatus INT, usingjointacctg TINYINT)
  
  -- Get the Acq Approved project status, when the entire project would be locked
  SELECT @v_approved_project_status = datacode
  FROM gentables 
  WHERE tableid = 522 AND qsicode = 1
  
  -- NOTE: When adding/deleting p&l relationships for projects (i.e. when this stored procedure gets called), 
  -- Stage-level items must be recalculated immediately, as well as any levels preceding the Stage-level order.

  -- Get the recalc group for Stage-level summary items.
  SELECT @v_stage_recalcgroup = recalcgroup 
  FROM plsummaryitemrecalcorder 
  WHERE summarylevelcode = 1 AND jointacctgind = 0  --Stage for current project
    
  -- Loop through all active p&l summary levels
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
  
    PRINT '---'
    PRINT '@v_recalcgroup=' + CONVERT(VARCHAR, @v_recalcgroup)
    PRINT '@v_summarylevel=' + CONVERT(VARCHAR, @v_summarylevel)
    PRINT '@v_jointacctgind=' + CONVERT(VARCHAR, @v_jointacctgind)

    -- Row is for current project when the joint accounting indicator is 0; otherwise, row is for related projects.    
    IF @v_jointacctgind = 1      
      SET @v_recalc_current_project = 0
    ELSE
      SET @v_recalc_current_project = 1

    -- At least one active saved (alwaysrecalcind=0) summary item must exist for the given summary level to be processed
    IF @v_summarylevel = 5
    BEGIN
      -- If this is not a master project (0) or master p&l relationship no longer exists (-1), delete all consolidated summary level p&l items
      -- for this project if any exist and move on to next recalc order row
      IF @v_is_master_project <> 1 BEGIN
        IF EXISTS (SELECT * FROM taqplsummaryitems WHERE taqprojectkey = @i_projectkey 
                    AND plsummaryitemkey IN (SELECT plsummaryitemkey FROM plsummaryitemdefinition WHERE summarylevelcode = 5)) BEGIN
          DELETE FROM taqplsummaryitems
          WHERE taqprojectkey = @i_projectkey
          AND plsummaryitemkey IN (SELECT plsummaryitemkey FROM plsummaryitemdefinition WHERE summarylevelcode = 5)
        END
        -- We are not calculating Consolidated - process next row
        GOTO NEXT_RECALCORDER_FETCH
      END

      SELECT @v_num_active_items = COUNT(*)
      FROM plsummaryitemdefinition 
      WHERE summarylevelcode = @v_summarylevel AND activeind = 1 AND alwaysrecalcind = 0
    END
    ELSE
    BEGIN
      -- For any other P&L Summary Levels other than Consolidated Stage, we only need to recalculate Joint Accounting p&l summary items
      SET @v_jointacctgind = 1  --override the retrieved jointacctgind value

      SELECT @v_num_active_items = COUNT(*)
      FROM plsummaryitemdefinition 
      WHERE summarylevelcode = @v_summarylevel AND activeind = 1 AND alwaysrecalcind = 0 AND jointacctgind = 1
    END

    PRINT '@v_num_active_items=' + CONVERT(VARCHAR, @v_num_active_items)
	
    IF @v_num_active_items = 0
      GOTO NEXT_RECALCORDER_FETCH

    IF @v_recalc_current_project = 1  --row is for current project
    BEGIN
      DECLARE projects_cur CURSOR FOR
        SELECT taqprojectkey, taqprojectstatuscode, 1
        FROM taqproject
        WHERE taqprojectkey = @i_projectkey
    END
    ELSE
    BEGIN --row is for related projects

      -- ***** Determine all related projects - insert all into temp table first time only ******
      IF (SELECT COUNT(*) FROM #TEMP_REL_PROJECTS) = 0
      BEGIN
        INSERT INTO #TEMP_REL_PROJECTS (projectkey, projectstatus, usingjointacctg)
        SELECT r.projectkey, p.taqprojectstatuscode, r.jointacctgind
        FROM dbo.qpl_get_pl_related_projects(@i_projectkey) r, taqproject p
        WHERE r.projectkey = p.taqprojectkey
      END

      DECLARE projects_cur CURSOR FOR
        SELECT projectkey, projectstatus, usingjointacctg
        FROM #TEMP_REL_PROJECTS
    END --@v_recalc_current_project = 0 (row is for related projects)

    OPEN projects_cur

    FETCH projects_cur INTO @v_projectkey, @v_project_status, @v_using_jointacctg

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      PRINT ' @v_projectkey=' + CONVERT(VARCHAR, @v_projectkey)
      PRINT ' @v_project_status=' + CONVERT(VARCHAR, @v_project_status)
      PRINT ' @v_using_jointacctg=' + CONVERT(VARCHAR, @v_using_jointacctg)
      
      -- Do not recalculate at all for projects with LOCKED status.
      IF @v_project_status = @v_approved_project_status
      BEGIN
        FETCH projects_cur INTO @v_projectkey, @v_project_status, @v_using_jointacctg
        CONTINUE		
      END

      -- Loop through all Stages on this project
      DECLARE stages_cur CURSOR FOR
        SELECT plstagecode
        FROM taqplstage
        WHERE taqprojectkey = @v_projectkey
        ORDER BY plstagecode ASC
	      
      OPEN stages_cur 

      FETCH stages_cur INTO @v_plstage

      WHILE (@@FETCH_STATUS=0)
      BEGIN
      
        PRINT '  @v_plstage=' + CONVERT(VARCHAR, @v_plstage)

        -- For Stage or Consolidated Stage level inserts, use 0 taqversionkey
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
        
          PRINT '   @v_plversion=' + CONVERT(VARCHAR, @v_plversion)

          -- If the recalc group for the current row precedes or equals the Stage-level recalc group, recalculate p&l summary items immediately for that summary level
          IF @v_recalcgroup <= @v_stage_recalcgroup
          BEGIN
            PRINT ' **** IMMEDIATE recalc ****'
            PRINT '@v_projectkey=' + CONVERT(VARCHAR, @v_projectkey)
            PRINT '@v_plstage=' + CONVERT(VARCHAR, @v_plstage)
            PRINT '@v_plversion=' + CONVERT(VARCHAR, @v_plversion)
            PRINT '@v_summarylevel=' + CONVERT(VARCHAR, @v_summarylevel)
            PRINT '@v_jointacctgind=' + CONVERT(VARCHAR, @v_jointacctgind)
			
            -- Recalculate all summary items for the current project/stage/version for the given P&L summary level and joint accounting indicator.
            -- NOTE: The procedure has a check for Locked versions (i.e. does not recalculate for Locked versions).
            EXEC qpl_recalc_pl_items @v_projectkey, @v_plstage, @v_plversion, @v_summarylevel, @v_jointacctgind, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

            IF @v_errorcode <> 0
              GOTO ERROR
          END -- @v_recalcgroup <= @v_stage_recalcgroup (process recalc immediately)
          ELSE
          BEGIN -- @v_recalcgroup > @v_stage_recalcgroup (send recalc to background)          
            PRINT ' **** BACKGROUND recalc ****'
            PRINT '@v_projectkey=' + CONVERT(VARCHAR, @v_projectkey)
            PRINT '@v_plstage=' + CONVERT(VARCHAR, @v_plstage)
            PRINT '@v_plversion=' + CONVERT(VARCHAR, @v_plversion)
            PRINT '@v_summarylevel=' + CONVERT(VARCHAR, @v_summarylevel)
            PRINT '@v_jointacctgind=' + CONVERT(VARCHAR, @v_jointacctgind)
          
            -- Check if row exists on taqversionrecalcneeded for this row.
            -- No need to insert if it is already there for processingind = 0 (not already in progress)
            SELECT @v_count = COUNT(*)
            FROM taqversionrecalcneeded
            WHERE taqprojectkey = @v_projectkey
              AND plstagecode = @v_plstage
              AND taqversionkey = @v_plversion
              AND summarylevelcode = @v_summarylevel
              AND jointacctgonlyind = @v_jointacctgind
              AND processingind = 0

            PRINT '@v_count=' + CONVERT(VARCHAR, @v_count)
			
            IF @v_count = 0
              INSERT INTO taqversionrecalcneeded
                (taqprojectkey, plstagecode, taqversionkey, summarylevelcode, jointacctgonlyind, lastuserid, lastmaintdate)
              VALUES
                (@v_projectkey, @v_plstage, @v_plversion, @v_summarylevel, @v_jointacctgind, @i_userid, getdate())
          END --@v_recalcgroup > @v_stage_recalcgroup 

          FETCH versions_cur INTO @v_plversion
        END

        CLOSE versions_cur
        DEALLOCATE versions_cur

        FETCH stages_cur INTO @v_plstage
      END

      CLOSE stages_cur
      DEALLOCATE stages_cur	

      FETCH projects_cur INTO @v_projectkey, @v_project_status, @v_using_jointacctg
    END

    CLOSE projects_cur
    DEALLOCATE projects_cur

    NEXT_RECALCORDER_FETCH:
    FETCH recalcorder_cur INTO @v_recalcgroup, @v_summarylevel, @v_jointacctgind
  END

  CLOSE recalcorder_cur
  DEALLOCATE recalcorder_cur
  
  RETURN

  ERROR:
  CLOSE versions_cur
  DEALLOCATE versions_cur
  CLOSE stages_cur
  DEALLOCATE stages_cur
  CLOSE projects_cur
  DEALLOCATE projects_cur
  CLOSE recalcorder_cur
  DEALLOCATE recalorder_cur
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@i_projectkey AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN
   
END
GO

GRANT EXEC ON qpl_recalc_pl_items_consolidated_for_projects TO PUBLIC
GO
