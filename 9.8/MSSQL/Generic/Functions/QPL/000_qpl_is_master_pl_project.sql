if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_is_master_pl_project') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_is_master_pl_project
GO

CREATE FUNCTION qpl_is_master_pl_project (
  @i_taqprojectkey as integer
  ) 
RETURNS int

/**************************************************************************************************************************************************
**  Name: qpl_is_master_pl_project
**  Desc: This function returns 1 if the project is the Master PL Project, 0 if is secondary,
**        and -1 otherwise. 
**
**  Auth: Uday A. Khisty
**  Date: March 17 2015
**************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @error_var    INT,
    @v_count_master INT,
    @v_count_secondary INT,    
    @v_returncode INT

  IF @i_taqprojectkey IS NULL OR @i_taqprojectkey <= 0 BEGIN
	return -1
  END
  
  SET @v_returncode = -1
  SET @v_count_master = 0
  SET @v_count_secondary = 0      
		
	SELECT @v_count_master = COUNT(*) FROM
	(
	  SELECT taqprojectkey2 projectkey
	  FROM taqprojectrelationship r, coreprojectinfo c 
	  WHERE r.taqprojectkey2 = c.projectkey
		  AND r.taqprojectkey1 = @i_taqprojectkey
		  AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)	          
		  AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  UNION
	  SELECT taqprojectkey1 projectkey
	  FROM taqprojectrelationship r, coreprojectinfo c 
	  WHERE r.taqprojectkey1 = c.projectkey
		  AND r.taqprojectkey2 = @i_taqprojectkey
		  AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
		  AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
	 ) Master_Projects		
      
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
	SET @v_returncode = -1
  END		
		
  SELECT @v_count_secondary = COUNT(*) FROM
  (
   SELECT taqprojectkey2 projectkey
   FROM taqprojectrelationship r, coreprojectinfo c 
   WHERE r.taqprojectkey2 = c.projectkey
       AND r.taqprojectkey1 = @i_taqprojectkey
       AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)	          
       AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
   UNION
   SELECT taqprojectkey1 projectkey
   FROM taqprojectrelationship r, coreprojectinfo c 
   WHERE r.taqprojectkey1 = c.projectkey
       AND r.taqprojectkey2 = @i_taqprojectkey
       AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
       AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
   ) Secondary_Projects		
      
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @v_returncode = -1
  END
    
  IF @v_count_master > 0 AND @v_count_secondary = 0 BEGIN
	SET @v_returncode = 1
  END 
  
  IF @v_count_master = 0 AND @v_count_secondary > 0 BEGIN
	SET @v_returncode = 0
  END      
  
  RETURN @v_returncode
  
END
GO

GRANT EXEC ON dbo.qpl_is_master_pl_project TO PUBLIC
GO
