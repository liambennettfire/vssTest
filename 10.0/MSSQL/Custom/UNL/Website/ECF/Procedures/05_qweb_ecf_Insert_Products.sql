/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Products]    Script Date: 04/09/2009 14:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

drop procedure [qweb_ecf_Insert_Products] 
go

create procedure [dbo].[qweb_ecf_Insert_Products] (@i_bookkey int, @v_importtype varchar(1)) as

DECLARE @i_workkey int,
		@i_titlefetchstatus int,
		@i_MetaClassID int,
		@v_title nvarchar(50),
		@d_datetime datetime,
		@d_createdate datetime,
		@pss_publishtowebind int,
		@product_id int,
		@i_template_id int,
		@i_pubtoweb_count int
		
BEGIN

			Select @i_workkey = b.workkey
			/*, @pss_publishtowebind = bd.publishtowebind*/
			from UNL..book b, UNL..bookdetail bd
			where b.bookkey = bd.bookkey
			and b.bookkey = @i_bookkey
			
			select @pss_publishtowebind=0

			select @i_pubtoweb_count = count (*) from UNL..bookdetail bd
			where publishtowebind=1
			and bookkey in (select bookkey from UNL..book where workkey=@i_workkey)

			If @i_pubtoweb_count >0 
			begin				
			 select @pss_publishtowebind=1
			end
			
			If @i_bookkey = @i_workkey and  @pss_publishtowebind=1
			begin

				Select @v_title = Substring(UNL.dbo.qweb_get_Title(@i_bookkey,'T'),1,50)
				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Titles')
				Select @d_datetime = getdate()
				Select @i_template_id = ProductTemplateID from producttemplate where name = 'Book Template'
				
				
				If not exists (Select * from product where code = cast(@i_bookkey as varchar)) 
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

			/* sending ALL primarys now and leaving on if ANY Sku is pubtoweb*/
			
			IF @pss_publishtowebind=0 
			begin

				Select @v_title = Substring(UNL.dbo.qweb_get_Title(@i_bookkey,'T'),1,50)
				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Titles')
				Select @d_datetime = getdate()
				Select @i_template_id = ProductTemplateID from producttemplate where name = 'Book Template'
				
				If exists (Select * from product where code = cast(@i_bookkey as varchar))
				begin

					Select @product_id = dbo.qweb_ecf_get_product_id(@i_bookkey)	
					Select @d_createdate = created from product where code = cast(@i_bookkey as varchar)

					exec dbo.ProductUpdate

					@product_id,			--@ProductId int,
					@v_title,				--@Name nvarchar(50),
					NULL,					--@Description ntext = NULL,
					NULL,					--@Features ntext = NULL,
					0,	                      --@Visible bit = NULL,
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
				
			end -- @i_bookkey <> @i_workkey


END


