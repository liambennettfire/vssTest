if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_in_title_info') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.feed_in_title_info
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
create proc dbo.feed_in_title_info 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

4-22-04 Feedin from CISPUB.. 
**/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @i_isbn int

DECLARE @feedin_count int
DECLARE @feedin_bookkey  int
DECLARE @feed_shorttitle  varchar(100)
DECLARE @feed_titletypecode int
DECLARE @feed_discountcode varchar (40)
DECLARE @feed_territorycode int
DECLARE @feed_editioncode int
DECLARE @feed_formatcode1 int
DECLARE @feed_formatcode2 int
DECLARE @feed_seriescode int
DECLARE @feed_bisacstatuscode int
DECLARE @feed_trimsizelength varchar (20)
DECLARE @feed_trimsizewidth varchar (20)
DECLARE @feed_esttrimsizewidth varchar (20)
DECLARE @feed_esttrimsizelength varchar (20)
DECLARE @feed_tentativepagecount int
DECLARE @feed_pagecount int
DECLARE @feed_pricecode	int
DECLARE @feed_currencycode int
DECLARE @feed_pricebudget float
DECLARE @feed_pricefinal float

DECLARE @feedin_isbn varchar (10)  
DECLARE @feedin_format varchar (40)  
DECLARE @feedin_imprint varchar (40)  
DECLARE @feedin_type varchar (40)  
DECLARE @feedin_discount varchar (40)  
DECLARE @feedin_territories varchar (40)  
DECLARE @feedin_otheredit varchar (40)  
DECLARE @feedin_othereditisbn varchar (10)  
DECLARE @feedin_oto varchar (40)  
DECLARE @feedin_pubseries varchar (120)  
DECLARE @feedin_volume varchar (15)  
DECLARE @feedin_pmdesc1 varchar (40)  
DECLARE @feedin_pmdesc2 varchar (40)  
DECLARE @feedin_pmdesc3 varchar (40) 
DECLARE @feedin_pmdesc4 varchar (40) 
DECLARE @feedin_pagecount int 
DECLARE @feedin_pricecirca varchar (10)  
DECLARE @feedin_acqeditor varchar (120)  
DECLARE @feedin_bookseason varchar (40)  
DECLARE @feedin_bookedition varchar (40)  
DECLARE @feedin_trimsize varchar (40) 
DECLARE @feedin_newprice decimal (10,2)
DECLARE @feedin_effectivedate datetime  
DECLARE @feedin_priceclass	varchar (10)  
DECLARE @feedin_nyprelease	datetime  
DECLARE @feedin_kitcode	varchar (10)  
DECLARE @feedin_compcopy	varchar (40)  
DECLARE @feedin_commission	varchar (10)  
DECLARE @feedin_freightclass	varchar (10)  
DECLARE @feedin_proofofdeliv	varchar (10)  
DECLARE @feedin_shippingwhse	varchar (10)  
DECLARE @feedin_returnable 	varchar (10)  
DECLARE @feedin_timesprinted	varchar (10)  
DECLARE @feedin_abcclass	varchar (10)  
DECLARE @feedin_unitofissue	varchar (10)  
DECLARE @feedin_weight		varchar (10)  
DECLARE @feedin_priceonbook	varchar (10)  
DECLARE @feedin_writedowncode	varchar (40)  
DECLARE @feedin_bisacstatus	varchar (40)  
DECLARE @feedin_stockduedate	datetime 
DECLARE @feedin_freezeflag	varchar (10) 
DECLARE @feedin_qoh	int 
DECLARE @feedin_origqty1 int
DECLARE @feedin_origqty2 varchar (10) 
DECLARE @feedin_circafinal	varchar (10)  
DECLARE @feedin_short_title varchar (120)

DECLARE @feed_isbn  varchar (13)
DECLARE @feedin_convchar varchar(100)
DECLARE @feed_compare_code int
DECLARE @feed_compare_char varchar (120)
DECLARE @feed_error int
DECLARE @feed_update int
DECLARE @c_message  varchar(255)
DECLARE @i_freezeflag tinyint

select @statusmessage = 'BEGIN TMM FEED IN Title AT ' + convert (char,getdate())
print @statusmessage

begin tran

select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Inserts',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values('3',@feed_system_date,'Feed Summary: Updates',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Rejected',0)


DECLARE feedin_titles INSENSITIVE CURSOR
FOR

  select rtrim(f.isbn), rtrim(pmdiv),rtrim(imqtyonhand),priceunit,rtrim(pmdiscclass),
	rtrim(pmpubstatus),pmorlastmfgqty,pmorlastmfgdate,rtrim(pmfrzflg)
		from feedin_titles f, isbn i
			where f.isbn = i.isbn10
				order by f.isbn	  
FOR READ ONLY
		
OPEN feedin_titles 

FETCH NEXT FROM feedin_titles 
/******orginal in clause	
	INTO @feedin_isbn
		,@feedin_format,@feedin_imprint,@feedin_type,@feedin_discount, 
		@feedin_territories,@feedin_otheredit,@feedin_othereditisbn,@feedin_oto,
		@feedin_pubseries,@feedin_volume,@feedin_pmdesc1,@feedin_pmdesc2,@feedin_pmdesc3,
		@feedin_pmdesc4,@feedin_pagecount,@feedin_pricecirca,@feedin_acqeditor,@feedin_bookseason,
		@feedin_bookedition,@feedin_trimsize,@feedin_newprice,@feedin_effectivedate,@feedin_priceclass,
		@feedin_nyprelease,@feedin_kitcode,@feedin_compcopy,@feedin_commission,@feedin_freightclass,
		@feedin_proofofdeliv,@feedin_shippingwhse,@feedin_returnable,@feedin_timesprinted,
		@feedin_abcclass,@feedin_unitofissue,@feedin_weight,@feedin_priceonbook,@feedin_writedowncode
	  ,@feedin_bisacstatus,@feedin_stockduedate,@feedin_freezeflag
		,@feedin_qoh
	  ,@feedin_origqty1
		,@feedin_origqty2,@feedin_circafinal
	  ,@feedin_short_title
******/
	INTO @feedin_isbn,@feedin_format,@feedin_qoh,@feedin_newprice,@feedin_discount, 
		@feedin_bisacstatus,@feedin_origqty1,@feedin_stockduedate,@feedin_freezeflag
	 
select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',@feed_system_date,'NO ROWS to PROCESS - Titles')
end

while (@i_isbn<>-1 )  /* status 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

	/** Increment Title Count, Print Status every 500 rows **/
	select @titlecount=@titlecount + 1
	select @titlecountremainder=0
	select @titlecountremainder = @titlecount % 500
	if(@titlecountremainder = 0)
	begin
		select @titlestatusmessage =  convert (varchar (50),getdate()) + '   ' + convert (varchar (10),@titlecount) + '   Rows Processed'
		print @titlestatusmessage
	end 	

	select @feedin_bookkey  = 0
	select @feed_shorttitle = ''
	select @feed_titletypecode = 0
	select @feed_discountcode = 0
	select @feed_territorycode = 0
	select @feed_editioncode = 0
	select @feed_formatcode1 = 0
	select @feed_formatcode2 = 0
	select @feed_seriescode = 0
	select @feed_bisacstatuscode = 0
	select @feed_trimsizelength = ''
	select @feed_trimsizewidth = ''
	select @feed_esttrimsizewidth = ''
	select @feed_esttrimsizelength = ''
	select @feed_tentativepagecount = 0
	select @feed_pagecount = 0
	select @feed_pricebudget = 0
	select @feed_pricefinal = 0
	select @feed_isbn  = ''
	select @feedin_convchar = ''
	select @feed_error = 0
	select @feed_update = 0

	select @feed_isbn = RTRIM(@feedin_isbn) 

  	if @feedin_bisacstatus is null
	  begin
		select @feedin_bisacstatus = ''
	  end

	if @feedin_stockduedate is null
	  begin
		select @feedin_stockduedate = ''
	  end

	if @feedin_freezeflag is null
	  begin
		select @feedin_freezeflag = ''	
	  end
	
	if @feedin_origqty1 is null
	  begin
		select @feedin_origqty1 = 0
	  end

	if @feedin_short_title is null
	  begin
		select @feedin_short_title = ''
	  end
	
	if @feedin_discount is null
	  begin
		select @feedin_discount = ''
	  end
	if @feedin_newprice is null
	  begin
		select @feedin_newprice = 0
	  end

	if len(@feed_isbn) = 0 
	 begin
		select @feed_isbn = 'NO ISBN'

		insert into feederror 							
			(isbn,batchnumber,processdate,errordesc)
		values (RTRIM(@feedin_isbn),'3',@feed_system_date,('NO ISBN ENTERED ' + @feedin_isbn))
			
		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='3'
					  and processdate > = @feed_system_date
					 and errordesc LIKE 'Feed Summary: Rejected%'
	 end	

