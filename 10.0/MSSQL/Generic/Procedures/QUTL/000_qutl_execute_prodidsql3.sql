if exists (select * from dbo.sysobjects where id = Object_id('dbo.qutl_execute_prodidsql3') and (type = 'P' or type = 'RF'))
  drop proc dbo.qutl_execute_prodidsql3
GO

CREATE PROC dbo.qutl_execute_prodidsql3
  @i_sqlstring    VARCHAR(4000),
  @o_result       CHAR(7) OUTPUT,
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

DECLARE
  @v_sql  NVARCHAR(4000)
  
BEGIN

  SET @v_sql = LTRIM(RTRIM(@i_sqlstring))
    
  EXECUTE sp_executesql @v_sql, 
    N'@result CHAR(7) OUTPUT, @errorcode INT OUTPUT, @errordesc VARCHAR(2000) OUTPUT', 
    @o_result OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
END
GO

GRANT EXECUTE ON dbo.qutl_execute_prodidsql3 TO PUBLIC
GO