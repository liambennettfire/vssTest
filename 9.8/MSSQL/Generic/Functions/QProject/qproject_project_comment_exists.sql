if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_project_comment_exists') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_project_comment_exists
GO

CREATE FUNCTION qproject_project_comment_exists
    ( @i_taqprojectkey as integer,
      @i_commenttypecode as integer,
      @i_commenttypesubcode as integer) 

RETURNS int

/******************************************************************************
**  File: qproject_project_comment_exists.sql
**  Name: qproject_project_comment_exists
**  Desc: This function returns 1 if comments exist,0 if they don't exist,
**        and -1 for an error. 
**
**
**    Auth: James Weber
**    Date: 13 May 2004
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
  SELECT @i_count = count(taqprojectkey)
    FROM taqprojectcomments
   WHERE taqprojectkey = @i_taqprojectkey and
         commenttypecode = @i_commenttypecode and
         commenttypesubcode = @i_commenttypesubcode

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

GRANT EXEC ON dbo.qproject_project_comment_exists TO public
GO
