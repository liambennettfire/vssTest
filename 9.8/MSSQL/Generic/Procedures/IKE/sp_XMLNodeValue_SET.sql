SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: sp_XMLNodeValue_SET
**  Desc: IKE set node value in XML 
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
		WHERE id = object_id(N'[dbo].[sp_XMLNodeValue_SET]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[sp_XMLNodeValue_SET]
GO

CREATE PROCEDURE dbo.sp_XMLNodeValue_SET (
	@TableName VARCHAR(256)
	,@FieldName VARCHAR(256)
	,@WhereClause VARCHAR(256)
	,@XMLNodeName VARCHAR(256)
	,@XMLNodeValue VARCHAR(256)
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

	SET @szXML = CAST(@XML AS VARCHAR(MAX))
	IF LEN(COALESCE(@szXML,'')) = 0 SET @XML = '<root />'

	IF @NEW_XML_NODE IS NULL
	BEGIN
		--A NULL NODE VALUE WILL REMOVE THE NODE
		SET @XML.modify('delete (/root/*[local-name()=sql:variable("@XMLNodeName")])')
	END
	ELSE
	BEGIN
		--A NON-NULL NODE VALUE WILL INSERT/UPDATE THE NODE
		IF CHARINDEX('<' + @XMLNodeName + '>', @szXML, 1) > 0
		BEGIN
			--UPDATE
			SET @XML.modify('delete (/root/*[local-name()=sql:variable("@XMLNodeName")])')
			SET @XML.modify('insert sql:variable("@NEW_XML_NODE") as first into /root[1]')
		END
		ELSE
		BEGIN
			--INSERT
			SET @XML.modify('insert sql:variable("@NEW_XML_NODE") as first into /root[1]')
		END
	END
	SET @szXML = CAST(@XML AS VARCHAR(MAX))
	SET @szSQL = N'UPDATE ' + @TableName + ' SET ' + @FieldName + ' = ''' + @szXML + ''' ' + COALESCE(@WhereClause, '');
	EXEC sp_executesql @szSQL
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[sp_XMLNodeValue_SET]
	TO PUBLIC
GO


