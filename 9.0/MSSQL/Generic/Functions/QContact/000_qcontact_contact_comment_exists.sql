if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_contact_comment_exists') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qcontact_contact_comment_exists
GO

CREATE FUNCTION qcontact_contact_comment_exists
    ( @i_contactkey as integer,
      @i_commenttypecode as integer) 

RETURNS int

/******************************************************************************
**  File: qcontact_contact_comment_exists.sql
**  Name: qcontact_contact_comment_exists
**  Desc: This function returns 1 if comments exist,0 if they don't exist,
**        and -1 for an error. 
**
**
**    Auth: Jon Hess
**    Date: 09-10-2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_count = 0

  -- Project Comments.
  SELECT @i_count = count(commentkey)
    from qsicomments
   where commentkey = @i_contactkey
	 AND commenttypecode = @i_commenttypecode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 
  BEGIN
    SET @i_count = -1
  END 

  -- return 1 or 0 so that object can set params 
  IF @i_count > 0 BEGIN
    SET @i_count = 1
  END

  RETURN @i_count
END
GO

GRANT EXEC ON dbo.qcontact_contact_comment_exists TO public
GO
