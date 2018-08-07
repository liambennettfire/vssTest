if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_allow_approve_master_pl_version') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_allow_approve_master_pl_version
GO

CREATE FUNCTION qpl_allow_approve_master_pl_version (
  @i_taqprojectkey as integer,
  @i_plstagecode as integer
  ) 
RETURNS int

/********************************************************************************************************************************************************************************
**  Name: qpl_allow_approve_master_pl_version
**  Desc: @i_taqprojectkey - Project we are Approving. 
**		  @i_plstagecode - Stage of the Project		
**  This function returns 1 if the project is the Master PL Project and we allow Approval of Version, 0 if we do not allow version approval,
**        and -1 otherwise. 
**
**  Auth: Uday A. Khisty
**  Date: June 9 2015
********************************************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @error_var    INT,
    @v_count_secondary INT,    
    @v_returncode INT,
    @v_is_Master_Project INT,
    @v_ProcessSingleProject INT,
    @v_count_no_version_for_stage INT

  SET @v_ProcessSingleProject = 0
  SET @v_count_no_version_for_stage = 0
   
  IF @i_taqprojectkey IS NULL OR @i_taqprojectkey <= 0 BEGIN
	return -1
  END
  
  SELECT @v_is_Master_Project = dbo.qpl_is_master_pl_project(@i_taqprojectkey)
  
  IF @v_is_Master_Project <> 1 BEGIN  -- From anyplace, you cannot approve the master without having all secondary having a selected stage
	return 1
  END
  
  SELECT @v_count_no_version_for_stage = dbo.qpl_is_no_version_for_secondary_pl_projects_stage(@i_taqprojectkey, @i_plstagecode)
  
  IF @v_count_no_version_for_stage > 0 BEGIN
	RETURN 0
  END
  
  
  SELECT @v_count_secondary = COUNT(*) FROM
  (
	SELECT taqprojectkey2 projectkey
	FROM taqprojectrelationship r 
	INNER JOIN coreprojectinfo c 
	ON r.taqprojectkey2 = c.projectkey AND r.taqprojectkey1 = @i_taqprojectkey AND (c.projectstatus NOT IN(select datacode from gentables where tableid = 522 and gen2ind = 1 ))
	INNER JOIN taqversion v ON v.taqprojectkey = r.taqprojectkey2 AND v.plstagecode = @i_plstagecode
	LEFT OUTER JOIN taqplstage p ON p.taqprojectkey = v.taqprojectkey AND p.plstagecode = v.plstagecode AND v.taqversionkey = p.selectedversionkey
	WHERE relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)          
		AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)	        
		AND v.plstagecode > 0 AND COALESCE(p.selectedversionkey, 0) = 0 
		AND NOT EXISTS(SELECT * FROM taqplstage p1 WHERE p1.taqprojectkey = r.taqprojectkey2 AND p1.plstagecode = @i_plstagecode AND COALESCE(p1.selectedversionkey, 0) > 0)        
	UNION
	SELECT taqprojectkey1 projectkey
	FROM taqprojectrelationship r 
	INNER JOIN coreprojectinfo c 
	ON r.taqprojectkey1 = c.projectkey AND r.taqprojectkey2 = @i_taqprojectkey  AND (c.projectstatus NOT IN(select datacode from gentables where tableid = 522 and gen2ind = 1 ))
	INNER JOIN taqversion v ON v.taqprojectkey = r.taqprojectkey1 AND v.plstagecode = @i_plstagecode
	LEFT OUTER JOIN taqplstage p ON p.taqprojectkey = v.taqprojectkey AND p.plstagecode = v.plstagecode AND v.taqversionkey = p.selectedversionkey	
	WHERE r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
		AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)		
		AND v.plstagecode > 0 AND COALESCE(p.selectedversionkey, 0) = 0   
		AND NOT EXISTS(SELECT * FROM taqplstage p1 WHERE p1.taqprojectkey = r.taqprojectkey1 AND p1.plstagecode = @i_plstagecode AND COALESCE(p1.selectedversionkey, 0) > 0)
   ) Secondary_Projects		  
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @v_returncode = -1
  END
    
  IF @v_count_secondary > 0 BEGIN
	SET @v_returncode = 0
  END 
  
  IF @v_count_secondary = 0 BEGIN
	SET @v_returncode = 1
  END      
  
  RETURN @v_returncode
  
END
GO

GRANT EXEC ON dbo.qpl_allow_approve_master_pl_version TO PUBLIC
GO
