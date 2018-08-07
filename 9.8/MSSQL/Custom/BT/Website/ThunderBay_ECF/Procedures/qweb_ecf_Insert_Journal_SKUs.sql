USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Journal_SKUs]    Script Date: 01/27/2010 16:50:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_Insert_Journal_SKUs] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_MetaClassID int,
		@i_parent_productid int,
		@v_title nvarchar(100),
		@d_datetime datetime,
		@m_usretailprice money,
		@i_skuid int,
		@i_publishtowebind int,
		@v_pricetype varchar(40),
		@i_titlefetchstatus int,
		@v_pss_sku_code varchar(50),
		@i_taxcategoryid int,
		@i_packageid int

BEGIN

		Select @i_publishtowebind = bd.publishtowebind
		from BT..book b, BT..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey

		Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Journal_by_PriceType')
		Select @d_datetime = getdate()
		Select @i_parent_productid = dbo.qweb_ecf_get_product_id(@i_bookkey)
		--Select @i_skuid = dbo.qweb_ecf_get_sku_id (@i_bookkey)


------------------------------------------------------
-------  START JOURNAL PRICE TYPE CURSOR -------------
------------------------------------------------------

	DECLARE c_qweb_journalpricetypes INSENSITIVE CURSOR
	FOR

	Select bookkey, finalprice, BT.dbo.get_gentables_desc(306, pricetypecode, 'D') as pricetype, Cast(bookkey as varchar) + '-' + CAST(pricetypecode as varchar) + '-' + CAST(currencytypecode as varchar) as pss_sku_code
	from BT..bookprice
	where bookkey = @i_bookkey
    and pricetypecode in (13,14,16,17,18,23,24,25,26,27)
	order by pricetypecode
	

	FOR READ ONLY
			
	OPEN c_qweb_journalpricetypes 

	FETCH NEXT FROM c_qweb_journalpricetypes 
		INTO @i_bookkey, @m_usretailprice, @v_pricetype, @v_pss_sku_code

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin
		
		
		Select @v_title = BT.dbo.qweb_get_Title(@i_bookkey,'f') + ' (' + @v_pricetype + ')'
		Select @i_skuid = skuid from sku where name = @v_title 
		--and price = @m_usretailprice

		If not exists (Select * from SKU where name = @v_title) 
		--and price = @m_usretailprice)
		
		Begin
		
		print 'insert this'
		print 'title'
		print @v_title
		print 'price'
		print @m_usretailprice

		       
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
				@v_pss_sku_code,	    --@Code nvarchar(50) = NULL,
				0,					--@Weight float = NULL,
				8,					    --@PackageId int = NULL,
				1,						--@ShipEnabled bit = NULL,
				1,						--@SkuTemplateId int = NULL,
				@d_datetime,			--@Updated datetime = NULL,	
				@d_datetime,			--@ALTERd datetime = NULL,
				99999,					--@ReorderMinQty int = NULL,
				99999,					--@StockQty int = NULL,
				0,					    --@ReservedQty int = NULL,
				1,						--@OutOfStockVisible bit = NULL,
				NULL,					--@SNPackageId int = NULL,
				1,						--@ObjectLanguageId int = NULL,
				1,						--@LanguageId int,
				0,						--@ObjectGroupId int = 0,
				0,						--@CycleMode int,
				0,						--@CycleLength int,
				0,						--@MaxCyclesCount int,
				NULL,					--@WarehouseId int = null,
				0						--@Ordering int = 0       

		end

		Else	
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
				@v_pss_sku_code,	    --@Code nvarchar(50) = NULL,
				0,					--@Weight float = NULL,
				@i_packageid,		    --@PackageId int = NULL,
				1,						--@ShipEnabled bit = NULL,
				1,						--@SkuTemplateId int = NULL,
				@d_datetime,			--@Updated datetime = NULL,	
				@d_datetime,			--@ALTERd datetime = NULL,
				99999,					--@ReorderMinQty int = NULL,
				99999,					--@StockQty int = NULL,
				0,					    --@ReservedQty int = NULL,
				1,						--@OutOfStockVisible bit = NULL,
				NULL,					--@SNPackageId int = NULL,
				1,						--@ObjectLanguageId int = NULL,
				1,						--@LanguageId int,
				0,						--@ObjectGroupId int = 0,
				0,						--@CycleMode int,
				0,						--@CycleLength int,
				0,						--@MaxCyclesCount int,
				NULL,					--@WarehouseId int = null,
				0						--@Ordering int = 0       
		end

		end
	FETCH NEXT FROM c_qweb_journalpricetypes
		INTO @i_bookkey, @m_usretailprice, @v_pricetype, @v_pss_sku_code
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end


close c_qweb_journalpricetypes
deallocate c_qweb_journalpricetypes


END




