if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_in_title_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_in_title_info]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE proc dbo.feed_in_title_info 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

20031209 - Peter Sammons - Comment out add or update of canadian prices
20040223 - Peter Sammons - Put back add of canadian prices and update only if existing canadian price is zero, set all lastuserid to 'TOPSFEED'

**/

DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime

DECLARE @feedin_bookkey  int
DECLARE @feedin_authorkey  int

DECLARE @feedin_isbn  varchar(10)
DECLARE @feedin_bisacstatuscode varchar(10)
DECLARE @feedin_retailprice  varchar(20)
DECLARE @feedin_futureprice  varchar(20)
DECLARE @feedin_canadianprice varchar(20)
DECLARE @feedin_pubdate	varchar(20)
DECLARE @feedin_waredate varchar(20)
DECLARE @feedin_territory   varchar(20)
DECLARE @feedin_cartonqty  varchar(20)
DECLARE @feedin_qtyavailable  varchar(20)
DECLARE @feedin_qtyonorder  varchar(20)
DECLARE @feed_isbn  varchar (13)
DECLARE @feed_prepackind char(1) 
DECLARE @feedin_temp_isbn varchar(8)
DECLARE @feedin_isbn_prefix int
DECLARE @feedin_pubmonthcode int
DECLARE @feedin_price_temp  numeric(9,2)
DECLARE @feedin_retailp numeric(9,2) 
DECLARE @feedin_futurep numeric(9,2) 
DECLARE @feedin_canadianp numeric(9,2)
DECLARE @feedin_cartonqty1 int 
DECLARE @feedin_bookweight varchar(10)
DECLARE @feedin_pubtowebind   tinyint
DECLARE @feedin_pub	datetime
DECLARE @feedin_ware datetime

DECLARE @feedin_bisacstatus int
DECLARE @feedin_territorycode  int
DECLARE @feedin_pubstring  varchar(11)
DECLARE @feedin_bisacstatus_old int 
DECLARE @feedin_count int
DECLARE @i_isbn int
DECLARE @feedin_tableid int
DECLARE @nextkey  int
DECLARE @eloquenceind tinyint
DECLARE @feedin_weight numeric(9,4)
DECLARE @feedin_qtyavail int
DECLARE @feedin_qtyord int
DECLARE @feedin_bisacstatus_tmm varchar (30)
DECLARE @feedin_convchar varchar(100)
DECLARE @i_elementkey int
DECLARE @i_taskkey int
DECLARE @i_elementstatus int
DECLARE @i_firsttime int
DECLARE @d_maxprice numeric(9,2)

SET NOCOUNT ON

BEGIN tran 

SELECT @feed_system_date = getdate()

/* run titles feed from here */
insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Inserts',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values('3',@feed_system_date,'Feed Summary: Updates',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Rejected',0)


/* 11-11-03  add parameter for titlehistory_insert, 0,1 for updating eloquence tables*/

DECLARE feed_titles INSENSITIVE CURSOR
FOR

select  rtrim(t.isbn), 
	rtrim(bisacstatuscode),
	rtrim(retailprice), 
	rtrim(canadianprice), 
	'',/*rtrim(futureprice), */
	rtrim(pubdate),
	'',/*rtrim(waredate),*/
	'',/*rtrim(territory), */
	rtrim(cartonqty), 
	'',/*rtrim(bookweight), */
	rtrim(qtyavailable),
	rtrim(qtyonorder)

from feedin_titles t, isbn i
where i.isbn10 = t.isbn
	order by t.isbn

FOR READ ONLY
		
OPEN feed_titles 

FETCH NEXT FROM feed_titles 
INTO @feedin_isbn, 
	@feedin_bisacstatuscode,
	@feedin_retailprice , 
	@feedin_canadianprice,
	@feedin_futureprice, 
	@feedin_pubdate,
	@feedin_waredate,
	@feedin_territory,
	@feedin_cartonqty,
	@feedin_bookweight, 
	@feedin_qtyavailable,
	@feedin_qtyonorder

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',@feed_system_date,'NO ROWS to PROCESS')
end

