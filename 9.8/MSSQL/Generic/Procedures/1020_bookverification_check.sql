IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.bookverification_check') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.bookverification_check
END
GO

CREATE  PROCEDURE dbo.bookverification_check @i_clumnname varchar(50), 
				             @i_write_msg  int output
AS
BEGIN
DECLARE
@v_sql_stmt  NVARCHAR(500)


set @v_sql_stmt = N'select @p_value = count(*)
                from bookverificationcolumns
                where columnname = ' + char(39) + @i_clumnname + char(39) +
               ' and activeind = 1'

EXECUTE sp_executesql @v_sql_stmt,  N'@p_value VARCHAR(50) OUTPUT', @i_write_msg OUTPUT

END

