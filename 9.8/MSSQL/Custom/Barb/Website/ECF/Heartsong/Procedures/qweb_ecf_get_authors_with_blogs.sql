IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_get_authors_with_blogs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_get_authors_with_blogs]
go

create PROCEDURE [dbo].[qweb_ecf_get_authors_with_blogs]
(
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
		P.[ProductId],
		P.[Name] AuthorName,
		A.[Contributor_Blog],
		A.[Contributor_Display_Name]
	FROM [Product] P 
	INNER JOIN [ProductEx_Contributors] A ON  A.[ObjectId]=P.[ProductId]
	WHERE  (COALESCE(A.[Contributor_Blog],'') != '') AND
	((P.Visible = 1 AND [dbo].[IsObjectAccessGranted](P.ProductId, @product_type, @CustomerId, @AccessLevel) = 1) or @ShowHidden = 1)
	ORDER BY A.[Contributor_Sort_Order], A.[Contributor_Last_Name]
	SET @Err = @@Error
	RETURN @Err
END
