USE [MIZ_ECF]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]    Script Date: 03/17/2011 11:40:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Authors]    Script Date: 03/17/2011 11:40:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Authors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Authors]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]    Script Date: 03/17/2011 11:40:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Products]    Script Date: 03/17/2011 11:40:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Products]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Series]    Script Date: 03/17/2011 11:40:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Series]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Series]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_UNP_Category]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_UNP_Category]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_UNP_Category]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_WebFeature]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_WebFeature]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_WebFeature]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Author_WebFeature]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Author_WebFeature]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Author_WebFeature]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Contributor_Name]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Contributor_Name]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Contributor_Name]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Contributor_Type]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Contributor_Type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Contributor_Type]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Series]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Series]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Series]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_UNP_Category]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_UNP_Category]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_UNP_Category]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_WebFeature]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_WebFeature]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_WebFeature]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_CategoryExAuthorHome_Update]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_CategoryExAuthorHome_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_CategoryExAuthorHome_Update]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_CategoryExHome_Update]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_CategoryExHome_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_CategoryExHome_Update]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_get_newsarchive_dates]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_get_newsarchive_dates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_get_newsarchive_dates]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_import]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_import]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_author_images]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_insert_author_images]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_insert_author_images]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_CategoryObjectAccess]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_CategoryObjectAccess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_CategoryObjectAccess]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_CrossSelling_Products]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_CrossSelling_Products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_CrossSelling_Products]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_customer_roles]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_customer_roles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_customer_roles]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Journal_Products]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_Journal_Products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_Journal_Products]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_journal_reco_forms]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_insert_journal_reco_forms]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_insert_journal_reco_forms]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Journal_SKUs]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_Journal_SKUs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_Journal_SKUs]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_product_images]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_insert_product_images]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_insert_product_images]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_ProductObjectAccess]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_ProductObjectAccess]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_ProductObjectAccess]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Products]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_Products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_Products]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Products_Authors]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_Products_Authors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_Products_Authors]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_sku_digitalpresskit]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_insert_sku_digitalpresskit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_insert_sku_digitalpresskit]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_sku_excerpts]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_insert_sku_excerpts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_insert_sku_excerpts]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_sku_images]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_insert_sku_images]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_insert_sku_images]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_SKUs]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_SKUs]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_SKUs]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Authors]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_ProductEx_Authors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_ProductEx_Authors]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Journals]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_ProductEx_Journals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_ProductEx_Journals]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Titles]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_ProductEx_Titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_ProductEx_Titles]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Journal_By_Price]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_SkuEx_Journal_By_Price]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_SkuEx_Journal_By_Price]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Title_By_Format]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_SkuEx_Title_By_Format]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_SkuEx_Title_By_Format]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_UpdateImageData]    Script Date: 03/17/2011 11:40:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_UpdateImageData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_UpdateImageData]
GO

USE [MIZ_ECF]
GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]  as

DECLARE @i_c_contactkey int,
		@i_categorycode int,
		@subject_object_id int,
		@i_webfeature_fetchstatus int,
		@productid int,
		@d_datetime datetime,
		@parent_categoryid int,
		@v_tableid int

BEGIN
  set @v_tableid = 431
 	Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Author Web Feature')

	delete from categorization 
	where objectid in (select objectid from productex_contributors)
	and objecttypeid=1 
	and categoryid in (select categoryid from category 
	                    where parentcategoryid = @parent_categoryid)

	DECLARE c_pss_webfeature CURSOR fast_forward FOR
 	  Select globalcontactkey, contactcategorycode
	  from MIZ..globalcontactcategory
	  where tableid = @v_tableid
	    and globalcontactkey in (Select code from product)

	OPEN c_pss_webfeature

	FETCH NEXT FROM c_pss_webfeature
		INTO @i_c_contactkey, @i_categorycode

	select  @i_webfeature_fetchstatus  = @@FETCH_STATUS

	while (@i_webfeature_fetchstatus >-1 )
		begin
		  IF (@i_webfeature_fetchstatus <>-2) 
		  begin

			  Select @productid = productid from product where code =  cast(@i_c_contactkey as varchar)
        set @subject_object_id = 0
  			
			  Select @subject_object_id = objectid 
				  from CategoryEx_Web_Feature 
				 where pss_webfeature_categorytableid = @v_tableid
  		     and pss_webfeature_datacode = @i_categorycode
  		      
			  IF not exists (Select * 
							  from categorization 
							  where objectid = @productid 
							  and categoryid = @subject_object_id) and @subject_object_id > 0

			  begin
  						
			    exec CategorizationInsert

			    @subject_object_id,       --@CategoryId int,
			    @productid,				--@ObjectId int,
			    1,						--@ObjectTypeId int,
			    NULL					--@CategorizationId int = NULL output

			  end
                   
		  end

    	FETCH NEXT FROM c_pss_webfeature
		  INTO @i_c_contactkey, @i_categorycode
		  
	    select  @i_webfeature_fetchstatus  = @@FETCH_STATUS
		end

  close c_pss_webfeature
  deallocate c_pss_webfeature

END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Authors]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Authors] (@i_bookkey int) as
	
DECLARE @i_categorycode int,
		@productid int,
		@v_contactkey int,
		@i_categoryid int,
		@v_fetchstatus int
			
BEGIN
  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select authorkey
  	  from MIZ..bookauthor b, MIZ..bookdetail bd
	   where b.bookkey = bd.bookkey
	 	   and b.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1
				
	OPEN c_pss_authors
	
	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1) begin
	  IF (@v_fetchstatus <>-2) begin

		  Select @i_categoryid = dbo.qweb_ecf_get_Category_ID('Authors')
		  Select @productid = productid from product where code = cast(@v_contactkey as varchar)

		  If not exists(Select * 
					    From categorization 
					    Where categoryid = @i_categoryid
					      and objectid = @productid)
		  begin
			  exec CategorizationInsert
			  @i_categoryid,          --@CategoryId int,
			  @productid,				--@ObjectId int,
			  1,						--@ObjectTypeId int,
			  NULL					--@CategorizationId int = NULL output
		  end

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey

	    select  @v_fetchstatus  = @@FETCH_STATUS
    end
  end
    	
  close c_pss_authors
  deallocate c_pss_authors  		
END







GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Contibutor_Role] as

DECLARE @i_bookkey int,
		@i_globalcontactkey int,
        @i_authortypecode int,
		@contributor_object_id int,
		@role_categoryid int,
		@i_titlefetchstatus int,
		@title_productid int,
		@productid int,
		@d_datetime datetime

BEGIN

	DECLARE c_pss_titles INSENSITIVE CURSOR
	FOR

	Select bookkey, authorkey, authortypecode
	from MIZ..bookauthor
	where bookkey in (Select bookkey from MIZ..bookdetail where publishtowebind =1)

	FOR READ ONLY
			
	OPEN c_pss_titles

	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey, @i_globalcontactkey, @i_authortypecode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

			Select @productid = productid from product where code = @i_bookkey
			Select @contributor_object_id = objectid from CategoryEx_Contributor where pss_globalcontactkey = @i_globalcontactkey
			Select @role_categoryid = categoryid from category where parentCategoryid = @contributor_object_id
						
			exec CategorizationInsert

			@role_categoryid,       --@CategoryId int,
			@productid,				--@ObjectId int,
			1,						--@ObjectTypeId int,
			NULL					--@CategorizationId int = NULL output
                 
			end

		

	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey, @i_globalcontactkey, @i_authortypecode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_titles
deallocate c_pss_titles


END







GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Products]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Products] (@i_bookkey int) as
	
DECLARE @i_categorycode int,
		@i_title_categoryid int,
		@i_journal_categoryid int,
		@productid int,
		@i_publishtowebind int,
		@i_workkey int,
		@i_mediatypecode int,
		@i_mediatypesubcode int,
		@i_categoryid int
		
		
BEGIN
			
			Select @i_publishtowebind = publishtowebind,
				   @i_mediatypecode = mediatypecode,
				   @i_mediatypesubcode = mediatypesubcode
			from MIZ..bookdetail 
			where bookkey = @i_bookkey

			Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Titles')
			Select @i_journal_categoryid = dbo.qweb_ecf_get_Category_ID('Journals Home')
			Select @productid = productid from product where code = cast(@i_bookkey as varchar)
			Select @i_workkey = workkey from MIZ..book where bookkey = @i_bookkey
				
			IF coalesce (@productid,0) =0
			return
		
			If @i_mediatypecode = 6 and @i_mediatypesubcode = 1
			   begin
				Select @i_categoryid = @i_journal_categoryid
			   end
			Else 
				begin
				Select @i_categoryid = @i_title_categoryid
				end


			If not exists(Select * 
						  From categorization 
						  Where categoryid = @i_categoryid 
						    and objectid = @productid
							)
				
				/*and @i_publishtowebind = 1*/
				and @i_workkey = @i_bookkey

			begin
												
				exec CategorizationInsert
				@i_categoryid,          --@CategoryId int,
				@productid,				--@ObjectId int,
				1,						--@ObjectTypeId int,
				NULL					--@CategorizationId int = NULL output

			end

		
END








GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Series]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Series] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
		@i_categorycode int,
		@v_categorysubcode int,
		@subject_object_id int,
		@i_titlefetchstatus int,
		@productid int,
		@d_datetime datetime

BEGIN
	delete from categorization where objectid in 
	(select objectid from productex_titles where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 and categoryid in (select categoryid from category where parentcategoryid in
	(select categoryid from category where parentcategoryid in (select categoryid from category where lower(Name)='series')))

	DECLARE c_pss_series INSENSITIVE CURSOR
	FOR

	Select bookkey, seriescode
	from MIZ..bookdetail
	where bookkey = @i_bookkey
		/*and publishtowebind =1*/
		and exists (Select * from product where code = cast(@i_bookkey as varchar))

	FOR READ ONLY
			
	OPEN c_pss_series

	FETCH NEXT FROM c_pss_series INTO @i_c_bookkey, @i_categorycode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin
			Select @productid = productid from product where code = cast(@i_c_bookkey as varchar)
			  
			Select @subject_object_id = 153 --objectid from CategoryEx_Title_Series 
			-- where pss_subject_categorytableid = 327 
			--   and pss_subject_datacode = @i_categorycode
	
print 'here***************************************'
print cast(@i_bookkey as varchar)
print cast(@subject_object_id as varchar)
print cast(@productid as varchar)
		
		  if @subject_object_id > 0 begin
			  If not exists (Select * from categorization
							  where categoryid = 	@subject_object_id
							   and objectid = @productid)
			  begin

print 'here2***************************************'
print cast(@i_bookkey as varchar)
print cast(@subject_object_id as varchar)
print cast(@productid as varchar)

			    exec CategorizationInsert

			    @subject_object_id,       --@CategoryId int,
			    @productid,				--@ObjectId int,
			    1,						--@ObjectTypeId int,
			    NULL					--@CategorizationId int = NULL output
  			
			  end
			end
                 
		end

	  FETCH NEXT FROM c_pss_series INTO @i_c_bookkey, @i_categorycode
		
    select  @i_titlefetchstatus  = @@FETCH_STATUS
  end

close c_pss_series
deallocate c_pss_series


END









GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_UNP_Category]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_UNP_Category] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
		@i_categorycode int,
		@subject_object_id int,
		@i_titlefetchstatus int,
		@productid int,
		@d_datetime datetime

BEGIN
	delete from categorization where objectid in 
	(select objectid from productex_titles where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 and categoryid in (select categoryid from category where parentcategoryid=154)

	delete from categorization where objectid in 
	(select objectid from productex_journals where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 and categoryid in (select categoryid from category where parentcategoryid=154)


	DECLARE c_pss_category INSENSITIVE CURSOR
	FOR
	
	Select bookkey, categorycode
	from MIZ..booksubjectcategory
	where categorytableid = 437
		/*and bookkey in (Select bookkey from MIZ..bookdetail where publishtowebind =1)*/
		and bookkey = @i_bookkey
		and exists (Select * from product where code = cast(@i_bookkey as varchar))
	
	

	FOR READ ONLY
			
	OPEN c_pss_category

	FETCH NEXT FROM c_pss_category
		INTO @i_c_bookkey, @i_categorycode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin
			
			Select @productid = productid from product where code = cast(@i_c_bookkey as varchar)
			--Select @subject_object_id = objectid from CategoryEx_Title_Subject where pss_subject_datacode = @i_categorycode
			Select @subject_object_id = objectid from CategoryEx_Title_Subject 
			  where pss_subject_categorytableid = 437 
			    and pss_subject_datacode = @i_categorycode
		
			If not exists (Select * from categorization
							where categoryid = 	@subject_object_id
							 and objectid = @productid) and @subject_object_id > 0
			begin

			exec CategorizationInsert

			@subject_object_id,       --@CategoryId int,
			@productid,				--@ObjectId int,
			1,						--@ObjectTypeId int,
			NULL					--@CategorizationId int = NULL output
			
			end
                 
		end

		

	FETCH NEXT FROM c_pss_category
		INTO @i_c_bookkey, @i_categorycode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_category
deallocate c_pss_category


END







GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_WebFeature]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_WebFeature] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
		@i_categorycode int,
		@subject_object_id int,
		@i_webfeature_fetchstatus int,
		@productid int,
		@d_datetime datetime

BEGIN
	delete from categorization where objectid in 
	(select objectid from productex_titles where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 and categoryid in (Select categoryid from category
	where parentcategoryid = 155)
	--and objecttypeid=1 and categoryid in (299,300)

	delete from categorization where objectid in 
	(select objectid from productex_journals where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 and categoryid in (Select categoryid from category
	where parentcategoryid = 155)
	--and objecttypeid=1 and categoryid in (299,300)
	

	DECLARE c_pss_webfeature INSENSITIVE CURSOR
	FOR

	Select bookkey, categorycode
	from MIZ..booksubjectcategory
	where categorytableid = 434
		/*and bookkey in (Select bookkey from UAP..bookdetail where publishtowebind =1)*/
		and bookkey = @i_bookkey
		--and categorycode <> 1 -- bargain books will be handled by pricetypecode
		and bookkey in (Select code from product)
--	UNION
--	Select bookkey, '1'
--	from MIZ..bookprice 
--	where pricetypecode = 10
--        and activeind = 1
--	  and finalprice is not null
--	  /*and bookkey in (Select bookkey from UAP..bookdetail where publishtowebind =1)*/
--	  and bookkey = @i_bookkey
--	  and bookkey in (Select code from product)



	FOR READ ONLY
			
	OPEN c_pss_webfeature

	FETCH NEXT FROM c_pss_webfeature
		INTO @i_c_bookkey, @i_categorycode

	select  @i_webfeature_fetchstatus  = @@FETCH_STATUS

	 while (@i_webfeature_fetchstatus >-1 )
		begin
		IF (@i_webfeature_fetchstatus <>-2) 
		begin

			Select @productid = productid from product where code =  cast(@i_c_bookkey as varchar)
			
			Select @subject_object_id = objectid 
				from CategoryEx_Web_Feature 
				where pss_webfeature_datacode = @i_categorycode
				and pss_webfeature_categorytableid = 434
		

			IF not exists (Select * 
							from categorization 
							where objectid = @productid 
							and categoryid = @subject_object_id)

			begin
						
			exec CategorizationInsert

			@subject_object_id,       --@CategoryId int,
			@productid,				--@ObjectId int,
			1,						--@ObjectTypeId int,
			NULL					--@CategorizationId int = NULL output

			end
                 
		end

		

	FETCH NEXT FROM c_pss_webfeature
		INTO @i_c_bookkey, @i_categorycode
	        select  @i_webfeature_fetchstatus  = @@FETCH_STATUS
		end

close c_pss_webfeature
deallocate c_pss_webfeature


END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Author_WebFeature]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Category_Insert_Author_WebFeature] as

