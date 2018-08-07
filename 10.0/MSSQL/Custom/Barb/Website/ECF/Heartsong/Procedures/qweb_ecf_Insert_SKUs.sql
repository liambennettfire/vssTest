IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_SKUs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_SKUs]
go

CREATE procedure [dbo].[qweb_ecf_Insert_SKUs] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_workkey int,
		@i_MetaClassID int,
		@i_parent_productid int,
		@v_title nvarchar(100),
		@d_datetime datetime,
		@m_usretailprice money,
		@i_skuid int,
		@i_publishtowebind int,
		@i_taxcategoryid int,
		@i_packageid int,
		@i_stockqty int,
  	@i_parent_productid_old int



BEGIN

		Select @i_workkey = b.workkey,
			   @i_publishtowebind = bd.publishtowebind
		from barb..book b, barb..bookdetail bd
		where b.bookkey = bd.bookkey
		and bd.mediatypecode <> 6
		and b.bookkey = @i_bookkey


				Select @v_title = '('+ barb.dbo.qweb_get_ISBN(@i_bookkey,'16') + ') ' + Substring (barb.dbo.qweb_get_Title				(@i_bookkey,'f'),1,84)

				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Title_By_Format')
				Select @d_datetime = getdate()
				Select @i_parent_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				--Select @m_usretailprice = barb.dbo.qweb_get_BestUSPrice(@i_bookkey,8)

				If exists (Select * 
						   from barb..bookprice 
						   where (finalprice is not null 
                             			   and pricetypecode in (10) and activeind = 1)
						   and bookkey=@i_bookkey)

					begin							 
					Select @m_usretailprice = barb.dbo.qweb_get_BestUSPrice(@i_bookkey,10)
					end
				Else
					begin
					Select @m_usretailprice = barb.dbo.qweb_get_BestUSPrice(@i_bookkey,8)
					end

				Select @i_skuid = dbo.qweb_ecf_get_sku_id (@i_bookkey)
				
--				If exists (Select * 
--						   from barb..bookdetail 
--						   where (bisacstatuscode not in (1,5,3))
-- 					       and bookkey=@i_bookkey)
--					begin
--						Select @i_stockqty = 0
--					end
--				Else
--					begin
					 Select @i_stockqty = 99999
--					end
				
		
		If @i_skuid is null and @i_publishtowebind = 1
		Begin
	
				exec dbo.SKUInsert 
				@i_skuid,				--@SkuId int = NULL output,
				@v_title,				--@Name nvarchar(100),
				null,					--@Description ntext = NULL,
				@m_usretailprice,		--@Price money = NULL,
				@i_publishtowebind,		--@Visible bit = NULL,
				@i_parent_productid,	--@ProductId int = NULL,
				@i_MetaClassID,			--@MetaClassId int = NULL,
				NULL,					--@CurrencyId nchar(3) = NULL,
				2,					    --@TaxCategoryId int = NULL,
				1,						--@SkuType int = NULL,
				NULL,					--@LicenseAgreementId int = NULL,
				@i_bookkey,				--@Code nvarchar(50) = NULL,
				1,					--@Weight float = NULL,
				7,					--@PackageId int = NULL,
				1,						--@ShipEnabled bit = NULL,
				1,						--@SkuTemplateId int = NULL,
				@d_datetime,			--@Updated datetime = NULL,	
				@d_datetime,			--@Created datetime = NULL,
				99999,					--@ReorderMinQty int = NULL,
				@i_stockqty,					--@StockQty int = NULL,
				0,					    --@ReservedQty int = NULL,
				1,						--@OutOfStockVisible bit = NULL,
				NULL,					--@SNPackageId int = NULL,
				1,						--@ObjectLanguageId int = NULL,
				1,						--@LanguageId int,
				0,						--@ObjectGroupId int = 0,
				0,						--@CycleMode int,
				0,						--@CycleLength int,
				0,						--@MaxCyclesCount int,
				NULL,						--@WarehouseId int = null,
				0						--@Ordering int = 0       
		end

		If @i_skuid is not null
		Begin

		Select @i_taxcategoryid =TaxCategoryId from sku where skuid = @i_skuid
		Select @i_packageid = PackageId from sku where skuid = @i_skuid



				exec dbo.SKUUpdate
				@i_skuid,				--@SkuId int = NULL output,
				@v_title,				--@Name nvarchar(100),
				null,					--@Description ntext = NULL,
				@m_usretailprice,		--@Price money = NULL,
				@i_publishtowebind,		--@Visible bit = NULL,
				@i_parent_productid,	--@ProductId int = NULL,
				@i_MetaClassID,			--@MetaClassId int = NULL,
				NULL,					--@CurrencyId nchar(3) = NULL,
				@i_taxcategoryid,		--@TaxCategoryId int = NULL,
				1,						--@SkuType int = NULL,
				NULL,					--@LicenseAgreementId int = NULL,
				@i_bookkey,				--@Code nvarchar(50) = NULL,
				1,					--@Weight float = NULL,
				@i_packageid,			--@PackageId int = NULL,
				1,						--@ShipEnabled bit = NULL,
				1,						--@SkuTemplateId int = NULL,
				@d_datetime,			--@Updated datetime = NULL,	
				@d_datetime,			--@Created datetime = NULL,
				99999,					--@ReorderMinQty int = NULL,
				@i_stockqty,					--@StockQty int = NULL,
				0,					    --@ReservedQty int = NULL,
				1,						--@OutOfStockVisible bit = NULL,
				NULL,					--@SNPackageId int = NULL,
				1,						--@ObjectLanguageId int = NULL,
				1,						--@LanguageId int,
				0,						--@ObjectGroupId int = 0,
				0,						--@CycleMode int,
				0,						--@CycleLength int,
				0,						--@MaxCyclesCount int,
				NULL,						--@WarehouseId int = null,
				0						--@Ordering int = 0      
				
        -- if this sku already existed in the system as a primary title
        -- and it is now a subordinate title (bookkey <> workkey), then remove the 
        -- product record				
        if (@i_bookkey <> @i_workkey) begin
				  Select @i_parent_productid_old = dbo.qweb_ecf_get_product_id(@i_bookkey)
				  
				  if @i_parent_productid_old <> @i_parent_productid begin
				    print 'Removing Productid ' + cast(@i_parent_productid_old as varchar)
				    print 'With Bookkey ' + cast(@i_bookkey as varchar)
				    exec dbo.mdpsp_avto_ProductEx_Titles_Delete @i_parent_productid_old
				    exec dbo.ProductDelete @i_parent_productid_old
				  end
				end
				 
		end

END


