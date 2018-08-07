if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Insert_CrossSelling_Products]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Insert_CrossSelling_Products]

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



	delete 
	from CrossSelling 
	where productid IN (Select productid from product where code = cast(@i_bookkey as varchar))


BEGIN

	DECLARE c_pss_publishedbookkeys INSENSITIVE CURSOR
	FOR

	Select bookkey from cbd..bookdetail 
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

					Select top 4 bookkey, associatedtitlebookkey, sortorder
					from qweb_ecf_associated_crosselling_titles_vw
					where bookkey = @i_published_bookkey
					order by sortorder
				 


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
								
								exec dbo.CrossSellingInsert

								NULL,					 --@CrossSellingId int = NULL output,
								@i_productid,			 --@ProductId int,
								@i_associated_productid, --@RelatedProductId int,
								@i_sortorder		     --@Ordering int = NULL

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
Grant execute on dbo.qweb_ecf_Insert_CrossSelling_Products to Public
GO