DECLARE @WebFeature_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@v_tableid int

BEGIN
  set @v_tableid = 435

	DECLARE c_pss_WebFeature INSENSITIVE CURSOR
	FOR
	  Select datadesc, datacode
	  from MIZ..gentables
	  where tableid = @v_tableid
	  and deletestatus<>'Y'
	  --and datacode <> 4  -- Do not import publish to web category Publish to web

	FOR READ ONLY
			
	OPEN c_pss_WebFeature

	FETCH NEXT FROM c_pss_WebFeature
		INTO @v_categorydesc,@v_datacode

	select  @WebFeature_fetch_status  = @@FETCH_STATUS

  while (@WebFeature_fetch_status >-1 )
	begin
		IF (@WebFeature_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Author Web Feature')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Web_Feature')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'

			If not exists (Select * from category
							where parentcategoryid = @parent_categoryid		
							  and name = @v_categorydesc)

			begin
			
			  exec CategoryInsert
			  NULL,				--@CategoryId int = NULL output,
			  @v_categorydesc,		--@Name nvarchar(50),
			  0,					--@Ordering int = NULL,
			  1,					--@IsVisible bit = NULL,
			  @parent_categoryid,	--@ParentCategoryId int = NULL,
			  @i_categorytemplateid, --@CategoryTemplateId int = NULL,
			  0,					--@TypeId int = NULL,
			  null,				--@PageUrl nvarchar(255) = null,	
			  1,					--@ObjectLanguageId int = NULL output,
			  1,					--@LanguageId int,
			  @i_metaclassid,		--@MetaClassId int = NULL,
			  0,					--@ObjectGroupId int = 0,
			  @d_datetime,		--@Updated datetime = NULL,
			  @d_datetime,		--@Created datetime = NULL,
			  1					--@IsInherited bit = 0
		

			  Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

			  exec dbo.mdpsp_avto_CategoryEx_Web_Feature_Update
			  @Current_ObjectID,			 --@ObjectId INT, 
			  1,							 --@CreatorId INT, 
			  @d_datetime,				 --@Created DATETIME, 
			  1,							 --@ModifierId INT, 
			  @d_datetime,				 --@Modified DATETIME, 
			  null,						 --@Retval INT OUT, 
			  @v_tableid,						 --@pss_subject_categorytableid int, 
			  @v_datacode,				 --@pss_subject_datacode int, 
			  0							 --@pss_subject_datasubcode int 

			end
	  end

	  FETCH NEXT FROM c_pss_WebFeature
		INTO @v_categorydesc,@v_datacode
		
	  select  @WebFeature_fetch_status = @@FETCH_STATUS
  end

  close c_pss_WebFeature
  deallocate c_pss_WebFeature

END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Contributor_Name]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Category_Insert_Contributor_Name] as

DECLARE @contrib_fetch_status int,
		@i_globalcontactkey int,
        @displayname varchar(255),
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@v_lastname varchar(75),
		@v_firstname varchar(75),
		@v_displayname varchar(255),
		@Current_ObjectID int,
		@i_Categorytemplateid int

BEGIN

	DECLARE c_pss_contributor_names INSENSITIVE CURSOR
	FOR

	Select distinct g.globalcontactkey, displayname
	from MIZ..globalcontact g, MIZ..bookauthor ba
	where ba.authorkey = g.globalcontactkey
	and ba.bookkey IN (Select bookkey from MIZ..bookdetail where publishtowebind = 1)
	order by 2

	FOR READ ONLY
			
	OPEN c_pss_contributor_names

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_pss_contributor_names
		INTO @i_globalcontactkey, @displayname

	select  @contrib_fetch_status  = @@FETCH_STATUS

	 while (@contrib_fetch_status >-1 )
		begin
		IF (@contrib_fetch_status <>-2) 
		begin


			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Contributors')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Contributor')
			Select @d_datetime = getdate()
			Select @i_Categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'
			Select @v_lastname = lastname,
				   @v_firstname = firstname,
				   @v_displayname = displayname
			FROM MIZ..globalcontact
					WHERE globalcontactkey = @i_globalcontactkey
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@displayname,		--@Name nvarchar(50),
			0,					--@Ordering int = NULL,
			1,					--@IsVisible bit = NULL,
			@parent_categoryid,	--@ParentCategoryId int = NULL,
			@i_Categorytemplateid, --@CategoryTemplateId int = NULL,
			0,					--@TypeId int = NULL,
			null,				--@PageUrl nvarchar(255) = null,	
			1,					--@ObjectLanguageId int = NULL output,
			1,					--@LanguageId int,
			@i_metaclassid,		--@MetaClassId int = NULL,
			0,					--@ObjectGroupId int = 0,
			@d_datetime,		--@Updated datetime = NULL,
			@d_datetime,		--@Created datetime = NULL,
			1					--@IsInherited bit = 0
		

			Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

			exec dbo.mdpsp_avto_CategoryEx_Contributor_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							--@CreatorId INT, 
			@d_datetime,				--@Created DATETIME, 
			1,							--@ModifierId INT, 
			@d_datetime,				--@Modified DATETIME, 
			NULL,						--@Retval INT OUT, 
			@i_globalcontactkey,		--@pss_globalcontactkey int, 
			@v_firstname,				--@Contributor_First_Name nvarchar(       512) , 
			null,						--@Contributor_Middle_Name nvarchar(       512) , 
			@v_lastname,				--@Contributor_Last_Name nvarchar(       512) , 
			@v_displayname,				--@Contributor_Display_Name nvarchar(       512) , 
			0,							--@Contributor_Primary_Ind int, 
			0							--@Contributor_Sort_Order int 

	end

	FETCH NEXT FROM c_pss_contributor_names
		INTO @i_globalcontactkey, @displayname
	        select  @contrib_fetch_status = @@FETCH_STATUS
		end

close c_pss_contributor_names
deallocate c_pss_contributor_names


END






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Contributor_Type]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[qweb_ecf_Category_Insert_Contributor_Type] as

DECLARE @contrib_fetch_status int,
		@i_globalcontactkey int,
        @authortype varchar(40),
		@authortypecode varchar(40),
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int

BEGIN

	DECLARE c_pss_contributor_types INSENSITIVE CURSOR
	FOR

	Select distinct g.globalcontactkey, MIZ.dbo.get_gentables_desc(134,ba.authortypecode,''),ba.authortypecode
	from MIZ..globalcontact g, MIZ..bookauthor ba
	where ba.authorkey = g.globalcontactkey
	and ba.bookkey IN (Select bookkey from MIZ..bookdetail where publishtowebind = 1)

	FOR READ ONLY
			
	OPEN c_pss_contributor_types

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_pss_contributor_types
		INTO @i_globalcontactkey, @authortype, @authortypecode

	select  @contrib_fetch_status  = @@FETCH_STATUS	

	 while (@contrib_fetch_status >-1 )
		begin
		IF (@contrib_fetch_status <>-2) 
		begin


			Select @parent_categoryid = objectid from CategoryEx_Contributor where pss_globalcontactkey = @i_globalcontactkey
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Contributor_Type_Category')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@authortype,		--@Name nvarchar(50),
			0,					--@Ordering int = NULL,
			1,					--@IsVisible bit = NULL,
			@parent_categoryid,	--@ParentCategoryId int = NULL,
			@i_categorytemplateid,--@CategoryTemplateId int = NULL,
			0,					--@TypeId int = NULL,
			Null,				--@PageUrl nvarchar(255) = null,	
			1,					--@ObjectLanguageId int = NULL output,
			1,					--@LanguageId int,
			@i_metaclassid,		--@MetaClassId int = NULL,
			0,					--@ObjectGroupId int = 0,
			@d_datetime,		--@Updated datetime = NULL,
			@d_datetime,		--@Created datetime = NULL,
			1					--@IsInherited bit = 0

			Select @Current_ObjectID = IDENT_CURRENT('Category')

			exec [mdpsp_avto_CategoryEx_Contributor_Type_Category_Update]
			@Current_ObjectID,	 --@ObjectId INT, 
			1,					 --@CreatorId INT, 
			@d_datetime,		 --@Created DATETIME, 
			1,					 --@ModifierId INT, 
			@d_datetime,		 --@Modified DATETIME, 
			NULL,				 --@Retval INT OUT, 
			@authortype,		 --@Contributor_Type nvarchar(512) , 
			@authortypecode		 --@pss_roletypecode int 

		end

	FETCH NEXT FROM c_pss_contributor_types
		INTO @i_globalcontactkey, @authortype, @authortypecode
	        select  @contrib_fetch_status = @@FETCH_STATUS
		end

close c_pss_contributor_types
deallocate c_pss_contributor_types


END








GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Series]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Category_Insert_Series] as

DECLARE @category_fetch_status int,
		@v_categorydesc varchar(50),
		@v_tableid int,
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@v_cnt int,
		@v_Description varchar(max),
		@v_alternatedesc1 varchar(255),
		@v_categoryid int

BEGIN
  SET @v_tableid = 327

  DECLARE c_pss_series CURSOR fast_forward FOR

	Select datadesc, datacode, COALESCE(sortorder,0) sortorder, deletestatus, COALESCE(alternatedesc1,'')
	from MIZ..gentables
	where tableid = 327
	--and deletestatus<>'Y'
	--and sortorder is not null
				
	OPEN c_pss_series

	/* get the next one*/	
	FETCH NEXT FROM c_pss_series
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @v_alternatedesc1

	select  @category_fetch_status  = @@FETCH_STATUS
	
	print 'begin cursor loop iteration'

	 while (@category_fetch_status >-1 )
		begin
		IF (@category_fetch_status <>-2) 
		begin

		  if (@v_alternatedesc1 is not null AND ltrim(rtrim(@v_alternatedesc1)) <> '')
          begin
		    if len(@v_alternatedesc1) <= 50 
			begin
			    -- alternatedesc1 is filled in and length <= 50 - use it instead
    		  Select @v_categorydesc = @v_alternatedesc1
    		end
		  end

		Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Series')
			print  '@parent_categoryid= ' +	CAST(@parent_categoryid AS nvarchar)

			If not exists (Select * from category where parentcategoryid = @parent_categoryid
							  and [name] = @v_categorydesc) AND @v_categoryid = 0 and @v_deletestatus ='n'
							  BEGIN
                  print 'WTF?' + CAST(@parent_categoryid AS nvarchar) 
							  END


		Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Series')	
		print  @i_metaclassid
			
		Select @d_datetime = getdate()
		
		Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Series Category Template'
		print  @i_categorytemplateid
			
		IF @v_deletestatus='Y'
		begin
			delete from category where parentcategoryid = 156 and name = @v_categorydesc
			delete from categoryex_title_series where pss_subject_datacode=@v_datacode
		end
		SET @v_categoryid = 0
			
		Select @v_Description = GeneralDescription, @v_categoryid = objectid
		from CategoryEx_Title_Series
		where pss_subject_categorytableid = @v_tableid
		and pss_subject_datacode = @v_datacode
		and pss_subject_datasubcode = 0
			
		IF @v_categoryid is null 
			BEGIN
			  SET @v_categoryid = 0
			END
			
		If not exists (Select * from category where parentcategoryid = @parent_categoryid
							  and [name] = @v_categorydesc) AND @v_categoryid = 0 and @v_deletestatus ='n'
		begin
		print 'exec CategoryInsert'
		      exec CategoryInsert
			  NULL,					--@CategoryId int = NULL output,
			  @v_categorydesc,		--@Name nvarchar(50),
			  1,					--@Ordering int = NULL,
			  1,					--@IsVisible bit = NULL,
			  @parent_categoryid,	--@ParentCategoryId int = NULL,
			  @i_categorytemplateid,--@CategoryTemplateId int = NULL,
			  0,					--@TypeId int = NULL,
			  null,					--@PageUrl nvarchar(255) = null,	
			  1,					--@ObjectLanguageId int = NULL output,
			  1,					--@LanguageId int,
			  @i_metaclassid,		--@MetaClassId int = NULL,
			  0,					--@ObjectGroupId int = 0,
			  @d_datetime,			--@Updated datetime = NULL,
			  @d_datetime,			--@Created datetime = NULL,
			  1						--@IsInherited bit = 0
			  print 'category inserted: ' + @v_categorydesc
		end
		IF exists (Select * from category where parentcategoryid = @parent_categoryid
							  and [name] = @v_categorydesc) AND @v_categoryid = 0 and @v_deletestatus ='n'
		begin	
		
		print 'exec CategoryUpdate'
					        
			  exec CategoryUpdate
			  @v_categoryid,				--@CategoryId int = NULL output,
			  @v_categorydesc,		--@Name nvarchar(50),
			  1,		--@Ordering int = NULL,
			  1,					--@IsVisible bit = NULL,
			  @parent_categoryid,	--@ParentCategoryId int = NULL,
			  @i_categorytemplateid,--@CategoryTemplateId int = NULL,
			  0,					--@TypeId int = NULL,
			  null,				--@PageUrl nvarchar(255) = null,	
			  1,					--@ObjectLanguageId int = NULL output,
			  1,					--@LanguageId int,
			  @i_metaclassid,		--@MetaClassId int = NULL,
			  0,					--@ObjectGroupId int = 0,
			  @d_datetime,		--@Updated datetime = NULL,
			  @d_datetime,		--@Created datetime = NULL,
			  1					--@IsInherited bit = 0
	  print 'category updated: ' + @v_categorydesc
		end
      		
		Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

		print 'exec dbo.mdpsp_avto_CategoryEx_Title_Series_Update'

		exec dbo.mdpsp_avto_CategoryEx_Title_Series_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							 --@CreatorId INT, 
			@d_datetime,				 --@Created DATETIME, 
			1,							 --@ModifierId INT, 
			@d_datetime,				 --@Modified DATETIME, 
			null,						 --@Retval INT OUT, 
			@v_tableid,		   --@pss_subject_categorytableid int
			@v_datacode,		  --@PSS_subject_datacode int
			0, 		            --@PSS_subject_datasubcode
			@v_Description    --@GeneralDescription
			print 'title series inserted'
	end
  
	FETCH NEXT FROM c_pss_series
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @v_alternatedesc1

	select  @category_fetch_status = @@FETCH_STATUS
end

close c_pss_series
deallocate c_pss_series


END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_UNP_Category]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[qweb_ecf_Category_Insert_UNP_Category] as

DECLARE @unpcategory_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@rowcount int,
		@alternatedesc1 varchar(255),
		@v_cnt int,
		@v_tableid int


