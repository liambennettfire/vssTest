if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_all_products_for_author]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_get_all_products_for_author]
GO


CREATE PROCEDURE [dbo].[qweb_ecf_get_all_products_for_author]
(
	@AuthorProductId int,
	--@CustomerId int,
	@AccessLevel int = 1,
	@ShowHidden bit = 0
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	declare @product_type as int
	set @product_type= 1

	--	SELECT 
	--		CS.[CrossSellingId],
	--		CS.[RelatedProductId] ProductId,
	--		CS.[ProductId] RelatedProductId,
	--		CS.[Ordering],
	--		P.[Name] RelatedProductName,
	--		dbo.qweb_ecf_get_sku_format(CS.ProductId) SKU_Format
	--	FROM [CrossSelling] CS 
	--	INNER JOIN [Product] P ON  P.[ProductId]=CS.[ProductId]
	--	INNER JOIN [Product] P1 ON  P1.[ProductId]=CS.[RelatedProductId]
	--	WHERE  (CS.[RelatedProductId] = @AuthorProductId) AND
	--	P.Visible = 1 and P1.Visible = 1
	--	--((P.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.ProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1) AND
	--	--((P1.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.RelatedProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1)
	--	ORDER BY CS.[Ordering]
	
	--GOT RID OF THE FUNCTION CALL 
		SELECT 
			CS.[CrossSellingId],
			CS.[RelatedProductId] ProductId,
			CS.[ProductId] RelatedProductId,
			CS.[Ordering],
			P.[Name] RelatedProductName,
			se.SKU_Format --,dbo.qweb_ecf_get_sku_format(CS.ProductId) SKU_Format
		FROM [CrossSelling] CS 
		INNER JOIN [Product] P ON  P.[ProductId]=CS.[ProductId]
		INNER JOIN [Product] P1 ON  P1.[ProductId]=CS.[RelatedProductId]
		JOIN Sku s
		ON CS.ProductId = s.ProductId
		JOIN skuex_title_by_format se
		ON s.SkuId = se.objectid
		WHERE  (CS.[RelatedProductId] = @AuthorProductId) AND
		P.Visible = 1 and P1.Visible = 1
		--((P.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.ProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1) AND
		--((P1.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.RelatedProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1)
		ORDER BY CS.[Ordering]
		SET @Err = @@Error
		RETURN @Err
END
GO
Grant execute on dbo.qweb_ecf_get_all_products_for_author to Public
GO