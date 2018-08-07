if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Link_Authors_to_Titles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Link_Authors_to_Titles]
GO


CREATE procedure [dbo].[qweb_ecf_Link_Authors_to_Titles] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
        @v_contactkey int,
		@i_sortorder int,
		@v_fetchstatus int,
		@i_title_productid int,
		@i_author_productid int,	
		@i_published_bookkey int,
		@v_cnt int

BEGIN

	DECLARE c_pss_authors INSENSITIVE CURSOR
	FOR
	  Select authorkey, b.sortorder
  	  from uap..bookauthor b, uap..bookdetail bd
	   where b.bookkey = bd.bookkey
	 	   and b.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1

  FOR READ ONLY
			
	OPEN c_pss_authors

	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey, @i_sortorder

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1 ) begin
	  IF (@v_fetchstatus <>-2)	begin

      Select @i_title_productid = dbo.qweb_ecf_get_product_id (@i_bookkey)
		  Select @i_author_productid = dbo.qweb_ecf_get_product_id (@v_contactkey)
      
      if (@i_title_productid > 0 AND @i_author_productid > 0) begin
        set @i_sortorder = @i_sortorder + 100

	      delete from CrossSelling 
	      where productid = @i_title_productid
	      and relatedproductid = @i_author_productid
        
	      exec dbo.CrossSellingInsert
	        NULL,					 --@CrossSellingId int = NULL output,
	        @i_title_productid,			 --@ProductId int,
	        @i_author_productid, --@RelatedProductId int,
	        @i_sortorder		     --@Ordering int = NULL

        delete from CrossSelling 
        where productid = @i_author_productid
        and relatedproductid = @i_title_productid

        -- only want a max of 6 related titles for the author
        select @v_cnt = count(*) from CrossSelling
	      where productid = @i_author_productid

        if @v_cnt < 6 begin
          -- only insert available titles
          Select @v_cnt = count(*) 
						from uap..bookauthor b, uap..bookdetail bd 
					 where b.bookkey = bd.bookkey
	 	         and bd.bisacstatuscode in (1)
      	 	   and bd.publishtowebind=1
 					   and b.bookkey=@i_bookkey
 					        					       
 					if @v_cnt > 0 begin
	          exec dbo.CrossSellingInsert
	            NULL,					 --@CrossSellingId int = NULL output,
	            @i_author_productid, --@ProductId int,
	            @i_title_productid,			 --@RelatedProductId int,
	            @i_sortorder		     --@Ordering int = NULL
	        end
        end
	    end
	     
		  FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey, @i_sortorder
		   
		  select  @v_fetchstatus  = @@FETCH_STATUS	     
    end
	end

	close c_pss_authors
	deallocate c_pss_authors
END
GO
Grant execute on dbo.qweb_ecf_Link_Authors_to_Titles to Public
GO