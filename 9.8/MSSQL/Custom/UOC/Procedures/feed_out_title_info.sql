if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_title_info') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.feed_out_title_info
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
create proc dbo.feed_out_title_info 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

4-12-04 Feedout out CISPUB.. make sure only get rows that are ready; this will be set 
in a custom field
**/

/*7-29-04 CRM 1395:  title length now 255 so substring variable title select to 120*/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @i_isbn int

DECLARE @feed_count int
DECLARE @feedout_bookkey  int
DECLARE @feed_shorttitle  varchar(100)
DECLARE @feed_titletypecode int
DECLARE @feed_discountcode int
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
DECLARE @feed_pricebudget decimal(10,2)
DECLARE @feed_pricefinal decimal(10,2)

DECLARE @feedout_isbn varchar (10)  
DECLARE @feedout_format varchar (40)  
DECLARE @feedout_imprint varchar (40)  
DECLARE @feedout_type varchar (40)  
DECLARE @feedout_discount varchar (40)  
DECLARE @feedout_territories varchar (40)  
DECLARE @feedout_otheredit varchar (40)  
DECLARE @feedout_othereditisbn varchar (10)  
DECLARE @feedout_oto varchar (40)  
DECLARE @feedout_pubseries varchar (120)  
DECLARE @feedout_volume varchar (15)  
DECLARE @feedout_pmdesc1 varchar (40)  
DECLARE @feedout_pmdesc2 varchar (40)  
DECLARE @feedout_pmdesc3 varchar (40) 
DECLARE @feedout_pmdesc4 varchar (40) 
DECLARE @feedout_pagecount int 
DECLARE @feedout_pricecirca varchar (10)  
DECLARE @feedout_acqeditor varchar (120)  
DECLARE @feedout_bookseason varchar (40)  
DECLARE @feedout_bookedition varchar (40)  
DECLARE @feedout_trimsize varchar (40) 
DECLARE @feedout_newprice decimal(10,2)
DECLARE @feedout_effectivedate datetime  
DECLARE @feedout_priceclass	varchar (10)  
DECLARE @feedout_nyprelease	datetime  
DECLARE @feedout_kitcode	varchar (10)  
DECLARE @feedout_compcopy	varchar (40)  
DECLARE @feedout_commission	varchar (10)  
DECLARE @feedout_freightclass	varchar (10)  
DECLARE @feedout_proofofdeliv	varchar (10)  
DECLARE @feedout_shippingwhse	varchar (10)  
DECLARE @feedout_returnable 	varchar (10)  
DECLARE @feedout_timesprinted	varchar (10)  
DECLARE @feedout_abcclass	varchar (10)  
DECLARE @feedout_unitofissue	varchar (10)  
DECLARE @feedout_weight		varchar (10)  
DECLARE @feedout_priceonbook	varchar (10)  
DECLARE @feedout_writedowncode	varchar (40)  
DECLARE @feedout_bisacstatus	varchar (40)  
DECLARE @feedout_stockduedate	datetime 
DECLARE @feedout_freezeflag	varchar (10) 
DECLARE @feedout_qoh	int 
DECLARE @feedout_origqty1 int
DECLARE @feedout_origqty2 varchar (10) 
DECLARE @feedout_circafinal	varchar (10)  
DECLARE @feedout_short_title varchar (120)
DECLARE @feed_parentkey   int
DECLARE @feed_childkey  int

DECLARE @c_message  varchar(255)

/*7-19-04 CRM 1578 change title/shorttitle separator from comma to pipe */

select @statusmessage = 'BEGIN TMM FEED OUT Title AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

delete from feedout_titles

DECLARE feedout_titles INSENSITIVE CURSOR
FOR

select bookkey
	from bookcustom 
		where customcode09 = 2 /*ready to transmit*/
	
FOR READ ONLY
		
OPEN feedout_titles 

FETCH NEXT FROM feedout_titles 
	INTO @feedout_bookkey
 
