if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_taqversioncomment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_taqversioncomment
GO

CREATE PROCEDURE qpl_get_taqversioncomment
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_taqversionkey  integer,
  @i_commenttypecode    integer,
  @i_commenttypesubcode integer, 
  @i_commentformattype  varchar(20),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qpl_get_taqversioncomment
**  Desc: This stored procedure gets the P&L comment based on the
**        type of comment and based on the format requested.  If the 
**        HTML version is requested and it is not available then the
**        plain text version is sent instead.  
**
**  Auth: Kate
**  Date: April 2 2010
*******************************************************************************/
  
DECLARE
  @v_commentkey INT,
  @v_error    INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @i_commentformattype = upper(@i_commentformattype)
 
  SELECT @v_commentkey = commentkey 
  FROM taqversioncomments 
  WHERE taqprojectkey = @i_projectkey and
    plstagecode = @i_plstagecode and
    taqversionkey = @i_taqversionkey and
    commenttypecode = @i_commenttypecode and
    commenttypesubcode = @i_commenttypesubcode 
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error != 0
    GOTO ExitHandler

  IF @v_rowcount = 0
    RETURN

  SET @v_rowcount = 0
  
  IF @v_commentkey IS NOT NULL
  BEGIN
  
    IF @i_commentformattype = 'HTML'
      SELECT commentkey, commenttypecode, commenttypesubcode, parenttable, commenthtml commentbody
      FROM qsicomments 
      WHERE commentkey = @v_commentkey
    ELSE IF @i_commentformattype = 'HTMLLITE'
      SELECT commentkey, commenttypecode, commenttypesubcode, parenttable, commenthtmllite commentbody
      FROM qsicomments 
      WHERE commentkey = @v_commentkey 
    ELSE IF (@i_commentformattype = 'TEXT')
      SELECT commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext commentbody
      FROM qsicomments 
      WHERE commentkey = @v_commentkey
   
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  END

  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error retrieving qsicomments (for qpl_get_taqversioncomment - ' + @i_commentformattype + ').'   
  END
  IF @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: qsicomments (for qpl_get_taqversioncomment).'   
  END

  RETURN

  ExitHandler:
  SET @o_error_code = -1
  SET @o_error_desc = 'Error getting values from taqversioncomments.'

END
go

GRANT EXEC ON qpl_get_taqversioncomment TO PUBLIC
go
