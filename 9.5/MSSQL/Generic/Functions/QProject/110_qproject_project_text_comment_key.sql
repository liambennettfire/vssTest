  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_project_text_comment_key') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_project_text_comment_key
GO

CREATE FUNCTION qproject_project_text_comment_key
    ( @i_taqprojectkey as integer,
      @i_commenttypecode as integer,
      @i_commenttypesubcode as integer) 

RETURNS int

/******************************************************************************
**  File: qproject_project_text_comment_key.sql
**  Name: qproject_project_text_comment_key
**  Desc: Returns the TEXT comment key if it exists. 
**
**
**    Auth: James Weber
**    Date: 18 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_text_key   INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_text_key = NULL

  -- Project Comments.
  SELECT @i_text_key = commentkey
    FROM taqprojectcomments
   WHERE taqprojectkey = @i_taqprojectkey and
         commenttypecode = @i_commenttypecode and
         commenttypesubcode = @i_commenttypesubcode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 
  BEGIN
    SET @i_text_key = NULL
  END 

  RETURN @i_text_key
END
GO

GRANT EXEC ON dbo.qproject_project_text_comment_key TO public
GO
