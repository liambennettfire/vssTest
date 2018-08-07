IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.verificationcolumn_check') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.verificationcolumn_check
END
GO

CREATE  PROCEDURE dbo.verificationcolumn_check 
                     @i_tablename varchar(100),
                     @i_clumnname varchar(50), 
				             @i_write_msg  int output
AS
BEGIN
DECLARE
@v_sql_stmt  NVARCHAR(500)


set @v_sql_stmt = N'select @p_value = count(*)
                from ' + @i_tablename + 
               ' where columnname = ' + char(39) + @i_clumnname + char(39) +
               ' and activeind = 1'

EXECUTE sp_executesql @v_sql_stmt,  N'@p_value VARCHAR(50) OUTPUT', @i_write_msg OUTPUT

END

