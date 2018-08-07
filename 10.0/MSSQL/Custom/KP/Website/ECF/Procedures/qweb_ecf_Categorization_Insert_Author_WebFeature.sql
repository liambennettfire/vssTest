if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Categorization_Insert_Author_WebFeature]


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
	  from cbd..globalcontactcategory
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
Grant execute on dbo.qweb_ecf_Categorization_Insert_Author_WebFeature to Public
GO