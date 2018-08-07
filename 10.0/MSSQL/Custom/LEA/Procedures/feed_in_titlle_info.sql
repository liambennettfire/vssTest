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
**/

DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime

DECLARE @feedin_bookkey  int
DECLARE @feedin_authorkey  int

DECLARE @feedin_isbn  varchar(10)
DECLARE @feedin_bisacstatuscode varchar(10)
DECLARE @feedin_itemstatuscode varchar(10)
DECLARE @feedin_stockstatuscode varchar(10)
DECLARE @feedin_discount varchar(10)
DECLARE @feedin_retailprice  varchar(20)
DECLARE @feedin_alternateprice  varchar(20)
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
DECLARE @feedin_alternatep numeric(9,2)
DECLARE @feedin_futurep numeric(9,2) 
DECLARE @feedin_canadianp numeric(9,2)
DECLARE @feedin_cartonqty1 int 
DECLARE @feedin_bookweight float
DECLARE @feedin_pubtowebind   tinyint
DECLARE @feedin_pub	datetime
DECLARE @feedin_ware	datetime
DECLARE @feedin_bisacstatus int
DECLARE @feedin_territorycode  int
DECLARE @feedin_discountcode varchar(10)
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

DECLARE feed_titles_LEA INSENSITIVE CURSOR
FOR

select  
	rtrim(t.isbn),
	rtrim(t.itemstatuscode),
	rtrim(t.stockstatus),
	rtrim(t.listprice), 
	rtrim(t.altprice), 
	'',/*rtrim(canadianprice), */
	'',/*rtrim(futureprice), */
	rtrim(t.pubdate),
	'',/*rtrim(waredate),*/
	'',/*rtrim(territory), */
	'',/*rtrim(t.cartonqty), */
	rtrim(weight),
	'',/*rtrim(t.qtyavailable),*/
	'',/*rtrim(t.qtybackorder),*/
	''/*rtrim(t.discount)*/

from LEA_TitleInfo t, isbn i
where i.isbn10 = Rtrim(t.isbn)
	order by t.isbn


FOR READ ONLY
		
OPEN feed_titles_LEA 

FETCH NEXT FROM feed_titles_LEA 
INTO @feedin_isbn, 
	@feedin_itemstatuscode,
	@feedin_stockstatuscode,
	@feedin_retailprice , 
	@feedin_alternateprice,
	@feedin_canadianprice,
	@feedin_futureprice, 
	@feedin_pubdate,
	@feedin_waredate,
	@feedin_territory,
	@feedin_cartonqty,
	@feedin_bookweight, 
	@feedin_qtyavailable,
	@feedin_qtyonorder,
	@feedin_discount

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin --1
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',@feed_system_date,'NO ROWS to PROCESS')
end --1

while (@i_isbn<>-1 )  /* sttus 1*/
begin --2
	IF (@i_isbn<>-2) /* status 2*/
	begin --3

	
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
	select @feedin_alternatep = 0
	select @feedin_futurep  = 0
	select @feedin_canadianp  = 0
	select @feedin_cartonqty1  = 0
	select @feedin_pub  = ''
	select @feedin_ware = ''
	select @feedin_territorycode = 0
	select @feedin_weight = 0 
	select @feedin_bisacstatus_tmm = ''
	select @feedin_qtyord = 0
	select @feedin_discountcode = 0
	select @feed_isbn = RTRIM(@feedin_isbn) 

/****************************************************************************************************************/
/*** Validate ISBN's - If it's a good ISBN set @feedin_bookkey  to be used in updates otherwise output errors ***/
/****************************************************************************************************************/
	if len(@feed_isbn) = 0 /* isbn is empty*/

	 begin --4
		select @feed_isbn = 'NO ISBN'

		insert into feederror 							
			(isbn,batchnumber,processdate,errordesc)
		values (RTRIM(@feedin_isbn),'3',@feed_system_date,('NO ISBN ENTERED ' + @feedin_isbn))
			
		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='3'
				  and processdate > = @feed_system_date
				  and errordesc LIKE 'Feed Summary: Rejected%'
	 end --4	

	else  /* isbn not empty*/
begin
 	  begin --5
print @feedin_isbn
		select @feedin_count = 0
		select @feedin_count = count(*) 
			from isbn
			where isbn10 = @feedin_isbn

	     if @feedin_count = 0 -- ISBN is not in the database - generate error record
  	       begin --6
		insert into feederror 			
			(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',@feed_system_date,('ISBN NOT FOUND' + @feedin_isbn))

		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='3'
					  and processdate > = @feed_system_date
					 and errordesc LIKE 'Feed Summary: Rejected%'
               end --6
	     else -- ISBN is in the database - get bookkey
	        begin --7
		 Select @feedin_bookkey = bookkey
			from isbn
			where isbn10 = @feedin_isbn	
		end --7
	end --5
	if len(@feed_isbn) = 10
	begin --8

/**************************************************************************************/
/******************************* BISAC STATUS ***************************************/
/**************************************************************************************/

--Match stockstatus to External Code with the following exception. 
--If Items Status Code (@feedin_itemstatuscode) = CA or NO, 
--	use Item Status Code to match on External Code instead of Stock Status
		  if  @feedin_itemstatuscode in ('CA','NO')
		    begin --9	
			select @feedin_bisacstatuscode = @feedin_itemstatuscode
		    end --9
		  else 
		     begin --9.5
			select @feedin_bisacstatuscode = @feedin_stockstatuscode
		     end --9.5
		print @feedin_bisacstatuscode
		  begin --10
			/* look for value on gentables, since might not be on feedtitlestatusmap*/
			select @feedin_count = 0
			select @feedin_count = count(*) 
					from gentables
						where UPPER(externalcode)= UPPER(RTRIM(@feedin_bisacstatuscode))
							and tableid=314 
			if @feedin_count > 0 
			  begin --11
				select @feedin_bisacstatus = datacode, @feedin_bisacstatus_tmm = externalcode
					from gentables
						where UPPER(externalcode)=UPPER(RTRIM(@feedin_bisacstatuscode)) 
							and tableid=314 
			  end --11

		  end --10

		if @feedin_bisacstatus = 0
		  begin --12
			select @feedin_bisacstatus  = 0
			  insert into feederror
				(isbn,batchnumber,processdate,errordesc)
			  values (rtrim(@feedin_isbn), '3',@feed_system_date,('BISAC STATUS NOT ON GENTABLES; BISAC STATUS NOT UPDATED '+ @feedin_bisacstatuscode))
		  end --12

		if @feedin_bisacstatus > 0 
		begin --13
			select @feedin_bisacstatus_old = datacode,@feedin_pubtowebind=publishtowebind 
				from bookdetail b, isbn i,gentables g
				where i.isbn10=rtrim(@feedin_isbn) 
					and i.bookkey=b.bookkey
					and b.bisacstatuscode=g.datacode
					and tableid=314
		end --13

	
/**************************************************************************************/
/******************************* RETAIL PRICE ****************************************/
/**************************************************************************************/
		if len(RTRIM(LTRIM(@feedin_retailprice))) > 0 
		begin --14
			select @feedin_price_temp = convert(numeric,(RTRIM(LTRIM(@feedin_retailprice))))
			if @feedin_price_temp >0 
			begin --15
				select @feedin_retailp  = @feedin_price_temp
			end --15
			else 
			begin --16 	 
			  select @feedin_retailp = 0
			end --16
		end  --14

/**************************************************************************************/
/******************************* ALTERNATE PRICE ****************************************/
/**************************************************************************************/

		if len(RTRIM(LTRIM(@feedin_alternateprice))) > 0 
		begin --17
			select @feedin_price_temp = convert(numeric,(RTRIM(LTRIM(@feedin_alternateprice))))
			if @feedin_price_temp >0 
			begin --18
				select @feedin_alternatep  = @feedin_price_temp
			end --18
			else 	
			begin --19
			  select @feedin_alternatep = 0
			end --19
		end --17

/**************************************************************************************/

	
/*dates */

	/* do not like the format so no formating date go in as is
	select @feedin_pub = convert(datetime,@feedin_pubdate,110)
	select @feedin_ware = convert(datetime,@feedin_waredate,110)*/

	select @feedin_pub = @feedin_pubdate
	select @feedin_ware = @feedin_waredate

/* 10-9-00 add pubmonthcode for new titles*/
	if len(@feedin_pubdate) > 0 
	begin --20
		/*select @feedin_pubmonthcode = convert(numeric,(char,@feedin_pub,'MM')) */
		select @feedin_pubmonthcode = convert(numeric,substring(convert(char,@feedin_pub,101),1,2))
	end --20

 /* ----------------------------------------------------------------*/
/* --------------start UPDATING  existing title  record ------------*/					
 /* ----------------------------------------------------------------*/

	if @feedin_bookkey > 0 
	begin --21
/* BISAC STATUS */				
		select @feedin_count = 0 
		select @feedin_count = count(*) 
				from bookdetail
					where bookkey=@feedin_bookkey
		if @feedin_count = 0 
		begin --22
			insert into bookdetail 
			(bookkey,lastuserid,lastmaintdate)
			values (@feedin_bookkey,'ADVANTAGEFEED',@feed_system_date)
		end --22


		if @feedin_bisacstatus > 0 
		begin --23
			update feederror 
				set detailtype = (detailtype + 1)
					where batchnumber='3'
					  and processdate >= @feed_system_date
						 and errordesc LIKE 'Feed Summary: Updates%'
			

			EXEC dbo.titlehistory_insert 'BISACSTATUSCODE','BOOKDETAIL',@feedin_bookkey,0,'',@feedin_bisacstatus

			update bookdetail
				set bisacstatuscode = @feedin_bisacstatus,
				lastuserid='ADVANTAGEFEED',
				lastmaintdate = @feed_system_date
					where bookkey = @feedin_bookkey
		end --23

/*cartonqty*/
	select @feedin_count = 0
	if len(LTRIM(RTRIM(@feedin_cartonqty)))>0
	  begin --24
		select @feedin_cartonqty1 = convert(int,@feedin_cartonqty)
		select @feedin_count = count (*)  
			from bindingspecs
				where bookkey = @feedin_bookkey
					and printingkey=1
		if @feedin_count>0  		 
		  begin --25
			EXEC dbo.titlehistory_insert 'CARTONQTY1','BINDINGSPECS',@feedin_bookkey,1,'',@feedin_cartonqty1
			update bindingspecs
				set cartonqty1 = @feedin_cartonqty1,
					lastuserid='ADVANTAGEFEED',
					lastmaintdate = @feed_system_date
						where bookkey = @feedin_bookkey
						and printingkey = 1
		  end --25
		else
		   begin --26
			EXEC dbo.titlehistory_insert 'CARTONQTY1','BINDINGSPECS',@feedin_bookkey,1,'',@feedin_cartonqty1
			insert into bindingspecs 
				(bookkey,printingkey,vendorkey,cartonqty1,lastuserid,lastmaintdate)
				values (@feedin_bookkey,1,0,@feedin_cartonqty1,'ADVANTAGEFEED',@feed_system_date)
		   end --26
	  end --24
 	
/* bookweight*/
	select @feedin_count = 0

	if len(LTRIM(RTRIM(@feedin_bookweight)))>0 and @feedin_bookweight <>.00000
	 begin --27
		select @feedin_weight = LTRIM(RTRIM(@feedin_bookweight))
		select @feedin_count = count (*)  
			from booksimon
				where bookkey = @feedin_bookkey

			select @feedin_convchar = ''
			select @feedin_convchar = convert(char,@feedin_bookweight)

		if @feedin_count>0 
		  begin --28

			EXEC dbo.titlehistory_insert 'BOOKWEIGHT','BOOKSIMON',@feedin_bookkey,0,'',@feedin_convchar
			update booksimon
				set bookweight = @feedin_weight,
						lastuserid='ADVANTAGEFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
		  end --28
		else
		  begin --29
			EXEC dbo.titlehistory_insert 'BOOKWEIGHT','BOOKSIMON',@feedin_bookkey,0,'',@feedin_convchar
			insert into booksimon (bookkey,bookweight,lastmaintdate,lastuserid)
				values (@feedin_bookkey, @feedin_weight,@feed_system_date,'ADVANTAGEFEED')
		  end --29
	end --27
 
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
		  begin --30
			update bookcustom
				set customint01 = @feedin_qtyavail,
						lastuserid='ADVANTAGEFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
		  end --30
		else
		  begin --31
			insert into bookcustom (bookkey,customint01,lastmaintdate,lastuserid)
				values (@feedin_bookkey, @feedin_qtyavail,@feed_system_date,'ADVANTAGEFEED')
		  end --31
/**	end **/
	
/* topsqtyonorder -- 10-27-03 CHANGE FROM BOOKCUSTOM TO PRINTING.FIRSTPRINTQTY PRINTINGKEY=1*/
	select @feedin_count = 0

	if len(LTRIM(RTRIM(@feedin_qtyonorder)))>0 
	 begin --32
		select @feedin_qtyord= LTRIM(RTRIM(@feedin_qtyonorder))
		select @feedin_count = count (*)  
			from printing
				where bookkey = @feedin_bookkey
				   and printingkey= 1
		if @feedin_count>0 
		  begin --33
			EXEC dbo.titlehistory_insert 'FIRSTPRINTINGQTY','PRINTING',@feedin_bookkey,1,'',@feedin_qtyord
			update printing
				set firstprintingqty = @feedin_qtyord,
						lastuserid='ADVANTAGEFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
							  and printingkey = 1
		  end --33
		else
		  begin --34
			EXEC dbo.titlehistory_insert 'FIRSTPRINTINGQTY','PRINTING',@feedin_bookkey,1,'',@feedin_qtyord
			insert into printing(bookkey,printingkey,firstprintingqty,lastmaintdate,lastuserid)
				values (@feedin_bookkey,1, @feedin_qtyord,@feed_system_date,'ADVANTAGEFEED')
		  end --34
	end --32
	
/************************update titles that are not NYP***************/

/****  10-26-03 update prices and dates for all titles now
		if RTRIM(LTRIM(@feedin_bisacstatuscode)) <>'NYP' 
	 	  begin
***/

		/*retail price*/
			if len(RTRIM(LTRIM(@feedin_retailprice))) > 0 and  RTRIM(LTRIM(@feedin_retailprice))  <> '0.0000'
			begin --35
				select @feedin_count = 0   /* pricetypecode = 8, per doug*/
				select @feedin_count = count(*)
					from bookprice
						where bookkey=@feedin_bookkey
							and currencytypecode=6
								and pricetypecode=8
			select @feedin_convchar = ''
			select @feedin_convchar = convert(float,@feedin_retailprice)

			if @feedin_count > 0 
			begin --36
					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'8',@feedin_convchar
					update bookprice
						set finalprice = RTRIM(LTRIM(@feedin_retailprice)),  /*since books pub only finalprice updated*/
							lastuserid='ADVANTAGEFEED',
							lastmaintdate = @feed_system_date
								where bookkey=@feedin_bookkey
									and currencytypecode=6
									and pricetypecode=8
			end --36
			else
				begin --37
					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'QSIADMIN', 
					lastmaintdate = getdate()
	
					select @nextkey = generickey from Keys
	
					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'8',@feedin_convchar
	
					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,8,6,1,
						RTRIM(LTRIM(@feedin_retailprice)),@feed_system_date,'ADVANTAGEFEED',@feed_system_date)
				end --37
			end --35

		/*alternate price*/
			if len(RTRIM(LTRIM(@feedin_alternateprice))) > 0 and  RTRIM(LTRIM(@feedin_alternateprice))  <> '0.0000'
			begin --38
				select @feedin_count = 0   /* pricetypecode = 2*/
				select @feedin_count = count(*)
					from bookprice
						where bookkey=@feedin_bookkey
							and currencytypecode=6
								and pricetypecode=2
			select @feedin_convchar = ''
			select @feedin_convchar = convert(float,@feedin_alternateprice)

				if @feedin_count > 0 
				begin --39
					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'2',@feedin_convchar
					update bookprice
						set finalprice = RTRIM(LTRIM(@feedin_alternateprice)),  /*since books pub only finalprice updated*/
							lastuserid='ADVANTAGEFEED',
							lastmaintdate = @feed_system_date
								where bookkey=@feedin_bookkey
									and currencytypecode=6
						 			and pricetypecode=2
				end --39
				else
				begin --40
					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'QSIADMIN', 
					lastmaintdate = getdate()

					select @nextkey = generickey from Keys

					EXEC dbo.titlehistory_insert 'FINALPRICE','BOOKPRICE',@feedin_bookkey,0,'2',@feedin_convchar

					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,2,6,1,
						RTRIM(LTRIM(@feedin_alternateprice)),@feed_system_date,'ADVANTAGEFEED',@feed_system_date)
				end --40
			end --38


/*pub date*/
if len(@feedin_pubdate) > 0 
  begin --41

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
		  begin --42
			EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'8',@feedin_convchar
			
			update bookdates
				set activedate = @feedin_pub,  /*since books pub only activedate updated*/	
					lastuserid ='ADVANTAGEFEED',
					lastmaintdate=@feed_system_date
						where bookkey= @feedin_bookkey
							and printingkey=1
							and datetypecode=8
		  end --42
		else		  
		  begin --43
			EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'8',@feedin_convchar

			insert into bookdates (bookkey,printingkey,datetypecode,
				activedate,actualind,sortorder,lastuserid ,lastmaintdate)
			values (@feedin_bookkey,1,8,@feedin_pub,0,1,'ADVANTAGEFEED',@feed_system_date)
		  end --43

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
		  begin --44
				IF (@i_elementstatus<>-2) /* status 2*/
		  begin --45
			if @i_firsttime = 1 
		  begin --46
			EXEC dbo.titlehistory_insert 'ACTUALDATE','TASK',@feedin_bookkey,@i_taskkey,'8',@feedin_convchar
		  end --46
			select @i_firsttime =  @i_firsttime + 1 

	/*use printingkey for taskkey*/

				update task
				  set actualdate = @feedin_pub,  /*since books pub only activedate updated*/	
					lastuserid ='ADVANTAGEFEED',
					lastmaintdate=@feed_system_date
						where elementkey= @i_elementkey
							and taskkey = @i_taskkey
							and datetypecode=8
		end --44 (status 2)

		    FETCH NEXT FROM feed_schedules 
			INTO @i_elementkey,@i_taskkey 

		select @i_elementstatus  = @@FETCH_STATUS
	   end --45 (status 1)
	close feed_schedules
	deallocate feed_schedules
   end		

/*ware date*/
select @feedin_count = 0
if len(@feedin_waredate) > 0 
  begin --47
		select @feedin_count = count(*) 
		from bookdates
			where bookkey=@feedin_bookkey
				and printingkey=1
				and datetypecode=8

		select @feedin_convchar = ''
		select @feedin_convchar = convert(char,@feedin_ware)

	if @feedin_count > 0 
	  begin	--48	
		EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'47',@feedin_convchar
	
		update bookdates
			set activedate = @feedin_ware,  /*since books pub only activedate updated*/	
				lastuserid ='ADVANTAGEFEED',
				lastmaintdate= @feed_system_date
					where bookkey= @feedin_bookkey
						and printingkey=1
						and datetypecode=47
	  end --48
	else
	  begin --49
		EXEC dbo.titlehistory_insert 'ACTIVEDATE','BOOKDATES',@feedin_bookkey,1,'47',@feedin_convchar

		insert into bookdates (bookkey,printingkey,datetypecode,
			activedate,actualind,sortorder,lastuserid ,lastmaintdate)
		values (@feedin_bookkey,1,47,@feedin_ware,0,47,'ADVANTAGEFEED',@feed_system_date)
	  end --49
  end --47
	
/*printing */
if len(@feedin_pubdate) > 0 
  begin --50
	select @feedin_count = 0
		select @feedin_count = count(*)
				from printing
					where bookkey=@feedin_bookkey
						and printingkey=1

	if  @feedin_count > 0  
	begin --51
		EXEC dbo.titlehistory_insert 'PUBMONTHCODE','PRINTING',@feedin_bookkey,1,'',@feedin_pubmonthcode

		update printing
			set pubmonthcode = @feedin_pubmonthcode,
				pubmonth = @feedin_pub,
				lastuserid='ADVANTAGEFEED',
				lastmaintdate = @feed_system_date
					where bookkey= @feedin_bookkey
						and printingkey=1	
	 end --51
	else
	  begin --52
		EXEC dbo.titlehistory_insert 'PUBMONTHCODE','PRINTING',@feedin_bookkey,1,'',@feedin_pubmonthcode

		insert into printing (bookkey,printingkey,
			creationdate,specind,lastuserid,lastmaintdate,
			printingnum,jobnum,printingjob,pubmonth,pubmonthcode)
		values (@feedin_bookkey,1,@feed_system_date,0,'ADVANTAGEFEED',	
			@feed_system_date,1,1,'1',@feedin_pub,@feedin_pubmonthcode)
	  end --52
  end --50

/*    end  10-26-03 no longer just update only published .. update all  all updates are published only*/
end --21  /* end bookkey > 0*/

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
end --3  /* ISBN Record*/

end --2 /*isbn status 2*/

FETCH NEXT FROM feed_titles_LEA 
INTO @feedin_isbn, 
	@feedin_itemstatuscode,
	@feedin_stockstatuscode,
	@feedin_retailprice , 
	@feedin_alternateprice,
	@feedin_canadianprice,
	@feedin_futureprice, 
	@feedin_pubdate,
	@feedin_waredate,
	@feedin_territory,
	@feedin_cartonqty,
	@feedin_bookweight, 
	@feedin_qtyavailable,
	@feedin_qtyonorder,
	@feedin_discount

select @i_isbn  = @@FETCH_STATUS


end /*isbn status 1*/



/*  delete when complete since looping through cursor undo comment once finish testing*/
/* DELETE FROM feedin_titles*/

insert into feederror (batchnumber,processdate,errordesc)
 values ('3',@feed_system_date,'Titles Completed' + convert(char,getdate()))

close feed_titles_LEA
deallocate feed_titles_LEA

commit tran
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

