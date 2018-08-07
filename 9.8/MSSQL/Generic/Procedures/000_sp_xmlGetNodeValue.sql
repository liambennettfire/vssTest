if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_xmlGetNodeValue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_xmlGetNodeValue]
GO

SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE  [dbo].[sp_xmlGetNodeValue] (
	@xmlDoc XML
	,@nvcDoc NVARCHAR(MAX)
	,@vcDocFullPath VARCHAR(MAX)
	,@vcRootNode VARCHAR(MAX)
	,@vcXPath VARCHAR(MAX)
	,@nvcRetVal NVARCHAR(MAX) OUTPUT
	,@vcErrMsg VARCHAR(MAX) OUTPUT
	,@iError INT OUTPUT
	)
AS

BEGIN
	DECLARE @DEBUG AS INT
		,@xmlInput XML
		,@SQL NVARCHAR(MAX)
		,@ParmDef NVARCHAR(MAX)

	SET @nvcRetVal=NULL
	SET @vcErrMsg=''
	SET @iError=0
	SET @DEBUG=0

	IF @DEBUG <> 0 PRINT 'START> sp_xmlGetNodeValue'

	IF @vcXPath IS NULL 
	BEGIN
		SET @vcErrMsg = 'INPUT PARAM "@vcXPath" CAN NOT BE NULL'
		SET @iError=1
		GOTO ERRTRAP
	END 

	IF @vcRootNode IS NULL 
	BEGIN
		SET @vcErrMsg = 'INPUT PARAM "@vcRootNode" CAN NOT BE NULL'
		SET @iError=1
		GOTO ERRTRAP
	END 

	IF @xmlDoc IS NOT NULL SET @xmlInput=@xmlDoc
	IF @nvcDoc IS NOT NULL AND @xmlInput IS NULL SET @xmlInput=CAST(@nvcDoc AS XML)
	IF @vcDocFullPath IS NOT NULL AND @xmlInput IS NULL 
	BEGIN
		BEGIN TRY
			--OPEN FILE FROM DRIVE
			SET @ParmDef=N'@o_xml xml OUTPUT'
			SET @SQL=N'SET @o_xml = (
					SELECT CONVERT(XML, BULKCOLUMN, 2)
					FROM OPENROWSET(BULK '''+@vcDocFullPath+''', SINGLE_BLOB) AS MYDOC
					)'	

			IF @DEBUG <> 0 PRINT @ParmDef
			IF @DEBUG <> 0 PRINT @SQL

			EXEC sp_executesql @SQL, @ParmDef,@o_xml = @xmlInput OUTPUT

			IF @DEBUG <> 0 SELECT @xmlInput
		END TRY
		BEGIN CATCH
			SET @nvcRetVal=NULL
			SET @vcErrMsg=ERROR_MESSAGE()
			SET @iError=ERROR_NUMBER()
			IF @DEBUG <> 0 PRINT 'IN CATCH (1)'
			GOTO ERRTRAP
		END CATCH
	END

	IF @xmlInput IS NULL 
	BEGIN
		SET @nvcRetVal=NULL
		SET @vcErrMsg = 'NO SOURCE HAS BEEN SPECIFIED'
		SET @iError=1
		GOTO ERRTRAP
	END 

	--All Prams have been validated ... now get the node value

	SET @ParmDef=N'@i_xml xml , @o_RetVal nvarchar(max) OUTPUT'
	SET @SQL=N'SELECT @o_RetVal=T.c.value('''+@vcXPath+''', ''nvarchar(max)'') FROM @i_xml.nodes('''+@vcRootNode+''') AS T(c)'	

	IF @DEBUG <> 0 PRINT @ParmDef
	IF @DEBUG <> 0 PRINT @SQL

	EXEC sp_executesql @SQL, @ParmDef,@i_xml=@xmlInput, @o_RetVal = @nvcRetVal OUTPUT

	IF @DEBUG <> 0 PRINT @nvcRetVal

	FINISH:
		IF @DEBUG <> 0 PRINT 'END> sp_xmlGetNodeValue'
		RETURN 
	ERRTRAP:
		SET @vcErrMsg='ERROR: ' + @vcErrMsg
		IF @DEBUG <> 0 PRINT @vcErrMsg
		GOTO FINISH		
END
go

grant execute on dbo.sp_xmlGetNodeValue to public
GO


