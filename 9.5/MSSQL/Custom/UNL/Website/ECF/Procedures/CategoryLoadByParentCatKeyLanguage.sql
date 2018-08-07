if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CategoryLoadByParentCatKeyLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CategoryLoadByParentCatKeyLanguage]
GO


CREATE PROCEDURE [dbo].[CategoryLoadByParentCatKeyLanguage]
(
	@ParentCategoryId int,
	@LanguageId int,
	@CustomerId int,
	@AccessLevel int,
	@ShowHidden bit = 0
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	declare @category_type as int
	set @category_type= 3
	
	if(@ParentCategoryId is null)
	begin
		SELECT C.*, OL.*
		FROM Category C LEFT OUTER JOIN ObjectLanguage OL ON C.CategoryId = OL.ObjectId and OL.ObjectTypeId = @category_type
		WHERE
			(OL.LanguageId = @LanguageId or OL.LanguageId is null or @LanguageId = 0 or @LanguageId is null)
		AND ((IsVisible = 1 
		--AND [dbo].[IsObjectAccessGranted](C.CategoryId, @category_type, @CustomerId, @AccessLevel) = 1
		) or @ShowHidden = 1)
		ORDER BY Ordering
	end
	else
	begin
		SELECT C.*, OL.*
		FROM Category C LEFT OUTER JOIN ObjectLanguage OL ON C.CategoryId = OL.ObjectId and OL.ObjectTypeId = @category_type
		WHERE
			([ParentCategoryId] = @ParentCategoryId) and (OL.LanguageId = @LanguageId or OL.LanguageId is null or @LanguageId = 0 or @LanguageId is null)
		AND ((IsVisible = 1 
		--AND [dbo].[IsObjectAccessGranted](C.CategoryId, @category_type, @CustomerId, @AccessLevel) = 1
		) or @ShowHidden = 1)
		ORDER BY Ordering
	end
	SET @Err = @@Error
	RETURN @Err
END
GO
Grant execute on dbo.CategoryLoadByParentCatKeyLanguage to Public
GO