BEGIN

	SET @v_tableid = 437


	DECLARE c_pss_unpcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datacode, datacode, deletestatus, alternatedesc1
	from MIZ..gentables
	where tableid = @v_tableid
	--and deletestatus<>'Y'
	--and sortorder is not null
	

	FOR READ ONLY
			
	OPEN c_pss_unpcategories

	/* get the next one*/	
	FETCH NEXT FROM c_pss_unpcategories
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @alternatedesc1

	select  @unpcategory_fetch_status  = @@FETCH_STATUS

	 while (@unpcategory_fetch_status >-1 )
		begin
		IF (@unpcategory_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Subjects')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Subject')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Category Simple Template'
		
			select @rowcount = count(*) from category 
						where parentcategoryid = @parent_categoryid
			   		    and name = @v_categorydesc

			
			IF @rowcount>0 and @v_deletestatus='Y'
				begin
				update category set isvisible=0 where parentcategoryid=@parent_categoryid  and [name] = @v_categorydesc
				--delete from categoryex_title_subject where pss_subject_datacode=@v_datacode
				end	
			
			ELSE IF @v_deletestatus='N'
		
					begin 
						If @alternatedesc1 is not null --use alternatedesc
							SET @v_categorydesc = @alternatedesc1
							-- if a title subject record already exists just update the category table
							-- this will update name field with alternate desc in category table
							-- also, if the user changes the description or alternatedesc field in TMM 
							-- we will be changing the existing record in category table rather than inserting a new one
						If exists (select * from CategoryEx_Title_Subject where pss_subject_categorytableid = @v_tableid and pss_subject_datacode = @v_datacode)
							begin
									DECLARE @catid int
									Select @catid = objectid from CategoryEx_Title_Subject where pss_subject_categorytableid = @v_tableid and pss_subject_datacode = @v_datacode
									
									DECLARE @typeid int, 
											@pageurl nvarchar(255),
											@updated_date datetime,
											@created_date datetime,
											@IsInherited bit,
											@Code nvarchar(50)
									
									if exists (Select * FROM Category where categoryid = @catid)
													Begin

														Select @typeid = Typeid, @pageurl = PageUrl, 
															@updated_date = Updated, 
															@created_date = Created,@IsInherited = IsInherited,
															@Code = Code FROM Category where categoryid = @catid

														exec CategoryUpdate
														@catid,				--@CategoryId int = NULL output,
														@v_categorydesc,	--@Name nvarchar(50),
														@i_sortorder,		--@Ordering int = NULL,
														1,					--@IsVisible bit = NULL,
														@parent_categoryid,	--@ParentCategoryId int = NULL,
														@i_categorytemplateid,--@CategoryTemplateId int = NULL,
														@typeid,			--@TypeId int = NULL,
														@pageurl,			--@PageUrl nvarchar(255) = null,	
														1,					--@ObjectLanguageId int = NULL output,
														1,					--@LanguageId int,
														@i_metaclassid,		--@MetaClassId int = NULL,
														0,					--@ObjectGroupId int = 0,
														@updated_date,		--@Updated datetime = NULL,
														@created_date,		--@Created datetime = NULL,
														@IsInherited,		--@IsInherited bit = 0
														@Code				--@Code nvarchar(50)
													end
							
							end
						else --must be new subject category but check to make sure this name doesn't exist in category
						if not exists (Select * from category 
											where parentcategoryid = @parent_categoryid
		   										and name = @v_categorydesc)
							begin
							
								exec CategoryInsert
								NULL,				--@CategoryId int = NULL output,
								@v_categorydesc,		--@Name nvarchar(50),
								@i_sortorder,		--@Ordering int = NULL,
								1,					--@IsVisible bit = NULL,
								@parent_categoryid,	--@ParentCategoryId int = NULL,
								@i_categorytemplateid,--@CategoryTemplateId int = NULL,
								0,					--@TypeId int = NULL,
								null,				--@PageUrl nvarchar(255) = null,	
								1,					--@ObjectLanguageId int = NULL output,
								1,					--@LanguageId int,
								@i_metaclassid,		--@MetaClassId int = NULL,
								0,					--@ObjectGroupId int = 0,
								@d_datetime,		--@Updated datetime = NULL,
								@d_datetime,		--@Created datetime = NULL,
								1,					--@IsInherited bit = 0
								null				--@code nvarchar
							
								Select @Current_ObjectID = IDENT_CURRENT( 'Category' )
											
								exec dbo.mdpsp_avto_CategoryEx_Title_Subject_Update
								@Current_ObjectID,			 --@ObjectId INT, 
								1,							 --@CreatorId INT, 
								@d_datetime,				 --@Created DATETIME, 
								1,							 --@ModifierId INT, 
								@d_datetime,				 --@Modified DATETIME, 
								null,						 --@Retval INT OUT, 
								@v_tableid,						 --@pss_subject_categorytableid int, 
								@v_datacode,					 --@pss_subject_datacode int, 
								0							 --@pss_subject_datasubcode int 

							end			

					end
		end

	--This is where we insert the subcategories if they exist
	Select @v_cnt = count(*)
	from MIZ..subgentables
	where tableid = @v_tableid
	  and datacode = @v_datacode
	  
	if @v_cnt > 0 begin
    exec dbo.qweb_ecf_Category_Insert_UNP_SubCategory @v_tableid, @v_datacode
  end

	FETCH NEXT FROM c_pss_unpcategories
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @alternatedesc1
	        select  @unpcategory_fetch_status = @@FETCH_STATUS
	end

close c_pss_unpcategories
deallocate c_pss_unpcategories


END








GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory] (@i_tableid int,@i_datacode int) as

DECLARE @unpcategory_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datasubcode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@rowcount int



BEGIN

	DECLARE c_pss_unpsubcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datasubcode, COALESCE(sortorder,0), deletestatus
	from MIZ..subgentables
	where tableid = @i_tableid
	and datacode = @i_datacode
	--and deletestatus<>'Y'
	
	FOR READ ONLY
			
	OPEN c_pss_unpsubcategories

	/* get the next one*/	
	FETCH NEXT FROM c_pss_unpsubcategories
		INTO @v_categorydesc,@v_datasubcode,@i_sortorder, @v_deletestatus

	select  @unpcategory_fetch_status  = @@FETCH_STATUS

	while (@unpcategory_fetch_status >-1 )
	begin
	  IF (@unpcategory_fetch_status <>-2) 
	  begin
		  --Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID(@i_parent_datadesc)
		  -- get the parent categoryid using tableid and datacode (not description because there may be a duplicate)
				Select @parent_categoryid = ObjectId
				from CategoryEx_Title_Subject
				where pss_subject_categorytableid = @i_tableid
				and pss_subject_datacode = @i_datacode
				and pss_subject_datasubcode = 0

				Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Subject_SubCategory')
				Select @d_datetime = getdate()
				Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Category Simple Template'

				--Select * FROM categorytemplate
				--Select * FROM MetaClass
				--select * FROM CategoryEx_Title_Subject_SubCategory
				--
				--Select * FROM Category
				--where categoryid > 538
				--and categoryid < 548

				--print 	@parent_categoryid
				--print  @i_metaclassid
				--print  @i_categorytemplateid

				select @rowcount = count(*) from category 
				where parentcategoryid = @parent_categoryid
				and name = @v_categorydesc


				IF @rowcount>0 and @v_deletestatus='Y'
					begin
						update category set isvisible=0 where parentcategoryid=@parent_categoryid  and [name] = @v_categorydesc
					end	

				ELSE IF @v_deletestatus='N'
					--if this entry already exists in CategoryEx_Title_Subject_SubCategory table 
					--then the user changed the data desc of subcategory (or inactive flag) in TMM, only update
					--if it doesn't exist then insert a new record

					begin
						If exists (select * from CategoryEx_Title_Subject_SubCategory where pss_subject_categorytableid = @i_tableid and pss_subject_datacode = @i_datacode and pss_subject_datasubcode=@v_datasubcode)
							begin
									DECLARE @catid int
									Select @catid = objectid from CategoryEx_Title_Subject_SubCategory where pss_subject_categorytableid = @i_tableid and pss_subject_datacode = @i_datacode and pss_subject_datasubcode=@v_datasubcode
									
									DECLARE @typeid int, 
											@pageurl nvarchar(255),
											@updated_date datetime,
											@created_date datetime,
											@IsInherited bit,
											@Code nvarchar(50)
									
									if exists (Select * FROM Category where categoryid = @catid)
													Begin

														Select @typeid = Typeid, @pageurl = PageUrl, 
															@updated_date = Updated, 
															@created_date = Created,@IsInherited = IsInherited,
															@Code = Code FROM Category where categoryid = @catid

														exec CategoryUpdate
														@catid,				--@CategoryId int = NULL output,
														@v_categorydesc,	--@Name nvarchar(50),
														@i_sortorder,		--@Ordering int = NULL,
														1,					--@IsVisible bit = NULL,
														@parent_categoryid,	--@ParentCategoryId int = NULL,
														@i_categorytemplateid,--@CategoryTemplateId int = NULL,
														@typeid,			--@TypeId int = NULL,
														@pageurl,			--@PageUrl nvarchar(255) = null,	
														1,					--@ObjectLanguageId int = NULL output,
														1,					--@LanguageId int,
														@i_metaclassid,		--@MetaClassId int = NULL,
														0,					--@ObjectGroupId int = 0,
														@updated_date,		--@Updated datetime = NULL,
														@created_date,		--@Created datetime = NULL,
														@IsInherited,		--@IsInherited bit = 0
														@Code				--@Code nvarchar(50)
													end
							
							end
						else --must be new subject category but check to make sure this name doesn't exist in category table
							if not exists (Select * from category 
												where parentcategoryid = @parent_categoryid
		   											and name = @v_categorydesc)
								begin
								
									exec CategoryInsert
									NULL,				--@CategoryId int = NULL output,
									@v_categorydesc,		--@Name nvarchar(50),
									@i_sortorder,		--@Ordering int = NULL,
									1,					--@IsVisible bit = NULL,
									@parent_categoryid,	--@ParentCategoryId int = NULL,
									@i_categorytemplateid,--@CategoryTemplateId int = NULL,
									0,					--@TypeId int = NULL,
									null,				--@PageUrl nvarchar(255) = null,	
									1,					--@ObjectLanguageId int = NULL output,
									1,					--@LanguageId int,
									@i_metaclassid,		--@MetaClassId int = NULL,
									0,					--@ObjectGroupId int = 0,
									@d_datetime,		--@Updated datetime = NULL,
									@d_datetime,		--@Created datetime = NULL,
									1,					--@IsInherited bit = 0
									null				--@code nvarchar
								
									Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

									exec dbo.mdpsp_avto_CategoryEx_Title_Subject_SubCategory_Update
									@Current_ObjectID,			 --@ObjectId INT, 
									1,							 --@CreatorId INT, 
									@d_datetime,				 --@Created DATETIME, 
									1,							 --@ModifierId INT, 
									@d_datetime,				 --@Modified DATETIME, 
									null,						 --@Retval INT OUT, 
									@i_tableid,						 --@pss_subject_categorytableid int, 
									@i_datacode,					 --@pss_subject_datacode int, 
									@v_datasubcode				 --@pss_subject_datasubcode int 

								end	

					end
				
      end

	  FETCH NEXT FROM c_pss_unpsubcategories
		  INTO @v_categorydesc,@v_datasubcode,@i_sortorder, @v_deletestatus
		  
	  select  @unpcategory_fetch_status = @@FETCH_STATUS
    end

  close c_pss_unpsubcategories
  deallocate c_pss_unpsubcategories
END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_WebFeature]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Category_Insert_WebFeature] as

DECLARE @unpWebFeature_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_pss_featuredjournal_categoryid int

BEGIN

	DECLARE c_pss_unpWebFeature INSENSITIVE CURSOR
	FOR

	Select datadesc, datacode
	from MIZ..gentables
	where tableid = 434
	and deletestatus<>'Y'
	--and sortorder is not null

	FOR READ ONLY
			
	OPEN c_pss_unpWebFeature

	FETCH NEXT FROM c_pss_unpWebFeature
		INTO @v_categorydesc,@v_datacode

	select  @unpWebFeature_fetch_status  = @@FETCH_STATUS

	 while (@unpWebFeature_fetch_status >-1 )
		begin
		IF (@unpWebFeature_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Web Feature')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Web_Feature')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'

			If not exists (Select * from category
							where parentcategoryid = @parent_categoryid		
							  and name = @v_categorydesc)

			begin
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@v_categorydesc,		--@Name nvarchar(50),
			0,					--@Ordering int = NULL,
			1,					--@IsVisible bit = NULL,
			@parent_categoryid,	--@ParentCategoryId int = NULL,
			@i_categorytemplateid, --@CategoryTemplateId int = NULL,
			0,					--@TypeId int = NULL,
			null,				--@PageUrl nvarchar(255) = null,	
			1,					--@ObjectLanguageId int = NULL output,
			1,					--@LanguageId int,
			@i_metaclassid,		--@MetaClassId int = NULL,
			0,					--@ObjectGroupId int = 0,
			@d_datetime,		--@Updated datetime = NULL,
			@d_datetime,		--@Created datetime = NULL,
			1					--@IsInherited bit = 0
		

			Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

			exec dbo.mdpsp_avto_CategoryEx_Web_Feature_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							 --@CreatorId INT, 
			@d_datetime,				 --@Created DATETIME, 
			1,							 --@ModifierId INT, 
			@d_datetime,				 --@Modified DATETIME, 
			null,						 --@Retval INT OUT, 
			434,						 --@pss_subject_categorytableid int, 
			@v_datacode,				 --@pss_subject_datacode int, 
			0							 --@pss_subject_datasubcode int 

			end
	end

	FETCH NEXT FROM c_pss_unpWebFeature
		INTO @v_categorydesc,@v_datacode
	        select  @unpWebFeature_fetch_status = @@FETCH_STATUS
		end

close c_pss_unpWebFeature
deallocate c_pss_unpWebFeature


			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('New This Month')
			Select @i_pss_featuredjournal_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Journal & Bison')

		


--			exec dbo.mdpsp_avto_CategoryEx_Home_Update
--			@parent_categoryid,		            --@ObjectId INT, 
--			1,						            --@CreatorId INT, 
--			@d_datetime,			            --@Created DATETIME, 
--			0,						            --@ModifierId INT, 
--			@d_datetime,			            --@Modified DATETIME, 
--			NULL,					            --@Retval INT OUT, 
--			@parent_categoryid,		            --@pss_featuredtitle_categoryid int, 
--			NULL,				                --@UNP_News ntext, 
--			NULL,				                --@Special_Offers ntext, 
--			@i_pss_featuredjournal_categoryid,	--@pss_featuredjournal_categoryid int 
--		    NULL				                --@Special_Messages ntext






END






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_CategoryExAuthorHome_Update]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_CategoryExAuthorHome_Update] as

DECLARE @i_home_categoryid int,
		@d_datetime datetime,
		@v_featured_author_categoryid int
		


BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Authors')
	Select @v_featured_author_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Author')
	
	Select @d_datetime = getdate()

	exec [dbo].[mdpsp_avto_CategoryEx_Author_Home_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	@v_featured_author_categoryid --@featured_author_categoryid

END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_CategoryExHome_Update]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_CategoryExHome_Update] as

DECLARE @i_home_categoryid int,
		@i_title_categoryid int,
		@i_journal_categoryid int,
		@d_datetime datetime,
		@n_UNP_News varchar(max),
		@n_SpecialOffers varchar(max),
		@n_SpecialMessages varchar(max),
		@v_seasonalcatalog_path varchar(max),
		@v_seasonalcatalogimage_path varchar(max)
		


BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Home')
	Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Titles')
	Select @i_journal_categoryid = 0 -- dbo.qweb_ecf_get_Category_ID('Home - New This Month')
	Select @d_datetime = getdate()
	select @v_seasonalcatalog_path = seasonalcatalog from categoryex_home where objectid = @i_home_categoryid
	select @v_seasonalcatalogimage_path = seasonalcatalogimage from categoryex_home where objectid = @i_home_categoryid

Select @n_UNP_News = ''
Select @n_SpecialOffers = ''
Select @n_SpecialMessages = ''


Select @n_UNP_News = UNP_News,
	   @n_SpecialOffers = Special_Offers,
	   @n_SpecialMessages = Special_Messages
