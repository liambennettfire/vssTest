IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_generic_select')
  DROP PROCEDURE  qutl_generic_select
GO

CREATE PROCEDURE qutl_generic_select (
  @i_select_sql   VARCHAR(max),
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT)
AS

/************************************************************************************
**  Name: qutl_generic_select
**  Desc: Generic stored procedure for simple select.
**
**  Auth: Kate
**  Date: August 13 2007
************************************************************************************/

BEGIN
  DECLARE
    @v_error  INT,
    @v_rowcount   INT,
    @v_SQLString  NVARCHAR(max)
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_select_sql IS NULL OR LTRIM(RTRIM(@i_select_sql)) = ''
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'qutl_generic_select cannot return data: select SQL not passed in.'
    RETURN
  END
  
  SET @v_SQLString = @i_select_sql
  
  --DEBUG
  --PRINT @v_SQLString

  EXECUTE sp_executesql @v_SQLString

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'qutl_generic_select could not return data (' + CAST(@v_error AS VARCHAR) + ').'
    RETURN
  END

END
GO

GRANT EXEC ON qutl_generic_select TO PUBLIC
GO
