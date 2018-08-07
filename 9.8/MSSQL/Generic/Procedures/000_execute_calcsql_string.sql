if exists (select * from dbo.sysobjects where id = Object_id('dbo.execute_calcsql_string') and (type = 'P' or type = 'RF'))
  drop proc dbo.execute_calcsql_string
GO

CREATE PROC dbo.execute_calcsql_string
  @i_sqlstring  VARCHAR(4000),
  @o_result     VARCHAR(255) OUTPUT
AS

DECLARE
  @v_sql  NVARCHAR(4000)
  
BEGIN

  SET @v_sql = LTRIM(RTRIM(@i_sqlstring))
  
  -- Replace double quotes with single quote
  SET @v_sql = REPLACE(@v_sql, '"','''')
  
  IF SUBSTRING(@v_sql, 1, 6) = 'SELECT'
    SET @v_sql = 'SELECT @result=' + SUBSTRING(@v_sql, 8, 4000)
  
  EXECUTE sp_executesql @v_sql, N'@result VARCHAR(255) OUTPUT', @o_result OUTPUT
  
END
GO

GRANT EXECUTE ON dbo.execute_calcsql_string TO PUBLIC
GO