from CategoryEx_Home
where objectid = @i_home_categoryid

	

	exec [dbo].[mdpsp_avto_CategoryEx_Home_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	0,					  --@pss_featuredtitle_categoryid int, 
	@i_title_categoryid,  --@featuredproduct_categoryid int, 
	@v_seasonalcatalog_path,				  --@seasonalcatalog
	@v_seasonalcatalogimage_path,					--@seasonalcatalogimage	
	@i_journal_categoryid,--@newthismonth_categoryid int, 
	0,					  --@pss_featuredjournal_categoryid int, 
	@n_UNP_News,		  --@UNP_News ntext, 
	@n_SpecialOffers,	  --@Special_Offers ntext, 
	@n_SpecialMessages	  --@Special_Messages ntext




END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_get_newsarchive_dates]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_get_newsarchive_dates] as

SET NOCOUNT ON
DECLARE @Err int

BEGIN

  SELECT distinct datepart(YY,pubdate) 'PubYear',datepart(MM,pubdate) 'PubMonth',
         cast(datepart(YY,pubdate) as varchar) + '|' + cast(datepart(MM,pubdate) as varchar) 'PubYearMonth',
         DATENAME(MM, pubdate) + ' ' + CAST(YEAR(pubdate) AS VARCHAR(4)) AS 'FormattedDesc'
    FROM newsmain
   WHERE published = 1
ORDER BY PubYear desc, PubMonth desc 

	SET @Err = @@Error
	RETURN @Err
END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_import]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[qweb_ecf_import] (@v_dbname varchar(255),@v_importtype varchar(1)) as

DECLARE @sql varchar(8000),
		@i_bookkey int,
		@i_mediatypecode int,
		@i_mediatypesubcode int,
		@i_titlefetchstatus int

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
	
	print @sql
	exec sp_sqlexec @sql

	end

If @v_importtype = 'I' -- Incremental Import
	begin

	Select @sql = 
	'Insert into qweb_ecfbookkeys (bookkey, mediatypecode, mediatypesubcode)
	Select distinct bookkey, mediatypecode, mediatypesubcode
	from '+ @v_dbname+ '..bookdetail 
	where 
		(bookkey in (Select bookkey from ' +@v_dbname+ '..titlehistory where lastmaintdate > getdate() -2))
        or (bookkey in (Select bookkey from ' +@v_dbname+ '..associatedtitles where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..book where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookdetail where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..booksubjectcategory where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..printing where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookauthor where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookprice where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookdates where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..bookcomments where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..filelocation where lastmaintdate > getdate() -2))
		or (bookkey in (Select bookkey from ' +@v_dbname+ '..tourevents where lastmaintdate > getdate() -2))'
		

	print @sql
	exec sp_sqlexec @sql
	end

      print 'qweb_ecf_Category_Insert_UNP_Category Starting'
		exec qweb_ecf_Category_Insert_UNP_Category
			print 'qweb_ecf_Category_Insert_UNP_Category COMPLETE'

      print 'qweb_ecf_Category_Insert_Series Starting'
		exec qweb_ecf_Category_Insert_Series
			print 'qweb_ecf_Category_Insert_Series COMPLETE'

      print 'qweb_ecf_Category_Insert_WebFeature starting'
		exec qweb_ecf_Category_Insert_WebFeature
			print 'qweb_ecf_Category_Insert_WebFeature COMPLETE'

      print 'qweb_ecf_Category_Insert_Author_WebFeature starting'
		exec qweb_ecf_Category_Insert_Author_WebFeature
			print 'qweb_ecf_Category_Insert_Author_WebFeature COMPLETE'

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
		  print 'qweb_ecf_Insert_Products_Authors Starting'
		exec [dbo].[qweb_ecf_Insert_Products_Authors] @i_bookkey, @v_importtype
			print 'qweb_ecf_Insert_Products_Authors COMPLETE'
		
		  print 'qweb_ecf_ProductEx_Authors Starting'
		exec [dbo].[qweb_ecf_ProductEx_Authors] @i_bookkey, @v_importtype
			print 'qweb_ecf_ProductEx_Authors COMPLETE'

      print '[qweb_ecf_Categorization_Insert_Authors] Starting'
		exec [dbo].[qweb_ecf_Categorization_Insert_Authors] @i_bookkey
			print '[qweb_ecf_Categorization_Insert_Authors] COMPLETE'

    -- Titles
		If (@i_mediatypecode <> 6)-- Not a Journal
		begin

			print @i_mediatypecode
			print @i_mediatypesubcode

          print 'qweb_ecf_Insert_Products Starting'
				exec [dbo].[qweb_ecf_Insert_Products] @i_bookkey, @v_importtype
					print 'qweb_ecf_Insert_Products COMPLETE'

					print 'qweb_ecf_Insert_SKUs Starting'
				exec [dbo].[qweb_ecf_Insert_SKUs] @i_bookkey, @v_importtype
					print 'qweb_ecf_Insert_SKUs COMPLETE'

					print 'qweb_ecf_ProductEx_Titles Starting'
				exec [dbo].[qweb_ecf_ProductEx_Titles] @i_bookkey, @v_importtype
					print 'qweb_ecf_ProductEx_Titles COMPLETE'

					print 'qweb_ecf_SkuEx_Title_By_Format Starting'
				exec [dbo].[qweb_ecf_SkuEx_Title_By_Format] @i_bookkey, @v_importtype
					print 'qweb_ecf_SkuEx_Title_By_Format COMPLETE'

					print '[qweb_ecf_Categorization_Insert_Products] Starting'
				exec [dbo].[qweb_ecf_Categorization_Insert_Products] @i_bookkey
					print '[qweb_ecf_Categorization_Insert_Products] COMPLETE'

		end

		--If (@i_mediatypecode = 6 and @i_mediatypesubcode = 1)-- IS a Journal - Master

		--begin	
				--exec [qweb_ecf_Insert_Journal_Products] @i_bookkey, @v_importtype
					--print 'qweb_ecf_Insert_Journal_Products COMPLETE'

				--exec [dbo].[qweb_ecf_Insert_Journal_SKUs] @i_bookkey, @v_importtype
					--print 'qweb_ecf_Insert_Journal_SKUs COMPLETE'

				--exec [dbo].[qweb_ecf_ProductEx_Journals] @i_bookkey, @v_importtype
					--print 'qweb_ecf_ProductEx_Journals COMPLETE'

				--exec [dbo].[qweb_ecf_SkuEx_Journal_By_Price] @i_bookkey, @v_importtype
					--print 'qweb_ecf_SkuEx_Journal_By_Price COMPLETE'

				--exec [dbo].[qweb_ecf_Categorization_Insert_Products] @i_bookkey
					--print '[qweb_ecf_Categorization_Insert_Products] COMPLETE'
		--end

			print 'qweb_ecf_Categorization_Insert_UNP_Category Starting'
		exec qweb_ecf_Categorization_Insert_UNP_Category @i_bookkey
			print 'qweb_ecf_Categorization_Insert_UNP_Category COMPLETE'

			print 'qweb_ecf_Categorization_Insert_Series Starting'
		exec qweb_ecf_Categorization_Insert_Series @i_bookkey
			print 'qweb_ecf_Categorization_Insert_Series COMPLETE'

			print 'qweb_ecf_Categorization_Insert_WebFeature Starting'
		exec qweb_ecf_Categorization_Insert_WebFeature @i_bookkey
			print 'qweb_ecf_Categorization_Insert_WebFeature COMPLETE'

			print 'qweb_ecf_Insert_CrossSelling_Products Starting'
		exec qweb_ecf_Insert_CrossSelling_Products @i_bookkey
			print 'qweb_ecf_Insert_CrossSelling_Products COMPLETE'
		
		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP		
	  --'\\Qsiweb001\MIZ\images\' --web\'
			print 'qweb_ecf_insert_product_images Starting'
		exec qweb_ecf_insert_product_images @i_bookkey, '\\Devhorse3\C$\DevLocal\database\DEV\MSSQL\Custom\MIZ\Website\ECF\web\images\' 
			print 'qweb_ecf_insert_product_images COMPLETE'
			--'\\Qsiweb001\MIZ\images\' --web\'
		  print 'qweb_ecf_insert_sku_images Starting'
		exec qweb_ecf_insert_sku_images @i_bookkey, '\\Devhorse3\C$\DevLocal\database\DEV\MSSQL\Custom\MIZ\Website\ECF\web\images\' 
			print 'qweb_ecf_insert_sku_images COMPLETE'


		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		--  '\\Qsiweb001\MIZ\images\downloads\excerpts\' 
		  print 'qweb_ecf_insert_sku_excerpts Starting'
		exec qweb_ecf_insert_sku_excerpts @i_bookkey, '\\Devhorse3\C$\DevLocal\database\DEV\MSSQL\Custom\MIZ\Website\ECF\web\downloads\excerpts\'
			print 'qweb_ecf_insert_sku_excerpts COMPLETE'

		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		--exec [dbo].qweb_ecf_insert_journal_reco_forms @i_bookkey,'\\mountain\clients\MIZ\Images\' 
			--print 'qweb_ecf_insert_journal_reco_forms COMPLETE'

		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		--exec qweb_ecf_insert_sku_digitalpresskit @i_bookkey, '\\mountain\clients\MIZ\Images\' 
			--print 'qweb_ecf_insert_sku_digitalpresskit COMPLETE'
      print 'qweb_ecf_Insert_ProductObjectAccess Starting'
		exec qweb_ecf_Insert_ProductObjectAccess @i_bookkey
			print 'qweb_ecf_Insert_ProductObjectAccess COMPLETE'

		end

	FETCH NEXT FROM c_qweb_titles
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_qweb_titles
deallocate c_qweb_titles

			print 'qweb_ecf_Categorization_Insert_Author_WebFeature Starting'
		exec qweb_ecf_Categorization_Insert_Author_WebFeature
			print 'qweb_ecf_Categorization_Insert_Author_WebFeature COMPLETE'

			print 'qweb_ecf_CategoryExHome_Update Starting'
		exec qweb_ecf_CategoryExHome_Update
			print 'qweb_ecf_CategoryExHome_Update COMPLETE'

			print 'qweb_ecf_CategoryExHome_Update Starting'
		exec qweb_ecf_CategoryExAuthorHome_Update
			print 'qweb_ecf_CategoryExHome_Update COMPLETE'

			print 'qweb_ecf_Insert_CategoryObjectAccess Starting'
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

END









GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_author_images]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_insert_author_images] (@i_contactkey int, @v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prodthumb_metafieldid int,
		@i_c_contactkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_productfetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40),
		@i_fileexists_flag int,
		@i_maxsubbookkey int

BEGIN

		SELECT @i_prodthumb_metafieldid = dbo.qweb_ecf_get_MetaFieldID('Contributor_MediumToThumbImage')

		delete from metafilevalue where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_contactkey as varchar)
                              and (m.metafieldid = @i_prodthumb_metafieldid))

		
		delete from metakey where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_contactkey as varchar)
                              and (m.metafieldid = @i_prodthumb_metafieldid))


  DECLARE c_ecf_products CURSOR fast_forward FOR

	Select productid, 
	dbo.qweb_ecf_get_metaclassid('Contributors'),
	dbo.qweb_ecf_get_MetaFieldID('Contributor_MediumToThumbImage'),
	code
	from product
	where code = cast(@i_contactkey as varchar)
	/*and code in (Select cast(bookkey as varchar) from UNL..bookdetail where publishtowebind = 1)*/
			
	OPEN c_ecf_products

	FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodthumb_metafieldid,
			@i_c_contactkey

	select  @i_productfetchstatus  = @@FETCH_STATUS

	 while (@i_productfetchstatus >-1 )
		begin
		IF (@i_productfetchstatus <>-2) 
		begin

		/** BEGIN PRODUCT MEDIUM IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodthumb_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @d_datetime = getdate()
		
		--  QSI  -- '\\mcdonald\mediachase\barb_images\AuthorImages\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(commenttext,50,datalength(commenttext)) 
		from MIZ..qsicomments 
		where commenttypecode = 12 and commentkey = @i_c_contactkey

--print @v_file
--print cast(@i_product_id as varchar)
--print cast(@i_current_metakey as varchar)

		-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

	  update productex_contributors
	  set Contributor_LargeToMediumImage = @i_current_metakey
	  where objectid = @i_product_id

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'defaultCover.png'
		end 

		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file
		/** END PRODUCT MEDIUM IMAGE **************************************************/

		/** BEGIN PRODUCT THUMB IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodthumb_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @d_datetime = getdate()
		
		--  QSI  -- '\\mcdonald\mediachase\barb_images\AuthorImages\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(commenttext,50,datalength(commenttext)) 
		from MIZ..qsicomments 
		where commenttypecode = 12 and commentkey = @i_c_contactkey

--print @v_file
--print cast(@i_product_id as varchar)
--print cast(@i_current_metakey as varchar)

		-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

	  update productex_contributors
	  set Contributor_MediumToThumbImage = @i_current_metakey
	  where objectid = @i_product_id

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'defaultCover.png'
		end 

		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file
		/** END PRODUCT THUMB IMAGE **************************************************/
	end

  FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodthumb_metafieldid,
			@i_c_contactkey

  select  @i_productfetchstatus  = @@FETCH_STATUS
  end

  close c_ecf_products
  deallocate c_ecf_products


		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update productex_contributors
		set Contributor_MediumToThumbImage = Null
		where Contributor_MediumToThumbImage in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes


END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_CategoryObjectAccess]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Insert_CategoryObjectAccess] as
DECLARE @i_categoryid int,
@i_ecfcategory_fetchstatus int

BEGIN

	DECLARE c_ecf_categories INSENSITIVE CURSOR
	FOR



	Select categoryid
	from category
	where parentcategoryid <> 0
	and categoryid not in (Select objectid from ObjectAccess)
	

	FOR READ ONLY
			
	OPEN c_ecf_categories

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_ecf_categories
		INTO @i_categoryid

	select  @i_ecfcategory_fetchstatus  = @@FETCH_STATUS

	 while (@i_ecfcategory_fetchstatus >-1 )
		begin
		IF (@i_ecfcategory_fetchstatus <>-2) 
		begin
			
	--Category = sys,category_id,1,3,1,0,1				

	If not exists (Select * from ObjectAccess where objectid = @i_categoryid)

		begin
		exec [dbo].[ObjectAccessInsert]
		NULL,		 --@ObjectAccessId int = NULL output,
		@i_categoryid,--@ObjectId int,
		1,			 --@PrincipalId int,
		3,			 --@ObjectTypeId int,
		1,			 --@AllowLevel tinyint,
		0,			 --@DenyLevel tinyint,
		1			 --@IsInherited bit
		end

	end

	FETCH NEXT FROM c_ecf_categories
		INTO @i_categoryid
	        select  @i_ecfcategory_fetchstatus  = @@FETCH_STATUS
		end

close c_ecf_categories
deallocate c_ecf_categories


END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_CrossSelling_Products]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[qweb_ecf_Insert_CrossSelling_Products] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
        @i_associatetitlebookkey int,
		@i_sortorder int,
		@i_associated_titlefetchstatus int,
		@i_bookkey_titlefetchstatus int,
		@i_productid int,
		@i_associated_productid int,	
		@i_published_bookkey int

BEGIN

	delete 
	from CrossSelling 
	where productid IN (Select productid from product where code = cast(@i_bookkey as varchar))

	DECLARE c_pss_publishedbookkeys INSENSITIVE CURSOR
	FOR

	Select bookkey from MIZ..bookdetail 
	where publishtowebind = 1
	and bookkey = @i_bookkey

	FOR READ ONLY
			
	OPEN c_pss_publishedbookkeys

	FETCH NEXT FROM c_pss_publishedbookkeys
		INTO @i_published_bookkey

	select  @i_bookkey_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_bookkey_titlefetchstatus >-1 )
		begin
		IF (@i_bookkey_titlefetchstatus <>-2) 
		begin


					DECLARE c_pss_associated_titles INSENSITIVE CURSOR
					FOR

          -- only insert available titles
          select top 4 b.bookkey, b.associatedtitlebookkey, b.sortorder
          from dbo.qweb_ecf_get_crossselling_products(@i_published_bookkey) b, MIZ..bookdetail bd
          where b.associatedtitlebookkey = bd.bookkey
	 	        and bd.bisacstatuscode in (1)
          order by b.sortorder, NEWID()

					--Select top 4 bookkey, associatedtitlebookkey, sortorder
					--from qweb_ecf_associated_crosselling_titles_vw
					--where bookkey = @i_published_bookkey
					--order by sortorder
				 
					FOR READ ONLY
							
					OPEN c_pss_associated_titles

					/* Get next bookkey that has more than one citation row */	
					FETCH NEXT FROM c_pss_associated_titles
						INTO @i_c_bookkey, @i_associatetitlebookkey, @i_sortorder

					select  @i_associated_titlefetchstatus  = @@FETCH_STATUS

					 while (@i_associated_titlefetchstatus >-1 )
						begin
						IF (@i_associated_titlefetchstatus <>-2) 
						begin
							

						Select @i_productid = dbo.qweb_ecf_get_product_id (@i_bookkey)
						Select @i_associated_productid = dbo.qweb_ecf_get_product_id (@i_associatetitlebookkey)
								
            if (@i_productid > 0 AND @i_associated_productid > 0) begin
								exec dbo.CrossSellingInsert

								NULL,					 --@CrossSellingId int = NULL output,
								@i_productid,			 --@ProductId int,
								@i_associated_productid, --@RelatedProductId int,
								@i_sortorder		     --@Ordering int = NULL
            end
            
						end

					FETCH NEXT FROM c_pss_associated_titles
						INTO @i_c_bookkey, @i_associatetitlebookkey, @i_sortorder
							select  @i_associated_titlefetchstatus  = @@FETCH_STATUS
						end

				close c_pss_associated_titles
				deallocate c_pss_associated_titles
		end
		FETCH NEXT FROM c_pss_publishedbookkeys
			INTO @i_published_bookkey
				select  @i_bookkey_titlefetchstatus  = @@FETCH_STATUS
		end

	close c_pss_publishedbookkeys
	deallocate c_pss_publishedbookkeys




END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_customer_roles]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure  [dbo].[qweb_ecf_Insert_customer_roles] (@i_roleid int) as

declare
@i_customerid int,
@i_customerroleid int

DECLARE c_customerid CURSOR FOR 
select customerid 
from customeraccount 
where disabled=1
FOR READ ONLY
BEGIN
open c_customerid
   FETCH NEXT FROM c_customerid into @i_customerid
   WHILE (@@FETCH_STATUS <> -1) BEGIN
     exec CustomerRoleInsert NULL, @i_customerid, @i_roleid
    FETCH NEXT FROM c_customerid into @i_customerid
   END 
close c_customerid
deallocate c_customerid
END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Journal_Products]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Insert_Journal_Products] (@i_bookkey int, @v_importtype varchar(1)) as

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
			from MIZ..book b, MIZ..bookdetail bd
			where b.bookkey = bd.bookkey
			and b.bookkey = @i_bookkey

			If @i_bookkey = @i_workkey
			begin

				Select @v_title = Substring(MIZ.dbo.qweb_get_Title(@i_bookkey,'f'),1,50)
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






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_journal_reco_forms]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_insert_journal_reco_forms] (@i_bookkey int,@v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prod_recoform_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_prodfetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40)

BEGIN

	DECLARE c_ecf_journal_prods INSENSITIVE CURSOR
	FOR

	Select p.productid, 
	dbo.qweb_ecf_get_metaclassid('Journals'),
	dbo.qweb_ecf_get_MetaFieldID('JournalLibraryRecommendationForm_File'),
	p.code
	from product p
	where p.code = CAST(@i_bookkey as varchar)
	and p.code in (Select bookkey from MIZ..bookdetail where publishtowebind = 1)


	FOR READ ONLY
			
	OPEN c_ecf_journal_prods

	FETCH NEXT FROM c_ecf_journal_prods
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prod_recoform_metafieldid,
			@i_c_bookkey

	select  @i_prodfetchstatus  = @@FETCH_STATUS

	 while (@i_prodfetchstatus >-1 )
		begin
		IF (@i_prodfetchstatus <>-2) 
		begin

		
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prod_recoform_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT      --@Retval	INT	OUT


	
		Select @d_datetime = getdate()

		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
		--\\mcdonald\mediachase\unl_images\e://Mcdonald/mediachase/UNL_IMAGES/Library%20Recommendation%20Forms/Library_recommendation_SAIL.pdf


		Select @v_file = @v_filepath + Substring(pathname,4,len(pathname)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 13 and bookkey = @i_c_bookkey
		--print @v_file
		--print @v_filepath


	-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'application/pdf',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		
		
			update ProductEx_Journals
			set JournalLibraryRecommendationForm_File = @i_current_metakey
			where objectid = @i_product_id


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		

		end

FETCH NEXT FROM c_ecf_journal_prods
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prod_recoform_metafieldid,
			@i_c_bookkey

	        select  @i_prodfetchstatus  = @@FETCH_STATUS
		end

		close c_ecf_journal_prods
		deallocate c_ecf_journal_prods

		-- get rid of missing image rows in metakey and metafilevalue
		-- was causing error
	
		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update ProductEx_Journals
		set JournalLibraryRecommendationForm_File = Null
		where JournalLibraryRecommendationForm_File in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Journal_SKUs]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
		@i_taxcategoryid int,
		@i_packageid int

BEGIN

		Select @i_publishtowebind = bd.publishtowebind
		from MIZ..book b, MIZ..bookdetail bd
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

	Select bookkey, finalprice, MIZ.dbo.get_gentables_desc(306, pricetypecode, 'D') as pricetype, Cast(bookkey as varchar) + '-' + CAST(pricetypecode as varchar) + '-' + CAST(currencytypecode as varchar) as pss_sku_code
	from MIZ..bookprice
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
		
		
		Select @v_title = MIZ.dbo.qweb_get_Title(@i_bookkey,'f') + ' (' + @v_pricetype + ')'
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




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_product_images]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[qweb_ecf_insert_product_images] (@i_bookkey int, @v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prodlarge_metafieldid int,
		@i_prodthumb_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_productfetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40),
		@i_fileexists_flag int,
		@i_maxsubbookkey int

BEGIN


		delete from metafilevalue where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_bookkey as varchar))
		
		delete from metakey where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_bookkey as varchar))


	DECLARE c_ecf_products INSENSITIVE CURSOR
	FOR

	Select productid, 
	dbo.qweb_ecf_get_metaclassid('Titles'),
	dbo.qweb_ecf_get_MetaFieldID('Product_LargeToMediumImage'),
	dbo.qweb_ecf_get_MetaFieldID('Product_LargeToThumbImage'),
	code
	from product
	where code = cast(@i_bookkey as varchar)
	/*and code in (Select cast(bookkey as varchar) from MIZ..bookdetail where publishtowebind = 1)*/

	FOR READ ONLY
			
	OPEN c_ecf_products

	FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodlarge_metafieldid,
			@i_prodthumb_metafieldid,
			@i_c_bookkey

	select  @i_productfetchstatus  = @@FETCH_STATUS

	 while (@i_productfetchstatus >-1 )
		begin
		IF (@i_productfetchstatus <>-2) 
		begin

		/** BEGIN PRODUCT LARGE IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodlarge_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = MIZ.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()
		select @i_maxsubbookkey=MIZ.dbo.qweb_get_subordinate_max_web(@i_c_bookkey)

		
		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		--Select @v_file = @v_filepath + Substring(pathname,len(pathname)-16,len(pathname)) 
		Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_maxsubbookkey

		IF coalesce(@v_file,'') =''
			begin 
				Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
				from MIZ..filelocation 
				where printingkey = 1 and filetypecode = 12 and bookkey = @i_maxsubbookkey
			end

		--print @v_file 

		-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		If @v_mediatype <> 'Journal'
			begin
			update productex_titles
			set Product_LargeToMediumImage = @i_current_metakey
			where objectid = @i_product_id
			end
		Else
			begin
			update ProductEx_Journals
			set Product_LargeToMediumImage = @i_current_metakey
			where objectid = @i_product_id
			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0
		begin
		Select @v_file = @v_filepath + 'defaultCover.png'
		end 


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file


		/** END PRODUCT LARGE IMAGE **************************************************/

		/** BEGIN PRODUCT THUMBNAIL IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,           --@MetaObjectId INT
		@i_metaclass_id,	     --@MetaClassId	INT,
		@i_prodthumb_metafieldid,--@MetaFieldId	INT,
		@i_current_metakey OUTPUT						 --@Retval	INT	


		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = MIZ.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()
		select @i_maxsubbookkey=MIZ.dbo.qweb_get_subordinate_max_web(@i_c_bookkey)

	
		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		--Select @v_file = @v_filepath + Substring(pathname,len(pathname)-16,len(pathname))  
		Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_maxsubbookkey

		IF coalesce(@v_file,'') =''
			begin 
				Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
				from MIZ..filelocation 
				where printingkey = 1 and filetypecode = 12 and bookkey = @i_maxsubbookkey
			end



		--print @v_file 

		-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME


		If @v_mediatype <> 'Journal'
			begin
			update productex_titles
			set Product_LargeToThumbImage = @i_current_metakey
			where objectid = @i_product_id
			end
		Else
			begin
			update ProductEx_Journals
			set Product_LargeToThumbImage = @i_current_metakey
			where objectid = @i_product_id
			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0
		begin
		Select @v_file = @v_filepath + 'defaultCover.png'
		end  


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END PRODUCT THUMBNAIL IMAGE **************************************************/

	end

FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodlarge_metafieldid,
			@i_prodthumb_metafieldid,
			@i_c_bookkey

	        select  @i_productfetchstatus  = @@FETCH_STATUS
		end

close c_ecf_products
deallocate c_ecf_products


		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update productex_titles
		set Product_LargeToMediumImage = Null
		where Product_LargeToMediumImage in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes


END






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_ProductObjectAccess]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Insert_ProductObjectAccess] (@i_bookkey int) as
DECLARE @i_productid int,
@i_ecfproduct_fetchstatus int

BEGIN

	DECLARE c_ecf_products INSENSITIVE CURSOR
	FOR

	Select productid
	from product
	where code = cast(@i_bookkey as varchar)
	

	FOR READ ONLY
			
	OPEN c_ecf_products

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_ecf_products
		INTO @i_productid

	select  @i_ecfproduct_fetchstatus  = @@FETCH_STATUS

	 while (@i_ecfproduct_fetchstatus >-1 )
		begin
		IF (@i_ecfproduct_fetchstatus <>-2) 
		begin
			
				
	If not exists (Select * from objectaccess where objectid = @i_productid)
			begin

			exec [dbo].[ObjectAccessInsert]
			NULL,		 --@ObjectAccessId int = NULL output,
			@i_productid,--@ObjectId int,
			1,			 --@PrincipalId int,
			1,			 --@ObjectTypeId int,
			1,			 --@AllowLevel tinyint,
			0,			 --@DenyLevel tinyint,
			0			 --@IsInherited bit

			end
		end

	FETCH NEXT FROM c_ecf_products
		INTO @i_productid
	        select  @i_ecfproduct_fetchstatus  = @@FETCH_STATUS
		end

close c_ecf_products
deallocate c_ecf_products


END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Products]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Insert_Products] (@i_bookkey int, @v_importtype varchar(1)) as

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
			from MIZ..book b, MIZ..bookdetail bd
			where b.bookkey = bd.bookkey
			and b.bookkey = @i_bookkey
			
			select @pss_publishtowebind=0

			select @i_pubtoweb_count = count (*) from MIZ..bookdetail bd
			where publishtowebind=1
			and bookkey in (select bookkey from MIZ..book where workkey=@i_workkey)

			If @i_pubtoweb_count >0 
			begin				
			 select @pss_publishtowebind=1
			end
			
			If @i_bookkey = @i_workkey and  @pss_publishtowebind=1
			begin

				Select @v_title = Substring(MIZ.dbo.qweb_get_Title(@i_bookkey,'T'),1,50)
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

				Select @v_title = Substring(MIZ.dbo.qweb_get_Title(@i_bookkey,'T'),1,50)
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






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_Products_Authors]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_Insert_Products_Authors] (@i_bookkey int, @v_importtype varchar(1)) as

DECLARE @v_contactkey int,
		@v_fetchstatus int,
		@i_MetaClassID int,
		@v_displayname nvarchar(50),
		@d_datetime datetime,
		@d_createdate datetime,
		@pss_publishtowebind int,
		@product_id int,
		@i_template_id int,
		@i_pubtoweb_count int
		
BEGIN

  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select authorkey, displayname
  	  from MIZ..bookauthor b, MIZ..bookdetail bd, MIZ..globalcontact c
	   where b.bookkey = bd.bookkey
	     and b.authorkey = c.globalcontactkey
	 	   and b.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1
				
	OPEN c_pss_authors
	
	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey, @v_displayname

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1) begin
	  IF (@v_fetchstatus <>-2) begin

			Select @v_displayname = Substring(@v_displayname,1,50)
			Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Contributors')
			Select @d_datetime = getdate()
			Select @i_template_id = ProductTemplateID from producttemplate where name = 'Author Template'
						
			If not exists (Select * from product where code = cast(@v_contactkey as varchar)) 
			begin
				exec dbo.ProductInsert
				NULL,					--@ProductId
				@v_displayname,				--@Name
				1,	--@Visible
				@i_template_id,			--@ProductTemplateId  --using book template for now
				@i_MetaClassID,			--@MetaClassId
				@d_datetime,			--@Updated
				@d_datetime,			--@Created
				1,						--@ObjectLanguageId
				1,						--@LanguageId
				0,						--@ObjectGroupId
				0,						--@IsInherited
				@v_contactkey				--@Code (bookkey)
			end

			If exists (Select * from product where code = cast(@v_contactkey as varchar))
			begin

				Select @product_id = dbo.qweb_ecf_get_product_id(@v_contactkey)	
				Select @d_createdate = created from product where code = cast(@v_contactkey as varchar)

				exec dbo.ProductUpdate
				@product_id,			--@ProductId int,
				@v_displayname,				--@Name nvarchar(50),
				NULL,					--@Description ntext = NULL,
				NULL,					--@Features ntext = NULL,
				1,	--@Visible bit = NULL,
				@i_template_id,			--@ProductTemplateId int = NULL,
				@i_MetaClassID,		    --@MetaClassId int = NULL,
				@d_datetime,			--@Updated datetime = NULL,	
				@d_createdate,			--@Created datetime = NULL,
				1,						--@ObjectLanguageId int = NULL,
				1,						--@LanguageId int,
				0,						--@ObjectGroupId int = 0,
				0,						--@IsInherited bit = 0,
				@v_contactkey				--@Code nvarchar(50) = NULL
			end
							
