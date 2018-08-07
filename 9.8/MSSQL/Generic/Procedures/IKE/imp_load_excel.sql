/******************************************************************************
**  Name: imp_load_excel
**  Desc: IKE load excel files to temp table
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_load_excel]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_load_excel]
GO

CREATE PROCEDURE dbo.imp_load_excel 
	@i_batch INT
	,@i_imput_file VARCHAR(500)
	,@i_tab VARCHAR(500)
	,@i_temp_table VARCHAR(500)
	,@o_errcode INT OUTPUT
	,@o_errmsg VARCHAR(1000) OUTPUT
AS
DECLARE 
	@v_sql NVARCHAR(4000)
	,@v_DropTableSql NVARCHAR(255)
	,@v_link NVARCHAR(1000)
	,@v_tempfile VARCHAR(4000)
	,@v_rowcnt INT
	,@v_squote CHAR
	,@v_RegValue VARCHAR(1000)
	,@v_OLEDB_Driver VARCHAR(1000)
	,@v_ExcelVersion VARCHAR(1000)
	,@DEBUG as int
BEGIN
	SET @DEBUG = 0
	IF @DEBUG>0 PRINT 'START dbo.imp_load_excel'
	
	IF @DEBUG>0 PRINT 'Find out what OLEDB driver (if any ) is installed on the server'
	EXEC	xp_regread 'HKEY_CLASSES_ROOT','Microsoft.ACE.OLEDB.12.0',N'',@v_RegValue OUTPUT
	IF @v_RegValue is not null BEGIN
		IF @DEBUG>0 PRINT 'FOUND ACE DRIVER - can handle 64bit + 32bit'
		SET @v_OLEDB_Driver='Microsoft.ACE.OLEDB.12.0'
	END ELSE BEGIN
		EXEC	xp_regread 'HKEY_CLASSES_ROOT','Microsoft.Jet.OLEDB.4.0',N'',@v_RegValue OUTPUT
		IF @v_RegValue is not null BEGIN
			IF @DEBUG>0 PRINT 'FOUND JET DRIVER - can handle 32bit ONLY'
			SET @v_OLEDB_Driver='Microsoft.Jet.OLEDB.4.0'
		END ELSE BEGIN
			IF @DEBUG>0 PRINT 'FOUND NO OLEDB DRIVER'
			SET @o_errcode = 100
			SET @o_errmsg ='Could not find an OLEDB Driver on this server (Microsoft.ACE.OLEDB.12.0 -OR- Microsoft.Jet.OLEDB.4.0)'
			EXECUTE imp_write_feedback @i_batch, null, null, null, null , @o_errmsg, 3, 1
			IF @DEBUG>0 PRINT @o_errmsg
			RETURN	
		END 
	END
	
	IF @DEBUG>0 PRINT 'SET @v_ExcelVersion = ''EXCEL 12.0;'''
	SET @v_ExcelVersion = 'EXCEL 8.0;'
	
	-- initalize 
	SET @v_squote = CHAR(39)
	SET @v_link = replace('ikelink' + cast(@i_batch AS VARCHAR(20)), ' ', '')
	SET @v_sql = 'EXEC sp_addlinkedserver N' + @v_squote + @v_link + @v_squote + ', '
	SET @v_sql = @v_sql + '@srvproduct = N' + @v_squote + @v_squote + ',@provider = N' + @v_squote + @v_OLEDB_Driver + @v_squote + ', '
	SET @v_sql = @v_sql + '@datasrc = N' + @v_squote + @i_imput_file + @v_squote + ', '
	SET @v_sql = @v_sql + '@provstr = N' + @v_squote + @v_ExcelVersion + @v_squote
	
	IF @DEBUG>0 PRINT @v_link
	IF @DEBUG>0 PRINT @v_OLEDB_Driver
	IF @DEBUG>0 PRINT @v_ExcelVersion
	IF @DEBUG>0 PRINT @i_temp_table
	
	IF @DEBUG>0 PRINT 'Cleanup from previous run'
	BEGIN TRY
		EXEC sp_dropserver @v_link,'droplogins'
	END TRY 
	BEGIN CATCH
		IF @DEBUG>0 PRINT 'CATCH sp_dropserver'
	END CATCH
	BEGIN TRY
		SET @v_DropTableSql= N'drop table ' + @i_temp_table
		EXEC sp_executesql @v_DropTableSql
	END TRY
	BEGIN CATCH
		IF @DEBUG>0 PRINT 'CATCH drop table '
	END CATCH
	
	IF @DEBUG>0 PRINT 'import excel into @v_link table'
	IF @DEBUG>0 PRINT @v_sql
	IF @DEBUG>0 PRINT 'EXEC sp_addlinkedsrvlogin ' + @v_link + ',''false'''

	EXEC sp_executesql @v_sql
	EXEC sp_addlinkedsrvlogin @v_link,'false'
	
	SET @v_sql = 'SELECT * into ' + @i_temp_table + ' FROM OPENQUERY(' + @v_link + ', ' + @v_squote + 'select * from [' + @i_tab + ']' + @v_squote + ')'
	IF @DEBUG>0 PRINT @v_sql
	IF @DEBUG>0 PRINT 'EXEC sp_dropserver ' + @v_link + ',''droplogins'''

	EXEC sp_executesql @v_sql
	EXEC sp_dropserver @v_link,'droplogins'
		
	IF @DEBUG>0 PRINT 'END dbo.imp_load_excel'
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.imp_load_excel
	TO PUBLIC
GO

