if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CategoryLoadAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CategoryLoadAll]
GO


CREATE PROCEDURE [dbo].[CategoryLoadAll]
	@CustomerId as int,
	@AccessLevel as int = 1,
	@ShowHidden bit = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	declare @category_type as int
	set @category_type= 3
	SELECT C.*, OL.* 
	FROM Category C LEFT OUTER JOIN ObjectLanguage OL ON C.CategoryId = OL.ObjectId and OL.ObjectTypeId = @category_type
	WHERE (IsVisible = 1 
	--AND [dbo].[IsObjectAccessGranted](C.CategoryId, @category_type, @CustomerId, @AccessLevel) = 1
	) or @ShowHidden = 1
	ORDER BY Ordering
	SET @Err = @@Error
	RETURN @Err
END
GO
Grant execute on dbo.CategoryLoadAll to Public
GO
