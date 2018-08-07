if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_check_subgentable_value_security') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_check_subgentable_value_security
GO

CREATE FUNCTION dbo.qutl_check_subgentable_value_security
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_datacode integer,
  @i_datasubcode integer
) 
RETURNS integer

/*******************************************************************************************************
**  Name: qutl_check_subgentable_value_security
**  Desc: This function returns accesscode for a gentable value on a specific window
**        0(No Access)/1(Read Only)/2(Update)
**
**  Auth: Alan Katzen
**  Date: June 22, 2010
*******************************************************************************************************/

BEGIN 
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowid_var INT,
          @object_accessind_var INT,   
          @return_accessind_var INT,
          @v_count INT

  IF COALESCE(@i_tableid,0) = 0 OR COALESCE(@i_datacode,0) = 0 OR COALESCE(@i_datasubcode,0) = 0 BEGIN
    RETURN 2
  END
  
  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    RETURN 0
  END 

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
    RETURN 0
  END 

  -- Get window information
  SELECT @windowid_var=q.windowid
    FROM qsiwindows q
   WHERE lower(q.windowname) = lower(@i_windowname)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    RETURN 0
  END 

  -- default to securityobjectsavailable.defaultaccesscode
  SELECT @return_accessind_var = COALESCE(defaultaccesscode, 2)
    FROM securityobjectsavailable a
   WHERE a.windowid = @windowid_var AND
         a.availobjectcodetableid = @i_tableid
         
  SET @object_accessind_var = @return_accessind_var
  
  -- Check security for user override row
  SELECT @v_count = count(*)   
    FROM securityobjects o,securityobjectsavailable a
   WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
         a.windowid = @windowid_var AND
         o.userkey = @i_userkey AND
         o.datacode = @i_datacode AND
         o.datasubcode = @i_datasubcode AND
         a.availobjectcodetableid = @i_tableid

  IF @v_count > 0 BEGIN 
    SELECT @object_accessind_var = accessind   
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
           a.windowid = @windowid_var AND
           o.userkey = @i_userkey AND
           o.datacode = @i_datacode AND
           o.datasubcode = @i_datasubcode AND
           a.availobjectcodetableid = @i_tableid
  END 
  ELSE BEGIN
    SELECT @v_count = count(*)   
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
           a.windowid = @windowid_var AND
           o.securitygroupkey = @securitygroupkey_var AND
           o.datacode = @i_datacode AND
           o.datasubcode = @i_datasubcode AND
           a.availobjectcodetableid = @i_tableid
           
    IF @v_count > 0 BEGIN
      SELECT @object_accessind_var = accessind   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             o.datacode = @i_datacode AND
             o.datasubcode = @i_datasubcode AND
             a.availobjectcodetableid = @i_tableid
    END
  END
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    RETURN 0
  END 

  IF @object_accessind_var <> @return_accessind_var BEGIN
    SET @return_accessind_var = @object_accessind_var
  END  
  
  RETURN @return_accessind_var
END
GO

GRANT EXEC ON dbo.qutl_check_subgentable_value_security TO public
GO