select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedout_isbn,'1',@feed_system_date,'NO ROWS to PROCESS - Titles')
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
/*set defaults here*/	

	select @feedout_isbn = ''
	select @feedout_format = '' 
	select @feedout_imprint = '' 
	select @feedout_type = ''
	select @feedout_discount = ''
	select @feedout_territories = '' 
	select @feedout_otheredit = ''
	select @feedout_othereditisbn = '' 
	select @feedout_oto = ''
	select @feedout_pubseries = '' 
	select @feedout_volume = '' 
	select @feedout_pmdesc1 = '' 
	select @feedout_pmdesc2 = '' 
	select @feedout_pmdesc3 = ''     
	select @feedout_pmdesc4 = '' 
   	select @feedout_pagecount = 0 
        select @feedout_pricecirca = 'C'  
        select @feedout_acqeditor = '' 
        select @feedout_bookseason = '' 
        select @feedout_bookedition = '' 
        select @feedout_trimsize = ''
        select @feedout_newprice = 0
        select @feedout_effectivedate = convert(char,getdate(),101)  /*what format they want*/  
        select @feedout_priceclass = '1' 
        select @feedout_nyprelease = convert(char,getdate(),101) /*what format they want*/    
        select @feedout_kitcode	= '03'
        select @feedout_compcopy = '' 
        select @feedout_commission = 'Y'  
        select @feedout_freightclass = '1' 
        select @feedout_proofofdeliv = 'N'  
        select @feedout_shippingwhse = '1'  
        select @feedout_returnable = 'Y'
        select @feedout_timesprinted = '1'  
        select @feedout_abcclass = 'A' 
        select @feedout_unitofissue = '1' 
        select @feedout_weight = '1'  
        select @feedout_priceonbook = 'N'
        select @feedout_writedowncode	= ''
        select @feedout_bisacstatus	= '' 
        select @feedout_stockduedate = '' 
        select @feedout_freezeflag = 'Y'  
        select @feedout_qoh = 0 
        select @feedout_origqty1 = 0 
        select @feedout_origqty2 = 'C' 
        select @feedout_circafinal = ''  
        select @feedout_short_title = ''

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

/*imprint*/
	select @feedout_imprint = orgentrydesc
	from bookorgentry b, orgentry o
	where b.orgentrykey = o.orgentrykey and b.bookkey = @feedout_bookkey
		and b.orglevelkey = 2  /*need imprint level right now only 2 levels, publisher
					and division*/


/*isbn, title, shorttitle, titletype, territory */

	select @feedout_isbn = isbn10, @feed_shorttitle = shorttitle,
		@feedout_short_title = substring(rtrim(title),1,120), @feedout_pmdesc2 = subtitle,
		@feed_titletypecode = titletypecode,
		@feed_territorycode = territoriescode
	from isbn i,book b
	where i.bookkey = b.bookkey and b.bookkey = @feedout_bookkey
		
/*PM descs */	
	select @feedout_pmdesc1 = @feedout_short_title
	
	if upper(@feedout_imprint) <> 'PRESS'
	  begin
		select @feedout_pmdesc4 = @feedout_imprint
	  end
	
	if @feed_shorttitle is null
	  begin
		select @feed_shorttitle = ''
	  end

/*CRM 1578 change title/shorttitle separator from comma to pipe */
	if datalength(@feed_shorttitle) > 0
	  begin
		/*select @feedout_short_title = @feed_shorttitle + ', ' + @feedout_short_title*/
		select @feedout_short_title = @feed_shorttitle + '| ' + @feedout_short_title
	  end

	if @feed_titletypecode > 0
	  begin
		select  @feedout_type = externalcode
			from gentables where tableid=132
			   and datacode=  @feed_titletypecode
	  end 

	if @feed_territorycode > 0
	  begin
		select  @feedout_territories = externalcode
			from gentables where tableid= 131
			   and datacode=  @feed_territorycode
	  end 
	
	
/*discount, edition, format, series, volume, bisacstatus */

	select @feed_discountcode = discountcode, @feed_editioncode = editioncode,
		@feed_formatcode1 = mediatypecode,@feed_formatcode2 = mediatypesubcode,
		@feed_seriescode = seriescode,@feedout_volume = volumenumber,
		@feed_bisacstatuscode = bisacstatuscode
			from bookdetail 
			where bookkey = @feedout_bookkey

