if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_import]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_import]

GO


CREATE procedure [dbo].[qweb_ecf_import] (@v_dbname varchar(255),@v_importtype varchar(1)) as

DECLARE @sql varchar(8000),
		@i_bookkey int,
		@i_mediatypecode int,
		@i_mediatypesubcode int,
		@i_titlefetchstatus int,
		@img_folder  varchar(255)

BEGIN

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecfbookkeys]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
create table [dbo].[qweb_ecfbookkeys] (bookkey int, mediatypecode int, mediatypesubcode int)
else truncate table [dbo].[qweb_ecfbookkeys]


If @v_importtype = 'F' --Full Import
	begin
	Select @sql = 
	'Insert into qweb_ecfbookkeys (bookkey, mediatypecode, mediatypesubcode)
	Select bookkey, mediatypecode, mediatypesubcode 
	from ' +@v_dbname+ '..bookdetail'
	
	--print @sql
	exec sp_sqlexec @sql

	end

If @v_importtype = 'I' -- Incremental Import
	begin

	Select @sql = 
	'Insert into qweb_ecfbookkeys (bookkey, mediatypecode, mediatypesubcode)
	Select distinct bookkey, mediatypecode, mediatypesubcode
	from '+ @v_dbname+ '..bookdetail 
	where (bookkey in (Select bookkey from ' +@v_dbname+ '..titlehistory where lastmaintdate > getdate() -2))
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
		--or  (bookkey in (select bookkey  from ' +@v_dbname+ '..bookdetail where mediatypecode=6 and mediatypesubcode=1))' 
	
	print @sql
	exec sp_sqlexec @sql
	end


		exec qweb_ecf_Category_Insert_UNP_Category
			print 'qweb_ecf_Category_Insert_UNP_Category COMPLETE'

		exec qweb_ecf_Category_Insert_MajorPressSubject_Category
			print 'qweb_ecf_Category_Insert_MajorPressSubject_Category COMPLETE'
		
		exec qweb_ecf_Category_Insert_Series
			print 'qweb_ecf_Category_Insert_Series COMPLETE'


		exec qweb_ecf_Category_Insert_WebFeature
			print 'qweb_ecf_Category_Insert_WebFeature COMPLETE'

		exec qweb_ecf_Category_Insert_Author_WebFeature
			--print 'qweb_ecf_Category_Insert_Author_WebFeature COMPLETE'

	--switch after go live
	--SET @img_folder = '\\qsiweb002\uap_images\covers\'
	SET @img_folder = '\\mcdonald\mediachase\UAP_images\covers\'


	DECLARE c_qweb_titles INSENSITIVE CURSOR
	FOR

	Select bookkey, mediatypecode, mediatypesubcode
	from qweb_ecfbookkeys

	FOR READ ONLY
			
	OPEN c_qweb_titles 

	FETCH NEXT FROM c_qweb_titles 
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin



		print getdate()
		print @i_bookkey

		-- Authors
		exec [dbo].[qweb_ecf_Insert_Products_Authors] @i_bookkey, @v_importtype
			--print 'qweb_ecf_Insert_Products_Authors COMPLETE'
		
		exec [dbo].[qweb_ecf_ProductEx_Authors] @i_bookkey, @v_importtype
			--print 'qweb_ecf_ProductEx_Authors COMPLETE'

		exec [dbo].[qweb_ecf_Categorization_Insert_Authors] @i_bookkey
			--print '[qweb_ecf_Categorization_Insert_Authors] COMPLETE'

		


		If NOT (@i_mediatypecode = 6 and @i_mediatypesubcode = 1)-- Not a Journal master record
		begin

			print @i_mediatypecode
			print @i_mediatypesubcode

				exec [dbo].[qweb_ecf_Insert_Products] @i_bookkey, @v_importtype
					print 'qweb_ecf_Insert_Products COMPLETE'

				exec [dbo].[qweb_ecf_Insert_SKUs] @i_bookkey, @v_importtype
					print 'qweb_ecf_Insert_SKUs COMPLETE'

				exec [dbo].[qweb_ecf_ProductEx_Titles] @i_bookkey, @v_importtype
					print 'qweb_ecf_ProductEx_Titles COMPLETE'

				exec [dbo].[qweb_ecf_SkuEx_Title_By_Format] @i_bookkey, @v_importtype
					print 'qweb_ecf_SkuEx_Title_By_Format COMPLETE'

				exec [dbo].[qweb_ecf_Categorization_Insert_Products] @i_bookkey
					print '[qweb_ecf_Categorization_Insert_Products] COMPLETE'

		end

		--SKIP JOURNALS FOR NOW

