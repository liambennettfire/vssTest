if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_is_contact_private') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qcontact_is_contact_private
GO

CREATE FUNCTION qcontact_is_contact_private
    ( @i_contactkey as integer,@i_userkey as integer) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qcontact_is_contact_private
**  Desc: This function returns 1 if contact is private for the passsed in userkey,
**        0 if it's public, and -1 for an error. 
**
**    Auth: Alan Katzen
**    Date: 27 June 2011
*******************************************************************************/

BEGIN 
  DECLARE @v_is_private INT
  DECLARE @v_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  -- default to public
  SET @v_is_private = 0
  SET @v_count = 0
  
  SELECT @v_count = count(*)
    FROM corecontactinfo c
   WHERE c.contactkey = @i_contactkey
     AND (COALESCE(c.privateind,0) = 0 
     OR (c.privateind = 1 
     AND (c.owneruserkey = @i_userkey 
     OR c.owneruserkey IN (SELECT accesstouserkey FROM qsiprivateuserlist 
                            WHERE primaryuserkey = @i_userkey))))
                         
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @v_is_private = -1
  END 

  -- return 1 or 0 so that object can set params 
  IF @v_count <= 0 BEGIN
    SET @v_is_private = 1
  END

  RETURN @v_is_private
END
GO

GRANT EXEC ON dbo.qcontact_is_contact_private TO public
GO
