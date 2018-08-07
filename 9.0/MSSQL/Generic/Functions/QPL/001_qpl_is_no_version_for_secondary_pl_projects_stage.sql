if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_is_no_version_for_secondary_pl_projects_stage') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_is_no_version_for_secondary_pl_projects_stage
GO

CREATE FUNCTION qpl_is_no_version_for_secondary_pl_projects_stage (
  @i_taqprojectkey as integer,
  @i_plstagecode as integer
  ) 
RETURNS int

/**************************************************************************************************************************************************
**  Name: qpl_is_no_version_for_secondary_pl_projects_stage
**  Desc: This function returns 1 if the secondary project has no versions, 0 if it has versions
**        and -1 otherwise. 
**
**  Auth: Uday A. Khisty
**  Date: June 10 2015
**************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @error_var    INT,
    @v_count_secondary INT,    
    @v_returncode INT

  IF @i_taqprojectkey IS NULL OR @i_taqprojectkey <= 0 BEGIN
	return -1
  END
  
  SET @v_returncode = -1
  SET @v_count_secondary = 0      	
		
  SELECT @v_count_secondary = COUNT(*) FROM
  (
	SELECT taqprojectkey2 projectkey
	FROM taqprojectrelationship r 
	INNER JOIN coreprojectinfo c 
	ON r.taqprojectkey2 = c.projectkey AND r.taqprojectkey1 = @i_taqprojectkey AND (c.projectstatus NOT IN(select datacode from gentables where tableid = 522 and gen2ind = 1 ))
	LEFT OUTER JOIN taqversion v ON v.taqprojectkey = r.taqprojectkey2 AND v.plstagecode = @i_plstagecode
	WHERE relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)          
		AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)	        
		AND v.plstagecode IS NULL	        
	UNION
	SELECT taqprojectkey1 projectkey
	FROM taqprojectrelationship r 
	INNER JOIN coreprojectinfo c 
	ON r.taqprojectkey1 = c.projectkey AND r.taqprojectkey2 = @i_taqprojectkey  AND (c.projectstatus NOT IN(select datacode from gentables where tableid = 522 and gen2ind = 1 ))
	LEFT OUTER JOIN taqversion v ON v.taqprojectkey = r.taqprojectkey1 AND v.plstagecode = @i_plstagecode
	WHERE r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
		AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)		
		AND v.plstagecode IS NULL
   ) Secondary_Projects		
      
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @v_returncode = -1
  END
    
  IF @v_count_secondary = 0 BEGIN
	SET @v_returncode = 0
  END 
  
  IF @v_count_secondary > 0 BEGIN
	SET @v_returncode = 1
  END      
  
  RETURN @v_returncode
  
END
GO

GRANT EXEC ON dbo.qpl_is_no_version_for_secondary_pl_projects_stage TO PUBLIC
GO
