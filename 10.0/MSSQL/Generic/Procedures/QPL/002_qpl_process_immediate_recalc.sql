if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_process_immediate_recalc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_process_immediate_recalc
GO

CREATE PROCEDURE qpl_process_immediate_recalc (
  @i_projectkey   integer,
  @i_plstage      integer,
  @i_versionkey   integer,
  @i_userid       varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: qpl_process_immediate_recalc
**  Desc: This stored procedure is called from Version Details after a successful save
**        to process the recalculation of all P&L Summary Levels that are set to recalc immediately.
**
**  Auth: Kate
**  Date: January 26 2016
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date    Author  Description
**	------  ------  -----------
**	
**********************************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),
  @v_is_master  INT,
  @v_jointacctgind  TINYINT,
  @v_num_active_items INT,
  @v_recalcgroup  INT,
  @v_related_projectkey INT,
  @v_related_versionkey INT,
  @v_selected_versionkey  INT,
  @v_subordinate_projectkey INT,
  @v_summarylevel INT,
  @v_using_jointacctg TINYINT
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  CREATE TABLE #TEMP_REL_PROJECTS (projectkey INT, is_master INT, usingjointacctg TINYINT)
  
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

    -- For immediate processing rows (recalcgroup=0), recalculate immediately
    IF @v_recalcgroup = 0
    BEGIN

      -- Recalculate all summary items for this project version, for the given P&L summary level and jointacctg indicator
      EXEC qpl_recalc_pl_items @i_projectkey, @i_plstage, @i_versionkey, @v_summarylevel, @v_jointacctgind, 
        @i_userid, @v_errorcode OUTPUT, @v_errordesc OUTPUT

      IF @v_errorcode <> 0
        GOTO ERROR

      -- We are not inserting into taqversionrecalcneeded in P&L Version Details for the immediate rows, 
      -- but just in case the row exists, delete it (jointaccctg or not) since we just recalculated it
      DELETE FROM taqversionrecalcneeded
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_versionkey AND summarylevelcode = @v_summarylevel

    END --@i_recalcgroup=0
    ELSE
    BEGIN --@i_recalcgroup > 0

      -- For all background processing rows (recalcgroup > 0), insert into taqversionrecalcneeded table if row doesn't already exist
      IF @v_jointacctgind = 0 --row is for current project
      BEGIN
        -- For Stage or Consolidated Stage level inserts, use 0 taqversionkey
        IF @v_summarylevel = 1 OR @v_summarylevel = 5
          SET @v_selected_versionkey = 0
        ELSE
          SET @v_selected_versionkey = @i_versionkey

        -- Current project must be a Master Project in order to request Consolidated Stage recalc
        SELECT @v_is_master = dbo.qpl_is_master_pl_project(@i_projectkey)
        IF (@v_summarylevel = 5 AND @v_is_master = 1) OR @v_summarylevel <> 5
        BEGIN
          SELECT @v_count = COUNT(*)
          FROM taqversionrecalcneeded
          WHERE taqprojectkey = @i_projectkey
            AND plstagecode = @i_plstage
            AND taqversionkey = @v_selected_versionkey
            AND summarylevelcode = @v_summarylevel
            AND jointacctgonlyind = 0
            AND processingind = 0

          IF @v_count = 0
            INSERT INTO taqversionrecalcneeded
              (taqprojectkey, plstagecode, taqversionkey, summarylevelcode, jointacctgonlyind, lastuserid, lastmaintdate)
            VALUES
              (@i_projectkey, @i_plstage, @v_selected_versionkey, @v_summarylevel, @v_jointacctgind, @i_userid, getdate())
        END --@v_summarylevel = 5 AND @v_is_master = 1
      END --@v_jointacctgind = 0
      IF @v_jointacctgind = 1 OR @v_summarylevel = 5
      BEGIN --@v_jointacctgind = 1 - must insert a row for each related project, which includes any of the related Master project's p&l related projects

        -- Check the selected version for the passed project/stage
        SELECT @v_selected_versionkey = selectedversionkey
        FROM taqplstage
        WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage

        -- If there is no selected version for this project/stage, or if the modified version is not the selected version for this project/stage,
        -- there is no need to recalculate related projects - move on to process next background recalc summary level row
        IF @v_selected_versionkey = 0 OR @i_versionkey <> @v_selected_versionkey
          GOTO NEXT_RECALCORDER_FETCH

        -- ***** Determine all related projects - insert all into temp table ******
        IF (SELECT COUNT(*) FROM #TEMP_REL_PROJECTS) = 0  --insert into temp table only on first run
        BEGIN
          INSERT INTO #TEMP_REL_PROJECTS (projectkey, is_master, usingjointacctg)
          SELECT projectkey, is_master, jointacctgind
          FROM dbo.qpl_get_pl_related_projects(@i_projectkey)
        END

        -- Now loop through ALL related projects and insert into taqversionrecalcneeded table if row doesn't exist yet.
        -- This needs to happen for each existing version under the modified stage of the original project.
        PRINT 'Joint Only - summary level ' + CONVERT(VARCHAR, @v_summarylevel) 

        DECLARE all_relatedprojects_cur CURSOR FOR
          SELECT projectkey, is_master, usingjointacctg
          FROM #TEMP_REL_PROJECTS
          ORDER BY is_master ASC

        OPEN all_relatedprojects_cur

        FETCH all_relatedprojects_cur INTO @v_related_projectkey, @v_is_master, @v_using_jointacctg

        WHILE (@@FETCH_STATUS=0)
        BEGIN

          IF @v_is_master = 1
            PRINT 'Related projectkey: ' + CONVERT(VARCHAR, @v_related_projectkey) + ' (Master)'
          ELSE
            PRINT 'Related projectkey: ' + CONVERT(VARCHAR, @v_related_projectkey) 
            
          PRINT '@v_using_jointacctg=' + CONVERT(VARCHAR, @v_using_jointacctg)
          
          -- If Joint Accounting is not used for this related project, continue to next row
          IF @v_using_jointacctg = 0 AND @v_summarylevel <> 5 BEGIN
            FETCH all_relatedprojects_cur INTO @v_related_projectkey, @v_is_master, @v_using_jointacctg
            CONTINUE
          END

          -- For Stage or Consolidated Stage level inserts, use 0 taqversionkey
          IF @v_summarylevel = 1 OR @v_summarylevel = 5
            DECLARE rel_stageversions_cur CURSOR FOR
              SELECT 0
          ELSE
            DECLARE rel_stageversions_cur CURSOR FOR
              SELECT taqversionkey
              FROM taqversion
              WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @i_plstage

          OPEN rel_stageversions_cur

          FETCH rel_stageversions_cur INTO @v_related_versionkey

          WHILE (@@FETCH_STATUS=0)
          BEGIN

            SELECT @v_count = COUNT(*)
            FROM taqversionrecalcneeded
            WHERE taqprojectkey = @v_related_projectkey
              AND plstagecode = @i_plstage
              AND taqversionkey = @v_related_versionkey
              AND summarylevelcode = @v_summarylevel
              AND jointacctgonlyind = @v_using_jointacctg
              AND processingind = 0

            PRINT ' Ver ' + CONVERT(VARCHAR, @v_related_versionkey) + ' (exists count=' + CONVERT(VARCHAR, @v_count) + ')'

            IF @v_count = 0
              INSERT INTO taqversionrecalcneeded
                (taqprojectkey, plstagecode, taqversionkey, summarylevelcode, jointacctgonlyind, lastuserid, lastmaintdate)
              VALUES
                (@v_related_projectkey, @i_plstage, @v_related_versionkey, @v_summarylevel, @v_using_jointacctg, @i_userid, getdate())

            -- After inserting a row for Stage-level items for Master projects, insert for Consolidated Stage (jointacctgonlyind=0)
            IF @v_summarylevel = 1 AND @v_is_master = 1
            BEGIN
              SELECT @v_count = COUNT(*)
              FROM taqversionrecalcneeded
              WHERE taqprojectkey = @v_related_projectkey
                AND plstagecode = @i_plstage
                AND taqversionkey = @v_related_versionkey
                AND summarylevelcode = 5
                AND jointacctgonlyind = 0
                AND processingind = 0

              IF @v_count = 0
                INSERT INTO taqversionrecalcneeded
                  (taqprojectkey, plstagecode, taqversionkey, summarylevelcode, jointacctgonlyind, lastuserid, lastmaintdate)
                VALUES
                  (@v_related_projectkey, @i_plstage, @v_related_versionkey, 5, 0, @i_userid, getdate())
            END

            FETCH rel_stageversions_cur INTO @v_related_versionkey
          END

          CLOSE rel_stageversions_cur
          DEALLOCATE rel_stageversions_cur

          FETCH all_relatedprojects_cur INTO @v_related_projectkey, @v_is_master, @v_using_jointacctg
        END

        CLOSE all_relatedprojects_cur
        DEALLOCATE all_relatedprojects_cur

      END --@v_jointacctgind = 1
    END --@v_recalcgroup > 0

    NEXT_RECALCORDER_FETCH:
    FETCH recalcorder_cur INTO @v_recalcgroup, @v_summarylevel, @v_jointacctgind
  END

  CLOSE recalcorder_cur
  DEALLOCATE recalcorder_cur

  RETURN

  ERROR:
  CLOSE recalcorder_cur
  DEALLOCATE recalcorder_cur
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@i_projectkey AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN

END
GO

GRANT EXEC ON qpl_process_immediate_recalc TO PUBLIC
GO