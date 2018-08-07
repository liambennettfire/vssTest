IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_gentable_value_page_object_security')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_gentable_value_page_object_security'
    DROP  Procedure  qutl_check_gentable_value_page_object_security
  END

GO

PRINT 'Creating Procedure qutl_check_gentable_value_page_object_security'
GO

CREATE PROCEDURE qutl_check_gentable_value_page_object_security
 (@i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_datacode integer,
  @o_accesscode  integer output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_check_gentable_value_page_object_security
**  Desc: 
**    Parameters:
**    Input              
**    ----------         
**    userkey - userkey for userid trying to access window
**    windowname - Name of Page to check security
**    tableid - tableid of gentable to check
**    datacode - datacode of gentable to check
**    
**    Output
**    -----------
**    accesscode - 0(No Access)/1(Read Only)/2(Update)
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Alan Katzen
**    Date: 6/22/10
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

  -- default accesscode to 2 - only "ALL" object security OR error can change it
  SET @o_accesscode = 2
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowid_var INT,
          @object_accessind_var INT,   
          @v_count INT

  IF COALESCE(@i_tableid,0) = 0 OR COALESCE(@i_datacode,0) = 0 BEGIN
    return
  END
  
  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Userid not setup on qsiusers table.'
    RETURN
  END 

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Userid is not a member of a security group.'
    RETURN
  END 

  -- Get window information
  SELECT @windowid_var=q.windowid
    FROM qsiwindows q
   WHERE lower(q.windowname) = lower(@i_windowname)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Database Error accessing qsiwindows table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  -- Check security for user override row
  SELECT @v_count = count(*)   
    FROM securityobjects o,securityobjectsavailable a
   WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
         a.windowid = @windowid_var AND
         o.userkey = @i_userkey AND
         o.datacode = @i_datacode AND
         a.availobjectcodetableid = @i_tableid

  IF @v_count > 0 BEGIN 
    SELECT @object_accessind_var = accessind   
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
           a.windowid = @windowid_var AND
           o.userkey = @i_userkey AND
           o.datacode = @i_datacode AND
           a.availobjectcodetableid = @i_tableid
  END 
  ELSE BEGIN
    SELECT @v_count = count(*)   
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
           a.windowid = @windowid_var AND
           o.securitygroupkey = @securitygroupkey_var AND
           o.datacode = @i_datacode AND
           a.availobjectcodetableid = @i_tableid
           
    IF @v_count > 0 BEGIN
      SELECT @object_accessind_var = accessind   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             o.datacode = @i_datacode AND
             a.availobjectcodetableid = @i_tableid
    END
  END
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Database Error accessing securityobjects table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  IF @object_accessind_var >= 0 BEGIN
    SET @o_accesscode = @object_accessind_var
  END  
GO

GRANT EXEC ON qutl_check_gentable_value_page_object_security TO PUBLIC
GO
