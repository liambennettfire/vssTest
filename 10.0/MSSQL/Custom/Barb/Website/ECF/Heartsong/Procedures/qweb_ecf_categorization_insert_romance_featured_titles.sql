IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Categorization_Insert_Romance_Featured_Titles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Categorization_Insert_Romance_Featured_Titles]
go

CREATE procedure [dbo].[qweb_ecf_Categorization_Insert_Romance_Featured_Titles] as

DECLARE @i_c_bookkey int,
		@v_categoryid int,
		@i_webfeature_fetchstatus int,
		@productid int,
		@d_datetime datetime,
		@v_last_featured_title_num int,
		@v_startnum int,
		@v_endnum int,
		@v_currentmonthnum int,
  	@v_last_featured_title_month_num int,
  	@v_cnt int


BEGIN
  select @v_last_featured_title_num = COALESCE(lastfeaturedtitlenumber, 0),
         @v_last_featured_title_month_num = COALESCE(bookclubmonthnum, 0)
  from categoryex_romance_home
  where objectid = dbo.qweb_ecf_get_Category_ID('Heartsong Romance Home')
  
  if @v_last_featured_title_num is null OR @v_last_featured_title_num <= 0 begin
    print 'WARNING:  Unable to import Romance Featured and Upcoming Titles because lastfeaturedtitlenumber is empty'
    return
  end
  
  select @v_currentmonthnum = month(getdate())
  
  if (@v_last_featured_title_month_num <> @v_currentmonthnum) begin
    set @v_startnum = @v_last_featured_title_num + 1
    set @v_endnum = @v_last_featured_title_num + 4
    
    Select @v_cnt = count(*)
	    from barb..bookdetail
     where volumenumber between @v_startnum and @v_endnum
       and publishtowebind = 1
 	     and bookkey in (Select code from product)
    
    if @v_cnt <= 0 begin
      -- no titles are available in the new range - revert back
      set @v_startnum = @v_last_featured_title_num - 3
      set @v_endnum = @v_last_featured_title_num
      set @v_currentmonthnum = @v_last_featured_title_month_num
    end
  end
  else begin
    set @v_startnum = @v_last_featured_title_num - 3
    set @v_endnum = @v_last_featured_title_num
  end
  
    -- Featured Titles
  select @v_categoryid = dbo.qweb_ecf_get_Category_ID('Romance Featured Titles')

	delete from categorization 
	where objecttypeid=1 
	and categoryid = @v_categoryid
  
	DECLARE c_pss_featuretitle INSENSITIVE CURSOR
	FOR
	  Select bookkey
	  from barb..bookdetail
	  where volumenumber between @v_startnum and @v_endnum
	    and publishtowebind = 1
		  and bookkey in (Select code from product)
		order by volumenumber

	FOR READ ONLY
			
	OPEN c_pss_featuretitle

	FETCH NEXT FROM c_pss_featuretitle INTO @i_c_bookkey

	select  @i_webfeature_fetchstatus  = @@FETCH_STATUS
	
	 while (@i_webfeature_fetchstatus >-1 )
		begin
		IF (@i_webfeature_fetchstatus <>-2) 
		begin

			Select @productid = productid from product where code =  cast(@i_c_bookkey as varchar)
			
			IF not exists (Select * 
							from categorization 
							where objectid = @productid 
							and categoryid = @v_categoryid)

			begin
						
			  exec CategorizationInsert
			    @v_categoryid,       --@CategoryId int,
			    @productid,				--@ObjectId int,
			    1,						--@ObjectTypeId int,
			    NULL					--@CategorizationId int = NULL output

			end               
		end

	  FETCH NEXT FROM c_pss_featuretitle INTO @i_c_bookkey
	  select  @i_webfeature_fetchstatus  = @@FETCH_STATUS
  end

  close c_pss_featuretitle
  deallocate c_pss_featuretitle

  -- save values for this month
  if (@v_last_featured_title_month_num <> @v_currentmonthnum) begin
    update categoryex_romance_home
       set lastfeaturedtitlenumber = @v_endnum,
           bookclubmonthnum = @v_currentmonthnum
     where objectid = dbo.qweb_ecf_get_Category_ID('Heartsong Romance Home')           
  end           

  -- Upcoming Titles
  select @v_categoryid = dbo.qweb_ecf_get_Category_ID('Romance Upcoming Titles')

	delete from categorization 
	where objecttypeid=1 
	and categoryid = @v_categoryid

  if (@v_last_featured_title_month_num <> @v_currentmonthnum) begin
    set @v_startnum = @v_last_featured_title_num + 5
    set @v_endnum = @v_last_featured_title_num + 8
  end
  else begin
    set @v_startnum = @v_last_featured_title_num + 1
    set @v_endnum = @v_last_featured_title_num + 4
  end
  
	DECLARE c_pss_upcomingtitle INSENSITIVE CURSOR
	FOR
	  Select bookkey
	  from barb..bookdetail
	  where volumenumber between @v_startnum and @v_endnum
	    and publishtowebind = 1
		  and bookkey in (Select code from product)
		order by volumenumber

	FOR READ ONLY
			
	OPEN c_pss_upcomingtitle

	FETCH NEXT FROM c_pss_upcomingtitle INTO @i_c_bookkey

	select  @i_webfeature_fetchstatus  = @@FETCH_STATUS
	
	 while (@i_webfeature_fetchstatus >-1 )
		begin
		IF (@i_webfeature_fetchstatus <>-2) 
		begin

			Select @productid = productid from product where code =  cast(@i_c_bookkey as varchar)
			
			IF not exists (Select * 
							from categorization 
							where objectid = @productid 
							and categoryid = @v_categoryid)

			begin
						
			  exec CategorizationInsert
			    @v_categoryid,       --@CategoryId int,
			    @productid,				--@ObjectId int,
			    1,						--@ObjectTypeId int,
			    NULL					--@CategorizationId int = NULL output

			end               
		end

	  FETCH NEXT FROM c_pss_upcomingtitle INTO @i_c_bookkey
	  select  @i_webfeature_fetchstatus  = @@FETCH_STATUS
  end

  close c_pss_upcomingtitle
  deallocate c_pss_upcomingtitle 
END



