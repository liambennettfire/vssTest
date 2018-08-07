IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Truly_Yours_Catalog]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Truly_Yours_Catalog]
go

Create procedure [dbo].[qweb_ecf_Categorization_Insert_Truly_Yours_Catalog]  as

DECLARE @i_c_bookkey int,
		@v_catalogkey int,
		@catalog_object_id int,
		@i_titlefetchstatus int,
		@productid int,
		@d_datetime datetime,
		@v_year varchar(4),
		@v_month varchar(15),
		@v_monthnumber int

BEGIN

	DECLARE c_pss_catalog CURSOR fast_forward FOR

	Select distinct substring(cs.description, 1, 4) clubyear,
	 CASE bc.catalogpagenumber
         WHEN 1 THEN 'January'
         WHEN 2 THEN 'February'
         WHEN 3 THEN 'March'
         WHEN 4 THEN 'April'
         WHEN 5 THEN 'May'
         WHEN 6 THEN 'June'
         WHEN 7 THEN 'July'
         WHEN 8 THEN 'August'
         WHEN 9 THEN 'September'
         WHEN 10 THEN 'October'
         WHEN 11 THEN 'November'
         WHEN 12 THEN 'December'
         ELSE ''
      END as clubmonth, bc.catalogpagenumber, bc.bookkey, cs.catalogkey
	from barb..bookcatalog bc, barb..catalogsection cs 
	where bc.sectionkey = cs.sectionkey 
	  and cs.catalogkey in (select c.catalogkey from barb..catalog c
	                         where lower(rtrim(ltrim(c.catalogtitle))) = 'truly yours')
		and bookkey in (Select bookkey from barb..bookdetail where publishtowebind = 1)
	order by clubyear, bc.catalogpagenumber
				
	OPEN c_pss_catalog

	FETCH NEXT FROM c_pss_catalog
	INTO @v_year,@v_month,@v_monthnumber,@i_c_bookkey, @v_catalogkey

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	while (@i_titlefetchstatus >-1 )
	begin
	  IF (@i_titlefetchstatus <>-2) 
		begin

		  Select @productid = productid from product where code = cast(@i_c_bookkey as varchar)
			Select @catalog_object_id = dbo.qweb_ecf_get_Category_ID(@v_year)

      if @productid > 0 and @catalog_object_id > 0 begin
			  If not exists (Select * from categorization
				  			  where categoryid = 	@catalog_object_id
					  		   and objectid = @productid)
			  begin
			    exec CategorizationInsert
			      @catalog_object_id,       --@CategoryId int,
		    	  @productid,				--@ObjectId int,
		    	  1,						--@ObjectTypeId int,
			      NULL					--@CategorizationId int = NULL output
  			
			  end 
			  
			  -- update book club month			  
			  if @i_c_bookkey > 0 begin
			    update skuex_title_by_format
			       set BookClubMonth = @v_month
			     where pss_sku_bookkey = @i_c_bookkey
			  end
			  
			end         
		end
		
	  FETCH NEXT FROM c_pss_catalog
		INTO @v_year,@v_month,@v_monthnumber,@i_c_bookkey, @v_catalogkey
	        
	  select  @i_titlefetchstatus  = @@FETCH_STATUS
  end

  close c_pss_catalog
  deallocate c_pss_catalog
END



