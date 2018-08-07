set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go







ALTER PROCEDURE [dbo].[ProductLoadByCategoryKey]
(
	@CategoryId int,
	@CustomerId int,
	@AccessLevel int = 1,
	@ShowHidden bit = 0,
	@sort nvarchar(50) = N'ProductId'
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	declare @product_type as int
	set @product_type= 1
	declare @stmt nvarchar(4000)
	if(@CategoryId = 0)
	begin
		SET @stmt=

		N'SELECT  P.ProductId, P.Name, P.Visible, P.ProductTemplateId, P.MetaClassId, P.Updated, P.Created, P.IsInherited, P.Code, NULL as SerializedData, OL.* '+
		N'FROM Product P LEFT OUTER JOIN Categorization C ON C.ObjectId = P.ProductId and C.ObjectTypeId = '+CAST(@product_type as nvarchar(20))+
		N'LEFT OUTER JOIN ObjectLanguage OL ON P.ProductId = OL.ObjectId and OL.ObjectTypeId = '+CAST(@product_type as nvarchar(20))+
		N' WHERE (OL.ObjectTypeId ='+ CAST(@product_type as nvarchar(20))+N') AND (C.CategoryId is NULL) AND '+
			N'((Visible = 1 and [dbo].[IsObjectAccessGranted](P.ProductId, '+CAST(@product_type as nvarchar(20))+N', '+CAST(@CustomerId as nvarchar(20))+N', '+CAST(@AccessLevel as nvarchar(20))+N') = 1) or '+CAST(@ShowHidden as nvarchar(20))+N' = 1) '+
		N' ORDER BY '+@sort
	end
	else
	begin
		SET @stmt=
		N'SELECT  P.ProductId, P.Name, P.Visible, P.ProductTemplateId, P.MetaClassId, P.Updated, P.Created, P.IsInherited, P.Code,  NULL as SerializedData,  OL.* '+
		N'FROM Product P LEFT OUTER JOIN Categorization C ON C.ObjectId = P.ProductId and C.ObjectTypeId = '+CAST(@product_type as nvarchar(20))+
		N'LEFT OUTER JOIN ObjectLanguage OL ON P.ProductId = OL.ObjectId and OL.ObjectTypeId = '+CAST(@product_type as nvarchar(20))+
		N' WHERE     (OL.ObjectTypeId ='+ CAST(@product_type as nvarchar(20))+N') AND (C.CategoryId = ' + CAST(@CategoryId as nvarchar(20))+N') AND '+
			N'((Visible = 1 and [dbo].[IsObjectAccessGranted](P.ProductId,' +CAST(@product_type as nvarchar(20))+N','+ CAST(@CustomerId as nvarchar(20))+N','+ CAST(@AccessLevel as nvarchar(20))+N') = 1) or '+CAST(@ShowHidden as nvarchar(20))+N' = 1) '+
		N' ORDER BY '+@sort
		--PRINT @stmt
	end
	exec (@stmt)
	SET @Err = @@Error
	RETURN @Err
END


