if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_verify_or_add_globalcontact_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_verify_or_add_globalcontact_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_verify_or_add_globalcontact_role
 (@i_globalcontactkey     integer,
  @i_rolecode       integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_verify_or_add_globalcontact_role
**  Desc: This stored procedure verifies that 
**        the role is present on the contact
**        and if not, adds it to the contact.
**
**  Auth: Colman
**  Date: 11/21/2016
*******************************************************************************/

  DECLARE 
    @v_rolecount INT,
    @v_keyind    INT
    
  SET @v_keyind = 0

  SET @o_error_code = 0
  SET @o_error_desc = ''  
   
  if (@i_rolecode is not null)
  BEGIN
    
    SELECT @v_rolecount = COUNT(*) 
    FROM globalcontactrole 
    WHERE globalcontactkey = @i_globalcontactkey

    IF @v_rolecount = 0
      SET @v_keyind = 1
    ELSE
      SELECT @v_rolecount = COUNT(*) 
      FROM globalcontactrole 
      WHERE globalcontactkey = @i_globalcontactkey AND rolecode = @i_rolecode
    
    IF @v_rolecount = 0
    BEGIN
      INSERT INTO globalcontactrole (globalcontactkey, rolecode, keyind, lastuserid, lastmaintdate, sortorder)
      VALUES (@i_globalcontactkey, @i_rolecode, @v_keyind, @i_userid, getdate(), null)      
    END 
  END

GO

GRANT EXEC ON qcontact_verify_or_add_globalcontact_role TO PUBLIC
GO
