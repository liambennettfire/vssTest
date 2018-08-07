SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: sp_XMLNodeValue_GET
**  Desc: IKE return value from XML node
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/


IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[sp_XMLNodeValue_GET]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[sp_XMLNodeValue_GET]
GO

CREATE PROCEDURE dbo.sp_XMLNodeValue_GET (
	@TableName VARCHAR(256)
	,@FieldName VARCHAR(256)
	,@WhereClause VARCHAR(256)
	,@XMLNodeName VARCHAR(256)
	,@XMLNodeValue VARCHAR(256) OUTPUT
	,@Error INT = NULL OUTPUT
	,@ErrorMSG VARCHAR(256) = NULL OUTPUT
	)
AS
BEGIN
	DECLARE @XML XML
	DECLARE @NEW_XML_NODE XML
	DECLARE @iCount INT
	DECLARE @szXML VARCHAR(MAX);
	DECLARE @szSQL NVARCHAR(500);
	DECLARE @szParmDefinition NVARCHAR(500);

	--Validations
	IF @TableName IS NULL SET @ErrorMSG = COALESCE(@ErrorMSG + ', ', '') + '@TableName can not be NULL'
	IF @FieldName IS NULL SET @ErrorMSG = COALESCE(@ErrorMSG + ', ', '') + '@FieldName can not be NULL'
	IF @XMLNodeName IS NULL SET @ErrorMSG = COALESCE(@ErrorMSG + ', ', '') + '@XMLNodeName can not be NULL'

	IF @ErrorMSG IS NOT NULL
	BEGIN
		SET @Error = 1
		RETURN
	END

	SET @szSQL = N'SELECT @iCountOUT=COUNT(*) FROM ' + @TableName + ' ' + COALESCE(@WhereClause, '');
	SET @szParmDefinition = N'@iCountOUT INT OUTPUT';

	EXEC sp_executesql @szSQL
		,@szParmDefinition
		,@iCountOUT = @iCOUNT OUTPUT;

	IF @iCount = 0
	BEGIN
		SET @Error = 2
		SET @ErrorMSG = 'Record Not Found: ' + replace(@szSQL, '@iCountOUT=COUNT(*)', '*')
		RETURN
	END

	--MAIN CODE
	SET @NEW_XML_NODE = '<' + @XMLNodeName + '>' + @XMLNodeValue + '</' + @XMLNodeName + '>'
	SET @szSQL = N'SELECT @XMLOUT = ' + @FieldName + ' FROM ' + @TableName + ' ' + COALESCE(@WhereClause, '');
	SET @szParmDefinition = N'@XMLOUT XML OUTPUT';

	EXEC sp_executesql @szSQL
		,@szParmDefinition
		,@XMLOUT = @XML OUTPUT;
	
	SET @XMLNodeValue = @XML.value('(/root//*[local-name()=sql:variable("@XMLNodeName")]/node())[1]', 'nvarchar(max)') 
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[sp_XMLNodeValue_GET]
	TO PUBLIC
GO