--		If (@i_mediatypecode = 6 and @i_mediatypesubcode = 1)-- IS a Journal - Master
--			OR exists (Select * FROM UAP..bookfamily where childbookkey = @i_bookkey and relationcode = 20005) --Journal Special Issue
--
--		begin	
--				exec [qweb_ecf_Insert_Journal_Products] @i_bookkey, @v_importtype
--					print 'qweb_ecf_Insert_Journal_Products COMPLETE'
--
--				exec [dbo].[qweb_ecf_Insert_Journal_SKUs] @i_bookkey, @v_importtype
--					print 'qweb_ecf_Insert_Journal_SKUs COMPLETE'
--
--				exec [dbo].[qweb_ecf_ProductEx_Journals] @i_bookkey, @v_importtype
--					print 'qweb_ecf_ProductEx_Journals COMPLETE'
--
--				exec [dbo].[qweb_ecf_SkuEx_Journal_By_Price] @i_bookkey, @v_importtype
--					print 'qweb_ecf_SkuEx_Journal_By_Price COMPLETE'
--
--				exec [dbo].[qweb_ecf_Categorization_Insert_Products] @i_bookkey
--					print '[qweb_ecf_Categorization_Insert_Products] COMPLETE'
--				
--
--		
--		end


		exec qweb_ecf_Categorization_Insert_UNP_Category @i_bookkey
			print 'qweb_ecf_Categorization_Insert_UNP_Category COMPLETE'

		exec qweb_ecf_Categorization_Insert_MajorPressSubject_Category @i_bookkey
				print 'qweb_ecf_Categorization_Insert_MajorPressSubject_Category COMPLETE'

		exec qweb_ecf_Categorization_Insert_Series @i_bookkey
			print 'qweb_ecf_Categorization_Insert_Series COMPLETE'


		exec qweb_ecf_Categorization_Insert_WebFeature @i_bookkey
			print 'qweb_ecf_Categorization_Insert_WebFeature COMPLETE'

		exec qweb_ecf_Insert_CrossSelling_Products @i_bookkey
			print 'qweb_ecf_Insert_CrossSelling_Products COMPLETE'
		
		exec qweb_ecf_Link_Authors_to_Titles @i_bookkey
			--print 'qweb_ecf_Link_Authors_to_Titles COMPLETE'
		
		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP				
		exec qweb_ecf_insert_product_images @i_bookkey,  @img_folder
			print 'qweb_ecf_insert_product_images COMPLETE'

		exec qweb_ecf_insert_sku_images @i_bookkey, @img_folder
			print 'qweb_ecf_insert_sku_images COMPLETE'


		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		
		--****** COMMENT OUT OTHER FILE/IMAGE TYPES FOR NOW *************
--		exec qweb_ecf_insert_sku_excerpts @i_bookkey, @img_folder
--			print 'qweb_ecf_insert_sku_excerpts COMPLETE'
--
--		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
--		--  UNP  -- '\\unp-muskie\Images\'  
--		exec [dbo].qweb_ecf_insert_journal_reco_forms @i_bookkey, @img_folder
--			print 'qweb_ecf_insert_journal_reco_forms COMPLETE'
--
--		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
--		--  UNP  -- '\\unp-muskie\Images\'  
--		exec qweb_ecf_insert_sku_digitalpresskit @i_bookkey, @img_folder
--			print 'qweb_ecf_insert_sku_digitalpresskit COMPLETE'

		exec qweb_ecf_Insert_ProductObjectAccess @i_bookkey
			print 'qweb_ecf_Insert_ProductObjectAccess COMPLETE'

		end

	FETCH NEXT FROM c_qweb_titles
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_qweb_titles
deallocate c_qweb_titles

		exec qweb_ecf_Categorization_Insert_Author_WebFeature
			--print 'qweb_ecf_Categorization_Insert_Author_WebFeature COMPLETE'

		exec qweb_ecf_CategoryExHome_Update
			print 'qweb_ecf_CategoryExHome_Update COMPLETE'

		exec qweb_ecf_CategoryExAuthorHome_Update
			--print 'qweb_ecf_CategoryExHome_Update COMPLETE'


		exec qweb_ecf_Insert_CategoryObjectAccess
			print 'qweb_ecf_Insert_CategoryObjectAccess COMPLETE'

		-- PM 07/25/07
		-- delete orphaned sku's because of parent titles that are not set to publishe to web
		/*delete from sku where productid is null*/

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


	-- authors should not be linked to other authors
		delete from crossselling
		where productid in (select objectid from productex_contributors)
       and relatedproductid in (select objectid from productex_contributors)
       
                                                  
		-- mark all authors that are not publish to web as not visible
		update product
		set visible = 0
		where code in (select distinct(cast(authorkey as varchar))
                    from uap..author 
                    where authorkey not in (select globalcontactkey from uap..globalcontactcategory
                                             where contactcategorycode = 2 and tableid = 431)) 
                                             
               
		--Mark all author records that are not active in TMM as not visible
		Update product
		set visible = 0
		FROM product p
		join ProductEx_Contributors pc
		on p.productid = pc.objectid
		WHERE pc.pss_globalcontactkey in
		(select globalcontactkey from uap..globalcontact
		where activeind = 0)
                                             
		--do not display email if "do not display email on the website" category is assigned to the contact
		Update ProductEx_Contributors
		SET Contributor_Email = NULL
		WHERE pss_globalcontactkey in (
		select distinct(cast(authorkey as varchar))
		from uap..author 
		where authorkey  in (select globalcontactkey from uap..globalcontactcategory
		where contactcategorycode = 3 and tableid = 431)) 

END


GO
Grant execute on dbo.qweb_ecf_import to Public
GO