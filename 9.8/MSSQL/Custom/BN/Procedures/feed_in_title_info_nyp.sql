set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER proc [dbo].[feed_in_title_info_nyp] 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

/*2-19-04 change titlehistory_insert parameter from tablename,columnname to columnkey*/
/*CRM 7-22-04 01594 add feedin_vista_exclude isbn table-- remove titles that should not be updated with this feed*/
/* 7-26-04  UPDATE NYP title prices only*/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @bookwasupdatedind int

DECLARE @feedin_bookkey  int
DECLARE @feedin_authorkey  int

DECLARE @feedin_isbn  varchar(10)
DECLARE @feedin_bisacstatuscode varchar(10)
DECLARE @feedin_retailprice  varchar(20)
DECLARE @feedin_canadianprice varchar(20)
DECLARE @feedin_pubdate	varchar(20)
DECLARE @feedin_reldate varchar(20)
DECLARE @feedin_categorycode   varchar(20)
DECLARE @feedin_cartonqty  varchar(20)
DECLARE @feedin_canadianrestriction  varchar(20)
DECLARE @feedin_projectisbn  varchar (20)
DECLARE @feedin_qtyavailable  varchar(20)

DECLARE @feedin_canadianrestrictcode  int
DECLARE @feedin_canrestrictcode_old  int
DECLARE @feed_isbn  varchar (13)
DECLARE @feedin_title  varchar (80)
DECLARE @feedin_shorttitle varchar (24)
DECLARE @feedin_subtitle varchar (255)
DECLARE @feedin_authorlast varchar (25)
DECLARE @feed_prepackind char(1) 
DECLARE @feedin_temp_isbn varchar(8)
DECLARE @feedin_isbn_prefix int
DECLARE @feedin_pubmonthcode int
DECLARE @feedin_price_temp  numeric(9,2)
DECLARE @feedin_retailp numeric(9,2) 
DECLARE @feedin_canadianp numeric(9,2)
DECLARE @feedin_retailprice_old numeric(9,2) 
DECLARE @feedin_canadianprice_old numeric(9,2)
DECLARE @feedin_cartonqty1 int 
DECLARE @feedin_cartonqty_old int
DECLARE @feedin_pubtowebind   tinyint
DECLARE @feedin_pub	datetime
DECLARE @feedin_rel	datetime
DECLARE @feedin_pub_old	datetime
DECLARE @feedin_rel_old	datetime
DECLARE @currentpubmonth	datetime
DECLARE @titlehistory_newvalue varchar (100)
DECLARE @feedin_NCRcode  int
DECLARE @feedin_publishedcode  int
DECLARE @feedin_publisheddesc  varchar (100)
DECLARE @feedin_i_qtyavailable int
DECLARE @feedin_i_receivedwarehouseind int
DECLARE @feedin_opexhaustedind int

DECLARE @feedin_bisacstatus int
DECLARE @feedin_titlestatuscode_old int
DECLARE @feedin_pubstring  varchar(11)
DECLARE @feedin_bisacstatus_old int 
DECLARE @feedin_count int
DECLARE @i_isbn int
DECLARE @i_seasonkey int
DECLARE @i_updateprices int
DECLARE @d_begindate datetime
DECLARE @feedin_tableid int
DECLARE @nextkey  int
DECLARE @eloquenceind tinyint
DECLARE @c_message  varchar(255)

DECLARE @edistatuscode int

select @statusmessage = 'BEGIN VISTA FEED IN AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0
select @feedin_NCRcode=0
select @feedin_publishedcode=0

select @edistatuscode = 0

SELECT @feed_system_date = getdate()

/* run titles feed from here */
insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Inserts',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values('3',@feed_system_date,'Feed Summary: Updates',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('3',@feed_system_date,'Feed Summary: Rejected',0)


select  @feedin_publishedcode = datacode, @feedin_publisheddesc=datadesc
from gentables
where tableid= 149
and  externalcode = 'PUBLISHED'
			
if @feedin_publishedcode = 0 or @feedin_publishedcode is null
begin
	insert into feederror 										
	(isbn,batchnumber,processdate,errordesc)
	values (@feedin_isbn,'3',@feed_system_date,'No Internal Status with External code = PUBLISHED')
end

select  @feedin_NCRcode = datacode
from gentables
where tableid= 428
and  externalcode = 'NCR'

if @feedin_NCRcode = 0 or @feedin_NCRcode is null
begin
	insert into feederror 										
	(isbn,batchnumber,processdate,errordesc)
	values (@feedin_isbn,'3',@feed_system_date,'No Canadian Restriction with External code = NCR')
end


DECLARE feed_titles INSENSITIVE CURSOR
FOR

select  rtrim(ltrim (t.isbn)), 
	rtrim(ltrim (bisacstatuscode)),
	rtrim(ltrim (retailprice )), 
	rtrim(ltrim (canadianprice)), 
	rtrim(ltrim (categorycode)),
	rtrim(ltrim (pubdate)),
	rtrim(ltrim (reldate)),
	rtrim(ltrim (cartonqty)), 
	rtrim(ltrim (canadianrestriction)),
	rtrim(ltrim (projectisbn)),
	rtrim(ltrim (qtyavailable)),
	opexhaustedind

from feedin_titles t, isbn i
where i.isbn10 = t.isbn and t.isbn not in (select isbn from feedin_vista_exclude)
 and t.bisacstatuscode='NYP'
	order by t.isbn

FOR READ ONLY
		
OPEN feed_titles 

FETCH NEXT FROM feed_titles 
INTO @feedin_isbn, 
	@feedin_bisacstatuscode,
	@feedin_retailprice , 
	@feedin_canadianprice, 
	@feedin_categorycode,
	@feedin_pubdate,
	@feedin_reldate,
	@feedin_cartonqty, 
	@feedin_canadianrestriction,
	@feedin_projectisbn,
	@feedin_qtyavailable,
	@feedin_opexhaustedind

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'3',@feed_system_date,'NO ROWS to PROCESS')
end

while (@i_isbn<>-1 )  /* status 1*/
begin
	IF (@i_isbn<>-2) /* status 2*/
	begin

	BEGIN tran 
	/** Increment Title Count, Print Status every 500 rows **/
	select @titlecount=@titlecount + 1
	select @titlecountremainder=0
	select @titlecountremainder = @titlecount % 500
	if(@titlecountremainder = 0)
	begin
		select @titlestatusmessage =  convert (varchar (50),getdate()) + '   ' + convert (varchar (10),@titlecount) + '   Rows Processed'
		print @titlestatusmessage
		insert into feederror 										
			(isbn,batchnumber,processdate,errordesc)
			values (@feedin_isbn,'3',@feed_system_date,@titlestatusmessage)
	end 
	
	select @bookwasupdatedind = 0
	select @feedin_bisacstatus = 0
	select @feedin_count = 0
	select @feedin_isbn_prefix = 0
	select @feedin_price_temp = 0
	select @feedin_bookkey = 0
	select @feedin_authorkey = 0
	select @feedin_pubstring  =''
	select @feed_isbn  = ''
	select @feedin_title  = ''
	select @feedin_shorttitle = ''
	select @feedin_subtitle = ''
	select @feedin_authorlast = ''
	select @feedin_temp_isbn = ''
	select @feedin_price_temp = 0
	select @feedin_pubmonthcode = 0
	select @feedin_canadianrestrictcode = 0
	select @feedin_canrestrictcode_old = 0
	select @feedin_bisacstatus_old = 0
	select @feedin_retailp  = 0
	select @feedin_canadianp  = 0
	select @feedin_retailprice_old  = 0
	select @feedin_canadianprice_old  = 0
	select @feedin_cartonqty1  = 0
	select @feedin_cartonqty_old  = 0
	select @feedin_pub  = ''
	select @feedin_rel = ''
	select @feedin_pub_old  = ''
	select @feedin_rel_old = ''
	select @feedin_i_qtyavailable  = 0
	select @feedin_i_receivedwarehouseind=0
	select @i_updateprices = 1

	select @feed_isbn = @feedin_isbn

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

	/** 1-8-04 do not need since all isbns on isbn table
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
**/
	

	select @feedin_bookkey = bookkey , @feed_isbn = isbn 
	from isbn 
	where isbn10= @feedin_isbn

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

		
	if len(@feed_isbn) = 13 
	begin

/*------------- intialize data for new or old ---------*/

/*bisacstatus*/

	select @feedin_count = 0

		select @feedin_count = count(*)
		from gentables
		where externalcode=@feedin_bisacstatuscode
		and tableid=314 

		if @feedin_count > 0 
		begin
			select @feedin_bisacstatus  = datacode
			from gentables
			where externalcode=@feedin_bisacstatuscode
			and tableid=314 
		end
		else
		begin
			insert into feederror 
				(isbn,batchnumber,processdate,errordesc)
			values  (@feedin_isbn, '3',@feed_system_date,('BISAC STATUS NOT ON GENTABLES; BISAC STATUS NOT UPDATED ' + @feedin_bisacstatuscode))
		end 



		
/* prices*/


		if len(@feedin_retailprice) > 0 
		begin
			select @feedin_price_temp = convert(float,@feedin_retailprice)
			if @feedin_price_temp >0 
			begin
				select @feedin_retailp  = @feedin_price_temp
			end
			else 	
			begin 
			  select @feedin_retailp = 0
			end 
		end 

		select @feedin_price_temp = 0

		if len(@feedin_canadianprice) > 0 
		begin
			select @feedin_price_temp = convert(float,@feedin_canadianprice)
			if @feedin_price_temp >0 
			begin
				select @feedin_canadianp   = @feedin_price_temp
			end 
			else 
			begin
			  select @feedin_canadianp = 0
			end
		end
		
		/** Check Seasonkey - we will not update any prices 
			for active titles in future seasons to prevent
			Vista overwriting ReIssued Titles with old prices
			after they have been modified in Title Management.
			As soon as the season becomes current, Vista will
			take over again. THIS ONY APPLIES TO ACTIVE TITLES
			WHICH ARE REISSUED INTO A NEW SEASON - ALL NYP TILES
			DO NOT HAVE TITLE MANAGEMENT PRICES OVERWRITTEN BY VISTA
			DSL 2/19/2003 - Per Adria D.**/ 
		select @i_seasonkey = seasonkey 
		from printing 
		where bookkey=@feedin_bookkey and printingkey = 1

		if @i_seasonkey > 0
		begin
			select @d_begindate=begindate from season
			where seasonkey = @i_seasonkey

			
			if @d_begindate > getdate()
			begin
				select @i_updateprices = 0
			end
			else
			begin
				select @i_updateprices = 1
			end
		end

		
		
/*dates */

	/* do not like the format so no formating date go in as is
	select @feedin_pub = convert(datetime,@feedin_pubdate,'MM/DD/YYYY')
	select @feedin_rel = convert(datetime,@feedin_reldate,'MM/DD/YYYY')*/

	select @feedin_pub = convert(datetime,@feedin_pubdate,110)
	select @feedin_rel = convert(datetime,@feedin_reldate,110)

/* 10-9-00 add pubmonthcode for new titles*/
	if len(@feedin_pubdate) > 0 
	begin
		/*select @feedin_pubmonthcode = convert(numeric,(char,@feedin_pub,'MM')) */
		select @feedin_pubmonthcode = convert(numeric,substring(convert(char,@feedin_pub,101),1,2))
	end

/* canadian restrictionrictions*/
	select @feedin_count = 0


   if len(@feedin_canadianrestriction) > 0 
   begin

		select @feedin_count = count(*)
		from gentables
		where tableid = 428
		and externalcode = convert(char,@feedin_canadianrestriction)	

		if @feedin_count > 0 
		  begin

			select  @feedin_canadianrestrictcode = datacode
			from gentables
			where tableid= 428
			and  externalcode = convert(char,@feedin_canadianrestriction)
		 end
		 else   
		  begin	

			select @feedin_tableid = 428
			select @feedin_canadianrestriction = @feedin_canadianrestriction
			EXEC feed_insert_gentables @feedin_tableid,@feedin_canadianrestriction, @feedin_canadianrestrictcode  OUTPUT
			/*select @feedin_canadianrestrictcode = convert(int,@feedin_canadianrestriction)*/
		 end
   end


/* --------------start updating existing title  record ------------*/					
	if @feedin_bookkey > 0 
	begin
				
/* ------------------start updating tables------------------*/

/**********************update titles that are ACTIVE ***************/

		if @feedin_bisacstatuscode ='NYP' 
		begin


/*retail price*/


		   if @feedin_retailp > 0 @i_updateprices =1
			begin

	          		select @feedin_count = 0   /* list price code is datacode 8, per doug*/
		
                   		select @feedin_count = count(*)
		   		from bookprice
		   		where bookkey=@feedin_bookkey
		   		and currencytypecode=6
		  	 	and pricetypecode=8

				if @feedin_count > 0 
				begin
					
					select @feedin_retailprice_old = finalprice
		   			from bookprice
		   			where bookkey=@feedin_bookkey
		   			and currencytypecode=6
		   			and pricetypecode=8
					


					if @feedin_retailp <> @feedin_retailprice_old
					begin
						select @bookwasupdatedind=1
						EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'6',@feedin_retailprice
					
						update bookprice
						set finalprice = @feedin_retailp,  
						lastuserid='VISTAFEED',
						lastmaintdate = @feed_system_date
						where bookkey=@feedin_bookkey
						and currencytypecode=6
						and pricetypecode=8
					end
				end
				else /** No Retail price row on bookprice, so insert **/
				begin
					select @bookwasupdatedind=1

					UPDATE keys SET generickey = generickey+1, 
					 lastuserid = 'QSIADMIN', 
					lastmaintdate = getdate()

					select @nextkey = generickey from Keys
					
					EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'6',@feedin_retailprice
					
					insert into bookprice  (pricekey,bookkey,pricetypecode,
						currencytypecode,activeind,finalprice,
						effectivedate,lastuserid,lastmaintdate)
					values (@nextkey,@feedin_bookkey,8,6,1,
						@feedin_retailp,@feed_system_date,'VISTAFEED',@feed_system_date)
				end
			end
/*canada*/
				/***********************************************************************************/
				/***** 10/18/07 KB if a title does not have Canadian rights it is not updated ******/
				/***** with a Canadian price from the vista feed. CRM# 4717                   ******/
				/***********************************************************************************/
				if @feedin_canadianrestrictcode > 0 
				begin
					select @feedin_canrestrictcode_old = canadianrestrictioncode
					from bookdetail
					where bookkey=@feedin_bookkey
					
					if (@feedin_canrestrictcode_old is null)
					begin
						 select @feedin_canrestrictcode_old = 0
					end
				end
			
				if (@feedin_canadianrestrictcode <> @feedin_NCRcode) AND (@feedin_canrestrictcode_old <> @feedin_NCRcode)
				begin
					if @feedin_canadianp > 0 and @i_updateprices =1 
					begin
		
		
						select @feedin_count = 0
						select @feedin_count = count(*)
						from bookprice
						where bookkey=@feedin_bookkey
						and currencytypecode=11
						and pricetypecode=8
						
						/** Check to see if Canadian Price exists **/
						if @feedin_count>0  
						begin
							select @feedin_canadianprice_old = finalprice
								from bookprice
								where bookkey=@feedin_bookkey
								and currencytypecode=11
								and pricetypecode=8
		
							/** Only update if price is different **/
							if @feedin_canadianp <> @feedin_canadianprice_old
							begin
								select @bookwasupdatedind=1
		
								EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'11',@feedin_canadianprice
							
								update bookprice
								set finalprice = @feedin_canadianp,  
								lastuserid='VISTAFEED',
								lastmaintdate = @feed_system_date
								where bookkey= @feedin_bookkey
								and currencytypecode=11
								and pricetypecode=8
							end
						end
					else
					begin
						select @bookwasupdatedind=1
							
						EXEC dbo.titlehistory_insert 9,@feedin_bookkey,0,'11',@feedin_canadianprice
							
						select @nextkey = 0
		
						UPDATE keys SET generickey = generickey+1, 
						lastuserid = 'QSIADMIN', 
						lastmaintdate = getdate()
		
						select @nextkey = generickey from Keys
		
						insert into bookprice (pricekey,bookkey,pricetypecode,
							currencytypecode,activeind,finalprice,effectivedate,lastuserid,lastmaintdate)
							values (@nextkey,@feedin_bookkey,8,11,1,convert (float,RTRIM(LTRIM(@feedin_canadianprice))),@feed_system_date,'VISTAFEED',@feed_system_date)
					end
				end
			end
         end /* all updates are NYP only*/
	end   /* end bookkey > 0*/

/* add publish to web indicator if title currently go web trigger status change*/
	/*if @feedin_bisacstatus_old <> @feedin_bisacstatus and @feedin_pubtowebind> 0 
	begin*/
	/*	trigger whatever to the web*/
/*	end if*/
end /* isbn 13 */

/* new title ----------------------------------------------------------*/

	if @feedin_bookkey = 0 
	begin  /* do not output this error since there are over 30,000 plus titles not in tmm*/
	/*	insert into feederror */
	/*		(isbn,batchnumber,processdate,errordesc)*/
	/*	values (rtrim(@feedin_isbn),'3',@feed_system_date,('Titles does not exists in TMM ' + rtrim(@feedin_isbn)))*/

		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='3'
					  and processdate >= @feed_system_date
					 and errordesc LIKE 'Feed Summary: Rejected%'
	end /* bookkey =0 new title */
end  /* ISBN Record*/

if @bookwasupdatedind=1 /** Output the Necessary Update Flags**/
begin
	update feederror 
	set detailtype = detailtype + 1
	where batchnumber='3'
	and processdate >= @feed_system_date
	and errordesc LIKE 'Feed Summary: Updates%'

	/** Datawarehouse Update **/
	select  @feedin_count = count(*) 
	from bookwhupdate 
	where bookkey = @feedin_bookkey

	if @feedin_count = 0 
	begin
		insert into bookwhupdate 
		(bookkey,lastmaintdate,lastuserid)
		values (@feedin_bookkey,getdate(),'VISTAFEED')
	end

	/** Eloquence Update **/

 /** update the record for the title - although it may not exist **/
	select 	@feedin_count = 0 

	select @feedin_count = count(*) from bookedipartner
		where bookkey =@feedin_bookkey

	if @feedin_count > 0 
	begin
      select @edistatuscode = edistatuscode
        from bookedistatus
       where bookkey =@feedin_bookkey
      
      /** Do not send to eloquence if edistatuscode = 7 (Do Not Send) or 8 (Never Send)  **/
		IF (@edistatuscode not in (7,8))   
      begin
			update bookedipartner 
				set sendtoeloquenceind=1,
				lastuserid='VISTAFEED',
				lastmaintdate = @feed_system_date
					where bookkey=@feedin_bookkey
      end
	end


end 
commit tran
end /*isbn status 2*/

FETCH NEXT FROM feed_titles 
INTO @feedin_isbn, 
	@feedin_bisacstatuscode,
	@feedin_retailprice , 
	@feedin_canadianprice, 
	@feedin_categorycode,
	@feedin_pubdate,
	@feedin_reldate,
	@feedin_cartonqty, 
	@feedin_canadianrestriction,
	@feedin_projectisbn,
	@feedin_qtyavailable,
	@feedin_opexhaustedind

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/



/*  delete when complete since looping through cursor undo comment once finish testing*/
/* DELETE FROM feedin_titles*/

insert into feederror (batchnumber,processdate,errordesc)
 values ('3',@feed_system_date,'Titles Completed')


close feed_titles
deallocate feed_titles

select @statusmessage = 'END VISTA FEED IN AT ' + convert (char,getdate())
print @statusmessage

return 0



