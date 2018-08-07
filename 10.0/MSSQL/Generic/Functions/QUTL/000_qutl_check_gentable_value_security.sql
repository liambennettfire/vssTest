if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_check_gentable_value_security') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_check_gentable_value_security
GO

CREATE FUNCTION dbo.qutl_check_gentable_value_security
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_datacode integer,
  @i_printingkey integer
) 
RETURNS integer

/*******************************************************************************************************
**  Name: qutl_check_gentable_value_security
**  Desc: This function returns accesscode for a gentable value on a specific window
**        0(No Access)/1(Read Only)/2(Update)
**
**  Auth: Alan Katzen
**  Date: June 22, 2010
********************************************************************************************************
**  Change History
********************************************************************************************************
**  Date:      Author:    Case #:   Description:
**  --------   --------   -------   --------------------------------------
**  06/07/18   Colman     50971     Implemented availsecurityobjectkey.firstprintingind support
*******************************************************************************************************/

BEGIN 
  DECLARE 
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowid_var INT,
          @object_accessind_var INT,   
          @object_defaultaccessind_var INT

  IF COALESCE(@i_tableid,0) = 0 OR COALESCE(@i_datacode,0) = 0 BEGIN
    RETURN 2
  END
  
  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- All users must be part of a security group
  IF ISNULL(@securitygroupkey_var, 0) <= 0
    RETURN 0

  -- Get window information
  SELECT @windowid_var=q.windowid
    FROM qsiwindows q
   WHERE lower(q.windowname) = lower(@i_windowname)

  IF @@ERROR <> 0 OR @@ROWCOUNT = 0
    RETURN 0
    
  SET @object_defaultaccessind_var = 2

  -- default to securityobjectsavailable.defaultaccesscode
  SELECT @object_defaultaccessind_var = COALESCE(defaultaccesscode, 2)
    FROM securityobjectsavailable a
   WHERE a.windowid = @windowid_var AND
         a.availobjectcodetableid = @i_tableid
         
  -- Check security for user override row
  SELECT @object_accessind_var = accessind
    FROM securityobjects o,securityobjectsavailable a
   WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
         a.windowid = @windowid_var AND
         o.userkey = @i_userkey AND
         o.datacode = @i_datacode AND
        (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@i_printingkey, 1) = 1) AND
         a.availobjectcodetableid = @i_tableid

  IF @object_accessind_var IS NULL
      SELECT @object_accessind_var = accessind   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             o.datacode = @i_datacode AND
            (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@i_printingkey, 1) = 1) AND
             a.availobjectcodetableid = @i_tableid
 
  IF @@ERROR <> 0
    RETURN 0

  IF @object_accessind_var IS NULL
    SET @object_accessind_var = @object_defaultaccessind_var
  
  RETURN @object_accessind_var
END
GO

GRANT EXEC ON dbo.qutl_check_gentable_value_security TO public
GO
