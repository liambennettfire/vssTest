if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Insert_Journal_SKUs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Insert_Journal_SKUs]

GO


CREATE procedure [dbo].[qweb_ecf_Insert_Journal_SKUs] (@i_bookkey int, @v_importtype varchar(1)) as
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
		@i_mediatypesubcode int,
		@Journals_Single_Issues_Available int,
--		@Issueind int,
		@isVisible int,
		@ptc int, --pricetypecode,
		@ordering int,
		@skuweight int,
		@ShipEnabled int

BEGIN

--		Select @i_publishtowebind = bd.publishtowebind
--		from UAP..book b, UAP..bookdetail bd
--		where b.bookkey = bd.bookkey
--		and b.bookkey = @i_bookkey

		Select @i_publishtowebind = bd.publishtowebind,
		@i_mediatypesubcode = mediatypesubcode,
		@Journals_Single_Issues_Available = (CASE Upper(UAP.dbo.[get_Tab_Journals_Single_Issues_Available?](@i_bookkey))
				WHEN 'YES' Then 1
				ELSE 0 END)
		from UAP..book b, UAP..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey

		Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Journal_by_PriceType')
		Select @d_datetime = getdate()
		Select @i_parent_productid = dbo.qweb_ecf_get_product_id(@i_bookkey)
		--Select @i_skuid = dbo.qweb_ecf_get_sku_id (@i_bookkey)


		--Make it visible only if publishtoweb and Journals_Single_Issues_Available flags are set to true
		If 	@i_publishtowebind = 1 And @Journals_Single_Issues_Available = 1
			SET @isVisible = 1
		else
			SET @isVisible = 0	

------------------------------------------------------
-------  START JOURNAL PRICE TYPE CURSOR -------------
------------------------------------------------------

		DECLARE c_qweb_journalpricetypes INSENSITIVE CURSOR
		FOR

		Select bookkey, finalprice, UAP.dbo.get_gentables_desc(306, pricetypecode, 'D') as pricetype, 
		Cast(bookkey as varchar) + '-' + CAST(pricetypecode as varchar) + '-' + CAST(currencytypecode as varchar) as pss_sku_code,
		pricetypecode
		from UAP..bookprice
		where bookkey = @i_bookkey
		and pricetypecode in (13,14,16,17,18,23,24,25,26,27,28,29)
		order by pricetypecode
			

			FOR READ ONLY
			OPEN c_qweb_journalpricetypes 
			FETCH NEXT FROM c_qweb_journalpricetypes 
				INTO @i_bookkey, @m_usretailprice, @v_pricetype, @v_pss_sku_code, @ptc
			select  @i_titlefetchstatus  = @@FETCH_STATUS
			 while (@i_titlefetchstatus >-1 )
				begin
					IF (@i_titlefetchstatus <>-2) 
						begin
						--17 institution, 18 individual single issue price type
							SET @ordering = 0
							If @i_mediatypesubcode <> 1 --journal single issues
								begin
									if @ptc <> 17 And @ptc <> 18
										--only inst or ind price types allowed for journal single issues
										--if user added them in TMM by mistake don't add to ECF
										Begin
											goto finished 
										End
									else --assign ordering here
										if @ptc = 17
											SET @ordering = 2
										else --18, individudal
											SET @ordering = 1
								end

								--no shipping charge for electronic subscription price types
								
								If @ptc <> 28 AND @ptc <> 29
									set @skuweight = 1
									
								ELSE
									set @skuweight = 0
								
								If @ptc <> 28 AND @ptc <> 29
									set @ShipEnabled = 1
								ELSE
									set @ShipEnabled = 0


						
								Select @v_title = UAP.dbo.qweb_get_Title(@i_bookkey,'f') + ' (' + @v_pricetype + ')'
								Select @i_skuid = skuid from sku where name = @v_title 
								--and price = @m_usretailprice

								If not exists (Select * from SKU where name = @v_title) 
								--and price = @m_usretailprice)
								
									Begin
									
									       
											exec dbo.SKUInsert 
											@i_skuid,				--@SkuId int = NULL output,
											@v_title,				--@Name nvarchar(100),
											null,					--@Description ntext = NULL,
											@m_usretailprice,		--@Price money = NULL,
											@isVisible,				--@Visible bit = NULL,
											@i_parent_productid,	--@ProductId int = NULL,
											@i_MetaClassID,			--@MetaClassId int = NULL,
											NULL,					--@CurrencyId nchar(3) = NULL,
											2,					    --@TaxCategoryId int = NULL,
											1,						--@SkuType int = NULL,
											NULL,					--@LicenseAgreementId int = NULL,
											@v_pss_sku_code,	    --@Code nvarchar(50) = NULL,
											@skuweight,					    --@Weight float = NULL,
											8,					    --@PackageId int = NULL,
											@ShipEnabled,			--@ShipEnabled bit = NULL,
											1,						--@SkuTemplateId int = NULL,
											@d_datetime,			--@Updated datetime = NULL,	
											@d_datetime,			--@Created datetime = NULL,
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
											@ordering				--@Ordering int = 0       

									end

								Else	
									Begin

										Declare @i_taxcategoryid int,
											@i_packageid int,
											@crtdate datetime,
											@upddate datetime,
											@wght float

											Select @i_taxcategoryid =TaxCategoryId, 
											@i_packageid = PackageId,
											--@Ordering = Ordering,
											@crtdate = Created,
											@upddate = Updated,
											@wght = Weight	
											from sku where skuid = @i_skuid

											exec dbo.SKUUpdate
											@i_skuid,				--@SkuId int = NULL output,
											@v_title,				--@Name nvarchar(100),
											null,					--@Description ntext = NULL,
											@m_usretailprice,		--@Price money = NULL,
											@isVisible,				--@Visible bit = NULL,
											@i_parent_productid,	--@ProductId int = NULL,
											@i_MetaClassID,			--@MetaClassId int = NULL,
											NULL,					--@CurrencyId nchar(3) = NULL,
											@i_taxcategoryid,		--@TaxCategoryId int = NULL,
											1,						--@SkuType int = NULL,
											NULL,					--@LicenseAgreementId int = NULL,
											@v_pss_sku_code,	    --@Code nvarchar(50) = NULL,
											@skuweight,					--@Weight float = NULL,
											@i_packageid,		    --@PackageId int = NULL,
											1,						--@ShipEnabled bit = NULL,
											1,						--@SkuTemplateId int = NULL,
											@crtdate,				--@Created datetime = NULL,	
											@upddate,				--@Updated datetime = NULL,
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
											@ordering				--@Ordering int = 0  

									end

						end

					finished:

					FETCH NEXT FROM c_qweb_journalpricetypes
					INTO @i_bookkey, @m_usretailprice, @v_pricetype, @v_pss_sku_code, @ptc
					select  @i_titlefetchstatus  = @@FETCH_STATUS
				end

		close c_qweb_journalpricetypes
		deallocate c_qweb_journalpricetypes
END


GO
Grant execute on dbo.qweb_ecf_Insert_Journal_SKUs to Public
GO