if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_test_pl_calcsql') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_test_pl_calcsql
GO

CREATE PROCEDURE dbo.qpl_test_pl_calcsql
  (@i_calcsql     VARCHAR(4000), 
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT)
AS

/**********************************************************************************
**  Name: qpl_test_pl_calcsql
**  Desc: Stored procedure to test P&L Summary Item Calculation.
**        Returns 1 if SQL is OK, or -1 for an error. 
**
**  Auth: Kate Wiewiora
**  Date: 24 August 2007
**********************************************************************************/

BEGIN
 DECLARE
    @v_calcsql  NVARCHAR(4000),
    @v_calcvalue  FLOAT,
    @v_comma_pos INT,
    @v_end_pos INT,
    @v_equal_pos INT,
    @v_length INT,
    @v_param VARCHAR(50),
    @v_param_pos  INT,
    @v_parenth_pos	INT,
    @v_quote  CHAR(1),
    @v_space_pos INT,
    @v_summarylevel INT,
    @v_summaryheading INT,
    @v_value VARCHAR(50),
    @v_valid_params VARCHAR(2000),
    @v_error  INT,
    @v_errormsg VARCHAR(4000),
    @v_rowcount INT

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_calcsql = LOWER(LTRIM(RTRIM(@i_calcsql)))
  SET @v_length = LEN(@v_calcsql)
  
  IF @v_length = 0 BEGIN
    SET @o_error_code = 1
    RETURN
  END
  
  IF @v_length > 4000 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'SQL statements are limited to 4000 characters.'
    RETURN
  END

  IF LEFT(@v_calcsql, 6) = 'select'
    BEGIN
      IF CHARINDEX(' from ', @v_calcsql, 1) = 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'SELECT statement must include a valid FROM clause.'
        RETURN
      END
      IF CHARINDEX(' where ', @v_calcsql, 1) = 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'SELECT statement must include a valid WHERE clause.'
        RETURN
      END
    END
  ELSE IF LEFT(@v_calcsql, 4) = 'exec'
    BEGIN
      IF CHARINDEX('exec sp_executesql', @v_calcsql, 1) > 0 OR CHARINDEX('execute sp_executesql', @v_calcsql, 1) > 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'SQL may not include sp_executesql EXECUTE statements.'
        RETURN
      END
      IF CHARINDEX('@result output', @v_calcsql, 1) = 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'EXECUTE stored procedure statement must include @result OUTPUT parameter.'
        RETURN
      END
    END
  ELSE
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'SQL statement must begin with SELECT or EXECUTE keyword.'
      RETURN
    END

  -- Valid parameter list
  SET @v_valid_params = '@projectkey, @plstagecode, @versionkey, @yearcode'
  -- UserKey, UserID and the output Result parameter are always allowed
  SET @v_valid_params = @v_valid_params + ', @userkey, @userid, @result'

  -- Parse each parameter
  SET @v_param_pos = CHARINDEX('@', @v_calcsql, 1)

  WHILE (@v_param_pos > 0)
  BEGIN

    --Determine the end position of parameter name
    SET @v_end_pos = NULL
    SET @v_comma_pos = CHARINDEX(',', @v_calcsql, @v_param_pos)
    IF @v_comma_pos > 0
      SET @v_end_pos = @v_comma_pos

    SET @v_parenth_pos = CHARINDEX(')', @v_calcsql, @v_param_pos)
    IF @v_parenth_pos > 0 BEGIN
      IF @v_end_pos IS NULL
        SET @v_end_pos = @v_parenth_pos
      ELSE IF @v_parenth_pos < @v_end_pos
        SET @v_end_pos = @v_parenth_pos
    END

    SET @v_equal_pos = CHARINDEX('=', @v_calcsql, @v_param_pos)
    IF @v_equal_pos > 0 BEGIN
      IF @v_end_pos IS NULL
        SET @v_end_pos = @v_equal_pos
      ELSE IF @v_equal_pos < @v_end_pos
        SET @v_end_pos = @v_equal_pos
    END

    SET @v_space_pos = CHARINDEX(' ', @v_calcsql, @v_param_pos)
    IF @v_space_pos > 0 BEGIN
      IF @v_end_pos IS NULL
        SET @v_end_pos = @v_space_pos
      ELSE IF @v_space_pos < @v_end_pos
        SET @v_end_pos = @v_space_pos
    END

    --Get parameter name
    IF @v_end_pos > 0
      SET @v_param = SUBSTRING(@v_calcsql, @v_param_pos, @v_end_pos - @v_param_pos)
    ELSE
      SET @v_param = SUBSTRING(@v_calcsql, @v_param_pos, 4000)

    --Validate parameters
    IF CHARINDEX(@v_param, @v_valid_params, 1) = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'SQL contains invalid paramater ' + @v_param + '.<newline><newline>Valid parameters for P&L Item calculations are:<newline>' + @v_valid_params + '.'
      RETURN
    END
    
    --Determine value based on parameter placeholder
    IF @v_param <> '@result'
    BEGIN
      IF @v_param = '@userid'
        SET @v_value = @v_quote + 'QSI' + @v_quote
      ELSE IF @v_param = '@projectkey' OR @v_param = '@plstagecode' OR @v_param = '@versionkey' OR @v_param = '@yearcode' OR @v_param = '@userkey'
        SET @v_value = '0'
      ELSE
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'SQL contains invalid paramater ' + @v_param + '.<newline>Valid parameters for P&L Item calculations are: ' + @v_valid_params + '.'
          RETURN        
        END

      --Replace parameter placeholder with corresponding value
      SET @v_calcsql = REPLACE(@v_calcsql, @v_param, @v_value)
    END

    -- Get next paramater position
    SET @v_param_pos = CHARINDEX('@', @v_calcsql, @v_param_pos + 1)
  END

  -- Execute the SQL statement to test
  IF SUBSTRING(@v_calcsql, 1, 6) = 'SELECT'
    SET @v_calcsql = 'SELECT @result=' + SUBSTRING(@v_calcsql, 8, 4000)
    
  BEGIN TRY
    EXECUTE sp_executesql @v_calcsql, N'@result FLOAT OUTPUT', @v_calcvalue OUTPUT
  END TRY

  BEGIN CATCH
    SELECT @v_error=ERROR_NUMBER(), @v_errormsg=ERROR_MESSAGE()
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      IF @v_error = 8162
        SET @o_error_desc = 'Invalid number of arguments to the stored procedure.'
      ELSE IF @v_error = 8114
        SET @o_error_desc = 'At least one argument to the stored procedure does not match the actual parameter datatype.'
      ELSE
        SET @o_error_desc = @v_errormsg
      RETURN
    END
  END CATCH
  
END
GO

GRANT EXECUTE ON qpl_test_pl_calcsql TO PUBLIC
go
