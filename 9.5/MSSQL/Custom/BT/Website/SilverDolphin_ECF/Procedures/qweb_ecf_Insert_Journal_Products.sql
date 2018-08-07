USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Journal_Products]    Script Date: 01/27/2010 16:24:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_Insert_Journal_Products] (@i_bookkey int, @v_importtype varchar(1)) as

DECLARE @i_workkey int,
		@i_titlefetchstatus int,
		@i_MetaClassID int,
		@v_title nvarchar(50),
		@d_datetime datetime,
		@d_createdate datetime,
		@pss_publishtowebind int,
		@product_id int,
		@i_template_id int
		
BEGIN

			Select @i_workkey = b.workkey,
				   @pss_publishtowebind = bd.publishtowebind
			from TAMU..book b, TAMU..bookdetail bd
			where b.bookkey = bd.bookkey
			and b.bookkey = @i_bookkey

			If @i_bookkey = @i_workkey
			begin

				Select @v_title = Substring(TAMU.dbo.qweb_get_Title(@i_bookkey,'f'),1,50)
				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Journals')
				Select @d_datetime = getdate()
				Select @i_template_id = ProductTemplateID from producttemplate where name = 'Journal Template'
				

				If not exists (Select * from product where code = CAST(@i_bookkey as varchar)) and @pss_publishtowebind = 1
				begin
					exec dbo.ProductInsert
					NULL,					--@ProductId
					@v_title,				--@Name
					@pss_publishtowebind,	--@Visible
					@i_template_id,			--@ProductTemplateId  --using book template for now
					@i_MetaClassID,			--@MetaClassId
					@d_datetime,			--@Updated
					@d_datetime,			--@Created
					1,						--@ObjectLanguageId
					1,						--@LanguageId
					0,						--@ObjectGroupId
					0,						--@IsInherited
					@i_bookkey				--@Code (bookkey)
				end

				If exists (Select * from product where code = cast(@i_bookkey as varchar))
				begin

					Select @product_id = dbo.qweb_ecf_get_product_id(@i_bookkey)	
					Select @d_createdate = created from product where code = cast(@i_bookkey as varchar)

					exec dbo.ProductUpdate

					@product_id,			--@ProductId int,
					@v_title,				--@Name nvarchar(50),
					NULL,					--@Description ntext = NULL,
					NULL,					--@Features ntext = NULL,
					@pss_publishtowebind,	--@Visible bit = NULL,
					@i_template_id,			--@ProductTemplateId int = NULL,
					@i_MetaClassID,		    --@MetaClassId int = NULL,
					@d_datetime,			--@Updated datetime = NULL,	
					@d_createdate,			--@Created datetime = NULL,
					1,						--@ObjectLanguageId int = NULL,
					1,						--@LanguageId int,
					0,						--@ObjectGroupId int = 0,
					0,						--@IsInherited bit = 0,
					@i_bookkey				--@Code nvarchar(50) = NULL
				end
				
			end -- @i_bookkey = @i_workkey


END