/* remove reissue isbn book keys*/
	select @feedin_bookkey = count(*)  
			from isbn i, book b
				where i.bookkey= b.bookkey
					and (b.reuseisbnind is null or reuseisbnind = 0) 
						and isbn10= RTRIM(@feedin_isbn)

	if @feedin_bookkey > 0  
	 begin
		select @feedin_bookkey = b.bookkey, @feed_isbn= i.isbn 
			from isbn i, book b
				where i.bookkey= b.bookkey
					and (b.reuseisbnind is null or reuseisbnind = 0) 
						and isbn10= RTRIM(@feedin_isbn)
	  end

	if len(@feed_isbn) = 13 
	  begin

/*------------- intialize data and update---------*/

/*bisacstatus*/
	select @feedin_count = 0
	select @feedin_count = count(*)
		from gentables
		where UPPER(externalcode)= @feedin_bisacstatus
			and tableid=314 

		if @feedin_count > 0 
		begin
			select @feed_bisacstatuscode = datacode
				from gentables
				where UPPER(externalcode)= @feedin_bisacstatus
					and tableid=314 

		 end
/*Freeze Flag*/

	if @feedin_freezeflag = 'Y'
	  begin
		select @i_freezeflag = 1
	  end
	else
	  begin
		select @i_freezeflag = 0
	  end


	select @feedin_count = 0
	select @feedin_count = customcode09 from bookcustom where bookkey = @feedin_bookkey
	if @feedin_count is null
	  begin
		select @feedin_count = 0
	  end

	if @feedin_count > 0 

/*qoh customint01, freezeflag customind02*/
	  begin
		update bookcustom
		set customint01 = @feedin_qoh, customind02 = @i_freezeflag,
			lastuserid='FEEDIN_UOC',
			lastmaintdate = @feed_system_date
				where bookkey = @feedin_bookkey
			
		select @feed_update = 1
	  end

/*update bookcustom to feeding/received*/
		if @feedin_origqty1 > 0 and datalength(@feedin_stockduedate) >0  and @feedin_freezeflag = 'N' and @feed_bisacstatuscode = 1 /*available*/
		  begin

			select @feedin_count = 0
			select @feedin_count = customcode09 from bookcustom where bookkey = @feedin_bookkey
			if @feedin_count is null
			  begin
				select @feedin_count = 0
			  end
			if @feedin_count = 3 /*feeding/not received*/
			  begin

				update bookcustom
				  set customcode09 = 4  /*feeding/received*/
					where bookkey = @feedin_bookkey	

				EXEC dbo.titlehistory_insert 4,@feedin_bookkey,0,'',@feed_bisacstatuscode,1

				update bookdetail
					set bisacstatuscode = @feed_bisacstatuscode,
						lastuserid='FEEDIN_UOC',
						lastmaintdate = @feed_system_date
						where bookkey = @feedin_bookkey
			
				select @feed_update = 1
/* actual quantity*/
			  if @feedin_origqty1 > 0
			    begin
				select @feedin_count = 0
			
				select @feedin_count = firstprintingqty
					FROM printing
					 WHERE bookkey = @feedin_bookkey
						AND  printingkey = 1 

				if @feedin_count is null
				  begin
					select @feedin_count = 0
				  end

				if @feedin_count = 0 /*actual value not filled in so update*/
				  begin
					EXEC dbo.titlehistory_insert 18,@feedin_bookkey,1,'',@feedin_origqty1,0

					update printing
					  set firstprintingqty = @feedin_origqty1,
						lastuserid ='FEEDIN_UOC',
						lastmaintdate=@feed_system_date
						 WHERE bookkey = @feedin_bookkey
							AND  printingkey = 1 

					select @feed_update = 1
			  	  end
			 end

/*actual warehouse-stockdue date*/
			if len(@feedin_stockduedate) > 0 
 			 begin

				select @feedin_count = 0
				select @feedin_count = count(*) 
					from bookdates
						where bookkey=@feedin_bookkey
							and printingkey=1
							and datetypecode=47

				select @feedin_convchar = ''
				select @feedin_convchar = convert(char,@feedin_stockduedate)

				if @feedin_count > 0 			
				  begin
					EXEC dbo.titlehistory_insert 36,@feedin_bookkey,1,'47',@feedin_convchar,0
			
					update bookdates
						set activedate = @feedin_stockduedate,  	
							lastuserid ='FEEDIN_UOC',
							lastmaintdate=@feed_system_date
								where bookkey= @feedin_bookkey
									and printingkey=1
									and datetypecode=47

					select @feed_update = 1
				  end
				else
				  begin
					EXEC dbo.titlehistory_insert 36,@feedin_bookkey,1,'47',@feedin_convchar,1

					insert into bookdates (bookkey,printingkey,datetypecode,
						activedate,actualind,sortorder,lastuserid ,lastmaintdate)
					values (@feedin_bookkey,1,47,@feedin_stockduedate,0,1,'FEEDIN_UOC',@feed_system_date)

					select @feed_update = 1
				  end
			end

		end /* 3*/
	end /*end update not received to received*/

/*compare info if difference add feed status = error*/

/*price, discount*/
	select @feed_compare_code = 0
	select @feedin_count = 0
	if datalength(@feedin_discount) >0 
	  begin
	
/** PER CHRIS use function ucp_get_langley_discount(bookkey) to get discount 
		select @feedin_count = count(*)
			from gentables
				where UPPER(externalcode)= @feedin_discount
				and tableid=459

			if @feedin_count > 0 
			begin
				select @feed_discountcode = datacode
					from gentables
					where UPPER(externalcode)= @feedin_discount
						and tableid=459 
			 end

	select @feed_compare_code = discountcode from bookdetail where bookkey= @feedin_bookkey

**/	

	select @feed_discountcode = dbo.ucp_get_langley_discount(@feedin_bookkey)

	
	if @feed_discountcode is null
	  begin
		select @feed_discountcode = ''
	  end

	if @feedin_discount <> @feed_discountcode
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',getdate(),'discount on TMM not the same as feed in value; feed discount ' + @feedin_discount)
		
		update bookcustom
			  set customcode10 = 1  /*error*/
				where bookkey = @feedin_bookkey	

		select @feed_error = 1
	 end
 end
