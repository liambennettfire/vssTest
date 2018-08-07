IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_get_all_products_for_author]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_get_all_products_for_author]
go

create PROCEDURE [dbo].[qweb_ecf_get_all_products_for_author]
(
	@AuthorProductId int,
	@CustomerId int,
	@AccessLevel int = 1,
	@ShowHidden bit = 0
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	declare @product_type as int
	set @product_type= 1

	SELECT 
		CS.[CrossSellingId],
		CS.[RelatedProductId] ProductId,
		CS.[ProductId] RelatedProductId,
		CS.[Ordering],
		P.[Name] RelatedProductName,
		dbo.qweb_ecf_get_sku_format(CS.ProductId) SKU_Format
	FROM [CrossSelling] CS 
	INNER JOIN [Product] P ON  P.[ProductId]=CS.[ProductId]
	INNER JOIN [Product] P1 ON  P1.[ProductId]=CS.[RelatedProductId]
	WHERE  (CS.[RelatedProductId] = @AuthorProductId) AND
	((P.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.ProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1) AND
	((P1.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.RelatedProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1)
	ORDER BY CS.[Ordering], P.[Name]
	SET @Err = @@Error
	RETURN @Err
END
