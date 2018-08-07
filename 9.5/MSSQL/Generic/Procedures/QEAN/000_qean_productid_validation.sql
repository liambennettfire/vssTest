if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qean_productid_validation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qean_productid_validation]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
DECLARE @o_new_string varchar(25),
@o_error_code INT,
@o_error_desc varchar(2000)

exec qean_productid_validation 2, '978-1-4039-6216-4', 1, 1, 3198857, @o_new_string output, @o_error_desc output, @o_error_desc output

print 'ostring = ' + @o_new_string
print 'err = ' + convert(varchar, @o_error_code)
print 'desc = ' + @o_error_desc
*/

CREATE PROCEDURE dbo.qean_productid_validation
  @i_qsicode          INT,
  @i_passed_string    VARCHAR(25),
  @i_type             TINYINT,
  @i_check_if_exists  TINYINT,
  @i_bookkey          INT,
  @o_new_string       VARCHAR(25) OUTPUT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT
AS

/*****************************************************************************************************
**  Name: qean_productid_validation
**
**  Desc: This stored procedure executes the validation SQL for a type of product id.  The stored
**          procedure call should be set up in gentables.alternatedesc1 of tableid 551.  Any new
**          parameters will need to be added/modified here.
**
**  Auth: Lisa
**  Date: November 10 2009
*****************************************************************************************************/

DECLARE
  @v_error  INT,
  @v_quote  CHAR(1),  
  @v_rowcount INT,
  @v_sql nvarchar(4000),
  @v_new_string  NVARCHAR(25),
  @v_error_code  INT,
  @v_error_desc  NVARCHAR(2000),
  @v_ParmDefinition NVARCHAR(500),
  @v_qsicode INT,
  @v_passed_string VARCHAR(25),
  @v_type TINYINT,
  @v_check_if_exists TINYINT,
  @v_bookkey INT

BEGIN
  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_bookkey IS NULL OR @i_bookkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid bookkey.'
    GOTO RETURN_ERROR
  END

  IF @i_qsicode IS NULL OR @i_qsicode <= 0 BEGIN
    SET @o_error_desc = 'Invalid qsicode.'
    GOTO RETURN_ERROR
  END
  
  -- Get validation SQL
  SELECT @v_sql = rtrim(ltrim(alternatedesc1))
  FROM gentables
  WHERE qsicode = @i_qsicode AND tableid = 551

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not access gentables for validation SQL (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  IF @v_rowcount <= 0 BEGIN --not an error
    SET @o_error_code = 0
    SET @o_error_desc = 'Validation procedure (alternatedesc1) not found on gentable 551, qsicode: ' + cast(@i_qsicode AS VARCHAR)
    RETURN
  END 

  -- Replace each parameter placeholder with corresponding value
  SET @v_sql = REPLACE(@v_sql, '@i_passed_string', @v_quote + @i_passed_string + @v_quote)  
  SET @v_sql = REPLACE(@v_sql, '@i_type', CONVERT(VARCHAR, @i_type))
  SET @v_sql = REPLACE(@v_sql, '@i_check_if_exists', CONVERT(VARCHAR, @i_check_if_exists))
  SET @v_sql = REPLACE(@v_sql, '@i_bookkey', CONVERT(VARCHAR, @i_bookkey))  
  
  -- Set up the output parameters
  SET @v_ParmDefinition='@o_new_string varchar(25) OUTPUT, @o_error_code int OUTPUT, @o_error_desc varchar(2000) OUTPUT'

  -- DEBUG
  --PRINT 'SQL: ' + @v_sql

  EXECUTE sp_executesql
    @v_sql,
    @v_ParmDefinition,
    @o_new_string=@v_new_string OUTPUT, @o_error_code=@v_error_code OUTPUT,@o_error_desc=@v_error_desc OUTPUT

  SET @o_new_string = @v_new_string
  SET @o_error_code = @v_error_code
  SET @o_error_desc = @v_error_desc
  
  --SELECT @v_new_string, @v_error_code, @v_error_desc
  RETURN  
  
RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON qean_productid_validation TO PUBLIC
GO
