IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_comptype')
  DROP PROCEDURE qutl_get_comptype
GO

CREATE PROCEDURE qutl_get_comptype
(
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/*****************************************************************************************************
**  Name: qutl_get_comptype
**  Desc: This stored procedure returns comptype data.
**
**  Auth: Kate
**  Date: 9/19/2014
******************************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT * FROM comptype
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access comptype table.'
    RETURN
  END

END
GO

GRANT EXEC ON qutl_get_comptype TO PUBLIC
GO
