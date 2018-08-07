IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_assetkey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_assetkey]
GO

CREATE FUNCTION [dbo].[qcs_get_assetkey](@bookkey int, @assetId uniqueidentifier)
RETURNS int
AS
BEGIN
	DECLARE @productidcode INT
	DECLARE @assetKey INT
	
	SET @assetKey = NULL
	SELECT @productidcode=datacode FROM gentables WHERE tableid=551 /*ProductIdType*/ AND qsicode=8 /*GUID*/
	
	SELECT TOP 1
		@assetKey = n.elementkey
	FROM
		taqprojectelement AS e,
		taqproductnumbers AS n
	WHERE
		e.bookkey = @bookkey AND
		e.taqelementkey = n.elementkey AND
		n.productidcode = @productidcode AND
		CAST(n.productnumber AS uniqueidentifier) = @assetId

	RETURN @assetKey
END
GO

GRANT EXEC ON dbo.qcs_get_assetkey TO PUBLIC
GO
