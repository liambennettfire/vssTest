if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_verify_or_add_author_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_verify_or_add_author_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_verify_or_add_author_role
 (@i_contactkey     integer,
  @author_role_type integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_verify_or_add_author_role
**  Desc: This stored procedure verifies that 
**        the role associated with the author type is present on the contact
**        and if it is not, it is added to the contact.
**
**  Auth: James Weber
**  Date: 21 June 2004
*******************************************************************************/

  DECLARE @v_contact_role INT,
    @ExistingRoleCount INT,
    @error_var    INT,
    @rowcount_var INT,
    @SQLString	NVARCHAR(4000),
    @v_author_rolecode INT
    
  SET @v_contact_role = null  
  SET @o_error_code = 0
  SET @o_error_desc = ''  
   
  -- use the author role as a default for any authortypecode that is not mapped to a rolecode
  select @v_author_rolecode = datacode 
    from gentables
   where tableid = 285 
     and qsicode = 4

  SELECT @v_contact_role = code2
  FROM gentablesrelationshipdetail
  WHERE gentablesrelationshipkey = 1 AND code1 = @author_role_type
    
  SET @v_contact_role = coalesce(@v_contact_role, @v_author_rolecode)

  if (@v_contact_role > 0) BEGIN
    SELECT @ExistingRoleCount = COUNT(*) 
    FROM globalcontactrole 
    WHERE globalcontactkey = @i_contactkey AND rolecode = @v_contact_role
    
    IF @ExistingRoleCount = 0
    BEGIN
      INSERT INTO globalcontactrole (globalcontactkey, rolecode, keyind, lastuserid, lastmaintdate, sortorder)
      VALUES (@i_contactkey, @v_contact_role, 0, 'verifier', getdate(), null)      
    END 
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
--  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
--  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
--    SET @o_error_code = 1
--    SET @o_error_desc = 'no data found on globalcontactaddress (' + cast(@error_var AS VARCHAR) + '): globalcontactkey = ' + cast(@i_contactkey AS VARCHAR)   
--  END 

GO

GRANT EXEC ON qcontact_verify_or_add_author_role TO PUBLIC
GO
