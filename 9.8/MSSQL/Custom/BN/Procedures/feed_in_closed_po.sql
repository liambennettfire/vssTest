if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_in_closedpo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_in_closedpo]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


ALTER  proc dbo.feed_in_closedpo
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
DECLARE @err_msg varchar (100)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @feed_system_date datetime

DECLARE @feedin_bookkey  int

DECLARE @feedin_isbn  varchar(10)
DECLARE @feedin_ponumber varchar(10)
DECLARE @feedin_jobno varchar(10)
DECLARE @feedin_ordqty varchar(10)
DECLARE @feedin_recqty varchar(10)
DECLARE @feedin_dateord	varchar(20)
DECLARE @feedin_datedue varchar(20)
DECLARE @feedin_cmpflag  char(1)
DECLARE @feedin_datecomp  varchar(20)
DECLARE @feedin_lastdelref varchar(10)
DECLARE @feedin_lastdelno  varchar (10)
DECLARE @feedin_smref char(1)

DECLARE @d_orddate	datetime
DECLARE @d_duedate	datetime
DECLARE @d_compdate datetime
DECLARE @i_isbn int
DECLARE @feedin_count int
DECLARE @feed_isbn  varchar (13)
DECLARE @feedin_temp_isbn varchar(8)
DECLARE @feedin_isbn_prefix int
DECLARE @feedin_printingkey int
DECLARE @i_statuscode int
DECLARE @i_qtyrecv int

select @statusmessage = 'BEGIN VISTA FEED IN CLOSED PO AT ' + convert (char,getdate())
print @statusmessage


SELECT @feed_system_date = getdate()

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('4',@feed_system_date,'Feed Summary: Inserts',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values('4',@feed_system_date,'Feed Summary: Updates',0)

insert into feederror (batchnumber,processdate,errordesc,detailtype)
     	 values ('4',@feed_system_date,'Feed Summary: Rejected',0)

DECLARE feed_closedpo INSENSITIVE CURSOR
FOR

select  rtrim(ltrim (t.isbn)), 
	rtrim(ltrim (ponumber)),
	rtrim(ltrim (jobno)), 
	rtrim(ltrim (ordqty)), 
	rtrim(ltrim (recqty)),
	rtrim(ltrim (dateord)),
	rtrim(ltrim (datedue)),
	rtrim(ltrim (cmpflag)), 
	rtrim(ltrim (datecomp)),
	rtrim(ltrim (lastdelref)),
	rtrim(ltrim (lastdelno)),
	rtrim(ltrim (smref)) 

from feedin_closedpo t, isbn i
where i.isbn10 = t.isbn
	order by t.isbn

FOR READ ONLY
		
OPEN feed_closedpo 

FETCH NEXT FROM feed_closedpo 
INTO @feedin_isbn, 
	@feedin_ponumber,
	@feedin_jobno , 
	@feedin_ordqty, 
	@feedin_recqty,
	@feedin_dateord,
	@feedin_datedue,
	@feedin_cmpflag, 
	@feedin_datecomp,
	@feedin_lastdelref,
	@feedin_lastdelno,
	@feedin_smref

select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedin_isbn,'4',@feed_system_date,'NO ROWS to PROCESS CLOSED PO FEED')
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
			values (@feedin_isbn,'4',@feed_system_date,@titlestatusmessage)
	end 
	
	select @feedin_count = 0
	select @feedin_bookkey = 0
	select @feed_isbn  = ''
	select @d_orddate  = ''
	select @d_duedate= ''
	select @d_compdate = ''
	select @feedin_temp_isbn = ''
 	select @feedin_isbn_prefix = 0
	select @feedin_printingkey = 0
	select @i_statuscode = 0
	select @i_qtyrecv = 0
	
	select @feedin_bookkey = bookkey,@feed_isbn=isbn
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

/*get printingkey*/

	select @feedin_count = 0
	if @feedin_bookkey > 0
	  begin
		if isnumeric(@feedin_ponumber) = 1 
		  begin
			select @feedin_count = count(*)
					from gposection g ,gpo gp
					where g.gpokey=gp.gpokey
						and g.key1 = @feedin_bookkey
						and convert(int,ltrim(rtrim(gp.gponumber))) = convert(int,@feedin_ponumber)
		  end
		 else
		 begin
		/*	select @feedin_count = count(*)
					from gposection g ,gpo gp
					where g.gpokey=gp.gpokey
						and g.key1 = @feedin_bookkey
						and ltrim(rtrim(gp.gponumber)) = @feedin_ponumber */
		/* 4/5/05 - KB - For XPOs */
			select @feedin_count = count(*)
					from gposection g ,gpo gp
					where g.gpokey=gp.gpokey
						and g.key1 = @feedin_bookkey
						and ltrim(rtrim(g.xpolineponbr)) = @feedin_ponumber
		 end 
		if @feedin_count > 0 
		begin
			if isnumeric(@feedin_ponumber) = 1 
			begin
				select @feedin_printingkey = key2
					from gposection g ,gpo gp
						where g.gpokey=gp.gpokey
							and g.key1 = @feedin_bookkey
							and convert(int,ltrim(rtrim(gp.gponumber))) = convert(int,@feedin_ponumber)
							group by key2
			end
			else
			begin
				select @feedin_printingkey = key2
					from gposection g ,gpo gp
					where g.gpokey=gp.gpokey
						and g.key1 = @feedin_bookkey
						and ltrim(rtrim(g.xpolineponbr)) = @feedin_ponumber
			end
		end
		else
		begin
			insert into feederror 
				(isbn,batchnumber,processdate,errordesc)
			values  (@feedin_isbn, '4',@feed_system_date,('NO PRINTINGKEY ON GPO and GPOSECTION TABLES FOR BOOKKEY ' + convert(varchar,@feedin_bookkey) +
						' AND PONUMBER ' + @feedin_ponumber ))
		end 
	  end 


/* --------------start updating existing title  printing record ------------*/
/* ----- 4/5/05 - KB - added the condition to only update if compflag = 'Y'-*/					
	if @feedin_bookkey > 0 and @feedin_printingkey > 0
	begin
      if @feedin_cmpflag = 'Y' 
      begin

			select @i_statuscode = statuscode
				from printing
				where bookkey = @feedin_bookkey
					and printingkey = @feedin_printingkey

			if @i_statuscode is null  /*if not 4 then set printing.statuscode= 4 later*/
		   begin
				select @i_statuscode = 0
			end
				
			if len(@feedin_recqty) > 0 
			begin
				select @i_qtyrecv = convert(int,@feedin_recqty)
			end
					
			if len(@feedin_datecomp ) > 0 
			begin
				select @d_compdate = convert(datetime,@feedin_datecomp ,110)
			end

			if @i_statuscode <> 4 /* if not 4 then set printing.statuscode= 4 */
			  begin
			/*EXEC dbo.titlehistory_insert 'QTYRECEIVED','PRINTING',@feedin_bookkey,@feedin_printingkey,'',@i_qtyrecv -- no history yet*/
			/*EXEC dbo.titlehistory_insert 'PRINTINGCLOSEDDATE','PRINTING',@feedin_bookkey,@feedin_printingkey,'',@d_compdate -- no history yet*/
	
				update printing
					set statuscode = 4,
						qtyreceived  = @i_qtyrecv,
						printingcloseddate = @d_compdate,
						lastuserid = 'CLOSEDPOFEED',
						lastmaintdate = @feed_system_date
							where bookkey = @feedin_bookkey
							  and printingkey= @feedin_printingkey
			  end
		end
		/* else
		  begin

		/*EXEC dbo.titlehistory_insert 'QTYRECEIVED','PRINTING',@feedin_bookkey,@feedin_printingkey,'',@i_qtyrecv -- no history yet*/
		/*EXEC dbo.titlehistory_insert 'PRINTINGCLOSEDDATE','PRINTING',@feedin_bookkey,@feedin_printingkey,'',@d_compdate -- no history yet*/

			update printing
				set qtyreceived  = @i_qtyrecv,
					printingcloseddate = @d_compdate,
				 	lastuserid = 'CLOSEDPOFEED',
					lastmaintdate = @feed_system_date
						where bookkey = @feedin_bookkey
					 	  and printingkey= @feedin_printingkey
	 	 end */
	
		update feederror 
			set detailtype = detailtype + 1
				where batchnumber='4'
					and processdate >= @feed_system_date
					and errordesc LIKE 'Feed Summary: Updates%'



	end   /* end bookkey and printingkey > 0*/
end /* isbn 13 */

/* new title ----------------------------------------------------------*/

	if @feedin_bookkey = 0 
	begin  /* do not output this error since there are over 30,000 plus titles not in tmm*/
		update feederror 
			set detailtype = (detailtype + 1)
				where batchnumber='4'
					  and processdate >= @feed_system_date
					 and errordesc LIKE 'Feed Summary: Rejected%'
	end /* bookkey =0 new title */
commit tran
end /*isbn status 2*/

FETCH NEXT FROM feed_closedpo 
INTO @feedin_isbn, 
	@feedin_ponumber,
	@feedin_jobno , 
	@feedin_ordqty, 
	@feedin_recqty,
	@feedin_dateord,
	@feedin_datedue,
	@feedin_cmpflag, 
	@feedin_datecomp,
	@feedin_lastdelref,
	@feedin_lastdelno,
	@feedin_smref

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/

insert into feederror (batchnumber,processdate,errordesc)
 values ('4',@feed_system_date,'Closed PO Feed Completed')

close feed_closedpo 
deallocate feed_closedpo 

select @statusmessage = 'END VISTA FEED IN CLOSED PO AT ' + convert (char,getdate())
print @statusmessage

return 0



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

