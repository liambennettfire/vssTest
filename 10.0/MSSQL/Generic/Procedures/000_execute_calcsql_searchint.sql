if exists (select * from dbo.sysobjects where id = Object_id('dbo.execute_calcsql_searchint') and (type = 'P' or type = 'RF'))
  drop proc dbo.execute_calcsql_searchint
GO

/******************************************************************************
**  Name: execute_calcsql_searchint
**  Desc: Return the calculated value for a 'Calculated Search Int' misc item
**
**  Auth: Colman
**  Case: 48094
**  Date: 1/11/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*******************************************************************************/

CREATE PROC dbo.execute_calcsql_searchint
  @i_sqlstring  VARCHAR(max),
  @o_result     VARCHAR(255) OUTPUT
AS

DECLARE
  @v_sql  NVARCHAR(max),
  @v_sql_len int,
  @v_idx_from int,
  @v_int_result int
  
BEGIN

  SET @v_sql = LTRIM(RTRIM(@i_sqlstring))
  
  -- Replace double quotes with single quote
  SET @v_sql = REPLACE(@v_sql, '"','''')
  SET @v_sql_len = LEN(@v_sql)
  SET @v_idx_from = CHARINDEX('FROM', @v_sql)
  IF @v_idx_from > 0
  BEGIN
    SET @v_sql = 'SELECT COUNT(*) ' + SUBSTRING(@v_sql, @v_idx_from, @v_sql_len)
  
    EXECUTE sp_executesql @v_sql, N'@result INT OUTPUT', @v_int_result OUTPUT
    SET @o_result = CONVERT(VARCHAR, @v_int_result)
  END
END
GO

GRANT EXECUTE ON dbo.execute_calcsql_searchint TO PUBLIC
GO
