if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_joint_for_deleted_related_project') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_joint_for_deleted_related_project
GO

CREATE PROCEDURE qpl_recalc_joint_for_deleted_related_project (
  @i_projectkey   integer,
  @i_userid       varchar(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: qpl_recalc_joint_for_deleted_related_project
**  Desc: This stored procedure is called from ProjectRelationshipsEdit and ProjectRelationshipGridEdit when
**        P&L Relationship is deleted to send recalculation of all joint p&l summary items to the background
**        for the related non-Master projectkey.
**
**  Auth: Kate
**  Date: February 16 2016
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date    Author  Description
**	------  ------  -----------
**	
***********************************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_jointacctgind TINYINT,
  @v_num_active_items INT,
  @v_plstage  INT,
  @v_plversion  INT,
  @v_recalcgroup INT,
  @v_summarylevel INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Loop through all active P&L Summary Levels that are set up for related projects (jointacctgind=1)
  DECLARE recalcorder_cur CURSOR FOR
    SELECT o.recalcgroup, o.summarylevelcode, o.jointacctgind 
    FROM plsummaryitemrecalcorder o, gentables g
    WHERE o.summarylevelcode = g.datacode 
      AND g.tableid = 561
      AND g.deletestatus = 'N' 
      AND o.jointacctgind = 1
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
      SELECT plstagecode
      FROM taqplstage
      WHERE taqprojectkey = @i_projectkey
      ORDER BY plstagecode ASC
	      
    OPEN stages_cur 

    FETCH stages_cur INTO @v_plstage

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      
      -- For Stage or Consolidated Stage level inserts, use 0 taqversionkey
      IF @v_summarylevel = 1 OR @v_summarylevel = 5
        DECLARE versions_cur CURSOR FOR
          SELECT 0
      ELSE
        DECLARE versions_cur CURSOR FOR
          SELECT taqversionkey
          FROM taqversion
          WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstage
          ORDER BY taqversionkey ASC
	      
      OPEN versions_cur 

      FETCH versions_cur INTO @v_plversion

      WHILE (@@FETCH_STATUS=0)
      BEGIN

        -- Check if row exists on taqversionrecalcneeded for this row.
        -- No need to insert if it is already there for processingind = 0 (not already in progress)
        SELECT @v_count = COUNT(*)
        FROM taqversionrecalcneeded
        WHERE taqprojectkey = @i_projectkey
          AND plstagecode = @v_plstage
          AND taqversionkey = @v_plversion
          AND summarylevelcode = @v_summarylevel
          AND jointacctgonlyind = @v_jointacctgind
          AND processingind = 0
			
        IF @v_count = 0
          INSERT INTO taqversionrecalcneeded
            (taqprojectkey, plstagecode, taqversionkey, summarylevelcode, jointacctgonlyind, lastuserid, lastmaintdate)
          VALUES
            (@i_projectkey, @v_plstage, @v_plversion, @v_summarylevel, @v_jointacctgind, @i_userid, getdate())

        FETCH versions_cur INTO @v_plversion
      END

      CLOSE versions_cur
      DEALLOCATE versions_cur

      FETCH stages_cur INTO @v_plstage
    END

    CLOSE stages_cur
    DEALLOCATE stages_cur

    NEXT_RECALCORDER_FETCH:
    FETCH recalcorder_cur INTO @v_recalcgroup, @v_summarylevel, @v_jointacctgind
  END

  CLOSE recalcorder_cur
  DEALLOCATE recalcorder_cur

END
GO

GRANT EXEC ON qpl_recalc_joint_for_deleted_related_project TO PUBLIC
GO
