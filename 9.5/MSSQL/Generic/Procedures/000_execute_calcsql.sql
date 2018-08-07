if exists (select * from dbo.sysobjects where id = Object_id('dbo.execute_calcsql') and (type = 'P' or type = 'RF'))
  drop proc dbo.execute_calcsql
GO

CREATE PROC dbo.execute_calcsql
  @i_sqlstring  VARCHAR(4000),
  @o_result     FLOAT OUTPUT
AS

DECLARE
  @v_sql  NVARCHAR(4000)
  
BEGIN

  SET @v_sql = LTRIM(RTRIM(@i_sqlstring))
  
  -- Replace double quotes with single quote
  SET @v_sql = REPLACE(@v_sql, '"','''')
  
  IF SUBSTRING(@v_sql, 1, 6) = 'SELECT'
    SET @v_sql = 'SELECT @result=' + SUBSTRING(@v_sql, 8, 4000)
  
  EXECUTE sp_executesql @v_sql, N'@result FLOAT OUTPUT', @o_result OUTPUT
  
END
GO

GRANT EXECUTE ON dbo.execute_calcsql TO PUBLIC
GO