--			IF @pss_publishtowebind=0 
--			begin
--
--				Select @v_title = Substring(UNL.dbo.qweb_get_Title(@i_bookkey,'f'),1,50)
--				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Titles')
--				Select @d_datetime = getdate()
--				Select @i_template_id = ProductTemplateID from producttemplate where name = 'Book Template'
--				
--				If exists (Select * from product where code = cast(@i_bookkey as varchar))
--				begin
--
--					Select @product_id = dbo.qweb_ecf_get_product_id(@i_bookkey)	
--					Select @d_createdate = created from product where code = cast(@i_bookkey as varchar)
--
--					exec dbo.ProductUpdate
--
--					@product_id,			--@ProductId int,
--					@v_title,				--@Name nvarchar(50),
--					NULL,					--@Description ntext = NULL,
--					NULL,					--@Features ntext = NULL,
--					0,	                      --@Visible bit = NULL,
--					@i_template_id,			--@ProductTemplateId int = NULL,
--					@i_MetaClassID,		    --@MetaClassId int = NULL,
--					@d_datetime,			--@Updated datetime = NULL,	
--					@d_createdate,			--@Created datetime = NULL,
--					1,						--@ObjectLanguageId int = NULL,
--					1,						--@LanguageId int,
--					0,						--@ObjectGroupId int = 0,
--					0,						--@IsInherited bit = 0,
--					@i_bookkey				--@Code nvarchar(50) = NULL
--				end
--				
--			end -- @i_bookkey <> @i_workkey

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey, @v_displayname

	    select  @v_fetchstatus  = @@FETCH_STATUS
	  END
	END
	
  close c_pss_authors
  deallocate c_pss_authors
END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_sku_digitalpresskit]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_insert_sku_digitalpresskit] (@i_bookkey int, @v_filepath varchar(255)) as

DECLARE @i_sku_id int,
		@i_metaclass_id int,
		@i_sku_digitalpresskit_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_skufetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40)

BEGIN

	DECLARE c_ecf_skus INSENSITIVE CURSOR
	FOR

	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('Digital_Press_Kit'),
	f.pss_sku_bookkey
	from sku s, skuex_title_by_format f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from MIZ..bookdetail where publishtowebind = 1)
	


	FOR READ ONLY
			
	OPEN c_ecf_skus

	FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_sku_digitalpresskit_metafieldid,
			@i_c_bookkey

	select  @i_skufetchstatus  = @@FETCH_STATUS

	 while (@i_skufetchstatus >-1 )
		begin
		IF (@i_skufetchstatus <>-2) 
		begin

		/** BEGIN SKU DIGITAL PRESS KIT *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_sku_digitalpresskit_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT      --@Retval	INT	OUT


		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @d_datetime = getdate()
		
		--  QSI  -- '\\mcdonald\mediachase\UNL_IMAGES\'
		--  UNP  -- '\\unp-muskie\Images'  

		Select @v_file = @v_filepath + Substring(pathname,4,len(pathname)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 12 and bookkey = @i_bookkey


	-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'application/pdf',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		
			update skuex_title_by_format
			set digital_press_kit = @i_current_metakey
			where objectid = @i_sku_id


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU DIGITAL PRESS KIT **************************************************/

		end

FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_sku_digitalpresskit_metafieldid,
			@i_c_bookkey

	        select  @i_skufetchstatus  = @@FETCH_STATUS
		end

		close c_ecf_skus
		deallocate c_ecf_skus

		-- get rid of missing image rows in metakey and metafilevalue
		-- was causing error
		
		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update skuex_title_by_format
		set digital_press_kit = Null
		where digital_press_kit in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_sku_excerpts]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[qweb_ecf_insert_sku_excerpts] (@i_bookkey int,@v_filepath varchar(255)) as

DECLARE @i_sku_id int,
		@i_metaclass_id int,
		@i_sku_excerpt_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_skufetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40)

BEGIN

	DECLARE c_ecf_skus INSENSITIVE CURSOR
	FOR

	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('Excerpt'),
	f.pss_sku_bookkey
	from sku s, skuex_title_by_format f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from MIZ..bookdetail where publishtowebind = 1)
	


	FOR READ ONLY
			
	OPEN c_ecf_skus

	FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_sku_excerpt_metafieldid,
			@i_c_bookkey

	select  @i_skufetchstatus  = @@FETCH_STATUS

	 while (@i_skufetchstatus >-1 )
		begin
		IF (@i_skufetchstatus <>-2) 
		begin

		/** BEGIN SKU EXCERPT *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_sku_excerpt_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT      --@Retval	INT	OUT


	
		Select @d_datetime = getdate()

		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\'  

		Select @v_file = @v_filepath + Substring(pathname,30,len(pathname)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 13 and bookkey = @i_c_bookkey



	-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'application/pdf',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		
		
			update skuex_title_by_format
			set excerpt = @i_current_metakey
			where objectid = @i_sku_id


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU EXCERPT **************************************************/

		end

FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_sku_excerpt_metafieldid,
			@i_c_bookkey

	        select  @i_skufetchstatus  = @@FETCH_STATUS
		end

		close c_ecf_skus
		deallocate c_ecf_skus

		-- get rid of missing image rows in metakey and metafilevalue
		-- was causing error
		
		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update skuex_title_by_format
		set excerpt = Null
		where excerpt in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END







GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_sku_images]    Script Date: 03/17/2011 11:40:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[qweb_ecf_insert_sku_images] (@i_bookkey int, @v_filepath varchar(255)) as

DECLARE @i_sku_id int,
		@i_metaclass_id int,
		@i_skularge_metafieldid int,
		@i_skuthumb_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_skufetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40),
		@i_metakey int,
		@i_fileexists_flag int

BEGIN

	DECLARE c_ecf_skus INSENSITIVE CURSOR
	FOR

	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToMediumImage'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToThumbImage'),
	f.pss_sku_bookkey
	from sku s, skuex_title_by_format f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from MIZ..bookdetail where publishtowebind = 1)
	UNION
	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToMediumImage'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToThumbImage'),
	f.pss_sku_bookkey
	from sku s, SkuEx_Journal_by_PriceType f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from MIZ..bookdetail where publishtowebind = 1)
	


	FOR READ ONLY
			
	OPEN c_ecf_skus

	FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_skularge_metafieldid,
			@i_skuthumb_metafieldid,
			@i_c_bookkey

	select  @i_skufetchstatus  = @@FETCH_STATUS

	 while (@i_skufetchstatus >-1 )
		begin
		IF (@i_skufetchstatus <>-2) 
		begin

		/** BEGIN SKU LARGE IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_skularge_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT           --@Retval	INT	OUT

		
		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = MIZ.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()



		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		--Select @v_file = @v_filepath + Substring(pathname,len(pathname)-16,len(pathname))  
		Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_c_bookkey


		IF coalesce(@v_file,'') =''
			begin 
				Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
				from MIZ..filelocation 
				where printingkey = 1 and filetypecode = 12 and bookkey = @i_c_bookkey
			end


		-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		
		If @v_mediatype <> 'Journal'
			begin
			update skuex_title_by_format
			set SKU_LargeToMediumImage = @i_current_metakey
			where objectid = @i_sku_id
			end
		Else
			begin
			update SkuEx_Journal_by_PriceType
			set SKU_LargeToMediumImage = @i_current_metakey
			where objectid = @i_sku_id
			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'defaultCover.png'
		end 


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU LARGE IMAGE **************************************************/

		/** BEGIN SKU THUMBNAIL IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_skuthumb_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT    --@Retval	INT	OUT



		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = MIZ.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()


		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		--Select @v_file = @v_filepath + Substring(pathname,len(pathname)-16,len(pathname)) 
		Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
		from MIZ..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_c_bookkey

		IF coalesce(@v_file,'') =''
			begin 
				Select @v_file = @v_filepath + reverse(left(reverse(pathname), charindex(reverse('\images\'), reverse(pathname)) -1)) 
				from MIZ..filelocation 
				where printingkey = 1 and filetypecode = 12 and bookkey = @i_c_bookkey
			end

		-- Will insert or update row based on metakey
		

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		--print @i_sku_id
		--print @i_metaclass_id
		--print @i_skuthumb_metafieldid
		--print @i_current_metakey

		If @v_mediatype <> 'Journal'
			begin
			update skuex_title_by_format
			set SKU_LargeToThumbImage = @i_current_metakey
			where objectid = @i_sku_id
			end
		Else
			begin
			update SkuEx_Journal_by_PriceType
			set SKU_LargeToThumbImage = @i_current_metakey
			where objectid = @i_sku_id
			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'defaultCover.png'
		end

		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU THUMBNAIL IMAGE **************************************************/

	end

FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_skularge_metafieldid,
			@i_skuthumb_metafieldid,
			@i_c_bookkey

	        select  @i_skufetchstatus  = @@FETCH_STATUS
		end

close c_ecf_skus
deallocate c_ecf_skus

		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update skuex_title_by_format
		set SKU_LargeToMediumImage = Null
		where SKU_LargeToMediumImage in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_SKUs]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



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
		@i_stockqty int


BEGIN

		Select @i_workkey = b.workkey,
			   @i_publishtowebind = bd.publishtowebind
		from MIZ..book b, MIZ..bookdetail bd
		where b.bookkey = bd.bookkey
		and bd.mediatypecode <> 6
		and b.bookkey = @i_bookkey


				Select @v_title = '('+ MIZ.dbo.qweb_get_ISBN(@i_bookkey,'16') + ') ' + Substring (MIZ.dbo.qweb_get_Title				(@i_bookkey,'f'),1,84)

				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Title_By_Format')
				Select @d_datetime = getdate()
				Select @i_parent_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				--Select @m_usretailprice = MIZ.dbo.qweb_get_BestUSPrice(@i_bookkey,8)

				If exists (Select * 
						   from MIZ..bookprice 
						   where (finalprice is not null 
                             			   and pricetypecode in (10) and activeind = 1)
						   and bookkey=@i_bookkey)

					begin							 
					Select @m_usretailprice = MIZ.dbo.qweb_get_BestUSPrice(@i_bookkey,10)
					end
				Else
					begin
					Select @m_usretailprice = MIZ.dbo.qweb_get_BestUSPrice(@i_bookkey,8)
					end

				Select @i_skuid = dbo.qweb_ecf_get_sku_id (@i_bookkey)
				
				If exists (Select * 
						   from MIZ..bookdetail 
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
		end

END





GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Authors]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_ProductEx_Authors] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @v_contactkey int,
		@v_fetchstatus int,
		@i_productid int,
		@v_displayname nvarchar(512),
		@v_lastname nvarchar(512),
		@v_firstname nvarchar(512),
		@v_middlename nvarchar(512),
		@d_datetime datetime,
		@v_primaryind int,
		@i_publishtowebind int,
		@v_metakeywords varchar(512),
		@v_sortorder int,
		@v_about_comment nvarchar(max),
		@v_website nvarchar(512),
		@v_email nvarchar(512),
		@v_audio_clip int,
		@v_externalcode1 nvarchar(512)

BEGIN

  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select ba.authorkey, c.displayname, c.firstname, c.middlename, c.lastname,
	         ba.primaryind, ba.sortorder, c.externalcode1
  	  from MIZ..bookauthor ba, MIZ..bookdetail bd, MIZ..globalcontact c
	   where ba.bookkey = bd.bookkey
	     and ba.authorkey = c.globalcontactkey
	 	   and ba.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1
				
	OPEN c_pss_authors
	
	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname,
		     @v_primaryind, @v_sortorder, @v_externalcode1

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1) begin
	  IF (@v_fetchstatus <>-2) begin
      
			SELECT @v_displayname =  
		    CASE 
				  WHEN @v_firstname IS  NULL THEN ''
	        ELSE @v_firstname
	     	END
	         
	     +CASE 
			 	  WHEN @v_middlename IS NULL and @v_firstname is NOT NULL THEN ' '
					WHEN @v_middlename IS NULL and @v_firstname is NULL THEN ''
					WHEN @v_middlename is NOT NULL and @v_firstname is NOT NULL THEN ' '+@v_middlename+ ' '
        	ELSE ''
        END

	     + @v_lastname
      
  		Select @d_datetime = getdate()
			Select @i_productid = dbo.qweb_ecf_get_product_id(@v_contactkey)			
			Select @v_metakeywords = @v_displayname

      -- use primary author website
      select @v_website = gcm.contactmethodvalue
        from MIZ..globalcontactmethod gcm
       where gcm.globalcontactkey = @v_contactkey and
             gcm.primaryind = 1 and
             gcm.contactmethodcode = 4 and   -- Website
             gcm.contactmethodsubcode = 2    -- Approved Author Website

     -- use primary email address
     select @v_email = gcm.contactmethodvalue
       from MIZ..globalcontactmethod gcm
      where gcm.globalcontactkey = @v_contactkey and
            gcm.primaryind = 1 and
            gcm.contactmethodcode = 3       -- Email

     -- About the Author Comment
     select @v_about_comment = q.commenthtmllite
       from MIZ..qsicomments q
      where q.commentkey = @v_contactkey and
            q.commenttypecode = 2 and
            q.commenttypesubcode = 0 
            
		  exec dbo.mdpsp_avto_ProductEx_Contributors_Update 
				@i_productid,			 --@ObjectId INT, 
				1,						 --@CreatorId INT, 
				@d_datetime,			 --@Created DATETIME, 
				1,						 --@ModifierId INT, 
				@d_datetime,			 --@Modified DATETIME, 
				NULL,					 --@Retval INT OUT, 
				@v_contactkey,				 --@pss_globalcontactkey int, 
				@v_firstname,		  --@Contributor_First_Name nvarchar(512), 
				@v_middlename,		  --@Contributor_Middle_Name nvarchar(512), 
				@v_lastname,		  --@Contributor_Last_Name nvarchar(512), 
				@v_displayname,		  --@Contributor_Display_Name nvarchar(512), 
				@v_primaryind,     --@Contributor_Primary_Ind int,
				@v_about_comment,					--@Contributor_About_Comment ntext 
				@v_website,		  --@Contributor_WebSite nvarchar(512), 
				@v_email,		  --@Contributor_Email nvarchar(512), 
				0,						 --@Contributor_MediumToThumbImage int, 
				0,						 --@Audio_Clip
				@v_sortorder,    -- @Contributor_Sort_Order
				1,              --@IsAuthor,
				@v_externalcode1, --@Contributor_ExternalCode nvarchar(512)
				@v_metakeywords,		 --@AuthorMetaKeywords
				0						 --@Contributor_LargeToMediumImage int, 

			-- try to add author image
			--exec qweb_ecf_insert_author_images @v_contactkey,  '\\mcdonald\mediachase\Barb_images\AuthorImages\'

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname,
		         @v_primaryind, @v_sortorder, @v_externalcode1

	    select  @v_fetchstatus  = @@FETCH_STATUS
    END
  END
  
  close c_pss_authors
  deallocate c_pss_authors  
END






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Journals]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[qweb_ecf_ProductEx_Journals] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_workkey int,
		@i_titlefetchstatus int,
		@i_productid int,
		@v_fulltitle nvarchar(255),
		@v_subtitle nvarchar(255),
		@v_title nvarchar(255),
		@v_fullauthordisplayname nvarchar(255),
		@d_datetime datetime,
		@m_usretailprice money,
		@i_publishtowebind int,
		@v_metakeywords varchar(512),
		@v_MostRecentIssue_bookkey int,
		@d_dummy_datetime datetime,
		@v_toc varchar(max),
		@v_jstore_ind varchar(max),
		@v_IntructionsToContrib varchar(max),
		@v_MostRecent_VolIssue varchar(max),
		@v_SingleIssueAvail int,
		@v_Journal_Advertising varchar(max),
		@v_Journal_Website varchar(255),
		@v_Online_Journal_Link varchar(255),
		@i_Journals_Single_Issues int,
		@v_Journal_interval varchar(255),
		@v_publisher varchar(255),
		@v_price_text varchar (max),
		@n_Description_Comment varchar(max),
		@i_journal_muse_ind int,
		@v_authormetakeywords varchar(255),
		@v_unformat_fullauthordisplayname varchar(255)