while (@i_isbn<>-1 )  /* sttus 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

	
	select @feedin_bisacstatus = 0
	select @feedin_count = 0
	select @feedin_isbn_prefix = 0
	select @feedin_price_temp = 0
	select @feedin_bookkey = 0
	select @feedin_pubstring  =''
	select @feed_isbn  = ''
	select @feedin_temp_isbn = ''
	select @feedin_price_temp = 0
	select @feedin_pubmonthcode = 0
	select @feedin_bisacstatus_old = 0
	select @feedin_pubtowebind   = 0
	select @feedin_retailp  = 0
	select @feedin_futurep  = 0
	select @feedin_canadianp  = 0
	select @feedin_cartonqty1  = 0
	select @feedin_pub  = ''
	select @feedin_ware = ''
	select @feedin_territorycode = 0
	select @feedin_weight = 0 
	select @feedin_bisacstatus_tmm = ''
	select @feedin_qtyord = 0

	select @feed_isbn = RTRIM(@feedin_isbn) 

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

	else  /* isbn not empty*/
 	  begin
		/*
			all isbns already valid
			EXEC isbn_13 @feedin_isbn, @feed_isbn OUTPUT

		if @feed_isbn = 'NO ISBN' 
		begin

			insert into feederror 			
				(isbn,batchnumber,processdate,errordesc)
			values (@feedin_isbn,'3',@feed_system_date,('NO ISBN ENTERED ' + @feedin_isbn))

			update feederror 
				set detailtype = (detailtype + 1)
					where batchnumber='3'
						and processdate > = @feed_system_date
						 and errordesc LIKE 'Feed Summary: Rejected%'
		end
*/
	
/* remove reissue isbn book keys*/
	select @feedin_bookkey = count(*)  
			from isbn i, book b
				where i.bookkey= b.bookkey
					and (b.reuseisbnind is null or reuseisbnind = 0) 
						and isbn10= RTRIM(@feedin_isbn)

	if @feedin_bookkey = 0  
	begin
		select @feedin_bookkey = 0	/*new title title*/
		if @feed_isbn <> 'NO ISBN' 
		begin
			/* get isbn prefix code by stripping off values to the second '-'*/
			select @feedin_count = 0
			select @feedin_count = charindex('-', @feed_isbn)
			select @feedin_count = @feedin_count - 1
			select @feedin_temp_isbn = substring(@feed_isbn,1,@feedin_count)
	
			select @feedin_isbn_prefix= datacode  
					from gentables
						where datadesc = @feedin_temp_isbn
							and tableid=138
		end 
	end
	else
	begin
/* remove reissue isbn book keys*/
		select @feedin_bookkey = b.bookkey, @feed_isbn= i.isbn 
			from isbn i, book b
				where i.bookkey= b.bookkey
					and (b.reuseisbnind is null or reuseisbnind = 0) 
						and isbn10= RTRIM(@feedin_isbn)
	end
	if len(@feed_isbn) = 13 
	begin

/*------------- intialize data for new or old ---------*/

/*bisacstatus*/

	select @feedin_count = 0

		select @feedin_count = count(*)
			from feedtitlestatusmap
				where UPPER(bisacstatuscode)=UPPER(RTRIM(@feedin_bisacstatuscode))

		if @feedin_count > 0 
		  begin
			select @feedin_bisacstatus_tmm = UPPER(tmmexternalcode)
					from feedtitlestatusmap
					where UPPER(bisacstatuscode)=UPPER(RTRIM(@feedin_bisacstatuscode)) 

			select @feedin_count = 0
			select @feedin_count = count(*)
					from gentables
						where UPPER(externalcode)= @feedin_bisacstatus_tmm
							and tableid=314 
			if @feedin_count > 0 
			  begin
				select @feedin_bisacstatus = datacode, @feedin_bisacstatus_tmm = externalcode
					from gentables
						where UPPER(externalcode)= @feedin_bisacstatus_tmm
							and tableid=314 
			  end
		  end
		else
		  begin
			/* look for value on gentables, since might not be on feedtitlestatusmap*/
			select @feedin_count = 0
			select @feedin_count = count(*) 
					from gentables
						where UPPER(externalcode)= UPPER(RTRIM(@feedin_bisacstatuscode))
							and tableid=314 
			if @feedin_count > 0 
			  begin
				select @feedin_bisacstatus = datacode, @feedin_bisacstatus_tmm = externalcode
					from gentables
						where UPPER(externalcode)=UPPER(RTRIM(@feedin_bisacstatuscode)) 
							and tableid=314 
			  end

		  end

		if @feedin_bisacstatus = 0
		  begin
			select @feedin_bisacstatus  = 0
			  insert into feederror
				(isbn,batchnumber,processdate,errordesc)
			  values (rtrim(@feedin_isbn), '3',@feed_system_date,('BISAC STATUS NOT ON GENTABLES; BISAC STATUS NOT UPDATED '+ @feedin_bisacstatuscode))
		  end

		if @feedin_bisacstatus > 0 
		begin
			select @feedin_bisacstatus_old = datacode,@feedin_pubtowebind=publishtowebind 
				from bookdetail b, isbn i,gentables g
				where i.isbn10=rtrim(@feedin_isbn) 
					and i.bookkey=b.bookkey
					and b.bisacstatuscode=g.datacode
					and tableid=314
		end
/* prices*/
/*  do not convert it just put in as is  convert rounds do not do this*/
		if len(RTRIM(LTRIM(@feedin_retailprice))) > 0 
		begin
			select @feedin_price_temp = convert(numeric,(RTRIM(LTRIM(@feedin_retailprice))))
			if @feedin_price_temp >0 
			begin
				select @feedin_retailp  = @feedin_price_temp
			end
			else 	
			begin 
			  select @feedin_retailp = 0
			end 
		end 

		if len(RTRIM(LTRIM(@feedin_futureprice))) > 0 
		begin
			select @feedin_price_temp = convert(numeric,(RTRIM(LTRIM(@feedin_futureprice))))
			if @feedin_price_temp >0 
			begin
				select @feedin_futurep  = @feedin_price_temp
			end
			else 	
			begin 
			  select @feedin_futurep = 0
			end 
		end 

		select @feedin_price_temp = 0

	if len(RTRIM(LTRIM(@feedin_canadianprice))) > 0 
		begin
			select @feedin_price_temp = convert(numeric,(RTRIM(LTRIM(@feedin_canadianprice))))
			if @feedin_price_temp >0 
			begin
				select @feedin_canadianp = @feedin_price_temp
			end
			else 	
			begin 
			  select @feedin_canadianp = 0
			end 
		end 
		
/*dates */

	/* do not like the format so no formating date go in as is
	select @feedin_pub = convert(datetime,@feedin_pubdate,110)
	select @feedin_ware = convert(datetime,@feedin_waredate,110)*/

	select @feedin_pub = @feedin_pubdate
	select @feedin_ware = @feedin_waredate

/* 10-9-00 add pubmonthcode for new titles*/
	if len(@feedin_pubdate) > 0 
	begin
		/*select @feedin_pubmonthcode = convert(numeric,(char,@feedin_pub,'MM')) */
		select @feedin_pubmonthcode = convert(numeric,substring(convert(char,@feedin_pub,101),1,2))
	end

/* territory*/
	select @feedin_count = 0

   if len(rtrim(ltrim(@feedin_territory))) > 0 
     begin
		select @feedin_count = count(*)
				from gentables
					where tableid = 131
						and externalcode = LTRIM(RTRIM(@feedin_territory))

		if @feedin_count > 0 
		  begin
			select  @feedin_territorycode = datacode
					from gentables
					 where tableid= 131
						and  externalcode = LTRIM(RTRIM(@feedin_territory))
		 end
		 else   
		  begin	
			insert into feederror
				(isbn,batchnumber,processdate,errordesc)
			  values (rtrim(@feedin_isbn), '3',@feed_system_date,('TERRITORY CODE NOT PRESENT ON GENTABLES; PLEASE ADD '
					+ @feedin_territory))
		 end
   end
 
/* --------------start updating existing title  record ------------*/					
	if @feedin_bookkey > 0 
	begin
				
/* ------------------start updating tables------------------*/
		select @feedin_count = 0 
		select @feedin_count = count(*) 
				from bookdetail
					where bookkey=@feedin_bookkey
		if @feedin_count = 0 
		begin
			insert into bookdetail 
			(bookkey,lastuserid,lastmaintdate)
			values (@feedin_bookkey,'TOPSFEED',@feed_system_date)
		end

		if @feedin_bisacstatus > 0 
		begin
			update feederror 
				set detailtype = (detailtype + 1)
					where batchnumber='3'
					  and processdate >= @feed_system_date
						 and errordesc LIKE 'Feed Summary: Updates%'
			

			EXEC dbo.titlehistory_insert 'BISACSTATUSCODE','BOOKDETAIL',@feedin_bookkey,0,'',@feedin_bisacstatus,1

			update bookdetail
				set bisacstatuscode = @feedin_bisacstatus,
				lastuserid='TOPSFEED',
				lastmaintdate = @feed_system_date
					where bookkey = @feedin_bookkey
		end
/*territory*/
	if @feedin_territorycode > 0 
	  begin
		EXEC dbo.titlehistory_insert 'TERRITORIESCODE','BOOK',@feedin_bookkey,0,'',@feedin_territorycode,1

		update book
			set territoriescode = @feedin_territorycode,
				lastuserid='TOPSFEED',
				lastmaintdate = @feed_system_date
				where bookkey = @feedin_bookkey
	  end

/*cartonqty*/
	select @feedin_count = 0
	if len(LTRIM(RTRIM(@feedin_cartonqty)))>0
	  begin
		select @feedin_cartonqty1 = convert(int,@feedin_cartonqty)
		select @feedin_count = count (*)  
			from bindingspecs
				where bookkey = @feedin_bookkey
					and printingkey=1
		if @feedin_count>0  		  begin
			EXEC dbo.titlehistory_insert 'CARTONQTY1','BINDINGSPECS',@feedin_bookkey,1,'',@feedin_cartonqty1,1
			update bindingspecs
				set cartonqty1 = @feedin_cartonqty1,
					lastuserid='TOPSFEED',
					lastmaintdate = @feed_system_date
						where bookkey = @feedin_bookkey
						and printingkey = 1
		  end
		else
		   begin
			EXEC dbo.titlehistory_insert 'CARTONQTY1','BINDINGSPECS',@feedin_bookkey,1,'',@feedin_cartonqty1,1
			insert into bindingspecs 
				(bookkey,printingkey,vendorkey,cartonqty1,lastuserid,lastmaintdate)
				values (@feedin_bookkey,1,0,@feedin_cartonqty1,'TOPSFEED',@feed_system_date)
			 end
	   	    end
 	

/* bookweight*/
	select @feedin_count = 0

	if len(LTRIM(RTRIM(@feedin_bookweight)))>0 and @feedin_bookweight <>.00000
	 begin
		select @feedin_weight = LTRIM(RTRIM(@feedin_bookweight))
		select @feedin_count = count (*)  
			from booksimon
				where bookkey = @feedin_bookkey

			select @feedin_convchar = ''
			select @feedin_convchar = convert(char,@feedin_bookweight)

		if @feedin_count>0 
		  begin

			EXEC dbo.titlehistory_insert 'BOOKWEIGHT','BOOKSIMON',@feedin_bookkey,0,'',@feedin_convchar ,1
			update booksimon
				set bookweight = @feedin_weight,
						lastuserid='TOPSFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
		  end
		else
		  begin
			EXEC dbo.titlehistory_insert 'BOOKWEIGHT','BOOKSIMON',@feedin_bookkey,0,'',@feedin_convchar ,1
			insert into booksimon (bookkey,bookweight,lastmaintdate,lastuserid)
				values (@feedin_bookkey, @feedin_weight,@feed_system_date,'TOPSFEED')
		  end
	end
 
/* topsqtyavailable*/
	select @feedin_count = 0
/**** 10-26-03   update even if new value = 0
	if len(LTRIM(RTRIM(@feedin_qtyavailable)))>0 
	 begin
****/	
	select @feedin_qtyavail= LTRIM(RTRIM(@feedin_qtyavailable))
		select @feedin_count = count (*)  
			from bookcustom
				where bookkey = @feedin_bookkey
		if @feedin_count>0 
		  begin
			update bookcustom
				set customint01 = @feedin_qtyavail,
						lastuserid='TOPSFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
		  end
		else
		  begin
			insert into bookcustom (bookkey,customint01,lastmaintdate,lastuserid)
				values (@feedin_bookkey, @feedin_qtyavail,@feed_system_date,'TOPSFEED')
		  end
/**	end **/
	
/* topsqtyonorder -- 10-27-03 CHANGE FROM BOOKCUSTOM TO PRINTING.FIRSTPRINTQTY PRINTINGKEY=1*/
	select @feedin_count = 0

	if len(LTRIM(RTRIM(@feedin_qtyonorder)))>0 
	 begin
		select @feedin_qtyord= LTRIM(RTRIM(@feedin_qtyonorder))
		select @feedin_count = count (*)  
			from printing
				where bookkey = @feedin_bookkey
				   and printingkey= 1
		if @feedin_count>0 
		  begin
			EXEC dbo.titlehistory_insert 'FIRSTPRINTINGQTY','PRINTING',@feedin_bookkey,1,'',@feedin_qtyord,0
			update printing
				set firstprintingqty = @feedin_qtyord,
						lastuserid='TOPSFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
							  and printingkey = 1
		  end
		else
		  begin
			EXEC dbo.titlehistory_insert 'FIRSTPRINTINGQTY','PRINTING',@feedin_bookkey,1,'',@feedin_qtyord,0
			insert into printing(bookkey,printingkey,firstprintingqty,lastmaintdate,lastuserid)
				values (@feedin_bookkey,1, @feedin_qtyord,@feed_system_date,'TOPSFEED')
		  end
	end
	
/************************update titles that are not NYP***************/

/****  10-26-03 update prices and dates for all titles now
		if RTRIM(LTRIM(@feedin_bisacstatuscode)) <>'NYP' 
	 	  begin
***/

		/*retail price*/
			if len(RTRIM(LTRIM(@feedin_retailprice))) > 0 and  RTRIM(LTRIM(@feedin_retailprice))  <> '0.00'
			begin
				select @feedin_count = 0   /* pricetypecode = 8, per doug*/
				select @feedin_count = count(*)
					from bookprice
						where bookkey=@feedin_bookkey
							and currencytypecode=6
								and pricetypecode=8
			select @feedin_convchar = ''
			select @feedin_convchar = convert(float,@feedin_retailprice)

				if @feedin_count > 0 
				begin
					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'8',@feedin_convchar,1
					update bookprice
						set finalprice = RTRIM(LTRIM(@feedin_retailprice)),  /*since books pub only finalprice updated*/
							lastuserid='TOPSFEED',
							lastmaintdate = @feed_system_date
								where bookkey=@feedin_bookkey
									and currencytypecode=6
									and pricetypecode=8
				end
				else
				begin
					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'TOPSFEED', 
					lastmaintdate = getdate()

					select @nextkey = generickey from Keys

					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'8',@feedin_convchar,1

					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,8,6,1,
						RTRIM(LTRIM(@feedin_retailprice)),@feed_system_date,'TOPSFEED',@feed_system_date)
				end
			end
		/*future price*/
			if len(RTRIM(LTRIM(@feedin_futureprice))) > 0 and  RTRIM(LTRIM(@feedin_futureprice))  <> '0.00'
			begin
				select @feedin_count = 0   /* pricetypecode = 13, per doug*/
				select @feedin_count = count(*)
					from bookprice
						where bookkey=@feedin_bookkey
							and currencytypecode=6
								and pricetypecode=13

			select @feedin_convchar = ''
			select @feedin_convchar = convert(float,@feedin_futureprice)

				if @feedin_count > 0 
				begin
					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'13',@feedin_convchar,1
					update bookprice
						set finalprice = RTRIM(LTRIM(@feedin_futureprice)),  /*since books pub only finalprice updated*/
							lastuserid='TOPSFEED',
							lastmaintdate = @feed_system_date
								where bookkey=@feedin_bookkey
									and currencytypecode=6
									and pricetypecode=13
				end
				else
				begin
					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'TOPSFEED', 
					lastmaintdate = getdate()

					select @nextkey = generickey from Keys

					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'13',@feedin_convchar,1

					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,13,6,1,
						RTRIM(LTRIM(@feedin_futureprice)),@feed_system_date,'TOPSFEED',@feed_system_date)
				end
			end

/*canada */

	if @feedin_canadianp> 0
	  begin
		select @feedin_count = 0
		select @feedin_count = count(*), @d_maxprice = max(finalprice)
			from bookprice
				where bookkey=@feedin_bookkey
					and currencytypecode=11
					and pricetypecode=8

		select @feedin_convchar = ''
		select @feedin_convchar = convert(float,@feedin_canadianprice)

		if @feedin_count>0
		  begin
			if @d_maxprice = 0   /* Do not update existing canadian prices */
			  begin
				EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'11',@feedin_convchar,1
				update bookprice
				set finalprice = RTRIM(LTRIM(@feedin_canadianprice)),  
					lastuserid='TOPSFEED',
					lastmaintdate = @feed_system_date
						where bookkey= @feedin_bookkey
							and currencytypecode=11
							and pricetypecode=8
			  end
		  end
		else
		  begin
			select @nextkey = 0
			UPDATE keys SET generickey = generickey+1, 
				lastuserid = 'TOPSFEED', 
				lastmaintdate = getdate()

			select @nextkey = generickey from Keys
			EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'11',@feedin_convchar,1

			select @nextkey = generickey from Keys

			insert into bookprice (pricekey,bookkey,pricetypecode,
				currencytypecode,activeind,finalprice,effectivedate,lastuserid,lastmaintdate)
			values (@nextkey,@feedin_bookkey,8,11,1,RTRIM(LTRIM(@feedin_canadianprice)),
				@feed_system_date,'TOPSFEED',@feed_system_date)
		end
	end

/*pub date*/
if len(@feedin_pubdate) > 0 
  begin

	select @feedin_count = 0
	select @feedin_count = count(*) 
		from bookdates
			where bookkey=@feedin_bookkey
				and printingkey=1
				and datetypecode=8

		select @feedin_convchar = ''
		select @feedin_convchar = convert(char,@feedin_pub)
		select @i_firsttime = 1

		if @feedin_count > 0 			
		  begin
			EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'8',@feedin_convchar,1
			
			update bookdates
				set activedate = @feedin_pub,  /*since books pub only activedate updated*/	
					lastuserid ='TOPSFEED',
					lastmaintdate=@feed_system_date
						where bookkey= @feedin_bookkey
							and printingkey=1
							and datetypecode=8
		  end
		else
		  begin
			EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'8',@feedin_convchar,1

			insert into bookdates (bookkey,printingkey,datetypecode,
				activedate,actualind,sortorder,lastuserid ,lastmaintdate)
			values (@feedin_bookkey,1,8,@feedin_pub,0,1,'TOPSFEED',@feed_system_date)
		  end

/*12-22-03  update pubdate on any schedule that is present*/
	DECLARE feed_schedules INSENSITIVE CURSOR
	  FOR
		select t.elementkey, t.taskkey
		    FROM  BOOKELEMENT b, ELEMENT e, TASK t 
			where  b.ELEMENTKEY = e.ELEMENTKEY and
         			e.ELEMENTKEY = t.ELEMENTKEY  and
         			b.bookkey = @feedin_bookkey AND
         			b.printingkey = 1 and t.datetypecode= 8
	FOR READ ONLY
		
	OPEN feed_schedules 

	FETCH NEXT FROM feed_schedules 
		INTO @i_elementkey,@i_taskkey
                
		select @i_elementstatus = @@FETCH_STATUS

		while (@i_elementstatus<>-1 )  /* sttus 1*/
		  begin
			IF (@i_elementstatus<>-2) /* status 2*/
			  begin
				if @i_firsttime = 1 
			  begin
				/*1-14-05 variable was not set before*/
				select @feedin_convchar = ''
				select @feedin_convchar = convert(char,@feedin_pub)

				EXEC dbo.titlehistory_insert 'ACTUALDATE','TASK',@feedin_bookkey,@i_elementkey,'8',@feedin_convchar,0
			  end
		select @i_firsttime =  @i_firsttime + 1 

	/*use printingkey for taskkey*/

				update task
				  set actualdate = @feedin_pub,  /*since books pub only activedate updated*/	
					lastuserid ='TOPSFEED',
					lastmaintdate=@feed_system_date
						where elementkey= @i_elementkey
							and taskkey = @i_taskkey
							and datetypecode=8
			end /*status 2*/

		    FETCH NEXT FROM feed_schedules 
			INTO @i_elementkey,@i_taskkey 

		select @i_elementstatus  = @@FETCH_STATUS
	   end /*status 1*/
	close feed_schedules
	deallocate feed_schedules
   end		

/*ware date*/
select @feedin_count = 0
if len(@feedin_waredate) > 0 
  begin 
		select @feedin_count = count(*) 
		from bookdates
			where bookkey=@feedin_bookkey
				and printingkey=1
				and datetypecode=8

		select @feedin_convchar = ''
		select @feedin_convchar = convert(char,@feedin_ware)

	if @feedin_count > 0 
	  begin		
		EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'47',@feedin_convchar,1
	
		update bookdates
			set activedate = @feedin_ware,  /*since books pub only activedate updated*/	
				lastuserid ='TOPSFEED',
				lastmaintdate= @feed_system_date
					where bookkey= @feedin_bookkey
						and printingkey=1
						and datetypecode=47
	  end 
	else
	  begin
		EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'47',@feedin_convchar,1

		insert into bookdates (bookkey,printingkey,datetypecode,
			activedate,actualind,sortorder,lastuserid ,lastmaintdate)
		values (@feedin_bookkey,1,47,@feedin_ware,0,47,'TOPSFEED',@feed_system_date)
		end
	end		
	
/*printing */
if len(@feedin_pubdate) > 0 
  begin
	select @feedin_count = 0
		select @feedin_count = count(*)
				from printing
					where bookkey=@feedin_bookkey
						and printingkey=1

	if  @feedin_count > 0  
	begin
		EXEC dbo.titlehistory_insert 'PUBMONTHCODE','PRINTING',@feedin_bookkey,1,'',@feedin_pubmonthcode,1

		update printing
			set pubmonthcode = @feedin_pubmonthcode,
				pubmonth = @feedin_pub,
				lastuserid='TOPSFEED',
				lastmaintdate = @feed_system_date
					where bookkey= @feedin_bookkey
						and printingkey=1	
	 end
	else
	  begin
		EXEC dbo.titlehistory_insert 'PUBMONTHCODE','PRINTING',@feedin_bookkey,1,'',@feedin_pubmonthcode,1

		insert into printing (bookkey,printingkey,
			creationdate,specind,lastuserid,lastmaintdate,
			printingnum,jobnum,printingjob,pubmonth,pubmonthcode)
		values (@feedin_bookkey,1,@feed_system_date,0,'TOPSFEED',	
			@feed_system_date,1,1,'1',@feedin_pub,@feedin_pubmonthcode)
	  end
	end

/*    end  10-26-03 no longer just update only published .. update all  all updates are published only*/
end   /* end bookkey > 0*/

/* add publish to web indicator if title currently go web trigger status change*/
	/*if @feedin_bisacstatus_old <> @feedin_bisacstatus and @feedin_pubtowebind> 0 
	begin*/
	/*	trigger whatever to the web*/
/*	end if*/
end /* isbn 13 */

/* new title ----------------------------------------------------------*/

	if @feedin_bookkey = 0 
	begin  /* do not add new titlesoutput this error since there are over 30,000 plus titles not in tmm*/
	/*	insert into feederror */
	/*		(isbn,batchnumber,processdate,errordesc)*/
	/*	values (rtrim(@feedin_isbn),'3',@feed_system_date,('Titles does not exists in TMM ' + rtrim(@feedin_isbn)))*/

		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='3'
					  and processdate >= @feed_system_date
					 and errordesc LIKE 'Feed Summary: Rejected%'
	end /* bookkey =0 new title */

print @feedin_isbn
end  /* ISBN Record*/

end /*isbn status 2*/

FETCH NEXT FROM feed_titles 
INTO @feedin_isbn, 
	@feedin_bisacstatuscode,
	@feedin_retailprice , 
	@feedin_canadianprice,
	@feedin_futureprice, 
	@feedin_pubdate,
	@feedin_waredate,
	@feedin_territory,
	@feedin_cartonqty,
	@feedin_bookweight, 
	@feedin_qtyavailable,
	@feedin_qtyonorder

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/



/*  delete when complete since looping through cursor undo comment once finish testing*/
/* DELETE FROM feedin_titles*/

insert into feederror (batchnumber,processdate,errordesc)
 values ('3',@feed_system_date,'Titles Completed' + convert(char,getdate()))

close feed_titles
deallocate feed_titles

commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO