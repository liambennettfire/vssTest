if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_display_choices') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pl_display_choices
GO

CREATE PROCEDURE qpl_get_pl_display_choices (  
  @i_projectkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qpl_get_pl_display_choices
**  Desc: This stored procedure returns the display choices for the P&L Summary:
**        For now, Current Project and Consolidated (for clients w/Allow Alternate P&L Currencies)
**
**  Auth: Kate
**  Date: January 31 2014
***************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_Is_Master_Project INT
        
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_Is_Master_Project = dbo.qpl_is_master_pl_project(@i_projectkey)     

  IF @v_Is_Master_Project = 1 BEGIN
	  SELECT taqprojectkey2 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder
	  FROM taqprojectrelationship r, coreprojectinfo c 
	  WHERE r.taqprojectkey2 = c.projectkey
		  AND r.taqprojectkey1 = @i_projectkey
          AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)	          
	      AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  UNION
	  SELECT taqprojectkey1 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder
	  FROM taqprojectrelationship r, coreprojectinfo c 
	  WHERE r.taqprojectkey1 = c.projectkey
		  AND r.taqprojectkey2 = @i_projectkey
	      AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	      AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
	  UNION
	  SELECT projectkey, projecttitle + ' - Current Project' projecttitle, 1 sortorder
	  FROM coreprojectinfo
	  WHERE projectkey = @i_projectkey
	  UNION
	  SELECT -99 projectkey, 'Consolidated' projecttitle, 3 sortorder
	  ORDER by sortorder, projecttitle
  END
  ELSE BEGIN
	  SELECT taqprojectkey2 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder
	  FROM taqprojectrelationship r, coreprojectinfo c 
	  WHERE r.taqprojectkey2 = c.projectkey
		  AND r.taqprojectkey1 = @i_projectkey
          AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)	          
	      AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
	  UNION
	  SELECT taqprojectkey1 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder
	  FROM taqprojectrelationship r, coreprojectinfo c 
	  WHERE r.taqprojectkey1 = c.projectkey
		  AND r.taqprojectkey2 = @i_projectkey
	      AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
	      AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  UNION
	  SELECT projectkey, projecttitle + ' - Current Project' projecttitle, 1 sortorder
	  FROM coreprojectinfo
	  WHERE projectkey = @i_projectkey
	  ORDER by sortorder, projecttitle  
  END  

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access coreprojectinfo table to get display choices (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_pl_display_choices TO PUBLIC
GO