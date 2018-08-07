if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_version_html_commentkey') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qpl_version_html_commentkey
GO

CREATE FUNCTION qpl_version_html_commentkey (
  @i_taqprojectkey as integer,
  @i_plstagecode as integer,
  @i_taqversionkey as integer,
  @i_commenttypecode as integer,
  @i_commenttypesubcode as integer) 
RETURNS int

/******************************************************************************
**  Name: qpl_version_html_commentkey
**  Desc: Returns the HTML comment key if it exists. 
**
**  Auth: Kate
**  Date: April 2 2010
*******************************************************************************/

BEGIN 
  DECLARE
    @v_htmlkey  INT,
    @error_var  INT

  SELECT @v_htmlkey = commentkey
  FROM taqversioncomments
  WHERE taqprojectkey = @i_taqprojectkey AND
    plstagecode = @i_plstagecode AND
    taqversionkey = @i_taqversionkey AND
    commenttypecode = @i_commenttypecode AND
    commenttypesubcode = @i_commenttypesubcode

  SELECT @error_var = @@ERROR
  IF @error_var <> 0 
  BEGIN
    SET @v_htmlkey = NULL
  END 

  RETURN @v_htmlkey
  
END
GO

GRANT EXEC ON dbo.qpl_version_html_commentkey TO public
GO
