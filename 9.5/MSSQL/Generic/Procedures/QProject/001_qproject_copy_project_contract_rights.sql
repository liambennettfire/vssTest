if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_contract_rights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_project_contract_rights
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_project_contract_rights
  (@i_copy_projectkey     integer,
  @i_copy2_projectkey     integer,
  @i_new_projectkey       integer,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_project_contract_rights
**  Desc: This stored procedure handles copying Contract rights and territory.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 10 May 2012
****************************************************************************************/

DECLARE
  @v_approved_status  INT,
  @v_count  INT,
  @v_error	INT
	
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Copy projectkey not passed to copy P&L Version.'
    RETURN
  END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'New projectkey not passed to copy P&L Version: copy_projectkey=' + CAST(@i_copy_projectkey AS VARCHAR)   
    RETURN
  END
    
  /* 5/10/12 - KW - From case 17842:
  Contract Rights and Territory: If taqprojectrights exist for i_copy_projectkey, copy this table along with all associated tables 
  (taqprojectrightsformat, taqprojectrightslanguage, territoryrights, territoryrightcountries), for this taqprojectkey.
  If there are no taqprojectrights for i_copy_projectkey, copy all taqprojectrights and associated tables for i_copy2_projectkey instead.
  THEN, if there is an approved P&L for i_copy_projectkey, for every taqversionsubrights.rightscode for that version, find all taqprojectrights 
  for that rightstypecode and update the authorsubrightspercent for those rights. If there is no approved P&L for i_copy_projectkey 
  and there one for i_copy2_projectkey, copy from this instead. */
  
  SELECT @v_count = COUNT(*)
  FROM taqprojectrights
  WHERE taqprojectkey = @i_copy_projectkey
  
  IF @v_count > 0 --taqprojectrights exist for i_copy_projectkey - copy from i_copy_projectkey
  BEGIN
    EXEC qproject_copy_rightsinfo @i_copy_projectkey, @i_new_projectkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    IF @o_error_code < 0
      RETURN
  END  
  ELSE IF @i_copy2_projectkey > 0 --no taqprojectrights exist for i_copy_projectkey and i_copy2_projectkey was passed in - copy from i_copy2_projectkey
  BEGIN
	  SELECT @v_count = COUNT(*)
    FROM taqprojectrights
    WHERE taqprojectkey = @i_copy2_projectkey
    
    IF @v_count > 0
    BEGIN
      EXEC qproject_copy_rightsinfo @i_copy2_projectkey, @i_new_projectkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
      
      IF @o_error_code < 0
        RETURN    
    END
  END
  
  -- Get the final approval status to be used for this client from clientdefaults
  SELECT @v_approved_status = clientdefaultvalue
  FROM clientdefaults
  WHERE clientdefaultid = 61
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get P&L Final Approval Status from clientdefaults table.'
    RETURN
  END
  
  IF @v_approved_status IS NULL
    SET @v_approved_status = 0
    
  -- Check if at least one approved p&l version exists for i_copy_projectkey
  SELECT @v_count = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_copy_projectkey AND 
    plstatuscode = @v_approved_status
    
  IF @v_count > 0 --approved p&l exists for i_copy_projectkey - update author subrights percentages from approved p&l for i_copy_projectkey
  BEGIN
    EXEC qproject_copy_rightsinfo_addtl @i_copy_projectkey, @i_new_projectkey, @v_approved_status, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    IF @o_error_code < 0
      RETURN 
  END
  ELSE IF @i_copy2_projectkey > 0  --update author subrights percentages from approved p&l for i_copy2_projectkey
  BEGIN
    EXEC qproject_copy_rightsinfo_addtl @i_copy2_projectkey, @i_new_projectkey, @v_approved_status, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    IF @o_error_code < 0
      RETURN
  END
      
END
GO

GRANT EXEC ON qproject_copy_project_contract_rights TO PUBLIC
GO
