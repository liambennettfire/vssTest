PRINT 'STORED PROCEDURE : dbo.datawarehouse_titlepositioning'

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[datawarehouse_titlepositioning]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[datawarehouse_titlepositioning]
GO

CREATE  proc dbo.datawarehouse_titlepositioning 
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime, @ware_associationtypecode int

AS 

DECLARE @ware_count int 
DECLARE @cnt int 

DECLARE @ware_authordisplayname1 varchar(255) 
DECLARE @ware_origpubhouse1 varchar(40) 
DECLARE @ware_isbn1 varchar(25)  
DECLARE @ware_title1 varchar(255)  
DECLARE @ware_media1 varchar(40)  
DECLARE @ware_format1 varchar(120)  
DECLARE @ware_mediashort1 varchar(20)  
DECLARE @ware_formatshort1 varchar(20)  
DECLARE @ware_price1  float
DECLARE @ware_pubdate1 datetime
DECLARE @ware_publishedinhouseyesno1 varchar(3) 
DECLARE @ware_salesunitgross1 int
DECLARE @ware_salesunitnet1 int
DECLARE @ware_edition1 varchar(150)  

DECLARE @ware_authordisplayname2 varchar(255)  
DECLARE @ware_origpubhouse2 varchar(40) 
DECLARE @ware_isbn2 varchar(25) 
DECLARE @ware_title2 varchar(255)  
DECLARE @ware_media2 varchar(40)  
DECLARE @ware_format2 varchar(120)  
DECLARE @ware_mediashort2 varchar(20)  
DECLARE @ware_formatshort2 varchar(20)  
DECLARE @ware_price2  float
DECLARE @ware_pubdate2 datetime
DECLARE @ware_publishedinhouseyesno2 varchar(3)  
DECLARE @ware_salesunitgross2 int
DECLARE @ware_salesunitnet2 int
DECLARE @ware_edition2 varchar(150)  

DECLARE @ware_authordisplayname3 varchar(255)  
DECLARE @ware_origpubhouse3 varchar(40) 
DECLARE @ware_isbn3 varchar(25)  
DECLARE @ware_title3 varchar(255)  
DECLARE @ware_media3 varchar(40)  
DECLARE @ware_format3 varchar(120)  
DECLARE @ware_mediashort3 varchar(20)  
DECLARE @ware_formatshort3 varchar(20)  
DECLARE @ware_price3  float
DECLARE @ware_pubdate3 datetime
DECLARE @ware_publishedinhouseyesno3 varchar(3)  
DECLARE @ware_salesunitgross3 int
DECLARE @ware_salesunitnet3 int
DECLARE @ware_edition3 varchar(150)  

DECLARE @ware_authordisplayname4 varchar(255)  
DECLARE @ware_origpubhouse4 varchar(40) 
DECLARE @ware_isbn4 varchar(25)  
DECLARE @ware_title4 varchar(255)  
DECLARE @ware_media4 varchar(40)  
DECLARE @ware_format4 varchar(120)  
DECLARE @ware_mediashort4 varchar(20)  
DECLARE @ware_formatshort4 varchar(20)  
DECLARE @ware_price4  float
DECLARE @ware_pubdate4 datetime
DECLARE @ware_publishedinhouseyesno4 varchar(3)  
DECLARE @ware_salesunitgross4 int
DECLARE @ware_salesunitnet4 int
DECLARE @ware_edition4 varchar(150)  

DECLARE @ware_authordisplayname5 varchar(255)  
DECLARE @ware_origpubhouse5 varchar(40) 
DECLARE @ware_isbn5 varchar(25)  
DECLARE @ware_title5 varchar(255)  
DECLARE @ware_media5 varchar(40)  
DECLARE @ware_format5 varchar(120) 
DECLARE @ware_mediashort5 varchar(20)  
DECLARE @ware_formatshort5 varchar(20)  
DECLARE @ware_price5  float
DECLARE @ware_pubdate5 datetime
DECLARE @ware_publishedinhouseyesno5 varchar(3) 
DECLARE @ware_salesunitgross5 int
DECLARE @ware_salesunitnet5 int
DECLARE @ware_edition5 varchar(150)  

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
DECLARE @ware_isbn varchar(25)  
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
DECLARE @ware_editiondesc VARCHAR(150)

DECLARE @i_authorkey int
DECLARE @c_authorname varchar(255)
DECLARE @i_associatetitlebookkey int
DECLARE @i_origpubhousecode int
DECLARE @c_isbn varchar(13)
DECLARE @c_title varchar(255)
DECLARE @i_mediatypecode int
DECLARE @i_mediatypesubcode int
DECLARE @i_price float
DECLARE @d_pubdate datetime
DECLARE @i_salesunitgross int
DECLARE @i_salesunitnet int
DECLARE @i_sortorder int
DECLARE @i_status_assoc  int
DECLARE @i_editiondescription VARCHAR(150)
DECLARE @ware_currencycode int
DECLARE @ware_pricecode int

DECLARE whassociatedtitles INSENSITIVE CURSOR
FOR
  SELECT authorkey, authorname, associatetitlebookkey, origpubhousecode,
    isbn, title, mediatypecode, mediatypesubcode, price, pubdate,
    salesunitgross, salesunitnet, sortorder, editiondescription
  FROM associatedtitles 
  WHERE  bookkey = @ware_bookkey and associationtypecode = @ware_associationtypecode
  ORDER BY sortorder ASC 
FOR READ ONLY

select @ware_count = 1 

 OPEN  whassociatedtitles

	FETCH NEXT FROM whassociatedtitles
    INTO @i_authorkey, @c_authorname, @i_associatetitlebookkey, @i_origpubhousecode,
    @c_isbn, @c_title, @i_mediatypecode, @i_mediatypesubcode, @i_price, @d_pubdate,
    @i_salesunitgross, @i_salesunitnet, @i_sortorder, @i_editiondescription

	select @i_status_assoc = @@FETCH_STATUS

	if @i_status_assoc <> 0 /** NO associated **/
    	  begin 
		if @ware_associationtypecode = 3  
		  begin
		   BEGIN tran
			INSERT into whauthorsalestrack (bookkey,lastuserid,lastmaintdate)
			VALUES  (@ware_bookkey,'WARE_STORED_PROC',@ware_system_date)  
		    commit tran
			close whassociatedtitles
			deallocate whassociatedtitles		
			RETURN
		    end
		else if @ware_associationtypecode = 1  
		    begin
			  BEGIN tran
			INSERT into whcompetitivetitles(bookkey,lastuserid,lastmaintdate)
			VALUES  (@ware_bookkey,'WARE_STORED_PROC',@ware_system_date)  
   		     commit tran	
			close whassociatedtitles
			deallocate whassociatedtitles	
			RETURN
		    end
		else if @ware_associationtypecode = 2 
		   begin	
		     BEGIN tran
			INSERT into whcomparativetitles(bookkey,lastuserid,lastmaintdate)
			VALUES  (@ware_bookkey,'WARE_STORED_PROC',@ware_system_date)  
		      commit tran	
			close whassociatedtitles
			deallocate whassociatedtitles	
			RETURN
		    end
	end

	 while (@i_status_assoc <>-1 )
	   begin

		IF (@i_status_assoc <>-2)
		  begin
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
			if @i_editiondescription is null
				begin
					select @i_editiondescription = ''
				end

			if @i_associatetitlebookkey > 0 				/* in house title*/
			  begin    
				select @ware_author_count =  0
				select @ware_author_count = count(*) 
					from coretitleinfo
						where coretitleinfo.bookkey = @i_associatetitlebookkey
						and coretitleinfo.printingkey = 1
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

				/*select @ware_author_displayname = @c_authorname */

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
            select @ware_mediatypecode = mediatypecode, @ware_mediatypesubcode = mediatypesubcode, @ware_titleprefix = titleprefix,
              @ware_editiondesc = editiondescription
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
					select @ware_editiondesc = ''
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

				select @cnt = 0
				select @cnt = count(*) from filterpricetype
					where filterkey = 5 /*currency and price types*/

				if @cnt > 0 
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

			select @ware_editiondesc = @i_editiondescription

			select @ware_title = @c_title

			select @ware_price = @i_price

			select @ware_pubdate = @d_pubdate

			select @ware_publishedinhouseyesno = 'no'

			select @ware_salesunitgross = @i_salesunitgross
			select @ware_salesunitnet = @i_salesunitnet
		  end 

	/*@ware_count = cursor_row.sortorder*/

		if @ware_count  = 1
		   begin
			select @ware_authordisplayname1   = @ware_author_displayname
			select @ware_origpubhouse1 =  @ware_origpubhouse
			select @ware_isbn1  = @ware_isbn
			select @ware_title1 =  @ware_title
			select @ware_media1  = @ware_mediacode_long
			select @ware_format1= @ware_formatcode_long
			select @ware_mediashort1 = @ware_mediacode_short
			select @ware_formatshort1 = @ware_formatcode_short
			select @ware_price1 =  @ware_price
			select @ware_pubdate1  =  @ware_pubdate
			select @ware_publishedinhouseyesno1 = @ware_publishedinhouseyesno
			select @ware_salesunitgross1 = @ware_salesunitgross
			select @ware_salesunitnet1 = @ware_salesunitnet
      select @ware_edition1 = @ware_editiondesc
		  end 
		 else if  @ware_count  = 2 
		  begin 
			select @ware_authordisplayname2  =  @ware_author_displayname
			select @ware_origpubhouse2 =  @ware_origpubhouse
			select @ware_isbn2  = @ware_isbn
			select @ware_title2  = @ware_title
			select @ware_media2  = @ware_mediacode_long
			select @ware_format2 = @ware_formatcode_long
			select @ware_mediashort2 = @ware_mediacode_short
			select @ware_formatshort2 = @ware_formatcode_short
			select @ware_price2  = @ware_price
			select @ware_pubdate2   = @ware_pubdate
			select @ware_publishedinhouseyesno2 = @ware_publishedinhouseyesno
			select @ware_salesunitgross2 = @ware_salesunitgross
			select @ware_salesunitnet2 = @ware_salesunitnet
			select @ware_edition2 = @ware_editiondesc
		  end	
		else if @ware_count  =  3
		  begin 
			select @ware_authordisplayname3  =  @ware_author_displayname
			select @ware_origpubhouse3  = @ware_origpubhouse
			select @ware_isbn3  = @ware_isbn
			select @ware_title3  = @ware_title
			select @ware_media3  = @ware_mediacode_long
			select @ware_format3 = @ware_formatcode_long
			select @ware_mediashort3 = @ware_mediacode_short
			select @ware_formatshort3  = @ware_formatcode_short
			select @ware_price3 =  @ware_price
			select @ware_pubdate3   = @ware_pubdate
			select @ware_publishedinhouseyesno3 = @ware_publishedinhouseyesno
			select @ware_salesunitgross3 = @ware_salesunitgross
			select @ware_salesunitnet3 = @ware_salesunitnet
			select @ware_edition3 = @ware_editiondesc
		  end	
		else if @ware_count  =  4 
		  begin 
			select @ware_authordisplayname4  =  @ware_author_displayname
			select @ware_origpubhouse4  = @ware_origpubhouse
			select @ware_isbn4  = @ware_isbn
			select @ware_title4 =  @ware_title
			select @ware_media4 =  @ware_mediacode_long
			select @ware_format4 = @ware_formatcode_long
			select @ware_mediashort4 = @ware_mediacode_short
			select @ware_formatshort4 = @ware_formatcode_short
			select @ware_price4  = @ware_price
			select @ware_pubdate4  =  @ware_pubdate
			select @ware_publishedinhouseyesno1 = @ware_publishedinhouseyesno
			select @ware_salesunitgross4 = @ware_salesunitgross
			select @ware_salesunitnet4 = @ware_salesunitnet
			select @ware_edition4 = @ware_editiondesc
		  end	
		else if @ware_count  =  5 
		  begin 
			select @ware_authordisplayname5  =  @ware_author_displayname
			select @ware_origpubhouse5 =  @ware_origpubhouse
			select @ware_isbn5  = @ware_isbn
			select @ware_title5  = @ware_title
			select @ware_media5  = @ware_mediacode_long
			select @ware_format5 = @ware_formatcode_long
			select @ware_mediashort5 = @ware_mediacode_short
			select @ware_formatshort5 = @ware_formatcode_short
			select @ware_price5 =  @ware_price
			select @ware_pubdate5  =  @ware_pubdate
			select @ware_publishedinhouseyesno5 = @ware_publishedinhouseyesno
			select @ware_salesunitgross5 = @ware_salesunitgross
			select @ware_salesunitnet5 = @ware_salesunitnet
			select @ware_edition5 = @ware_editiondesc
		 end  /*case*/

		select @ware_count = @ware_count +   1	
	   end /*<>*/

	  FETCH NEXT FROM whassociatedtitles
      INTO @i_authorkey, @c_authorname, @i_associatetitlebookkey, @i_origpubhousecode,
      @c_isbn, @c_title, @i_mediatypecode, @i_mediatypesubcode, @i_price, @d_pubdate,
      @i_salesunitgross, @i_salesunitnet, @i_sortorder, @i_editiondescription
      
		select @i_status_assoc  = @@FETCH_STATUS
	  end /*<>*/

BEGIN tran

if @ware_associationtypecode = 3 
  begin
	INSERT into whauthorsalestrack
		(bookkey, authordisplayname1,origpubhouse1 ,isbn1,
		title1,media1,format1,mediashort1, formatshort1, price1,pubdate1,
		publishedinhouseyesno1,salesunitgross1,salesunitnet1,
		authordisplayname2,origpubhouse2 ,isbn2,
		title2,media2,format2,mediashort2, formatshort2, price2,pubdate2,
		publishedinhouseyesno2,salesunitgross2,salesunitnet2,
		authordisplayname3,origpubhouse3 ,isbn3,
		title3,media3,format3,mediashort3, formatshort3, price3,pubdate3,
		publishedinhouseyesno3,salesunitgross3,salesunitnet3,
		authordisplayname4,origpubhouse4 ,isbn4,
		title4,media4,format4,mediashort4, formatshort4, price4,pubdate4,
		publishedinhouseyesno4,salesunitgross4,salesunitnet4,
		authordisplayname5,origpubhouse5 ,isbn5,
		title5,media5,format5,mediashort5, formatshort5, price5,pubdate5,
		publishedinhouseyesno5,salesunitgross5,salesunitnet5,lastuserid,lastmaintdate,
         edition1,edition2,edition3,edition4,edition5)

	VALUES (@ware_bookkey,@ware_authordisplayname1,@ware_origpubhouse1,@ware_isbn1,
		@ware_title1,@ware_media1,@ware_format1,@ware_mediashort1,@ware_formatshort1,@ware_price1,
		@ware_pubdate1,@ware_publishedinhouseyesno1,@ware_salesunitgross1,@ware_salesunitnet1,
		@ware_authordisplayname2,@ware_origpubhouse2,@ware_isbn2,
		@ware_title2,@ware_media2,@ware_format2,@ware_mediashort2,@ware_formatshort2,@ware_price2,
		@ware_pubdate2,@ware_publishedinhouseyesno2,@ware_salesunitgross2,@ware_salesunitnet2,
		@ware_authordisplayname3,@ware_origpubhouse3,@ware_isbn3,
		@ware_title3,@ware_media3,@ware_format3,@ware_mediashort3,@ware_formatshort3,@ware_price3,
		@ware_pubdate3,@ware_publishedinhouseyesno3,@ware_salesunitgross3,@ware_salesunitnet3,
		@ware_authordisplayname4,@ware_origpubhouse4,@ware_isbn4,
		@ware_title4,@ware_media4,@ware_format4,@ware_mediashort4,@ware_formatshort4,@ware_price4,
		@ware_pubdate4,@ware_publishedinhouseyesno4,@ware_salesunitgross4,@ware_salesunitnet4,
		@ware_authordisplayname5,@ware_origpubhouse5,@ware_isbn5,
		@ware_title5,@ware_media5,@ware_format5,@ware_mediashort5,@ware_formatshort5,@ware_price5,
		@ware_pubdate5,@ware_publishedinhouseyesno5,@ware_salesunitgross5,@ware_salesunitnet5,'WARE_STORED_PROC',@ware_system_date,
          @ware_edition1,@ware_edition2,@ware_edition3,@ware_edition4,@ware_edition5)
  end
 else if @ware_associationtypecode = 1 
  begin
	INSERT into whcompetitivetitles
		(bookkey, authordisplayname1,origpubhouse1 ,isbn1,
		title1,media1,format1,mediashort1, formatshort1, price1,pubdate1,
		publishedinhouseyesno1,salesunitgross1,salesunitnet1,
		authordisplayname2,origpubhouse2 ,isbn2,
		title2,media2,format2,mediashort2, formatshort2, price2,pubdate2,
		publishedinhouseyesno2,salesunitgross2,salesunitnet2,
		authordisplayname3,origpubhouse3 ,isbn3,
		title3,media3,format3,mediashort3, formatshort3, price3,pubdate3,
		publishedinhouseyesno3,salesunitgross3,salesunitnet3,
		authordisplayname4,origpubhouse4 ,isbn4,
		title4,media4,format4,mediashort4, formatshort4, price4,pubdate4,
		publishedinhouseyesno4,salesunitgross4,salesunitnet4,
		authordisplayname5,origpubhouse5 ,isbn5,
		title5,media5,format5,mediashort5, formatshort5, price5,pubdate5,
		publishedinhouseyesno5,salesunitgross5,salesunitnet5,lastuserid,lastmaintdate,
         edition1,edition2,edition3,edition4,edition5)

	VALUES (@ware_bookkey,@ware_authordisplayname1,@ware_origpubhouse1,@ware_isbn1,
		@ware_title1,@ware_media1,@ware_format1,@ware_mediashort1,@ware_formatshort1,@ware_price1,
		@ware_pubdate1,@ware_publishedinhouseyesno1,@ware_salesunitgross1,@ware_salesunitnet1,
		@ware_authordisplayname2,@ware_origpubhouse2,@ware_isbn2,
		@ware_title2,@ware_media2,@ware_format2,@ware_mediashort2,@ware_formatshort2,@ware_price2,
		@ware_pubdate2,@ware_publishedinhouseyesno2,@ware_salesunitgross2,@ware_salesunitnet2,
		@ware_authordisplayname3,@ware_origpubhouse3,@ware_isbn3,
		@ware_title3,@ware_media3,@ware_format3,@ware_mediashort3,@ware_formatshort3,@ware_price3,
		@ware_pubdate3,@ware_publishedinhouseyesno3,@ware_salesunitgross3,@ware_salesunitnet3,
		@ware_authordisplayname4,@ware_origpubhouse4,@ware_isbn4,
		@ware_title4,@ware_media4,@ware_format4,@ware_mediashort4,@ware_formatshort4,@ware_price4,
		@ware_pubdate4,@ware_publishedinhouseyesno4,@ware_salesunitgross4,@ware_salesunitnet4,
		@ware_authordisplayname5,@ware_origpubhouse5,@ware_isbn5,
		@ware_title5,@ware_media5,@ware_format5,@ware_mediashort5,@ware_formatshort5,@ware_price5,
		@ware_pubdate5,@ware_publishedinhouseyesno5,@ware_salesunitgross5,@ware_salesunitnet5,'WARE_STORED_PROC',@ware_system_date,
          @ware_edition1,@ware_edition2,@ware_edition3,@ware_edition4,@ware_edition5)
  end	
