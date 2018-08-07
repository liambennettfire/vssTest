if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_allow_remove_relationship') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_allow_remove_relationship
GO

CREATE FUNCTION qpl_allow_remove_relationship (
  @i_taqprojectkey as integer,
  @i_taqprojectkey_related as integer  
  ) 
RETURNS int

/*********************************************************************************************************************************************************************
**  Name: qpl_allow_remove_relationship
**  Desc: This function returns 1 we allow deletion, 0 if any LOCKED (approved) consolidated versions exist that use a selected version from the Additional P&L,
**        and -1 for an error. 
**
**  Auth: Uday A. Khisty
**  Date: March 18 2015
***************************************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @error_var    INT,
    @v_count INT,  
    @v_returncode INT,
    @v_Is_Master_Project INT,
    @v_Is_Master_RelatedProject INT,
    @v_is_stage_locked INT,
    @v_PL_Final_Approved_Status INT,
    @v_approved_project_status INT,
    @v_project_status INT,
    @_projectrelated_status INT
    
  SET @v_Is_Master_Project = -1
  SET @v_Is_Master_RelatedProject = -1
  SET @v_returncode = 1
  SET @v_PL_Final_Approved_Status = 0
  SET @v_count = 0
    
  IF @i_taqprojectkey IS NULL OR @i_taqprojectkey <= 0 BEGIN
	return @v_returncode
  END
  
  IF @i_taqprojectkey_related IS NULL OR @i_taqprojectkey_related <= 0 BEGIN
	return @v_returncode
  END  
  
  SELECT @v_is_stage_locked = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
    
  IF @v_is_stage_locked = 1 BEGIN
     SELECT @v_PL_Final_Approved_Status = COALESCE(CAST(clientdefaultvalue AS INT), 0) FROM clientdefaults where clientdefaultid = 61 
  END  
  
  SELECT @v_Is_Master_Project = dbo.qpl_is_master_pl_project(@i_taqprojectkey)
  SELECT @v_Is_Master_RelatedProject = dbo.qpl_is_master_pl_project(@i_taqprojectkey_related) 
  
  SELECT @v_project_status = taqprojectstatuscode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey
  SELECT @_projectrelated_status = taqprojectstatuscode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey_related
    
  IF ((@v_Is_Master_Project = 0 AND @v_Is_Master_RelatedProject = 1) OR (@v_Is_Master_Project = 1 AND @v_Is_Master_RelatedProject = 0)) AND @v_PL_Final_Approved_Status > 0 BEGIN
  
	IF @v_Is_Master_Project = 1 BEGIN	   
	   SELECT @v_count = COUNT(*) 
	   FROM taqplstage 
	   WHERE plstagecode IN
 			(select plstagecode from taqversion where taqprojectkey = @i_taqprojectkey and plstatuscode = @v_PL_Final_Approved_Status) AND
 		    taqprojectkey = @i_taqprojectkey_related AND
 		    selectedversionkey > 0 	
	END
	ELSE BEGIN
	   SELECT @v_count = COUNT(*) 
	   FROM taqplstage 
	   WHERE plstagecode IN
 			(select plstagecode from taqversion where taqprojectkey = @i_taqprojectkey_related and plstatuscode = @v_PL_Final_Approved_Status) AND
 		    taqprojectkey = @i_taqprojectkey AND
 		    selectedversionkey > 0 		
	END
	
	IF @v_count > 0 BEGIN
		SET @v_returncode = 0	
	END	
  END       
  
  -- Should not be able to delete anything related to a locked Acquisition
  IF @v_project_status IN (SELECT datacode FROM gentables WHERE tableid = 522 AND gen2ind = 1) OR
	 @_projectrelated_status IN (SELECT datacode FROM gentables WHERE tableid = 522 AND gen2ind = 1) BEGIN
	 
	 SET @v_returncode = 0
  END    
  
  RETURN @v_returncode
  
END
GO

GRANT EXEC ON dbo.qpl_allow_remove_relationship TO PUBLIC
GO