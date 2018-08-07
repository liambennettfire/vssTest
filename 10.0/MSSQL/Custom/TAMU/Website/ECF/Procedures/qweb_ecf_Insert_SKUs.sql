set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER procedure [dbo].[qweb_ecf_Insert_SKUs] (@i_bookkey int, @v_importtype varchar(1)) as
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
		@i_bookweight float


BEGIN

		Select @i_workkey = b.workkey,
			   @i_publishtowebind = bd.publishtowebind
		from TAMU..book b, TAMU..bookdetail bd
		where b.bookkey = bd.bookkey
		and bd.mediatypecode <> 6
		and b.bookkey = @i_bookkey


				Select @v_title = '('+ TAMU.dbo.qweb_get_ISBN(@i_bookkey,'16') + ') ' /*+ Substring (TAMU.dbo.qweb_get_Title(@i_bookkey,'f'),1,84)*/ + ' - '+TAMU.dbo.qweb_get_Format(@i_bookkey,'2')

				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Title_By_Format')
				Select @d_datetime = getdate()
				Select @i_parent_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				--Select @m_usretailprice = TAMU.dbo.qweb_get_BestUSPrice(@i_bookkey,8)
				select @i_bookweight = coalesce(bookweight,1) from tamu.dbo.printing where bookkey=@i_bookkey
				

				If exists (Select * 
						   from TAMU..bookprice 
						   where (finalprice is not null 
                             			   and pricetypecode in (10) and activeind = 1)
						   and bookkey=@i_bookkey)

					begin							 
					Select @m_usretailprice = TAMU.dbo.qweb_get_BestUSPrice(@i_bookkey,10)
					end
				Else
					begin
					Select @m_usretailprice = TAMU.dbo.qweb_get_BestUSPrice(@i_bookkey,8)
					end

				Select @i_skuid = dbo.qweb_ecf_get_sku_id (@i_bookkey)
				
				If exists (Select * 
						   from TAMU..bookdetail 
						   where (bisacstatuscode not in (1,5,3,10))
 					       and bookkey=@i_bookkey)
					begin
						Select @i_stockqty = 0
					end
				Else
					begin
					 Select @i_stockqty = 99999
					end
				
		
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
				@i_bookweight,			--@Weight float = NULL,
				1,						--@PackageId int = NULL,
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
				2,						--@WarehouseId int = null,
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
				@i_bookweight,					--@Weight float = NULL,
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
				2,						--@WarehouseId int = null,
				0						--@Ordering int = 0       
		end

END