BEGIN

		Select @i_workkey = b.workkey, 
			   @i_publishtowebind = bd.publishtowebind
		from MIZ..book b, MIZ..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey
		and mediatypecode = 6 and mediatypesubcode = 1

		IF @i_publishtowebind = 1
		begin
			print 'bookkey'
			print @i_bookkey
			print 'workkey'
			print @i_workkey
	
				Select @v_fulltitle = MIZ.dbo.qweb_get_Title(@i_bookkey,'F')
				Select @v_title = MIZ.dbo.qweb_get_Title(@i_bookkey,'T')
				Select @v_subtitle = MIZ.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fullauthordisplayname = MIZ.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,1,0,'L')
				Select @d_datetime = getdate()
				Select @i_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				Select @v_metakeywords = MIZ.dbo.qweb_ecf_get_product_metakeywords(@i_workkey)
				Select @v_jstore_ind = MIZ.dbo.get_Tab_Journals_JSTOR(@i_bookkey)
				Select @v_IntructionsToContrib = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 50 and bookkey = @i_bookkey 
				Select @v_SingleIssueAvail = CASE MIZ.dbo.[get_Tab_Journals_Single_Issues_Available?](@i_bookkey)
															 WHEN 'Y' Then 1
															 ELSE 0 END
			
				Select @v_MostRecentIssue_bookkey = bookkey 
					from MIZ..book where bookkey in (Select top 1 d.bookkey
												from MIZ..bookdates d, MIZ..bookdetail bd
												where d.bookkey = bd.bookkey 
													and bd.publishtowebind = 1
													and d.datetypecode = 47
													and d.bestdate is not null
													and d.bookkey in (Select childbookkey 
																	  from MIZ..bookfamily 
																	   where parentbookkey = @i_bookkey)
												order by d.bookkey desc)

				Select @v_MostRecent_VolIssue = commenttext from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 53 and bookkey = @v_MostRecentIssue_bookkey 
				Select @v_toc = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 52 and bookkey = @v_MostRecentIssue_bookkey 
				Select @v_Journal_Advertising = commenthtml from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 54 and bookkey = @i_bookkey 
				Select @v_Journal_Website = pathname from MIZ..filelocation where filetypecode = 8 and bookkey = @i_bookkey 
				Select @v_Online_Journal_Link = pathname from MIZ..filelocation where filetypecode = 10 and bookkey = @i_bookkey 
				Select @i_Journals_Single_Issues = MIZ.dbo.[get_Tab_Journals_Single_Issues_Available?] (@i_bookkey)
				Select @v_Journal_interval = MIZ.dbo.get_Tab_Journals_Journal_Interval (@i_bookkey)
				Select @v_publisher = MIZ.dbo.qweb_get_GroupLevel3(@i_bookkey,'1')
				select @v_price_text = commenthtmllite from MIZ..bookcomments where commenttypecode = 1 and commenttypesubcode = 49 and bookkey = @i_bookkey
				Select @n_Description_Comment = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
				select @i_journal_muse_ind = longvalue from MIZ..bookmisc where misckey=31 and bookkey= @i_bookkey
                                select @v_unformat_fullauthordisplayname = MIZ.dbo.replace_xchars(@v_fullauthordisplayname)
				select @v_authormetakeywords = @v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
								
				

				exec dbo.mdpsp_avto_ProductEx_Journals_Update 
				@i_productid,              --@ObjectId INT, 
				1,                         --@CreatorId INT, 
				@d_datetime,               --@Created DATETIME, 
				1,                         --@ModifierId INT, 
				@d_datetime,               --@Modified DATETIME, 
				NULL,                      --@Retval INT OUT, 
				@i_bookkey,                --@pss_product_bookkey int, 
				@n_Description_Comment,	   --@Journal_Description_Comment
				@v_Journal_Advertising,    --@Journal_Adveritising ntext, 
				@v_Journal_interval,	   --@JournalInterval nvarchar(       512) , 
				@v_price_text,		    --@price_text
				@i_journal_muse_ind,   --@journal_muse_ind int	
				@v_Journal_Website,	       --@Journal_WebSite nvarchar(       512), 
				@v_publisher,			   --@Publisher nvarchar(       512) , 
				@v_title,                  --@Product_Title nvarchar(512) ,				
				@v_fulltitle,              --@Product_Full_Title nvarchar(512) ,
				NULL,                      --@JournalLibraryRecommendationForm_File INT
				NULL,    --REMOVED PER BROCK ON 8/8/07 @Online_Journal_Link nvarchar(       512) ,  
				1,						   --@IsJournal int, 
				@v_subtitle,               --@Product_Subtitle nvarchar(512) , 
				@v_fullauthordisplayname,  --@Product_Fullauthordisplayname nvarchar(512) , 
				0,                         --@Product_LargeToThumbImage int, 
				0,                         --@Product_LargeToMediumImage int, 
				@v_metakeywords,           --@MetaKeywords nvarchar(512) , 
				@v_authormetakeywords,  --@AuthorMetaKeywords nvarchar(512) , 				
				@v_toc,                    --@Journal_TOC ntext, 
				@v_jstore_ind,             --@Journal_Jstor_Ind int, 
				@v_fullauthordisplayname,  --@Journal_JournalEditor nvarchar(512) , 
				@v_IntructionsToContrib,   --@Journal_SubmissionGuidelines ntext, 
				@v_MostRecent_VolIssue,    --@Journal_MostRecentVolIssue nvarchar(512) , 
				0						   --@Journal_SingleIssueAvail int,
				
					
				
			 
					



			end
			
END




GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Titles]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[qweb_ecf_ProductEx_Titles] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_workkey int,
		@i_titlefetchstatus int,
		@i_productid int,
		@v_fulltitle nvarchar(255),
		@v_subtitle nvarchar(255),
		@v_title nvarchar(255),
		@v_fullauthordisplayname nvarchar(255),
		@d_datetime datetime,
		@m_usretailprice money,
		@i_publishtowebind int,
		@v_metakeywords varchar(512),
		@v_publisher varchar(255),
		@d_pubdate datetime,
		@v_authormetakeywords varchar(255),
		@v_unformat_fullauthordisplayname varchar(255)

BEGIN

		Select @i_workkey = b.workkey, 
			   @i_publishtowebind = bd.publishtowebind
		from MIZ..book b, MIZ..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey

		Select @i_productid = coalesce (dbo.qweb_ecf_get_product_id(@i_workkey),0)

		
		IF @i_bookkey = @i_workkey /*and @i_publishtowebind = 1*/ and @i_productid <>0
		begin
			/*print 'bookkey'
			print @i_bookkey
			print 'workkey'
			print @i_workkey*/
	
				Select @v_fulltitle = MIZ.dbo.qweb_get_Title(@i_bookkey,'F')
				Select @v_title = MIZ.dbo.qweb_get_Title(@i_bookkey,'T')
				Select @v_subtitle = MIZ.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fullauthordisplayname = fullauthordisplayname from MIZ..bookdetail where bookkey=@i_bookkey /*MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')*/
				Select @d_datetime = getdate()
				Select @i_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				Select @v_metakeywords = MIZ.dbo.qweb_ecf_get_product_metakeywords(@i_workkey)
				Select @v_publisher = MIZ.dbo.qweb_get_GroupLevel3 (@i_bookkey,'F')
				select @d_pubdate = MIZ.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_unformat_fullauthordisplayname = MIZ.dbo.replace_xchars(@v_fullauthordisplayname)
				select @v_authormetakeywords = @v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
								
				
				exec dbo.mdpsp_avto_ProductEx_Titles_Update 
				@i_productid,			 --@ObjectId INT, 
				1,						 --@CreatorId INT, 
				@d_datetime,			 --@Created DATETIME, 
				1,						 --@ModifierId INT, 
				@d_datetime,			 --@Modified DATETIME, 
				NULL,					 --@Retval INT OUT, 
				@i_bookkey,				 --@pss_product_bookkey int, 
				@v_metakeywords,		 --@MetaKeywords
				0,						 --@IsJournal int, 
				@v_publisher,			 --@Publisher nvarchar(       512) ,
				@d_pubdate,					--@product_pubdate 
				@v_authormetakeywords,            --@AuthorMetaKeywords 
				@v_title,				 --@Product_Title nvarchar(512) , 
				@v_fulltitle,	  		 --@Product_Full_Title nvarchar(512) , 
				@v_subtitle,			 --@Product_Subtitle nvarchar(512) , 
				@v_fullauthordisplayname,        --@Product_Fullauthordisplayname nvarchar(512) , 
				0,						 --@Product_PrimaryImage int, 
				0						 --@Product_LargeImage 
				


			end



END







GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Journal_By_Price]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[qweb_ecf_SkuEx_Journal_By_Price] (@i_bookkey int, @v_importtype varchar(1)) as

DECLARE @i_titlefetchstatus int,
		@i_skuid int,
		@v_sku_name varchar(100),
		@i_pricetypecode int,
		@v_title nvarchar(512),
		@v_subtitle nvarchar(512),
		@v_fulltitle nvarchar(512),	
        @v_Fullauthordisplayname nvarchar(512),
		@d_datetime datetime,
		@v_ISBN nvarchar(13), 
		@v_EAN nvarchar(50), 
		@v_Display nvarchar,
		@v_Format nvarchar(512) , 
		@i_pagecount nvarchar(512) , 
		@v_season nvarchar(512) , 
		@v_PubYear nvarchar(512) , 
		@v_Discount nvarchar(512) , 
		@v_Series nvarchar(512) ,
		@v_edition nvarchar(512),
		@n_Description_Comment varchar(max),
		@n_About_Author_Comment varchar(max),
		@i_PrimaryImage int, 
		@i_LargeImage int,
		@v_Journal_ISSN varchar(20),
		@v_Journal_IssueInd varchar(255),
		@v_Journals_Brief_Description varchar(255),
		@v_SubsidyCreditLine varchar(max),
		@m_promotionalprice money,
		@v_Awards varchar(max),
		@v_SKU_title varchar (512),
		@v_journalsubscriptionlocation varchar(255),
		@v_journalsubsrcriptionlength varchar(255),
		@v_authorbylineprepro varchar(max)

BEGIN

------------------------------------------------------
-------  START JOURNAL PRICE TYPE CURSOR -------------
------------------------------------------------------
	DECLARE c_qweb_journalskupricetypes INSENSITIVE CURSOR
	FOR

	Select skuid, Name, Substring(code,len(code) -3,2) as pricetypecode
	from sku 
	where Substring(code,1,Patindex('%-%',code)-1) = cast(@i_bookkey as varchar)
	and code like '%-%'
	UNION
	Select skuid, Name, '' as pricetypecode
	from sku 
	where code = cast(@i_bookkey as varchar)
	and code not like '%-%'

	FOR READ ONLY
			
	OPEN c_qweb_journalskupricetypes 

	FETCH NEXT FROM c_qweb_journalskupricetypes 
		INTO @i_skuid, @v_sku_name, @i_pricetypecode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

				Select @v_title = MIZ.dbo.qweb_get_Title(@i_bookkey,'s')
				-- This is the Journal price type without the title
				Select @v_SKU_title = Substring(@v_sku_name,len(@v_title)+3,len(@v_sku_name))
				Select @v_SKU_title = Substring(@v_SKU_title,1,len(@v_SKU_title) -1)
				PRINT '@v_SKU_title' 
				PRINT @v_SKU_title 
				Select @d_datetime = getdate()
				Select @v_subtitle =  MIZ.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = MIZ.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @v_fullauthordisplayname = MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')
				Select @v_ISBN = MIZ.dbo.qweb_get_ISBN(@i_bookkey,'13')
				Select @v_EAN = MIZ.dbo.qweb_get_ISBN(@i_bookkey,'16')
				Select @v_Display = ''
				Select @v_Format = MIZ.dbo.qweb_get_Format(@i_bookkey,'D')
				Select @i_pagecount = MIZ.dbo.qweb_get_BestPageCount(@i_bookkey,1)
				Select @v_season = s.seasondesc
									from MIZ..printing p
									Left outer join MIZ..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey
				
				Select @v_PubYear = MIZ.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = MIZ.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = MIZ.dbo.qweb_get_series(@i_bookkey,'d')
				Select @v_edition = MIZ.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @n_Description_Comment = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
				Select @v_Journals_Brief_Description = commenttext FROM  MIZ..bookcomments WHERE commenttypecode = 3 AND commenttypesubcode = 7 AND bookkey = @i_bookkey
				Select @n_About_Author_Comment = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from MIZ..isbn i where i.bookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from MIZ..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @v_Awards = MIZ.dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				Select @v_journalsubscriptionlocation = alternatedesc1 from MIZ..gentables where datacode = @i_pricetypecode and tableid = 306
				Select @v_journalsubsrcriptionlength = alternatedesc2 from MIZ..gentables where datacode = @i_pricetypecode and tableid = 306
				Select @v_authorbylineprepro = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey
			

				
				exec dbo.mdpsp_avto_SkuEx_Journal_by_PriceType_Update 
				@i_skuid,			           --@ObjectId INT, 
				1,					           --@CreatorId INT, 
				@d_datetime,		           --@Created DATETIME, 
				1,					           --@ModifierId INT, 
				@d_datetime,		           --@Modified DATETIME, 
				0,					           --@Retval INT OUT, 
				@i_bookkey,			           --@pss_sku_bookkey int, 
				0,						       --@JournalsSingleIssues int, 
				NULL,						   --@Journal_IssueInd( nvarchar(512),
				@v_Journals_Brief_Description, --@Journals_Brief_Description( nvarchar(512),
				NULL,					       --@JournalAdvertisingLink ntext,
				@v_SKU_title,		           --@SKU_Title nvarchar(       512) , 
				@v_fulltitle,		           --@SKU_Full_Title nvarchar(       512) , 
				@v_journalsubscriptionlocation,--@JournalSubscriptionLocation nvarchar(       512) , 
				@v_journalsubsrcriptionlength, --@JournalSubscriptionLength nvarchar(       512) ,
				@v_subtitle,		           --@SKU_Subtitle nvarchar(       512) ,  
				@i_pagecount,		           --@SKU_pagecount nvarchar(       512) , 
				NULL,						   --@author_first nvarchar(       512) , 
				NULL,                          --@author_last nvarchar(       512) , 
				@v_season,			           --@SKU_season nvarchar(       512) , 
				@v_PubYear,			           --@SKU_PubYear nvarchar(       512) ,				
				@v_authorbylineprepro,		   --@AuthorBylinePrePro ntext, 
				1,							   --@never_discount int, @author_last nvarchar(       512) ,  
				@v_Discount,		           --@SKU_Discount nvarchar(       512) , 
				@v_series,			           --@SKU_Series nvarchar(       512) , 
				@v_Fullauthordisplayname,      --@SKU_fullauthordisplayname nvarchar(       512) ,
				@n_Description_Comment,        --@SKU_Description_Comment ntext, 
				@n_About_Author_Comment,       --@SKU_About_Author_Comment ntext, 
				NULL,					       --@SKU_LargeToThumbImage int, 
				NULL,					       --@SKU_LargeToMediumImage int, 
				@v_Journal_ISSN,		       --@Journal_ISSN nvarchar(       512) , 
				@v_Awards,   			       --@SKU_Awards ntext, 
				@v_SubsidyCreditLine,	       --@SKU_SubsidyCreditLine ntext, 
				@m_promotionalprice	           --@Journal_PromotionalPrice money 
				--NULL					       --@JournalLibraryRecommendationForm nvarchar(       512) , 


	FETCH NEXT FROM c_qweb_journalskupricetypes
		INTO @i_skuid, @v_sku_name, @i_pricetypecode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end
end
			

close c_qweb_journalskupricetypes
deallocate c_qweb_journalskupricetypes


END






GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Title_By_Format]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE procedure [dbo].[qweb_ecf_SkuEx_Title_By_Format] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_titlefetchstatus int,
		@i_skuid int,
		@v_title nvarchar(512),
		@v_subtitle nvarchar(512),
		@v_fulltitle nvarchar(512),
        @v_Fullauthordisplayname nvarchar(512),
		@d_datetime datetime,
		@v_ISBN nvarchar(512), 
		@v_EAN nvarchar(50), 
		@v_Display nvarchar,
		@v_Format nvarchar(512) , 
		@i_pagecount nvarchar(512) , 
		@v_season nvarchar(512) , 
		@v_PubYear nvarchar(512) , 
		@v_Discount nvarchar(512) , 
		@v_Series nvarchar(512) ,
		@v_edition nvarchar(512),
		@n_Description_Comment varchar(max),
		@n_About_Author_Comment varchar(max),
		@i_PrimaryImage int, 
		@i_LargeImage int,
		@v_Journal_ISSN varchar(20),
		@v_SubsidyCreditLine varchar(max),
		@m_promotionalprice money,
		@m_fullprice money,
		@v_Awards varchar(max),
		@v_Web_Page varchar(255),
		@v_Author_Web_Page varchar(255),
		@v_Society_Web_Site varchar(255),
		@v_Web_Document varchar(255),
		@v_Citation_Author varchar(80),
		@v_Citation_Source varchar(80),
		@v_Citation_Text varchar(max),
		@v_Praise varchar(max),
		@v_quote varchar(max),
		@i_citation_fetchstatus int,
		@i_bisactatuscode int,
		@i_sendtoeloind int,
		@v_authorfirstname varchar(120),
		@v_authorlastname varchar(120),
		@v_authorbylineprepro varchar(max),
		@v_authortype varchar(255),
		@v_neverdiscountflag int,
		@v_isdiscounted int,
		@d_pubdate datetime,
		@v_bisacstatusdesc varchar (255),
		@v_awardscomment varchar(max),
		@v_author_events varchar(max),
		@v_Insert_Illus varchar(255),
		@v_TrimSize varchar(255),
		@v_cnt int,
		@n_title_filelocations varchar(max)




BEGIN

--	DECLARE c_qweb_citations INSENSITIVE CURSOR
--	FOR
--
--	select q.commenthtmllite, c.citationauthor, c.citationsource
--	from MIZ..citation c, MIZ..qsicomments q
--	where c.webind=1
--	and c.qsiobjectkey=q.commentkey
--	and bookkey = @i_bookkey
--	order by sortorder
--
--	FOR READ ONLY
--			
--	OPEN c_qweb_citations 
--
--	FETCH NEXT FROM c_qweb_citations 
--		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source
--
--	select  @i_citation_fetchstatus  = @@FETCH_STATUS
--
--	 while (@i_citation_fetchstatus >-1 )
--		begin
--		IF (@i_citation_fetchstatus <>-2) 
--		begin
--
--		--Select @v_Praise =  ISNULL(@v_Praise,'')  + @v_Citation_Text + ' -' + ISNULL(@v_Citation_Author,'') + ', ' + ISNULL(@v_Citation_Source,'') + '<BR><BR>'
--		Select @v_Praise =  ISNULL(@v_Praise,'')  + @v_Citation_Text + '<BR>'
--
--		end
--
--	FETCH NEXT FROM c_qweb_citations
--		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source
--	        select  @i_citation_fetchstatus  = @@FETCH_STATUS
--		end
--
--	close c_qweb_citations
--	deallocate c_qweb_citations
		
		    -- combine quote1, quote2, and quote3 into Praise
        set @v_Praise = ''
  		  select @v_quote = MIZ.dbo.get_Comment_HTMLLITE (@i_bookkey,3,4)
        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
      		Select @v_Praise =  @v_Praise + @v_quote
        end
  		  select @v_quote = MIZ.dbo.get_Comment_HTMLLITE (@i_bookkey,3,5)
        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote
        end
  		  select @v_quote = MIZ.dbo.get_Comment_HTMLLITE (@i_bookkey,3,6)
        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
        end
    
		     
				Select @v_title = MIZ.dbo.qweb_get_Title(@i_bookkey,'s')
				Select @d_datetime = getdate()
				Select @i_skuid = dbo.qweb_ecf_get_sku_id(@i_bookkey)
				Select @v_subtitle =  MIZ.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = MIZ.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @v_fullauthordisplayname = fullauthordisplayname from MIZ..bookdetail where bookkey=@i_bookkey /*MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
												  MIZ.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')*/
				Select @v_ISBN = MIZ.dbo.qweb_get_ISBN(@i_bookkey,'13') /*+ ',' + MIZ.dbo.qweb_get_ISBN(@i_bookkey,'16') + ',' + 					MIZ.dbo.qweb_get_ISBN(@i_bookkey,'10') + ',' + MIZ.dbo.qweb_get_ISBN(@i_bookkey,'17')*/
				Select @v_EAN = MIZ.dbo.qweb_get_ISBN(@i_bookkey,'16') 
				Select @v_Display = ''
				
				Select @v_Format = MIZ.dbo.qweb_get_Format(@i_bookkey,'1')
				if (@v_Format is null OR ltrim(rtrim(@v_Format)) = '') begin
				  -- alternatedesc2 is not filled in - use full desc
    		  Select @v_Format = MIZ.dbo.qweb_get_Format(@i_bookkey,'D')
				end
				
				Select @i_pagecount = MIZ.dbo.qweb_get_BestPageCount(@i_bookkey,1)
				Select @v_TrimSize = MIZ.dbo.qweb_get_BestTrimSize(@i_bookkey,1)
				Select @v_season = s.seasondesc
									from MIZ..printing p
									Left outer join MIZ..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey
		 
				Select @v_PubYear = MIZ.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = REPLACE( MIZ.dbo.qweb_get_Discount(@i_bookkey,'E'), '77','')
				
				Select @v_Series = MIZ.dbo.qweb_get_series(@i_bookkey,'1')
				if (@v_Series is null OR ltrim(rtrim(@v_Series)) = '' OR len(ltrim(rtrim(@v_Series))) > 50) begin
				  -- alternatedesc1 is not filled in or too long - use full desc
    		  Select @v_Series = MIZ.dbo.qweb_get_series(@i_bookkey,'D')
				end
				
				Select @v_edition = MIZ.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @i_bisactatuscode = bisacstatuscode from MIZ..bookdetail where bookkey = @i_bookkey
				Select @i_sendtoeloind = releasetoeloquenceind from MIZ..bookcomments where commenttypecode = 3 and (commenttypesubcode = 8 or commenttypesubcode = 10) and bookkey = @i_bookkey
				
				Select @v_authorbylineprepro = fullauthordisplayname from MIZ..bookdetail  where bookkey=@i_bookkey --commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey

				Select @v_authortype = MIZ.dbo.qweb_get_Authortype(@i_bookkey,1,'D')
				
			If not exists (select * 
						   from MIZ..gentables 
						   where tableid = 134 
							 and datacode in (57,59,61,71,73,74,75,76,77,78) 
							 and datadesc = @v_authortype)

				begin
				Select @v_authorfirstname = MIZ.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,2,0,'F') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,3,0,'F') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,4,0,'F') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,5,0,'F') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,6,0,'F') 

				Select @v_authorlastname = MIZ.dbo.[qweb_get_Author](@i_bookkey,1,0,'L') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,2,0,'L') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,3,0,'L') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,4,0,'L') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,5,0,'L') + ',' +
				MIZ.dbo.[qweb_get_Author](@i_bookkey,6,0,'L') 
				end

			Else 
				begin
				Select @v_authorfirstname = ''
				Select @v_authorlastname = ''
				end
					

				If @i_bisactatuscode in (4,10) and coalesce (@i_sendtoeloind,0) <> 1
					begin
					 Select @n_Description_Comment = ''
					 Select @n_About_Author_Comment = ''
					end		
				Else 
					begin
					Select @n_Description_Comment = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
					Select @n_About_Author_Comment = commenthtmllite from MIZ..bookcomments where commenttypecode = 1 and commenttypesubcode = 37 and bookkey = @i_bookkey
					end
						
				  
				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from MIZ..isbn i, MIZ..bookfamily bf where i.bookkey = bf.parentbookkey and bf.childbookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from MIZ..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from MIZ..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @m_fullprice = finalprice from MIZ..bookprice where pricetypecode = 8 and currencytypecode = 6 and bookkey = @i_bookkey

				
				 
				--Select @v_Awards = dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				--select @v_cnt = count(*) 
	   --     from MIZ..booksubjectcategory
	   --    where categorytableid = 434 -- web feature
	   --      and categorycode = 5      -- awards
    --   		 and bookkey = @i_bookkey
				
				select @v_awardscomment = ''
				select @v_awardscomment = MIZ.dbo.get_Comment_HTMLLITE (@i_bookkey,1,74)

				 
				Select @v_Web_Page = pathname from MIZ..filelocation where filetypecode = 11 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Author_Web_Page = pathname from MIZ..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Society_Web_Site = pathname from MIZ..filelocation where filetypecode = 9 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Web_Document = pathname from MIZ..filelocation where filetypecode = 6 and bookkey = @i_bookkey and printingkey = 1

				If exists (Select * from MIZ..bookprice where 
		                           (bookkey=@i_bookkey
		                           and finalprice is not null 
		                           and pricetypecode in (10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27) 
                                           and activeind = 1)
		                           OR
		                           (bookkey=@i_bookkey 
                                           and bookkey in 
                                           (Select bookkey from MIZ..bookorgentry where orglevelkey = 3 and orgentrykey = 15)))

					begin							 
					Select @v_neverdiscountflag = 1
					end
				Else
					begin
					Select @v_neverdiscountflag = 0
					end	

				If exists (Select * from MIZ..bookprice 
					   where (finalprice is not null 
                             		   and pricetypecode in (10) and activeind = 1)
					   and bookkey=@i_bookkey)

					begin							 
					Select @v_isdiscounted = 1
					end
				Else
					begin
					Select @v_isdiscounted = 0
					end
				 
				select @d_pubdate = MIZ.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_bisacstatusdesc = MIZ.dbo.qweb_get_bisacstatus  (@i_bookkey,'D')
				select @v_author_events = MIZ.dbo.qweb_get_www_events (@i_bookkey)
				Select @v_Insert_Illus = MIZ.dbo.qweb_get_BestInsertIllus (@i_bookkey,1)
				Select @n_title_filelocations = dbo.qweb_ecf_get_title_filelocations(@i_bookkey)
  

				if @i_skuid is not null 
				begin
				
				exec dbo.mdpsp_avto_SkuEx_Title_By_Format_Update 
				@i_skuid ,				  --@ObjectId INT, 
				0,						  --@CreatorId INT, 
				@d_datetime,			  --@Created DATETIME, 
				0,						  --@ModifierId INT, 
				@d_datetime,			  --@Modified DATETIME, 
				0,						  --@Retval INT OUT, 
				@v_edition,				  --@SKU_Edition nvarchar(       512) , 
				@v_Journal_ISSN,		  --@Journal_ISSN nvarchar(       512) , 
				@i_bookkey,				  --@pss_sku_bookkey int, 
				@v_Praise,				  --@Praise ntext, 
				@v_authorfirstname,		  --@author_first nvarchar(       512) ,
				@v_isdiscounted,		--@isdicounted,
				@v_bisacstatusdesc,		--@sku_titlestatus nvarchar (512)
				@v_Insert_Illus,		--@SKU_Actual_Insert_Illus nvarchar (512 ),
				@v_TrimSize,		--@Trim_Size nvarchar (512 ),
				@v_author_events,			--@sku_author_events
				@m_fullprice, 			--@sku_fullprice,
				@v_authorlastname,		  --@author_last nvarchar(       512) , 
				Null,  			          --@Web_Page nvarchar(       512) ,
				--@v_Awards,				  --@SKU_Awards ntext,
				@v_awardscomment, 		--@SKU_Awards ntext,
				@v_ISBN,				  --@SKU_ISBN nvarchar(       512) , 
				@v_EAN,					  --@SKU_EAN nvarchar(       512) , 
				@v_SubsidyCreditLine,     --@SKU_SubsidyCreditLine ntext, 
				@v_authorbylineprepro,	  --@AuthorBylinePrePro ntext, 
				@v_Author_Web_Page,		  --@Author_Web_Page nvarchar(       512) , 
				@d_pubdate,			--@sku_pubdate datetime,
				@v_Society_Web_Site,	  --@Society_Web_Site nvarchar(       512) ,
				@v_neverdiscountflag,	  --@never_discount int,	 
				@m_promotionalprice,      --@Journal_PromotionalPrice money, 
				@v_Display,		          --@SKU_Display nvarchar(       512) , 
				@v_title,			      --@SKU_Title nvarchar(       512) , 
				@v_Web_Document,		  --@Web_Document nvarchar(       512) , 
				NULL,                     --@Excerpt int
				@v_fulltitle,		      --@SKU_Full_Title nvarchar(       512) , 
				@v_subtitle,		      --@SKU_Subtitle nvarchar(       512) , 
				NULL,					  --@Digital_Press_Kit int
				@v_Format,			      --@SKU_Format nvarchar(       512) , 
				@i_pagecount,		      --@SKU_pagecount nvarchar(       512) , 
				@v_season,			      --@SKU_season nvarchar(       512) , 
				@v_PubYear,			      --@SKU_PubYear nvarchar(       512) , 
				@v_Discount,		      --@SKU_Discount nvarchar(       512) , 
				@v_series,				  --@SKU_Series nvarchar(       512) , 
				@v_Fullauthordisplayname, --@SKU_fullauthordisplayname nvarchar(       512) , 
				@n_Description_Comment,   --@SKU_Description_Comment ntext, 
				@n_About_Author_Comment,  --@SKU_About_Author_Comment ntext, 
				NULL,					  --@SKU_LargeToThumbImage int, 
				NULL,					  --@SKU_LargeToMediumImage int,
				@n_title_filelocations	  --@File_Location_Links 	
				
				
				
				
				

				end
	
END










GO

/****** Object:  StoredProcedure [dbo].[qweb_ecf_UpdateImageData]    Script Date: 03/17/2011 11:40:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[qweb_ecf_UpdateImageData]
@metakey int,
@FileName varchar(255)
AS

DECLARE @SqlStatement nvarchar(MAX),
		@i_fileexists_flag int

CREATE TABLE #BlobData(BlobData varbinary(max))

--insert blob into temp table
SET @SqlStatement =
N'
INSERT INTO #BlobData
SELECT BlobData.*
FROM OPENROWSET
(BULK ''' + @FileName + ''',
SINGLE_BLOB) BlobData'

exec xp_fileexist @FileName, @i_fileexists_flag output

If @i_fileexists_flag = 1

begin

	EXEC sp_executesql @SqlStatement

	--update main table with blob data
	UPDATE dbo.MetaFileValue
	SET data = (SELECT BlobData FROM #BlobData),
	size = (SELECT datalength(BlobData) FROM #BlobData)
	WHERE MetaFileValue.Metakey = @metakey

	DROP TABLE #BlobData

end

else

begin
	print 'Warning: ' + @FileName + ' does not exist and will not be inserted.'
end


GO


