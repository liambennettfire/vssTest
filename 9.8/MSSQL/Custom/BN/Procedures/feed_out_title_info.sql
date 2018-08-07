if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_title_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_title_info]
GO

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
DECLARE @i_isbn2 int

DECLARE @feed_titletypecode int
DECLARE	@feed_territorycode  int
DECLARE	@feed_audiencecode  int
DECLARE	@feed_bisacstatuscode  int
DECLARE @feed_origincode int
DECLARE @feed_prefix varchar (100)
DECLARE @feed_salesdivisioncode  int
DECLARE @feed_mediatypecode int
DECLARE @feed_mediatypesubcode int
DECLARE @feed_seriescode int
DECLARE @feed_pagecount int
DECLARE @feed_tentativepagecount int
DECLARE @feed_trimsizewidth varchar (20)
DECLARE @feed_trimsizelength  varchar (20)
DECLARE @feed_esttrimsizewidth  varchar (20)
DECLARE @feed_esttrimsizelength	varchar (20)
DECLARE @feed_pricecode int
DECLARE @feed_currencycode int
DECLARE @feed_pricebudget float
DECLARE @feed_pricefinal float
DECLARE @feed_categorycode int
DECLARE @feed_categorysubcode int 
DECLARE @feed_sortorder int

DECLARE @feed_count int
DECLARE @feedout_bookkey  int
DECLARE @feedout_workkey int
DECLARE @feedout_isbn10 varchar (10)
DECLARE @feedout_titlewithprefix varchar (255)
DECLARE @feedout_subtitle varchar (255)
DECLARE @feedout_shorttitle varchar (50)
DECLARE @feedout_sponsordisplayname varchar (80)
DECLARE @feedout_sponsorphonebookkey varchar (40)
DECLARE @feedout_class varchar (100)
DECLARE @feedout_classdivision varchar (100)
DECLARE @feedout_adultjuvflag varchar (40)
DECLARE @feedout_tradebargainflag varchar (100)
DECLARE @feedout_imprint varchar (100)
DECLARE @feedout_bisacstatus varchar (40)
DECLARE @feedout_origin varchar (40)
DECLARE @feedout_orginphonebookkey varchar (50)
DECLARE @feedout_formatdesc varchar (40)
DECLARE @feedout_usretailprice float
DECLARE @feedout_canadaretailprice float
DECLARE @feedout_pagecount int
DECLARE @feedout_trimsize varchar (120)
DECLARE @feedout_pubdateMMDDYYYY varchar (40)
DECLARE @feedout_warehousedateMMDDYYYY varchar (40)
DECLARE @feedout_sponsornote varchar (2000)
DECLARE @feedout_livenote  varchar (2000)
DECLARE @feedout_territory varchar (40) 
DECLARE @feedout_subject varchar (40)
DECLARE @feedout_subjectcategory  varchar (140) 
DECLARE @feedout_series	varchar (40)
DECLARE @feedout_pubclass  varchar (100) 
DECLARE @feedout_livenote2 varchar(2000)
DECLARE @feedout_merchkey int
DECLARE @feedout_subjectcode varchar (100)
DECLARE @feedout_subjectsubcode  varchar (100) 
DECLARE @feedout_imprintcode varchar(100)
DECLARE @feedout_formatcode varchar(100)
DECLARE @feedout_mediacode varchar(100)
DECLARE @feedout_mediadesc varchar(120)


DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Title AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnmitstitlefeed

DECLARE feedout_titles INSENSITIVE CURSOR
FOR

select distinct bookkey from bnmitstitlefeedbookkeys 

/* table above created in job scheduler
select distinct bookkey
	from titlehistory
		where printingkey = 1 and lastmaintdate >= (select feeddate
		from pofeeddate where feeddatekey = 7) /* should I just do printingkey=1*/
*/
	
FOR READ ONLY
	
/*get price defaults*/
select @feed_count = 0
select @feed_pricecode = 0
select @feed_currencycode = 0

select @feed_count = count(*) from filterpricetype
	where filterkey = 5 /*currency and price types*/

if @feed_count > 0 
 begin
	select @feed_pricecode= pricetypecode, @feed_currencycode = currencytypecode
		 from filterpricetype
		where filterkey = 5 /*currency and price types*/
 end	
		
OPEN feedout_titles 

FETCH NEXT FROM feedout_titles 
	INTO @feedout_bookkey
 
select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
  begin tran
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('1',@feed_system_date,'NO ROWS to PROCESS - Titles')
  commit tran
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

	select @feed_count = 0
	select @feedout_workkey = 0
	select @feedout_isbn10 = ''
	select @feedout_titlewithprefix = ''
	select @feedout_subtitle = ''
	select @feedout_shorttitle = ''
	select @feedout_sponsordisplayname = ''
	select @feedout_sponsorphonebookkey = ''
	select @feedout_class = ''
	select @feedout_classdivision = ''
	select @feedout_adultjuvflag = ''
	select @feedout_tradebargainflag = ''
	select @feedout_imprint = ''
	select @feedout_bisacstatus = ''
	select @feedout_origin = ''
	select @feedout_orginphonebookkey = ''
	select @feedout_formatdesc = ''
	select @feedout_usretailprice = 0
	select @feedout_canadaretailprice = 0
	select @feedout_pagecount = 0
	select @feedout_trimsize = ''
	select @feedout_pubdateMMDDYYYY = ''
	select @feedout_warehousedateMMDDYYYY = ''
	select @feedout_sponsornote = ''
	select @feedout_livenote = ''
	select @feedout_livenote2 = ''
	select @feedout_territory = ''
	select @feedout_series	= ''
	select @feedout_pubclass = '' 

	select @feed_titletypecode  = 0
	select	@feed_territorycode  = 0
	select @feed_audiencecode  = 0
	select @feed_bisacstatuscode  = 0
	select @feed_origincode  = 0
	select @feed_prefix  = ''
	select @feed_salesdivisioncode   = 0
	select @feed_origincode  = 0
	select @feed_mediatypecode  = 0
	select @feed_mediatypesubcode  = 0
	select @feed_seriescode = 0
	select @feed_pagecount = 0
	select  @feed_tentativepagecount = 0
	select @feed_trimsizewidth =''
	select @feed_trimsizelength  = ''
	select @feed_esttrimsizewidth  = ''	
	select @feed_esttrimsizelength	= ''
	select @feed_pricebudget = 0
	select @feed_pricefinal = 0
	select @feedout_merchkey = 0
	select @feedout_subjectcode = ''
	select @feedout_subjectsubcode = ''
	select @feedout_imprintcode = ''
	select @feedout_formatcode = ''
	select @feedout_mediacode = ''
	select @feedout_mediadesc = ''

/*workkey*/
	select @feedout_workkey = workkey from book
		where bookkey = @feedout_bookkey
	if @feedout_workkey is null
	  begin
		select @feedout_workkey = 0
	  end
	if @feedout_workkey = 0
	  begin
		select @feedout_workkey = @feedout_bookkey
	  end

/*isbn, title, shorttitle, subtitle, titletype, territory,
status, origin, salesdivision, series, format */

	select @feedout_isbn10 = isbn10, @feedout_shorttitle = shorttitle,
		@feedout_titlewithprefix = title, @feedout_subtitle = subtitle,
		@feed_titletypecode = titletypecode,@feed_territorycode = territoriescode,
		@feed_prefix =titleprefix , @feed_bisacstatuscode=bisacstatuscode,
		@feed_salesdivisioncode = salesdivisioncode, @feed_origincode = origincode,
		@feed_mediatypecode = mediatypecode, @feed_mediatypesubcode = mediatypesubcode,
		@feed_seriescode = seriescode
	from isbn i,book b, bookdetail b2
	where i.bookkey = b.bookkey and 
	  i.bookkey = b2.bookkey and b.bookkey = @feedout_bookkey

	if @feed_prefix is null
	  begin
		select @feed_prefix = ''
	  end
	
	if datalength(@feed_prefix) > 0
	  begin
		select @feedout_titlewithprefix = @feedout_titlewithprefix + ', ' + @feed_prefix
	  end

