if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_validate_consolidated_view') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_validate_consolidated_view
GO

CREATE PROCEDURE qpl_validate_consolidated_view (  
  @i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************
**  Name: qpl_validate_consolidated_view
**  Desc: This stored procedure validates the P&L Summary "Consolidated" view:
**        For all related p&l projects, if at least one project has a selected version for the given stage,
**        all other related p&l projects should have a selected version for that stage.
**
**  Auth: Kate
**  Date: March 20 2014
*************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_cur_plstage  INT,
  @v_cur_projectkey INT,
  @v_details VARCHAR(MAX),
  @v_project_name VARCHAR(255),
  @v_rel_projectkey INT,
  @v_stage_name VARCHAR(40)
  
BEGIN
    
  SET @v_details = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE selver_projects_cur CURSOR FOR
    SELECT taqprojectkey, plstagecode
    FROM taqplstage
    WHERE selectedversionkey > 0 AND taqprojectkey IN  
      (SELECT taqprojectkey2 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey2 = c.projectkey
        AND r.taqprojectkey1 = @i_projectkey
        AND r.relationshipcode2 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT taqprojectkey1 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey1 = c.projectkey
        AND r.taqprojectkey2 = @i_projectkey
        AND r.relationshipcode1 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT taqprojectkey2 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey2 = c.projectkey
        AND r.taqprojectkey1 = @i_projectkey
        AND r.relationshipcode1 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT taqprojectkey1 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey1 = c.projectkey
        AND r.taqprojectkey2 = @i_projectkey
        AND r.relationshipcode2 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT projectkey
      FROM coreprojectinfo
      WHERE projectkey = @i_projectkey)
      
  OPEN selver_projects_cur
  
  FETCH selver_projects_cur INTO @v_cur_projectkey, @v_cur_plstage

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    
    -- Loop through all related projects other than self (currently processed project)
    -- to make sure that versions exist for that project/stage, and that version is selected
    DECLARE related_projects_cur CURSOR FOR
      SELECT taqprojectkey2 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey2 = c.projectkey
        AND r.taqprojectkey1 = @v_cur_projectkey
        AND r.relationshipcode2 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT taqprojectkey1 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey1 = c.projectkey
        AND r.taqprojectkey2 = @v_cur_projectkey
        AND r.relationshipcode1 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT taqprojectkey2 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey2 = c.projectkey
        AND r.taqprojectkey1 = @v_cur_projectkey
        AND r.relationshipcode1 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
      UNION
      SELECT taqprojectkey1 projectkey
      FROM taqprojectrelationship r, coreprojectinfo c 
      WHERE r.taqprojectkey1 = c.projectkey
        AND r.taqprojectkey2 = @v_cur_projectkey
        AND r.relationshipcode2 = (SELECT datacode FROM gentables where tableid = 582 AND qsicode = 24)
	            
    OPEN related_projects_cur 

    FETCH related_projects_cur INTO @v_rel_projectkey

    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      SELECT @v_project_name = projecttitle
      FROM coreprojectinfo
      WHERE projectkey = @v_rel_projectkey
      
      SELECT @v_stage_name = datadesc
      FROM gentables
      WHERE tableid = 562 AND datacode = @v_cur_plstage
    
      SELECT @v_count = COUNT(*)
      FROM taqversion
      WHERE taqprojectkey = @v_rel_projectkey AND plstagecode = @v_cur_plstage
      
      IF @v_count > 0
      BEGIN
        SELECT @v_count = COUNT(*)
        FROM taqplstage
        WHERE taqprojectkey = @v_rel_projectkey AND plstagecode = @v_cur_plstage AND selectedversionkey > 0

        IF @v_count = 0
          SET @v_details = @v_details + '\n' + @v_project_name + ' - does not have a selected version for ' + @v_stage_name + ' stage.'
      END
      ELSE
      BEGIN
        SET @v_details = @v_details + '\n' + @v_project_name + ' - does not have any versions for ' + @v_stage_name + ' stage.'
      END
      
      FETCH related_projects_cur INTO @v_rel_projectkey
    END

    CLOSE related_projects_cur
    DEALLOCATE related_projects_cur
    
    FETCH selver_projects_cur INTO @v_cur_projectkey, @v_cur_plstage
  END

  CLOSE selver_projects_cur
  DEALLOCATE selver_projects_cur
  
  IF @v_details <> ''
  BEGIN
    SET @v_details = 'Warning: Consolidated view does not include values from the following:' + @v_details

    SET @o_error_code = 1
    SET @o_error_desc = @v_details
  END
   
END
GO

GRANT EXEC ON qpl_validate_consolidated_view TO PUBLIC
GO


