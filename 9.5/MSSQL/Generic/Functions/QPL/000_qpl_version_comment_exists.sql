if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_version_comment_exists') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_version_comment_exists
GO

CREATE FUNCTION qpl_version_comment_exists (
  @i_taqprojectkey as integer,
  @i_plstagecode as integer,
  @i_taqversionkey as integer,
  @i_commenttypecode as integer,
  @i_commenttypesubcode as integer) 
RETURNS int

/******************************************************************************
**  Name: qpl_version_comment_exists
**  Desc: This function returns 1 if comments exist, 0 if they don't exist,
**        and -1 for an error. 
**
**  Auth: Kate
**  Date: April 2 2010
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count      INT,
    @error_var    INT

  -- P&L Comments
  SELECT @v_count = COUNT(taqprojectkey)
  FROM taqversioncomments
  WHERE taqprojectkey = @i_taqprojectkey AND
    plstagecode = @i_plstagecode AND
    taqversionkey = @i_taqversionkey AND
    commenttypecode = @i_commenttypecode AND
    commenttypesubcode = @i_commenttypesubcode

  SELECT @error_var = @@ERROR
  IF @error_var <> 0 
    SET @v_count = -1

  IF @v_count > 0
    SET @v_count = 1

  RETURN @v_count
  
END
GO

GRANT EXEC ON dbo.qpl_version_comment_exists TO PUBLIC
GO