else if   @ware_associationtypecode =  2 
  begin
	INSERT into whcomparativetitles
		(bookkey, authordisplayname1,origpubhouse1 ,isbn1,
		title1,media1,format1,mediashort1, formatshort1, price1,pubdate1,
		publishedinhouseyesno1,salesunitgross1,salesunitnet1,
		authordisplayname2,origpubhouse2 ,isbn2,
		title2,media2,format2,mediashort2, formatshort2, price2,pubdate2,
		publishedinhouseyesno2,salesunitgross2,salesunitnet2,
		authordisplayname3,origpubhouse3 ,isbn3,
		title3,media3,format3,mediashort3, formatshort3, price3,pubdate3,
		publishedinhouseyesno3,salesunitgross3,salesunitnet3,
		authordisplayname4,origpubhouse4 ,isbn4,
		title4,media4,format4,mediashort4, formatshort4, price4,pubdate4,
		publishedinhouseyesno4,salesunitgross4,salesunitnet4,
		authordisplayname5,origpubhouse5 ,isbn5,
		title5,media5,format5,mediashort5, formatshort5, price5,pubdate5,
		publishedinhouseyesno5,salesunitgross5,salesunitnet5,lastuserid,lastmaintdate,
         edition1,edition2,edition3,edition4,edition5)

	VALUES (@ware_bookkey,@ware_authordisplayname1,@ware_origpubhouse1,@ware_isbn1,
		@ware_title1,@ware_media1,@ware_format1,@ware_mediashort1,@ware_formatshort1,@ware_price1,
		@ware_pubdate1,@ware_publishedinhouseyesno1,@ware_salesunitgross1,@ware_salesunitnet1,
		@ware_authordisplayname2,@ware_origpubhouse2,@ware_isbn2,
		@ware_title2,@ware_media2,@ware_format2,@ware_mediashort2,@ware_formatshort2,@ware_price2,
		@ware_pubdate2,@ware_publishedinhouseyesno2,@ware_salesunitgross2,@ware_salesunitnet2,
		@ware_authordisplayname3,@ware_origpubhouse3,@ware_isbn3,
		@ware_title3,@ware_media3,@ware_format3,@ware_mediashort3,@ware_formatshort3,@ware_price3,
		@ware_pubdate3,@ware_publishedinhouseyesno3,@ware_salesunitgross3,@ware_salesunitnet3,
		@ware_authordisplayname4,@ware_origpubhouse4,@ware_isbn4,
		@ware_title4,@ware_media4,@ware_format4,@ware_mediashort4,@ware_formatshort4,@ware_price4,
		@ware_pubdate4,@ware_publishedinhouseyesno4,@ware_salesunitgross4,@ware_salesunitnet4,
		@ware_authordisplayname5,@ware_origpubhouse5,@ware_isbn5,
		@ware_title5,@ware_media5,@ware_format5,@ware_mediashort5,@ware_formatshort5,@ware_price5,
		@ware_pubdate5,@ware_publishedinhouseyesno5,@ware_salesunitgross5,@ware_salesunitnet5,'WARE_STORED_PROC',@ware_system_date,
          @ware_edition1,@ware_edition2,@ware_edition3,@ware_edition4,@ware_edition5)
  END
commit tran
	/**
if SQL%ROWCOUNT > 0 then 
	commit
else
	if @ware_associationtypecode = 3 THEN
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc, 
				 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
			'Unable to insert whauthorsalestrack table - for associatedtitles',
			('Warning/data error bookkey '+  to_char(@ware_bookkey)),
			'Stored procedure datawarehouse_titlepositioning','WARE_STORED_PROC', @ware_system_date) 
		commit
	elsif @ware_associationtypecode = 1 THEN
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc, 
				 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
			'Unable to insert whcompetitivetables table - for associatedtitles',
			('Warning/data error bookkey '+  to_char(@ware_bookkey)),
			'Stored procedure datawarehouse_titlepositioning','WARE_STORED_PROC', @ware_system_date) 
		commit
	elsif @ware_associationtypecode = 2 THEN
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc, 
				 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
			'Unable to insert whcomparativetables table - for associatedtitles',
			('Warning/data error bookkey '+  to_char(@ware_bookkey)),
			'Stored procedure datawarehouse_titlepositioning','WARE_STORED_PROC', @ware_system_date) 
		commit
	end if
end if
**/

close whassociatedtitles
deallocate whassociatedtitles



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



