IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_WebFeature]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_WebFeature]
go

CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_WebFeature] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
		@i_categorycode int,
		@subject_object_id int,
		@i_webfeature_fetchstatus int,
		@productid int,
		@d_datetime datetime,
		@parent_categoryid int

BEGIN
--	delete from categorization where objectid in 
--	(select objectid from productex_titles where pss_product_bookkey = @i_bookkey)
--	and objecttypeid=1 and categoryid in (299,300)
--
--	delete from categorization where objectid in 
--	(select objectid from productex_journals where pss_product_bookkey = @i_bookkey)
--	and objecttypeid=1 and categoryid in (299,300)
	
 	Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Web Feature')

	delete from categorization 
	where objectid in (select objectid from productex_titles where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 
	and categoryid in (select categoryid from category 
	                    where parentcategoryid = @parent_categoryid)

	delete from categorization 
	where objectid in (select objectid from productex_journals where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 
	and categoryid in (select categoryid from category 
	                    where parentcategoryid = @parent_categoryid)

	DECLARE c_pss_webfeature INSENSITIVE CURSOR
	FOR

	Select bookkey, categorycode
	from barb..booksubjectcategory
	where categorytableid = 431
		/*and bookkey in (Select bookkey from barb..bookdetail where publishtowebind =1)*/
		and bookkey = @i_bookkey
		--and categorycode <> 1 -- bargain books will be handled by pricetypecode
		and bookkey in (Select code from product)
--	UNION
--	Select bookkey, '1'
--	from barb..bookprice 
--	where pricetypecode = 10
--        and activeind = 1
--	  and finalprice is not null
--	  /*and bookkey in (Select bookkey from barb..bookdetail where publishtowebind =1)*/
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
			 where pss_webfeature_categorytableid = 431
 		     and pss_webfeature_datacode = @i_categorycode
		

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