/*class*/
	select @feed_count = 0

	select @feed_count = count(*)
		from bookmisc b, subgentables g
		where b.bookkey = @feedout_bookkey
			and misckey = 1 and datacode = 1
			and datasubcode = longvalue
			and tableid=525

	if @feed_count > 0
	  begin
		select @feedout_class = externalcode
			from bookmisc b, subgentables g
			where b.bookkey = @feedout_bookkey
				and misckey = 1 and datacode = 1
				and datasubcode = longvalue
				and tableid=525
	  end

	if @feed_territorycode > 0
	  begin
		select  @feedout_territory = externalcode
			from gentables where tableid= 131
			   and datacode=  @feed_territorycode
	  end 
	
	
	select @feed_count = 0

	select @feed_count = count(*)
		from bookmisc b, subgentables g
		where b.bookkey = @feedout_bookkey
			and misckey = 2 and datacode = 2
			and datasubcode = longvalue
			and tableid=525

	if @feed_count > 0
	  begin
		select @feedout_classdivision = externalcode
			from bookmisc b, subgentables g
			where b.bookkey = @feedout_bookkey
				and misckey = 2 and datacode = 2
				and datasubcode = longvalue
				and tableid=525
	  end
	
	
	if @feed_bisacstatuscode > 0
	  begin
		select  @feedout_bisacstatus = externalcode
			from gentables where tableid= 314
			   and datacode=  @feed_bisacstatuscode
	  end 
	
	if @feed_origincode > 0
	  begin
		select  @feedout_origin = datadesc, @feedout_orginphonebookkey = externalcode
			from gentables where tableid= 315
			   and datacode=  @feed_origincode
	  end 

	if @feed_seriescode > 0
	  begin
		select  @feedout_series = datadesc
			from gentables where tableid= 327
			   and datacode=  @feed_seriescode
	  end 

	if @feed_mediatypecode> 0 
	  begin
		select  @feedout_mediadesc =  datadesc,@feedout_mediacode =  externalcode
			from gentables where tableid= 312
			   and datacode=  @feed_mediatypecode
	  end 

	if @feed_mediatypecode> 0 and @feed_mediatypesubcode > 0
	  begin
		select  @feedout_formatdesc =  datadesc,@feedout_formatcode =  externalcode
			from subgentables where tableid= 312
			   and datacode=  @feed_mediatypecode
			   and datasubcode = @feed_mediatypesubcode
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

/* pagecount,trimsize*/	
	select @feed_tentativepagecount = tentativepagecount,
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
	
/* prices 7-12-04 trim prices in the export dts package*/
	select @feed_count = 0
	select @feed_count = max(pricekey) from bookprice
	   	WHERE  bookkey = @feedout_bookkey
			   and pricetypecode = @feed_pricecode
			    and currencytypecode = @feed_currencycode
	if @feed_count > 0
	  begin
			
		SELECT @feed_pricebudget =  budgetprice,
			@feed_pricefinal =  finalprice
	 	   FROM bookprice
	  	 	WHERE  bookkey = @feedout_bookkey
			   and pricetypecode = @feed_pricecode
			    and currencytypecode = @feed_currencycode

		if @feed_pricefinal > 0 
		 begin
			select @feedout_usretailprice = @feed_pricefinal

		  end
		else
		 begin 
			select @feedout_usretailprice = @feed_pricebudget
		  end
	end

	select @feed_count = 0
	select @feed_pricebudget = 0
	select @feed_pricefinal = 0

	select @feed_count = max(pricekey) from bookprice
	   	WHERE  bookkey = @feedout_bookkey
			   and pricetypecode = @feed_pricecode
			    and currencytypecode = 11
	if @feed_count > 0
	  begin
			
		SELECT @feed_pricebudget = budgetprice,
			@feed_pricefinal = finalprice
	 	   FROM bookprice
	  	 	WHERE  bookkey = @feedout_bookkey
			   and pricetypecode = @feed_pricecode
			    and currencytypecode = 11

		if @feed_pricefinal > 0 
		 begin
			
			select @feedout_canadaretailprice  = @feed_pricefinal
		  end
		else
		 begin
			select @feedout_canadaretailprice = @feed_pricebudget
		  end
	end

/*sponsor--personnel roletypecode=27 , sponsorphonebookkey*/
		select @feed_count = 0
		select @feed_count  = contributorkey
			from  bookcontributor
				where bookkey=@feedout_bookkey and printingkey = 1
				  and roletypecode = 27

		if @feed_count  > 0
		begin
			select @feedout_sponsordisplayname = displayname, @feedout_sponsorphonebookkey = externalcode
			 from person
				where contributorkey = @feed_count
		end

/*audience -- should be only 1 but just in case*/
	select @feed_count = 0
	select @feed_count = count(*)
		from bookaudience
			where sortorder = 1 and bookkey = @feedout_bookkey

	if @feed_count >0
	  begin
		select @feed_audiencecode  = audiencecode    
		from bookaudience
			where sortorder = 1 and bookkey = @feedout_bookkey
	
		if @feed_audiencecode > 0
		  begin
			select  @feedout_adultjuvflag = externalcode
			from gentables where tableid= 460
			   and datacode=  @feed_audiencecode 
		  end
	  end 

/*tradebargainflag, imprint, pub class*/
	select @feed_count = 0

	select @feed_count = count(*)
		from bookmisc b, subgentables g
		where b.bookkey = @feedout_bookkey
			and misckey = 4 and datacode = 4
			and datasubcode = longvalue
			and tableid=525

	if @feed_count > 0
	  begin
		select @feedout_tradebargainflag = externalcode
			from bookmisc b, subgentables g
			where b.bookkey = @feedout_bookkey
				and misckey = 4 and datacode = 4
				and datasubcode = longvalue
				and tableid=525
	  end

	select @feed_count = 0

/**	6-9-04 remove pubclass from table also

	select @feed_count = count(*)
		from bookmisc b, subgentables g
		where b.bookkey = @feedout_bookkey
			and misckey = 3 and datacode = 3
			and datasubcode = longvalue
			and tableid=525

	if @feed_count > 0
	  begin
		select @feedout_pubclass = externalcode
			from bookmisc b, subgentables g
			where b.bookkey = @feedout_bookkey
				and misckey = 3 and datacode = 3
				and datasubcode = longvalue
				and tableid=525
	  end
**/
	/** Modified by DSL to change Imprint to pull from Spine Imprint Level 4*/
	select @feedout_imprint = coalesce(altdesc1,orgentrydesc),@feedout_imprintcode = altdesc2
		from bookorgentry b, orgentry o
		where b.orgentrykey = o.orgentrykey and b.bookkey = @feedout_bookkey
			and b.orglevelkey = 4 

/*pubdate, warehouse date*/

	select @feedout_pubdateMMDDYYYY = convert(varchar,bestdate, 101)
		from bookdates where bookkey= @feedout_bookkey
			and printingkey=1 and datetypecode=8

	select @feedout_warehousedateMMDDYYYY = convert(varchar,bestdate, 101)
		from bookdates where bookkey= @feedout_bookkey
			and printingkey=1 and datetypecode=47

/*sponsornote, livenote */
	select @feed_count = 0  /*sponsor note*/
	select @feed_count= count(*) from bookcomments
		where printingkey = 1 and commenttypecode = 4 and commenttypesubcode=20006
			and bookkey = @feedout_bookkey
	
	if @feed_count  > 0
	  begin
		select @feedout_sponsornote= substring(commenttext,1,2000) from bookcomments
		where printingkey = 1 and commenttypecode =4 and commenttypesubcode=20006
			and bookkey = @feedout_bookkey
	  end	

	select @feed_count = 0  /*live note 1*/
	select @feed_count= count(*) from bookcomments
		where printingkey = 1 and commenttypecode =4 and commenttypesubcode=20004
			and bookkey = @feedout_bookkey
	
	if @feed_count  > 0
	  begin
		select @feedout_livenote= substring(commenttext,1,2000) from bookcomments
		where printingkey = 1 and commenttypecode = 4 and commenttypesubcode=20004
			and bookkey = @feedout_bookkey
	  end	
		
	select @feed_count = 0  /*live note 2*/
	select @feed_count= count(*) from bookcomments
		where printingkey = 1 and commenttypecode =4 and commenttypesubcode=20005
			and bookkey = @feedout_bookkey
	
	if @feed_count  > 0
	  begin
		select @feedout_livenote2 = substring(commenttext,1,2000) from bookcomments
		where printingkey = 1 and commenttypecode = 4 and commenttypesubcode=20005
			and bookkey = @feedout_bookkey
	  end		
	
/*subject, category will probably need multiple so for now just output first one 
7-6-04 change tableid from 523 to 437*/

	select @feed_count = 1
	DECLARE feed_subjects INSENSITIVE CURSOR
	FOR

	select distinct categorycode,categorysubcode,sortorder
		from booksubjectcategory
		where  categorytableid=437
			and bookkey = @feedout_bookkey order by sortorder
	
	FOR READ ONLY

	OPEN feed_subjects 

	FETCH NEXT FROM feed_subjects
		INTO @feed_categorycode,@feed_categorysubcode,@feed_sortorder

	select @i_isbn2  = @@FETCH_STATUS

	while (@i_isbn2<>-1 )  /* status 1*/
	  begin
		IF (@i_isbn2<>-2) /* status 2*/
		  begin
			
			if @feed_count = 1
			  begin
				select @feedout_subject = datadesc ,@feedout_subjectcode =externalcode
				from gentables where tableid=437 and datacode = @feed_categorycode 
			
				if @feed_categorysubcode is null
				  begin
					select @feed_categorysubcode = 0
				  end
			
				if @feed_categorysubcode > 0
				  begin
			
					select @feedout_subjectcategory = datadesc ,@feedout_subjectsubcode =externalcode
						from subgentables where tableid=437 and datacode = @feed_categorycode
						and datasubcode = @feed_categorysubcode
				  end
			    end
			   else
			    begin
				goto exitsubj
		           end
			select @feed_count = @feed_count + 1

		end /*isbn2 status 2*/

		FETCH NEXT FROM feed_subjects
		INTO @feed_categorycode,@feed_categorycode,@feed_sortorder

		select @i_isbn2  = @@FETCH_STATUS
	end /*isbn2 status 1*/

exitsubj:
	
close feed_subjects
deallocate feed_subjects

/*7-2-04 add merchkey*/
select @feed_count = 0
select @feed_count = count(*)
			from bookmisc b
			where b.bookkey = @feedout_bookkey
				and misckey = 5

	if @feed_count > 0
	  begin
		select @feedout_merchkey = longvalue
			from bookmisc b
			where b.bookkey = @feedout_bookkey
				and misckey = 5
	  end

/***************************   warning messages  comment for now   
begin tran
	if @feedout_titlewithprefix is null  
	  begin
		select @feedout_titlewithprefix = ''
	  end
	
	if datalength(@feedout_titlewithprefix) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning title missing')
	end

	if @feedout_isbn10 is null  
	  begin
		select @feedout_isbn10 = ''
	  end

	if datalength(@feedout_isbn10) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning isbn missing')
	end

	if @feedout_shorttitle is null  
	  begin
		select @feedout_shorttitle = ''
	  end
	if datalength(@feedout_shorttitle) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning shorttitle missing')
	end
	
	if @feedout_sponsordisplayname is null  
	  begin
		select @feedout_sponsordisplayname = ''
	  end

	if datalength(@feedout_sponsordisplayname) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Sponsor missing')
	end

	if @feedout_sponsorphonebookkey is null  
	  begin
		select @feedout_sponsorphonebookkey = ''
	  end

	if datalength(@feedout_sponsorphonebookkey) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning SponsorBookkey missing')
	end

	if @feedout_class is null  
	  begin
		select @feedout_class = ''
	  end

	if datalength(@feedout_class) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning class missing')
	end

	if @feedout_classdivision is null  
	  begin
		select @feedout_classdivision = ''
	  end

	if datalength(@feedout_classdivision) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Classdivision missing')
	end

	if @feedout_adultjuvflag is null  
	  begin
		select @feedout_adultjuvflag = ''
	  end

	if datalength(@feedout_adultjuvflag) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Adultjuvflag missing')
	end

	if @feedout_tradebargainflag is null  
	  begin
		select @feedout_tradebargainflag = ''
	  end

	if datalength(@feedout_tradebargainflag) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Tradebargainflag missing')
	end


	if @feedout_imprint is null  
	  begin
		select @feedout_imprint = ''
	  end

	if datalength(@feedout_imprint) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Imprint missing')
	end


	if @feedout_bisacstatus is null  
	  begin
		select @feedout_bisacstatus = ''
	  end

	if datalength(@feedout_bisacstatus) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Status missing')
	end

	if @feedout_orginphonebookkey is null  
	  begin
		select @feedout_orginphonebookkey = ''
	  end

	if datalength(@feedout_orginphonebookkey) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Vendor phone bookkey missing')
	end

	if @feedout_formatdesc is null  
	  begin
		select @feedout_formatdesc = ''
	  end

	if datalength(@feedout_formatdesc) = 0
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_isbn10,'1',@feed_system_date,'Title-- warning Format missing')
	end
commit tran

***************************/
	
/*insert into temporary table*/
begin tran
	insert into bnmitstitlefeed (bookkey,workkey,isbn10,titlewithprefix,subtitle,shorttitle,
		sponsordisplayname,sponsorphonebookkey,class,classdivision,
		adultjuvflag,tradebargainflag,imprint,bisacstatus,origin,
		orginphonebookkey,formatdesc,usretailprice,canadaretailprice,
		pagecount,trimsize,pubdateMMDDYYYY,warehousedateMMDDYYYY,
		sponsornote,livenote,territory,subject,subjectcategory,
		series,merchkey,subjectcode,subjectsubcode,livenote2,imprintcode,
		formatcode,mediacode,mediadesc)
	values (@feedout_bookkey,@feedout_workkey,@feedout_isbn10,@feedout_titlewithprefix,@feedout_subtitle,@feedout_shorttitle,
		@feedout_sponsordisplayname,@feedout_sponsorphonebookkey,@feedout_class,@feedout_classdivision,
		@feedout_adultjuvflag,@feedout_tradebargainflag,@feedout_imprint,@feedout_bisacstatus,@feedout_origin,
		@feedout_orginphonebookkey,@feedout_formatdesc,@feedout_usretailprice,@feedout_canadaretailprice,
		@feedout_pagecount,@feedout_trimsize,@feedout_pubdateMMDDYYYY,@feedout_warehousedateMMDDYYYY,
		@feedout_sponsornote,@feedout_livenote,@feedout_territory,@feedout_subject,@feedout_subjectcategory,
		@feedout_series,@feedout_merchkey,@feedout_subjectcode,@feedout_subjectsubcode,@feedout_livenote2,
		@feedout_imprintcode,@feedout_formatcode,@feedout_mediacode,@feedout_mediadesc)
	
commit tran

end /*isbn status 2*/

FETCH NEXT FROM feedout_titles 
	INTO @feedout_bookkey 

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/

begin tran

update pofeeddate
set feeddate = tentativefeeddate
where feeddatekey=7

/* 8-24-04 move all deletes before count*/
delete from bnmitstitlefeed where titlewithprefix is null

delete from bnmitstitlefeed where titlewithprefix = ''

select @feed_count = 0
select @feed_count = count(*) from bnmitstitlefeed
if @feed_count > 0
  begin
	insert into bnmitstitlefeed (bookkey,workkey,isbn10,titlewithprefix)
	  values (0,0,null,'Total Records '+ convert(varchar,@feed_count))
  end	

insert into feederror (batchnumber,processdate,errordesc)
 values ('1',@feed_system_date,'Titles Out Completed')

commit tran

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