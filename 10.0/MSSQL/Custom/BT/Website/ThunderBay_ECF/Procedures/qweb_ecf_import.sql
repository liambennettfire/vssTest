USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_import]    Script Date: 01/27/2010 16:49:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[qweb_ecf_import] (@v_dbname varchar(255),@v_importtype varchar(1)) as

DECLARE @sql varchar(8000),
		@i_bookkey int,
		@i_mediatypecode int,
		@i_mediatypesubcode int,
		@i_titlefetchstatus int

BEGIN

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecfbookkeys]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
create table [dbo].[qweb_ecfbookkeys] (bookkey int, mediatypecode int, mediatypesubcode int)
else truncate table [dbo].[qweb_ecfbookkeys]


If @v_importtype = 'F' --Full Import (Thunder Bay)
	begin
	Select @sql = 
	'Insert into qweb_ecfbookkeys (bookkey, mediatypecode, mediatypesubcode)
	Select bookkey, mediatypecode, mediatypesubcode 
	from ' +@v_dbname+ '..bookdetail
	where bookkey in (Select bookkey from ' +@v_dbname+ '..bookorgentry where orgentrykey = 9)' 
	
	--print @sql
	exec sp_sqlexec @sql

	end

If @v_importtype = 'I' -- Incremental Import
	begin

	Select @sql = 
	'Insert into qweb_ecfbookkeys (bookkey, mediatypecode, mediatypesubcode)
	Select distinct bookkey, mediatypecode, mediatypesubcode
	from '+ @v_dbname+ '..bookdetail 
	Where in (Select bookkey from ' +@v_dbname+ '..bookorgentry where orgentrykey = 9) 
	and (bookkey in (Select bookkey from ' +@v_dbname+ '..titlehistory where lastmaintdate > getdate() -2))
        or (bookkey in (Select bookkey from ' +@v_dbname+ '..associatedtitles where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..book where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookdetail where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..booksubjectcategory where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..printing where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookauthor where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookprice where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookdates where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookcomments where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..tourevents where lastmaintdate > getdate() -2))' 

	--print @sql
	exec sp_sqlexec @sql
	end

			print 'qweb_ecf_Category_Insert_WebFeature PENDING'
		exec qweb_ecf_Category_Insert_WebFeature
			print 'qweb_ecf_Category_Insert_WebFeature COMPLETE'

			print 'qweb_ecf_Category_Insert_UNP_Category PENDING'
		exec qweb_ecf_Category_Insert_UNP_Category
			print 'qweb_ecf_Category_Insert_UNP_Category COMPLETE'



--			print 'qweb_ecf_Category_Insert_Catalog PENDING'
--		exec qweb_ecf_Category_Insert_Catalog
--			print 'qweb_ecf_Category_Insert_Catalog COMPLETE'

--		exec qweb_ecf_Category_Insert_Distributors
--			print 'qweb_ecf_Category_Insert_Distributors COMPLETE'

	DECLARE c_qweb_titles CURSOR fast_forward FOR
  	Select bookkey, mediatypecode, mediatypesubcode
  	from qweb_ecfbookkeys
			
	OPEN c_qweb_titles 

	FETCH NEXT FROM c_qweb_titles 
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

		print 'titlefetchstatus ' + CAST(@i_titlefetchstatus as varchar)

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin
		
		print getdate()
		print 'Looping through Bookkey: '
		print @i_bookkey
		
		-- Authors
--		exec [dbo].[qweb_ecf_Insert_Products_Authors] @i_bookkey, @v_importtype
--			print 'qweb_ecf_Insert_Products_Authors COMPLETE'
--		
--		exec [dbo].[qweb_ecf_ProductEx_Authors] @i_bookkey, @v_importtype
--			print 'qweb_ecf_ProductEx_Authors COMPLETE'
--
--		exec [dbo].[qweb_ecf_Categorization_Insert_Authors] @i_bookkey
--			print '[qweb_ecf_Categorization_Insert_Authors] COMPLETE'
		
		-- Titles
		If (@i_mediatypecode <> 6)-- Not a Journal
		begin

			print @i_mediatypecode
			print @i_mediatypesubcode


					print 'qweb_ecf_Insert_Products PENDING'
				exec [dbo].[qweb_ecf_Insert_Products] @i_bookkey, @v_importtype
					print 'qweb_ecf_Insert_Products COMPLETE'

					print 'qweb_ecf_Insert_SKUs PENDING'
				exec [dbo].[qweb_ecf_Insert_SKUs] @i_bookkey, @v_importtype
					print 'qweb_ecf_Insert_SKUs COMPLETE'

					print 'qweb_ecf_ProductEx_Titles PENDING'
				exec [dbo].[qweb_ecf_ProductEx_Titles] @i_bookkey, @v_importtype
					print 'qweb_ecf_ProductEx_Titles COMPLETE'

					print 'qweb_ecf_SkuEx_Title_By_Format PENDING'
				exec [dbo].[qweb_ecf_SkuEx_Title_By_Format] @i_bookkey, @v_importtype
					print 'qweb_ecf_SkuEx_Title_By_Format COMPLETE'

					print '[qweb_ecf_Categorization_Insert_Products] PENDING'
				exec [dbo].[qweb_ecf_Categorization_Insert_Products] @i_bookkey
					print '[qweb_ecf_Categorization_Insert_Products] COMPLETE'

		end

    -- Journals
		If (@i_mediatypecode = 6 and @i_mediatypesubcode = 1)-- IS a Journal - Master
		begin	
--				exec [qweb_ecf_Insert_Journal_Products] @i_bookkey, @v_importtype
--					--print 'qweb_ecf_Insert_Journal_Products COMPLETE'

				exec [dbo].[qweb_ecf_Insert_Journal_SKUs] @i_bookkey, @v_importtype
					--print 'qweb_ecf_Insert_Journal_SKUs COMPLETE'

				exec [dbo].[qweb_ecf_ProductEx_Journals] @i_bookkey, @v_importtype
					--print 'qweb_ecf_ProductEx_Journals COMPLETE'

				exec [dbo].[qweb_ecf_SkuEx_Journal_By_Price] @i_bookkey, @v_importtype
					--print 'qweb_ecf_SkuEx_Journal_By_Price COMPLETE'

				exec [dbo].[qweb_ecf_Categorization_Insert_Products] @i_bookkey
					--print '[qweb_ecf_Categorization_Insert_Products] COMPLETE'				
		end

			print 'qweb_ecf_Categorization_Insert_UNP_Category PENDING'
		exec qweb_ecf_Categorization_Insert_UNP_Category @i_bookkey
			print 'qweb_ecf_Categorization_Insert_UNP_Category COMPLETE'

			print 'qweb_ecf_Categorization_Insert_WebFeature PENDING'
		exec qweb_ecf_Categorization_Insert_WebFeature @i_bookkey
			print 'qweb_ecf_Categorization_Insert_WebFeature COMPLETE'

--			print 'qweb_ecf_Categorization_Insert_Catalog PENDING' print @i_bookkey
--		exec qweb_ecf_Categorization_Insert_Catalog @i_bookkey
--			print 'qweb_ecf_Categorization_Insert_Catalog COMPLETE'

--			print 'qweb_ecf_Categorization_Insert_Catalog PENDING'
--		exec qweb_ecf_Categorization_Insert_Distributors @i_bookkey
--			print 'qweb_ecf_Categorization_Insert_Catalog COMPLETE'
			
		exec qweb_ecf_Insert_CrossSelling_Products @i_bookkey
			print 'qweb_ecf_Insert_CrossSelling_Products COMPLETE'
			print @i_bookkey

		exec qweb_ecf_Link_Authors_to_Titles @i_bookkey
			--print 'qweb_ecf_Link_Authors_to_Titles COMPLETE'
		
		--  QSI  -- '\\mcdonald\mediachase\Barb_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP				
		exec qweb_ecf_insert_product_images @i_bookkey,'\\qsiweb003\Websites\ECF\BT_Images\'
			print 'qweb_ecf_insert_product_images COMPLETE'

		exec qweb_ecf_insert_sku_images @i_bookkey,'\\qsiweb003\Websites\ECF\BT_Images\'
			print 'qweb_ecf_insert_sku_images COMPLETE'

		exec qweb_ecf_insert_product_interior_images @i_bookkey,'\\qsiweb003\Websites\ECF\BT_Images\'
			print 'qweb_ecf_insert_product_interior_images COMPLETE'


		--  QSI  -- '\\mcdonald\mediachase\Barb_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		---exec qweb_ecf_insert_sku_excerpts @i_bookkey, '\\fileserver\FS1\All-share\PDFs for Website\' 
--			print 'qweb_ecf_insert_sku_excerpts COMPLETE'

		--  QSI  -- '\\mcdonald\mediachase\Barb_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		--exec [dbo].qweb_ecf_insert_journal_reco_forms @i_bookkey,'\\mcdonald\mediachase\Barb_images\'
--			print 'qweb_ecf_insert_journal_reco_forms COMPLETE'

		--  QSI  -- '\\mcdonald\mediachase\Barb_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		--exec qweb_ecf_insert_sku_digitalpresskit @i_bookkey, '\\mcdonald\mediachase\Barb_images\' 
			--print 'qweb_ecf_insert_sku_digitalpresskit COMPLETE'

		--exec qweb_ecf_Insert_ProductObjectAccess @i_bookkey
			--print 'qweb_ecf_Insert_ProductObjectAccess COMPLETE'

		end

	FETCH NEXT FROM c_qweb_titles
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_qweb_titles
deallocate c_qweb_titles


		exec qweb_ecf_CategoryExHome_Update
			print 'qweb_ecf_CategoryExHome_Update COMPLETE'

		exec qweb_ecf_Insert_CategoryObjectAccess
			print 'qweb_ecf_Insert_CategoryObjectAccess COMPLETE'

		-- PM 07/25/07
		-- delete orphaned sku's because of parent titles that are not set to publishe to web
		/*delete from sku where productid is null*/

		--BL make any product without a sku invisible

		update product 
		set visible=0
		where productid not in (select productid from sku) 
		and producttemplateid=94


		--BL quick and dirty journal subscription ordering
		--update sku ordering

		update sku 
		set ordering=1
		where skuid in
		(select objectid from skuex_journal_by_pricetype
		where sku_title like '%U.S.%')

		update sku 
		set ordering=2
		where skuid in
		(select objectid from skuex_journal_by_pricetype
		where sku_title like '%Foreign%')

END






