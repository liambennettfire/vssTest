IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_assetid]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_assetid]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_assetid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_assetid]
GO

CREATE FUNCTION [dbo].[qcs_get_assetid](@bookkey int, @assetTypeTag varchar(25))
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @productidcode INT
	DECLARE @assetId uniqueidentifier
	
	SET @assetId = NULL
	SELECT @productidcode=datacode FROM gentables WHERE tableid=551 /*ProductIdType*/ AND qsicode=8 /*GUID*/
	
	SELECT TOP 1
		@assetId = CAST(n.productnumber AS uniqueidentifier)
	FROM
		taqprojectelement AS e,
		taqproductnumbers AS n,
		gentables AS g
	WHERE
		e.bookkey = @bookkey AND
		e.taqelementkey = n.elementkey AND
		n.productidcode = @productidcode AND
		e.taqelementtypecode = g.datacode AND
		g.eloquencefieldtag = @assetTypeTag AND
		g.tableid = 287 -- ElementType

	RETURN @assetId
END
GO

GRANT EXEC ON dbo.qcs_get_assetid TO PUBLIC
GO
