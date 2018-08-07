IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_metadataid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_metadataid]
GO

CREATE FUNCTION [dbo].[qcs_get_metadataid](@bookkey int)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @metadataId uniqueidentifier
	DECLARE @productidcode INT
	SET @metadataId = NULL
	SELECT @productidcode=datacode FROM gentables WHERE tableid=551 /*ProductIdType*/ AND qsicode=8 /*GUID*/
	
	SELECT TOP 1
		@metadataId = CAST(n.productnumber AS uniqueidentifier)
	FROM
		taqprojectelement AS e,
		taqproductnumbers AS n,
		gentables AS g
	WHERE
		e.bookkey = @bookkey AND
		e.taqelementkey = n.elementkey AND
		n.productidcode = @productidcode AND
		e.taqelementtypecode = g.datacode AND
		g.qsicode = 3 AND
		g.tableid = 287 -- ElementType
		
	RETURN @metadataId
END
GO

GRANT EXEC ON dbo.qcs_get_metadataid TO PUBLIC
GO