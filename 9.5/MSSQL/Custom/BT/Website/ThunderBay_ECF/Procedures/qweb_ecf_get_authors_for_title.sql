USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_get_authors_for_title]    Script Date: 01/27/2010 16:49:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[qweb_ecf_get_authors_for_title]
(
	@ProductId int,
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
		CS.[ProductId],
		CS.[RelatedProductId],
		CS.[Ordering],
		P1.[Name] AuthorName,
		A.[Contributor_Display_Name],
		COALESCE(datalength(A.[Contributor_About_Comment]),0) AboutAuthorLength
	FROM [CrossSelling] CS 
	INNER JOIN [Product] P ON  P.[ProductId]=CS.[ProductId]
	INNER JOIN [Product] P1 ON  P1.[ProductId]=CS.[RelatedProductId]
	INNER JOIN [ProductEx_Contributors] A ON  A.[ObjectId]=CS.[RelatedProductId]
	WHERE  (CS.[ProductId] = @ProductId) AND
	((P.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.ProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1) AND
	((P1.Visible = 1 AND [dbo].[IsObjectAccessGranted](CS.RelatedProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1) 
	ORDER BY CS.[Ordering]
	SET @Err = @@Error
	RETURN @Err
END