--Modified 2004.05.02 cgates Changed discount code to reference user defined function
	select  @feedout_discount = dbo.ucp_get_langley_discount(@feedout_bookkey)
-- Previous code block begins
--	if @feed_discountcode > 0
--	  begin
--		select  @feedout_discount = externalcode
--			from gentables where tableid= 459
--			   and datacode=  @feed_discountcode
--	  end 
-- Previous code block ends
	if @feed_editioncode > 0
	  begin
		select  @feedout_bookedition = externalcode
			from gentables where tableid= 200
			   and datacode=  @feed_editioncode
	  end 	

	if @feed_seriescode > 0
	  begin
		select  @feedout_pubseries = externalcode
			from gentables where tableid= 327
			   and datacode=  @feed_seriescode

		select @feedout_pmdesc3= @feedout_pubseries
	  end 	
	
	if @feed_bisacstatuscode > 0
	  begin
		select @feedout_bisacstatus  = externalcode
			from gentables
			where datacode = @feed_bisacstatuscode
			and tableid=314 
	  end
		
	if @feed_formatcode1 > 0 and @feed_formatcode2 >0
	  begin
		select @feedout_format  = externalcode
			from subgentables
			where datacode = @feed_formatcode1 and datasubcode = @feed_formatcode2
			and tableid=312 
	  end

	select @feed_count = 0

	select @feed_count = optionvalue from clientoptions
		where optionid = 4  /*9-9-03 clientoptions pagecount*/
	if @feed_count = 1
	  begin
		select @feed_pagecount = tmmpagecount 
		FROM printing
		 WHERE bookkey = @feedout_bookkey
			AND  printingkey = 1 
	  end
	else
	  begin	
		select @feed_pagecount = pagecount 
		FROM printing
		 WHERE bookkey = @feedout_bookkey
		AND  printingkey = 1 
	end

	select @feed_count = 0

	select @feed_count = optionvalue from clientoptions
		where optionid = 7  /*9-9-03 clientoptions trim*/
	if @feed_count = 1
	  begin
		select @feed_trimsizelength = tmmactualtrimlength,@feed_trimsizewidth =tmmactualtrimwidth
		FROM printing
		 WHERE bookkey = @feedout_bookkey
			AND  printingkey = 1 
	  end
	else
	  begin	
		select @feed_trimsizelength = trimsizelength,@feed_trimsizewidth = trimsizewidth
		FROM printing
		 WHERE bookkey = @feedout_bookkey
		AND  printingkey = 1 
	end

/* pagecount,trimsize, est quantity*/	
	select @feed_tentativepagecount = tentativepagecount,@feedout_origqty1 =tentativeqty,
		@feed_esttrimsizewidth = esttrimsizewidth,@feed_esttrimsizelength =esttrimsizelength		
		FROM printing
		 WHERE bookkey = @feedout_bookkey
			AND  printingkey = 1 


	if datalength(rtrim(@feed_trimsizewidth)) > 0 and datalength(rtrim(@feed_trimsizelength)) > 0 
	  begin
		select @feedout_trimsize = @feed_trimsizewidth + ' x ' + @feed_trimsizelength
	  end
	else
	  begin
		select @feedout_trimsize = @feed_esttrimsizewidth + ' x ' + @feed_esttrimsizelength
	  end
		
	if rtrim(ltrim(@feedout_trimsize)) = 'x' 
  	  begin
		select @feedout_trimsize = ''
	  end

	if @feed_pagecount > 0
	  begin
		select @feedout_pagecount =  @feed_pagecount
	  end
	else
	  begin
		select @feedout_pagecount = @feed_tentativepagecount
	  end
	