if @feedin_newprice > 0	
  begin
	select @feedin_count = 0
	select @feedin_count = count(*) from filterpricetype
			where filterkey = 5 /*currency and price types*/

	if @feedin_count > 0 
	 begin
		select @feed_pricecode= pricetypecode, @feed_currencycode = currencytypecode
		 from filterpricetype
			where filterkey = 5 /*currency and price types*/

		select @feedin_count = 0
		select @feedin_count = max(pricekey) from bookprice
			WHERE  bookkey = @feedin_bookkey
				   and pricetypecode = @feed_pricecode
				   and currencytypecode = @feed_currencycode
				   and convert(decimal(10,2),finalprice) = @feedin_newprice

		if @feedin_count is null 
		  begin
			select @feedin_count = 0
		  end

		if @feedin_count = 0
		  begin	
			select @feedin_count = max(pricekey) from bookprice
		   		WHERE  bookkey = @feedin_bookkey
				  and pricetypecode = @feed_pricecode
				  and currencytypecode = @feed_currencycode
				  and convert(decimal(10,2),budgetprice) = @feedin_newprice
		end
	  end 

	if @feedin_count is null 
	  begin
		select @feedin_count = 0
	  end
	
	if @feedin_count = 0 
	 begin	
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',getdate(),'price on TMM not the same as feed in value; feed Price = ' + convert(varchar,@feedin_newprice))
		
		update bookcustom
			  set customcode10 = 1  /*error*/
				where bookkey = @feedin_bookkey	

		select @feed_error = 1
	 end
end
/******************** not doing title
	select @feed_compare_char = shorttitle from book where bookkey = @feedin_bookkey

	if @feed_compare_char is null
	  begin
		select @feed_compare_char = ''
	  end
	
	if datalength(@feed_compare_char)>0
	  begin
		select @feed_compare_char = upper(shorttitle + ', ' + title) from book where bookkey = @feedin_bookkey
	  end
	else	
	  begin	
		select @feed_compare_char = upper(title) from book where bookkey = @feedin_bookkey
	  end

	if upper(@feedin_short_title) <> upper(@feed_compare_char)
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',getdate(),'title on TMM not the same as feed in value; feed title = ' + @feedin_short_title)
		
		update bookcustom
			  set customcode10 = 1  
				where bookkey = @feedin_bookkey	

		select @feed_error = 1
	  end
********************/

	if  @feed_error = 0 and @feed_update = 1
	  begin
		update bookcustom
			  set customcode10 = 2  /*OK*/
				where bookkey = @feedin_bookkey	
	  end

	if @feed_update = 1
	  begin

		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='3'
				  and processdate >= @feed_system_date
					 and errordesc LIKE 'Feed Summary: Updates%'	
	  end
  end  /*isbn =13*/
		
end /*isbn status 2*/

FETCH NEXT FROM feedin_titles 
/*******	INTO @feedin_isbn
		,@feedin_format,@feedin_imprint,@feedin_type,@feedin_discount, 
		@feedin_territories,@feedin_otheredit,@feedin_othereditisbn,@feedin_oto,
		@feedin_pubseries,@feedin_volume,@feedin_pmdesc1,@feedin_pmdesc2,@feedin_pmdesc3,
		@feedin_pmdesc4,@feedin_pagecount,@feedin_pricecirca,@feedin_acqeditor,@feedin_bookseason,
		@feedin_bookedition,@feedin_trimsize,@feedin_newprice,@feedin_effectivedate,@feedin_priceclass,
		@feedin_nyprelease,@feedin_kitcode,@feedin_compcopy,@feedin_commission,@feedin_freightclass,
		@feedin_proofofdeliv,@feedin_shippingwhse,@feedin_returnable,@feedin_timesprinted,
		@feedin_abcclass,@feedin_unitofissue,@feedin_weight,@feedin_priceonbook,@feedin_writedowncode
	  ,@feedin_bisacstatus,@feedin_stockduedate,@feedin_freezeflag
		,@feedin_qoh
	  ,@feedin_origqty1
		,@feedin_origqty2,@feedin_circafinal
	  ,@feedin_short_title

*******/
	INTO @feedin_isbn,@feedin_format,@feedin_qoh,@feedin_newprice,@feedin_discount, 
		@feedin_bisacstatus,@feedin_origqty1,@feedin_stockduedate,@feedin_freezeflag

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/


insert into feederror (batchnumber,processdate,errordesc)
 values ('3',@feed_system_date,'Titles In Completed')
commit tran

close feedin_titles
deallocate feedin_titles

select @statusmessage = 'END TMM FEED IN Titles AT ' + convert (char,getdate())
print @statusmessage

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO