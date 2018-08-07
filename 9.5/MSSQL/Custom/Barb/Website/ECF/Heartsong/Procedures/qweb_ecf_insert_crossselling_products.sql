IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_CrossSelling_Products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_CrossSelling_Products]
go

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

	Select bookkey from barb..bookdetail 
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
          select top 5 b.bookkey, b.associatedtitlebookkey, b.sortorder
          from dbo.qweb_ecf_get_crossselling_products(@i_published_bookkey) b, barb..bookdetail bd
          where b.associatedtitlebookkey = bd.bookkey
	 	        and bd.bisacstatuscode in (1)
          order by b.sortorder, NEWID()

--					Select top 4 bookkey, associatedtitlebookkey, sortorder
--					from qweb_ecf_associated_crosselling_titles_vw
--					where bookkey = @i_published_bookkey
--					order by sortorder
				 
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
								
								IF (@i_productid > 0 AND @i_associated_productid > 0) BEGIN
								
								  exec dbo.CrossSellingInsert
								  NULL,					 --@CrossSellingId int = NULL output,
								  @i_productid,			 --@ProductId int,
								  @i_associated_productid, --@RelatedProductId int,
								  @i_sortorder		     --@Ordering int = NULL
								  
								END

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




