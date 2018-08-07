/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_UNP_Category]    Script Date: 04/09/2009 14:58:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

drop procedure [qweb_ecf_Categorization_Insert_UNP_Category] 
go

CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_UNP_Category] (@i_bookkey int) as

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
	(select categoryid from category where parentcategoryid=157))

	delete from categorization where objectid in 
	(select objectid from productex_journals where pss_product_bookkey = @i_bookkey)
	and objecttypeid=1 and categoryid in (select categoryid from category where parentcategoryid in
	(select categoryid from category where parentcategoryid=157))

	DECLARE c_pss_category INSENSITIVE CURSOR
	FOR

	Select bookkey, categorycode, categorysubcode
	from unl..booksubjectcategory
	where categorytableid = 413
		/*and bookkey in (Select bookkey from barb..bookdetail where publishtowebind =1)*/
		and bookkey = @i_bookkey
		and exists (Select * from product where code = cast(@i_bookkey as varchar))

	FOR READ ONLY
			
	OPEN c_pss_category

	FETCH NEXT FROM c_pss_category
		INTO @i_c_bookkey, @i_categorycode, @v_categorysubcode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin
			Select @productid = productid from product where code = cast(@i_c_bookkey as varchar)
			if @v_categorysubcode > 0 begin
			  Select @subject_object_id = objectid from CategoryEx_Title_Subject_SubCategory 
			  where pss_subject_categorytableid = 413 
			    and pss_subject_datacode = @i_categorycode 
			    and pss_subject_datasubcode = @v_categorysubcode
			end
			else begin
			  Select @subject_object_id = objectid from CategoryEx_Title_Subject 
			  where pss_subject_categorytableid = 413 
			    and pss_subject_datacode = @i_categorycode
			end
	
--print 'here***************************************'
--print cast(@i_bookkey as varchar)
--print cast(@subject_object_id as varchar)
--print cast(@productid as varchar)
		
		  if @subject_object_id > 0 begin
			  If not exists (Select * from categorization
							  where categoryid = 	@subject_object_id
							   and objectid = @productid)
			  begin

--print 'here2***************************************'
--print cast(@i_bookkey as varchar)
--print cast(@subject_object_id as varchar)
--print cast(@productid as varchar)

			    exec CategorizationInsert

			    @subject_object_id,       --@CategoryId int,
			    @productid,				--@ObjectId int,
			    1,						--@ObjectTypeId int,
			    NULL					--@CategorizationId int = NULL output
  			
			  end
			end
                 
		end

		

	FETCH NEXT FROM c_pss_category
		INTO @i_c_bookkey, @i_categorycode, @v_categorysubcode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_category
deallocate c_pss_category


END