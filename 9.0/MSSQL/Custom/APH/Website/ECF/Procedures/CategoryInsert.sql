USE [APH_ECFDEV]
GO
/****** Object:  StoredProcedure [dbo].[CategoryInsert]    Script Date: 08/17/2009 17:00:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CategoryInsert]
(
	@CategoryId int = NULL output,
	@Name nvarchar(50),
	@Ordering int = 0,
	@IsVisible bit = NULL,
	@ParentCategoryId int = NULL,
	@CategoryTemplateId int = NULL,
	@TypeId int = NULL,
	@PageUrl nvarchar(255) = null,
	@ObjectLanguageId int = NULL output,
	@LanguageId int,
	@MetaClassId int = NULL,
	@ObjectGroupId int = 0,
	@Updated datetime = NULL,
	@Created datetime = NULL,
	@IsInherited bit = 0,
	@Code nvarchar(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON	
	DECLARE @Err int
BEGIN TRAN
	IF (@CategoryId is not null) AND NOT EXISTS(select null from [Category] where [CategoryId]=@CategoryId) 
	BEGIN
		SET IDENTITY_INSERT [Category] ON
		INSERT
		INTO [Category]
		(
			[CategoryId],
			[Name],
			[Ordering],
			[IsVisible],
			[ParentCategoryId],
			CategoryTemplateId,
			[MetaClassId],
			TypeId,
			PageUrl,
			Created,
			Updated,
			IsInherited,
			Code
		)
		VALUES
		(
			@CategoryId,
			@Name,
			@Ordering,
			@IsVisible,
			@ParentCategoryId,
			@CategoryTemplateId,
			@MetaClassId,
			@TypeId,
			@PageUrl,
			@Created,
			@Updated,
			@IsInherited,
			@Code
		)
		SET IDENTITY_INSERT [Category] OFF
		IF @@error != 0
			GOTO err
	END
	ELSE BEGIN
	
		INSERT
		INTO [Category]
		(
			[Name],
			[Ordering],
			[IsVisible],
			[ParentCategoryId],
			CategoryTemplateId,
			[MetaClassId],
			TypeId,
			PageUrl,
			Created,
			Updated,
			IsInherited,
			Code
		)
		VALUES
		(
			@Name,
			@Ordering,
			@IsVisible,
			@ParentCategoryId,
			@CategoryTemplateId,
			@MetaClassId,
			@TypeId,
			@PageUrl,
			@Created,
			@Updated,
			@IsInherited,
			@Code
		)
		IF @@error != 0
			GOTO err
	
		SELECT @CategoryId = SCOPE_IDENTITY()
	END
	declare @category_type as int
	set @category_type = 3
	exec ObjectLanguageInsert @ObjectLanguageId output, @CategoryId, @category_type, @LanguageId, @ObjectGroupId
	IF @@error != 0
		GOTO err
COMMIT TRAN
SET @Err = @@Error
RETURN @Err
err:
	ROLLBACK TRAN
	SET @Err = @@Error
	RETURN @Err
END