/* prices*/
		select @feed_count = 0
		select @feed_count = count(*) from filterpricetype
			where filterkey = 5 /*currency and price types*/

		if @feed_count > 0 
		  begin
			select @feed_pricecode= pricetypecode, @feed_currencycode = currencytypecode
				 from filterpricetype
					where filterkey = 5 /*currency and price types*/
		  end

		select @feed_count = 0
		select @feed_count = max(pricekey) from bookprice
		   	WHERE  bookkey = @feedout_bookkey
				   and pricetypecode = @feed_pricecode
				    and currencytypecode = @feed_currencycode
		if @feed_count > 0
		  begin
			
			SELECT @feed_pricebudget = budgetprice,@feed_pricefinal = finalprice
		 	   FROM bookprice
		  	 	WHERE  bookkey = @feedout_bookkey
				   and pricetypecode = @feed_pricecode
				    and currencytypecode = @feed_currencycode

			if @feed_pricefinal > 0 
			  begin
				select @feedout_newprice = @feed_pricefinal
			  end
			else
			  begin
				select @feedout_newprice = @feed_pricebudget
			  end
		end

/*season*/
		select @feed_count = 0
		select @feed_count  = seasonkey 
		from printing 
		where bookkey=@feedout_bookkey and printingkey = 1

		if @feed_count  > 0
		  begin
			select @feedout_bookseason = seasonshortdesc from season
			where seasonkey = @feed_count
		  end
		else
		  begin
			select @feed_count = 0
			select @feed_count  = estseasonkey 
			   from printing 
				where bookkey=@feedout_bookkey and printingkey = 1

			if @feed_count  > 0
			  begin
				select @feedout_bookseason = seasonshortdesc from season
				where seasonkey = @feed_count
			  end
		 end
		if rtrim(@feedout_bisacstatus) = '5'	
		  begin
			select @feedout_bookseason = 'N'
		  end


/*acq editor roletypecode=22 */
		select @feed_count = 0
		select @feed_count  = contributorkey
			from  bookcontributor
				where bookkey=@feedout_bookkey and printingkey = 1
				  and roletypecode = 22

		if @feed_count  > 0
		begin
			select @feedout_acqeditor = displayname from person
			where contributorkey = @feed_count
		end
/*stock due date -- warehouse date*/

		select @feedout_stockduedate = bestdate
			from bookdates where bookkey= @feedout_bookkey
				and printingkey=1 and datetypecode=47

/*		if @feedout_stockduedate is  null
		  begin
			select @feedout_stockduedate = ''
		  end
	
		if datalength(@feedout_stockduedate)>0		
		  begin
			select @feedout_stockduedate = convert(varchar,@feedout_stockduedate,101) 
		  end
		else
		  begin
			select @feedout_stockduedate = null
		end
*/
/*oto-- customind01, qoh-- customint01*/
	select @feed_count = 0
	select @feed_count= customind01,@feedout_qoh= customint01 from bookcustom
		where bookkey = @feedout_bookkey
	
	if @feed_count = 1 
	  begin
		select @feedout_oto = 'Yes'
	  end	
	else
	  begin
		select @feedout_oto = 'No'
	  end	
/* other edition, y or n and other edition isbn  not sure how to determine delayed?? pubdate maybe then
	how do i figure out which goes where*/

 	if @feed_formatcode1 = 2 and @feed_formatcode2 = 6 /*cloth*/
	  begin
		select @feed_count = linklevelcode
		   from book where bookkey = @feedout_bookkey
		
		if @feed_count = 10  /*parent see if any children that is paper*/
		  begin
			select @feedout_othereditisbn = isbn10 from isbn i, book b, bookdetail be
				where i.bookkey=b.bookkey and i.bookkey =be.bookkey
					and workkey = @feedout_bookkey and b.bookkey <> @feedout_bookkey
					and be.mediatypecode = 2 and mediatypecode = 20  /*paper*/
					and datalength(isbn10) > 0
		  end
		else if @feed_count = 20
		   begin  /* i am the child get parent paper*/
			select @feedout_othereditisbn = isbn10 from isbn i, book b, bookdetail be
				where i.bookkey=b.workkey and i.bookkey =be.bookkey
					and b.bookkey= @feedout_bookkey and  b.workkey <> @feedout_bookkey
					and be.mediatypecode = 2 and mediatypecode = 20  /*paper*/
					and datalength(isbn10) > 0
		   end
	  end
		
	if @feed_formatcode1 = 2 and @feed_formatcode2 = 20 /*paper*/
	  begin
		select @feed_count = linklevelcode
		   from book where bookkey = @feedout_bookkey
		
		if @feed_count = 10  /*parent see if any children that is cloth*/
		  begin
			select @feedout_othereditisbn = isbn10 from isbn i, book b, bookdetail be
				where i.bookkey=b.bookkey and i.bookkey =be.bookkey
					and workkey = @feedout_bookkey and b.bookkey <> @feedout_bookkey
					and be.mediatypecode = 2 and mediatypecode = 6  /*cloth*/
					and datalength(isbn10) > 0
		  end
		else if @feed_count = 20
		   begin  /* i am the child get parent cloth*/
			select @feedout_othereditisbn = isbn10 from isbn i, book b, bookdetail be
				where i.bookkey=b.workkey and i.bookkey =be.bookkey
					and b.bookkey= @feedout_bookkey and  b.workkey <> @feedout_bookkey
					and be.mediatypecode = 2 and mediatypecode = 6  /*cloth*/
					and datalength(isbn10) > 0
		   end
	  end
	
	if datalength(@feedout_othereditisbn) is null
         begin
		select @feedout_othereditisbn = ''
	  end

	if datalength(@feedout_othereditisbn) > 0
	  begin
		select @feedout_otheredit = 'Yes'
	  end
	else
	  begin
		select @feedout_otheredit = 'No'			
	  end


/*insert into temporary table*/

	insert into feedout_titles (isbn,format,imprint,type,discount,territories,otheredit,othereditisbn,oto,pubseries,volume,
		pmdesc1,pmdesc2,pmdesc3,pmdesc4,pagecount,pricecirca,acqeditor,bookseason,bookedition,
		trimsize,newprice,effectivedate,priceclass,nyprelease,kitcode,compcopy,commission,
		freightclass,proofofdeliv,shippingwhse,returnable,timesprinted,abcclass,unitofissue,
		weight,priceonbook,writedowncode,bisacstatus,stockduedate,freezeflag,qoh,origqty1,
		origqty2,circafinal,shorttitle_title)
	values (@feedout_isbn,@feedout_format,@feedout_imprint,@feedout_type,@feedout_discount, 
		@feedout_territories,@feedout_otheredit,@feedout_othereditisbn,@feedout_oto,
		@feedout_pubseries,@feedout_volume,@feedout_pmdesc1,@feedout_pmdesc2,@feedout_pmdesc3,
		@feedout_pmdesc4,@feedout_pagecount,@feedout_pricecirca,@feedout_acqeditor,@feedout_bookseason,
		@feedout_bookedition,@feedout_trimsize,@feedout_newprice,@feedout_effectivedate,@feedout_priceclass,
		@feedout_nyprelease,@feedout_kitcode,@feedout_compcopy,@feedout_commission,@feedout_freightclass,
		@feedout_proofofdeliv,@feedout_shippingwhse,@feedout_returnable,@feedout_timesprinted,
		@feedout_abcclass,@feedout_unitofissue,@feedout_weight,@feedout_priceonbook,@feedout_writedowncode,
		@feedout_bisacstatus,@feedout_stockduedate,@feedout_freezeflag,@feedout_qoh,@feedout_origqty1,
		@feedout_origqty2,@feedout_circafinal,@feedout_short_title)
	
/*update bookcustom to feeding/not received*/
	update bookcustom
	  set customcode09 = 3
		where bookkey = @feedout_bookkey	

end /*isbn status 2*/

FETCH NEXT FROM feedout_titles 
	INTO @feedout_bookkey 

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/

update pofeeddate
set feeddate = tentativefeeddate
where feeddatekey=7

insert into feederror (batchnumber,processdate,errordesc)
 values ('1',@feed_system_date,'Titles Out Completed')

close feedout_titles
deallocate feedout_titles

select @statusmessage = 'END TMM FEED OUT Titles AT ' + convert (char,getdate())
print @statusmessage

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO