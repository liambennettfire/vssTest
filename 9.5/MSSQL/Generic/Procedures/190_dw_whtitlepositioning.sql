PRINT 'STORED PROCEDURE : dbo.dw_whtitlepositioning'

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dw_whtitlepositioning]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dw_whtitlepositioning]
GO


/*dw_whtitlepositioning.sql*/


CREATE  proc dbo.dw_whtitlepositioning
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count int 

DECLARE @ware_author_count int
DECLARE @ware_author_displayname varchar(255) 
DECLARE @ware_bookdetail_count int
DECLARE @ware_mediatypecode int
DECLARE @ware_mediatypesubcode int
DECLARE @ware_mediacode_long varchar(40)  
DECLARE @ware_mediacode_short varchar(20)  
DECLARE @ware_formatcode_long varchar(120) 
DECLARE @ware_formatcode_short varchar(20)  
DECLARE @ware_titleprefix varchar(100)  
DECLARE @ware_book_count int
DECLARE @ware_title varchar(255)  
DECLARE @ware_titleprefixandtitle varchar(255)  
DECLARE @prefix varchar(25) 
DECLARE @ware_publishedinhouseyesno varchar(3) 
DECLARE @ware_salesunitgross int
DECLARE @ware_salesunitnet int
DECLARE @ware_isbn_count int
DECLARE @ware_isbn varchar(19)  
DECLARE @ware_bookprice_count int
DECLARE @ware_price float
DECLARE @ware_budgetprice float
DECLARE @ware_bookdates_count int
DECLARE @ware_pubdate datetime
DECLARE @ware_orglevelkey int
DECLARE @ware_orgentrykey int
DECLARE @filterorglevel_count int
DECLARE @orgentry_count int
DECLARE @ware_origpubhouse varchar(40)  
DECLARE @ware_bookorgentry_count int
DECLARE @ware_editioncode int
DECLARE @ware_editioncode_long varchar(150)  

DECLARE @i_authorkey int
DECLARE @c_authorname varchar(255)
DECLARE @i_associatetitlebookkey int
DECLARE @i_origpubhousecode int
DECLARE @c_isbn varchar(19)
DECLARE @c_title varchar(255)
DECLARE @i_mediatypecode int
DECLARE @i_mediatypesubcode int
DECLARE @i_price float
DECLARE @d_pubdate datetime
DECLARE @i_salesunitgross int
DECLARE @i_salesunitnet int
DECLARE @i_sortorder int
DECLARE @i_status_assoc  int
DECLARE @i_editioncode int
DECLARE @i_editiondescription varchar(150)
DECLARE @i_bookkey int
DECLARE @i_associationtypecode int
DECLARE @i_associationtypesubcode int
DECLARE @i_bisacstatuscode int
DECLARE @c_lastuserid varchar(255)
DECLARE @d_lastmaintdate datetime
DECLARE  @i_reportind tinyint

DECLARE @ware_currencycode int
DECLARE @ware_pricecode int
DECLARE @ware_bisacstatuscode int
DECLARE @ware_bisacstatuscode_long varchar(40)
DECLARE @ware_associationtypedesc varchar(40)
DECLARE @ware_lastmaintdate datetime

DECLARE whassociatedtitles INSENSITIVE CURSOR
FOR
		SELECT bookkey, associationtypecode, associationtypesubcode ,authorkey, authorname,associatetitlebookkey,  
      origpubhousecode,isbn, title, mediatypecode,mediatypesubcode,price,pubdate,
		salesunitgross, salesunitnet, sortorder,editiondescription, bisacstatus,lastuserid,
      lastmaintdate,reportind
		    FROM associatedtitles
          WHERE bookkey = @ware_bookkey 
		  	 ORDER BY bookkey ASC, associationtypecode ASC, sortorder ASC 
FOR READ ONLY

select @ware_count = 1 

 OPEN  whassociatedtitles

	FETCH NEXT FROM whassociatedtitles
	   INTO @i_bookkey, @i_associationtypecode,@i_associationtypesubcode, @i_authorkey,@c_authorname ,
		@i_associatetitlebookkey,@i_origpubhousecode,
		@c_isbn,@c_title,@i_mediatypecode,@i_mediatypesubcode,@i_price,@d_pubdate,
			@i_salesunitgross,@i_salesunitnet,@i_sortorder,@i_editiondescription,
      @i_bisacstatuscode,@c_lastuserid,@d_lastmaintdate, @i_reportind 

	select @i_status_assoc = @@FETCH_STATUS

	 while (@i_status_assoc <>-1 )
	   begin

		IF (@i_status_assoc <>-2)
		  begin
			if @i_bookkey is null
			  begin
                                select @i_bookkey = 0
                          end
			if  @i_associationtypecode is null 
			  begin
				select @i_associationtypecode = 0
 	 		 end
             if  @i_associationtypesubcode is null 
			  begin
				select @i_associationtypesubcode = 0
 	 		 end
			if  @i_authorkey is null 
			  begin
				select @i_authorkey = 0
 	 		 end
			if @c_authorname is null
			  begin
				select @c_authorname = ''
			  end 
			if @i_associatetitlebookkey is null
			  begin
				select  @i_associatetitlebookkey = 0
			  end
			if @i_origpubhousecode is null
			  begin
				select @i_origpubhousecode = 0
			  end
			if @c_isbn  is null
			  begin
				select @c_isbn = ''
			  end
			if @c_title is null
			  begin
				select @c_title = ''
			  end
			if @i_mediatypecode is null
			  begin
				select @i_mediatypesubcode = 0
			  end
			if @i_price is null
			  begin
				select @i_price = 0
			  end
			if @d_pubdate is null
			  begin
				select @d_pubdate = ''
			  end
			if @i_salesunitgross is null
			  begin
				select @i_salesunitgross = 0
			  end
			if @i_salesunitnet is null
			  begin
				select @i_salesunitnet = 0
			  end
			if @i_sortorder is null
			  begin
				select @i_sortorder = 0
			  end  
			/*if @i_editioncode is null
				begin
					select @i_editioncode = 0
				end*/
              if @i_editiondescription is null
              begin
                  select @i_editiondescription = ''
              end
			if @i_bisacstatuscode is null
				begin
					select @i_bisacstatuscode = 0
				end
			if @c_lastuserid is null
			  begin
				select @c_lastuserid = ''
			  end
			if @d_lastmaintdate is null
			  begin
				select @d_lastmaintdate = ''
			  end

			if @i_associatetitlebookkey > 0 				/* in house title*/
			  begin  
           
				select @ware_author_count =  0
				select @ware_author_count = count(*) 
					from coretitleinfo
						where coretitleinfo.bookkey = @i_associatetitlebookkey
				if  @ware_author_count > 0 
				  begin
					select @ware_author_displayname = coretitleinfo.authorname
						from coretitleinfo 
							where coretitleinfo.bookkey = @i_associatetitlebookkey
							and coretitleinfo.printingkey=1
				  end
				else
			 	 begin
					select @ware_author_displayname  = ''
			  	end 

				
				if @i_associationtypecode > 0 
				  begin
					exec gentables_longdesc 440,@i_associationtypecode, @ware_associationtypedesc OUTPUT 
					select @ware_associationtypedesc = substring(@ware_associationtypedesc,1,40)
				  end	
				else
				  begin
					select @ware_associationtypedesc = ''
				  end	

				select @ware_isbn_count = 0
				select @ware_isbn_count = count(*)
					from isbn
						where isbn.bookkey = @i_associatetitlebookkey
				if  @ware_isbn_count > 0 
				  begin
					select @ware_isbn = isbn
						from isbn
							where isbn.bookkey = @i_associatetitlebookkey
				 end
				else
				  begin
					select @ware_isbn =  ''
				  end

				select @filterorglevel_count = 0
				select @ware_orglevelkey = 0
				select @ware_bookorgentry_count = 0
				select @ware_orgentrykey = 0
				select @filterorglevel_count  = count(*) 
					from filterorglevel
						where filterkey = 23
				if @filterorglevel_count is null
				  begin
					select @filterorglevel_count = 0
				  end 
				if  @filterorglevel_count > 0 
				  begin
					select @ware_orglevelkey = filterorglevelkey 
						from filterorglevel
							where filterkey = 23
					if @ware_orglevelkey  is null
				 	  begin
						select @ware_orglevelkey  = 0
					  end 
					if @ware_orglevelkey > 0 
					  begin
						select @ware_bookorgentry_count =count(*)
							from bookorgentry
								where (orglevelkey = @ware_orglevelkey  and bookkey = @i_associatetitlebookkey)
			
						if  @ware_bookorgentry_count > 0 
						  begin
							select @ware_orgentrykey = orgentrykey
								from bookorgentry
									where bookkey = @i_associatetitlebookkey and
								orglevelkey = @ware_orglevelkey
							if @ware_orgentrykey > 0 
							  begin
								select @orgentry_count = count(*) 
									from orgentry
								where orgentry.orgentrykey = @ware_orgentrykey
								if @orgentry_count > 0 
								  begin
									select @ware_origpubhouse = orgentrydesc
										from orgentry
											where orgentry.orgentrykey = @ware_orgentrykey
								  end	
								else
								  begin
									select @ware_origpubhouse =  ''
								 end
							  end
					      end
					    else
					      begin
						  select @ware_origpubhouse = ''
 					      end 
				  	end
			 	end
			else
		          begin
				select @ware_origpubhouse  = ''
			 end
				select @ware_bookdetail_count = 0
				select @ware_bookdetail_count = count(*)
					from bookdetail
						where bookdetail.bookkey = @i_associatetitlebookkey
				if @ware_bookdetail_count > 0 
				  begin
					select @ware_mediatypecode = bookdetail.mediatypecode, 
						@ware_mediatypesubcode = bookdetail.mediatypesubcode, @ware_titleprefix = titleprefix,
						@ware_editioncode = bookdetail.editioncode,
                  @ware_bisacstatuscode = bookdetail.bisacstatuscode
							from bookdetail
								where bookdetail.bookkey = @i_associatetitlebookkey
					if @ware_titleprefix is null
					  begin 
						select @ware_titleprefix = ''
					  end
				  end
				else
				  begin
					select @ware_mediatypecode = 0
					select @ware_mediatypesubcode = 0
					select @ware_titleprefix = ''
					select @ware_editioncode = 0
               select @ware_bisacstatuscode = 0
				  end 
				if @ware_mediatypecode > 0 
				  begin
					exec gentables_longdesc 312,@ware_mediatypecode, @ware_mediacode_long OUTPUT 
					select @ware_mediacode_long = @ware_mediacode_long
					exec gentables_shortdesc 312,@ware_mediatypecode, @ware_mediacode_short OUTPUT
					select @ware_mediacode_short = substring(@ware_mediacode_short,1,20)
				  end	
				else
				  begin
					select @ware_mediacode_long = ''
					select @ware_mediacode_short = ''
				  end	

				if @ware_mediatypesubcode > 0 
				  begin
					exec subgent_longdesc 312,@ware_mediatypecode,@ware_mediatypesubcode,@ware_formatcode_long OUTPUT
					select @ware_formatcode_long = @ware_formatcode_long
					exec subgent_shortdesc 312,@ware_mediatypecode,@ware_mediatypesubcode,@ware_formatcode_short  OUTPUT
					select @ware_formatcode_short = substring(@ware_formatcode_short,1,20)
				  end
				else
				  begin
					select @ware_formatcode_long = ''
					select @ware_formatcode_short = ''
				  end	

				if @ware_editioncode > 0 
				  begin
					exec gentables_longdesc 200,@ware_editioncode, @ware_editioncode_long OUTPUT 
					select @ware_editioncode_long = substring(@ware_editioncode_long,1,40)
				  end	
				else
				  begin
					select @ware_editioncode_long = ''
				  end	

				if @ware_bisacstatuscode > 0 
				  begin
					exec gentables_longdesc 314,@ware_bisacstatuscode, @ware_bisacstatuscode_long OUTPUT 
					select @ware_bisacstatuscode_long = substring(@ware_bisacstatuscode_long,1,40)
				  end	
				else
				  begin
					select @ware_bisacstatuscode_long = ''
				  end	
		
				select @ware_book_count = 0
				select @ware_book_count = count(*)
					from book
					where book.bookkey = @i_associatetitlebookkey
				if @ware_book_count > 0 
				  begin
					select @ware_title = title 
						from book
						where book.bookkey = @i_associatetitlebookkey

					if @ware_title  is null
					  begin
						select @ware_title = ''
					  end
				  end
				else
				  begin
					select @ware_title  = ''
				 end

				select @prefix = rtrim(substring(@ware_titleprefix,1,15))
		
				if datalength(@prefix)> 0 
				  begin
					select @ware_titleprefixandtitle = @ware_title +   ',  ' +   @prefix
				  end
				else
				  begin
					select @ware_titleprefixandtitle =  @ware_title
				  end
				select @ware_title = @ware_titleprefixandtitle
	
				select @ware_publishedinhouseyesno = 'yes'

				select @ware_count = 0
				select @ware_count = count(*) from filterpricetype
					where filterkey = 5 /*currency and price types*/

				if @ware_count > 0 
				  begin
					select @ware_pricecode= pricetypecode, @ware_currencycode = currencytypecode
						 from filterpricetype
							where filterkey = 5 /*currency and price types*/
				  end
				else
			 	  begin
				BEGIN tran
					INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	          				errorseverity, errorfunction,lastuserid, lastmaintdate)
					 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
						'No row on filterpricetype - for bookprice',
						('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
						'Stored procedure datawarehouse_bookprice','WARE_STORED_PROC',@ware_system_date)
				commit tran
				  end

				select @ware_bookprice_count = 0
				select @ware_bookprice_count = count(*)
					from bookprice
						where bookprice.bookkey = @i_associatetitlebookkey and
								pricetypecode = @ware_pricecode and     
								currencytypecode = @ware_currencycode and activeind = 1

				if @ware_bookprice_count > 0 
				  begin
					select  @ware_price = finalprice, @ware_budgetprice = budgetprice
						from bookprice
							where bookprice.bookkey = @i_associatetitlebookkey and
								pricetypecode = @ware_pricecode and      
								currencytypecode = @ware_currencycode and activeind = 1
				  end
				  else
				  begin
						select @ware_price = 0
				  end

				if @ware_bookprice_count > 0 
				begin
					if @ware_budgetprice is null
					begin
					 select @ware_budgetprice = 0
				   end
					if @ware_price is null
					begin
					 select @ware_price = 0
					end
					if @ware_price = 0
					begin
					  select @ware_price = @ware_budgetprice
					end
				end


				select @ware_bookdates_count = 0
				select @ware_bookdates_count = count(*)
					from bookdates
						where bookdates.bookkey = @i_associatetitlebookkey and
							datetypecode = 8 and printingkey=1
				if  @ware_bookdates_count > 0 
				  begin
					select  @ware_pubdate = bestdate 
						from bookdates
							where bookdates.bookkey = @i_associatetitlebookkey and
								datetypecode = 8 and printingkey=1
				  end
				
				select @ware_salesunitgross = @i_salesunitgross
				select @ware_salesunitnet = @i_salesunitnet
				
				BEGIN tran
					INSERT into whtitlepositioning
					(bookkey, associationtypecode,associationtypesubcode, associationtypedesc,
					 associatetitlebookkey,sortorder,isbn,title,authorkey,authorname,
					 bisacstatus,bisacstatusdesc,
					 origpubhousecode,originalpubhouse,
					 mediatypecode,media,mediashort,
					 mediatypesubcode,format,formatshort,
					 price,pubdate,salesunitgross,salesunitnet,
					 reportind,publishedinhouse,edition,
					 lastuserid, lastmaintdate)
				VALUES (@ware_bookkey,@i_associationtypecode,@i_associationtypesubcode,@ware_associationtypedesc,
						  @i_associatetitlebookkey,@i_sortorder,@ware_isbn,rtrim(substring(@ware_title,1,80)),
                                                  @i_authorkey,@ware_author_displayname,
						  @i_bisacstatuscode,@ware_bisacstatuscode_long,
						  @i_origpubhousecode,@ware_origpubhouse,
						  @ware_mediatypecode,@ware_mediacode_long,@ware_mediacode_short,
						  @ware_mediatypesubcode,@ware_formatcode_long,@ware_formatcode_short,
						  @ware_price,@ware_pubdate,@ware_salesunitgross,@ware_salesunitnet,
						  @i_reportind,@ware_publishedinhouseyesno,@ware_editioncode_long,
						  'WARE_STORED_PROC',@ware_system_date);
				commit tran
		  end
		else                                                                               /* out of house title */
		  begin	
			select @ware_author_displayname = @c_authorname

			if @i_origpubhousecode > 0 
			  begin
				exec gentables_longdesc 126,@i_origpubhousecode,@ware_origpubhouse OUTPUT
			  end
			else
			  begin
				select @ware_origpubhouse = ''
			  end

			select @ware_isbn = @c_isbn
	
			if @i_mediatypecode > 0 
			  begin
				exec gentables_longdesc 312,@i_mediatypecode , @ware_mediacode_long OUTPUT
				select @ware_mediacode_long = @ware_mediacode_long
				exec gentables_shortdesc 312,@i_mediatypecode, @ware_mediacode_short OUTPUT
				select @ware_mediacode_short = substring(@ware_mediacode_short,1,20)
			  end
			else
			  begin
				select @ware_mediacode_long =  ''
				select @ware_mediacode_short = ''
			  end 

			if @i_mediatypesubcode > 0 
			  begin
				exec subgent_longdesc 312,@i_mediatypecode,@i_mediatypesubcode, @ware_formatcode_long OUTPUT
				select @ware_formatcode_long = @ware_formatcode_long
				exec subgent_shortdesc 312,@i_mediatypecode,@i_mediatypesubcode,  @ware_formatcode_short OUTPUT
				select @ware_formatcode_short = substring(@ware_formatcode_short,1,20)
			 end
			else
			  begin
				select @ware_formatcode_long = ''
				select @ware_formatcode_short = ''
			  end	

			select @ware_editioncode_long = @i_editiondescription
              if @ware_editioncode_long  is null
			 begin
				select @ware_editioncode_long = ''
			  end

			if @i_bisacstatuscode > 0 
				  begin
					exec gentables_longdesc 314,@i_bisacstatuscode, @ware_bisacstatuscode_long OUTPUT 
					select @ware_bisacstatuscode_long = substring(@ware_bisacstatuscode_long,1,40)
				  end	
				else
				  begin
					select @ware_bisacstatuscode_long = ''
				  end	

			select @ware_title = @c_title

			select @ware_price = @i_price

			select @ware_pubdate = @d_pubdate

			select @ware_publishedinhouseyesno = 'no'

			select @ware_salesunitgross = @i_salesunitgross
			select @ware_salesunitnet = @i_salesunitnet
		  
			
		  BEGIN tran
			  INSERT into whtitlepositioning
					(bookkey, associationtypecode,associationtypesubcode, associationtypedesc,
					 associatetitlebookkey,sortorder,isbn,title,authorkey,authorname,
					 bisacstatus,bisacstatusdesc,
					 origpubhousecode,originalpubhouse,
					 mediatypecode,media,mediashort,
					 mediatypesubcode,format,formatshort,
					 price,pubdate,salesunitgross,salesunitnet,
					 reportind,publishedinhouse,edition,
					 lastuserid, lastmaintdate)
				VALUES (@ware_bookkey,@i_associationtypecode,@i_associationtypesubcode,@ware_associationtypedesc,
						  @i_associatetitlebookkey,@i_sortorder,@ware_isbn,rtrim(substring(@ware_title,1,80)),
                                                  @i_authorkey,@ware_author_displayname,
						  @i_bisacstatuscode,@ware_bisacstatuscode_long,
						  @i_origpubhousecode,@ware_origpubhouse,
						  @ware_mediatypecode,@ware_mediacode_long,@ware_mediacode_short,
						  @ware_mediatypesubcode,@ware_formatcode_long,@ware_formatcode_short,
						  @ware_price,@ware_pubdate,@ware_salesunitgross,@ware_salesunitnet,
						  @i_reportind,@ware_publishedinhouseyesno,@ware_editioncode_long,
						  'WARE_STORED_PROC',@ware_system_date);
				commit tran
		end 
	 end /*<>*/
				
        FETCH NEXT FROM whassociatedtitles
			INTO @i_bookkey, @i_associationtypecode,@i_associationtypesubcode, @i_authorkey,@c_authorname ,
			@i_associatetitlebookkey,@i_origpubhousecode,
			@c_isbn,@c_title,@i_mediatypecode,@i_mediatypesubcode,@i_price,@d_pubdate,
				@i_salesunitgross,@i_salesunitnet,@i_sortorder,@i_editiondescription,
			@i_bisacstatuscode,@c_lastuserid,@d_lastmaintdate, @i_reportind 

		select @i_status_assoc  = @@FETCH_STATUS
	end /*<>*/

close whassociatedtitles
deallocate whassociatedtitles



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO