if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_printing_qtybkdwn_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_printing_qtybkdwn_info]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




create proc dbo.feed_out_printing_qtybkdwn_info
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
DECLARE @i_key int
DECLARE @i_key2 int
DECLARE @feed_count int

DECLARE @feedout_bookkey  int
DECLARE @feedout_printingkey int
DECLARE @feedout_printingnumber varchar (25) 
DECLARE @feedout_jobnumberalpha varchar (40) 
DECLARE @feedout_outlettypecode   int 
DECLARE @feedout_outlettypeexternal   varchar (30)  
DECLARE @feedout_outlettype	varchar (120) 
DECLARE @feedout_outletcode	int 
DECLARE @feedout_outletexternal	varchar (30)
DECLARE @feedout_outletsubtype varchar (120) 
DECLARE @feedout_bkdwn_qty	int
 
DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Printings Qty Break Down AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnmitsprintingqtybreakdownfeed

DECLARE feedout_printings INSENSITIVE CURSOR
FOR

select distinct bookkey,printingkey from bnpubprintingfeedkeys

/* table above created in job scheduler*/
	
FOR READ ONLY
	
select @feed_count = 0

		
OPEN feedout_printings
FETCH NEXT FROM feedout_printings
	INTO @feedout_bookkey, @feedout_printingkey
 
select @i_key  = @@FETCH_STATUS

if @i_key <> 0 /*no breakdown*/
begin	
  begin tran
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('2',@feed_system_date,'NO ROWS to PROCESS - Printings-Qty Break Down')
  commit tran
end

while (@i_key<>-1 )  /* status 1*/
begin
	IF (@i_key<>-2) /* status 2*/
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

	select @feed_count = 0
	
	select @feedout_printingnumber = ''
	select @feedout_jobnumberalpha = ''
	

	select @feed_count = 0
	select @feed_count  = count(*)
		from printing where
		 bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey
	
	if @feed_count > 0
	  begin
		select @feedout_printingnumber = printingnum
			from printing where
			  bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey

		select @feedout_jobnumberalpha = jobnumberalpha
			FROM printing
			 WHERE bookkey = @feedout_bookkey
			AND  printingkey = @feedout_printingkey 

/* do all components in cursor*/

		DECLARE feedout_qtybkdwn INSENSITIVE CURSOR
		  FOR		
			select qtyoutletcode,qtyoutletsubcode,qty from bookqtybreakdown
			  where bookkey = @feedout_bookkey and printingkey= @feedout_printingkey
		FOR READ ONLY

		OPEN feedout_qtybkdwn
			FETCH NEXT FROM feedout_qtybkdwn
				INTO @feedout_outlettypecode,@feedout_outletcode,@feedout_bkdwn_qty

 		select @i_key2  = @@FETCH_STATUS

		while (@i_key2<>-1 )  /* status 1*/
		  begin
			IF (@i_key2<>-2) /* status 2*/
			  begin

				select @feedout_outlettype = '' 
				select @feedout_outletsubtype  = ''
				select @feedout_outlettypeexternal = ''
				select @feedout_outletexternal = ''

				if @feedout_outlettypecode > 0 
				  begin
					select @feedout_outlettype = datadesc,@feedout_outlettypeexternal = externalcode
					 from gentables
					   where tableid = 527 and datacode = @feedout_outlettypecode
				  end

				if @feedout_outlettypecode > 0 and @feedout_outletcode > 0
				  begin
					select @feedout_outletsubtype = datadesc , @feedout_outletexternal = externalcode
					from subgentables
					   where tableid = 527 and datacode = @feedout_outlettypecode
						and  datasubcode = @feedout_outletcode
				  end



/***************************   warning messages  comment for now   
begin tran

				if @feedout_printingnumber is null  
				  begin
					select @feedout_printingnumber = ''
	 			 end
				if datalength(@feedout_printingnumber) = 0
				  begin
					insert into feederror 										
					(isbn,batchnumber,processdate,errordesc)
					  values (@feedout_isbn10,'2',@feed_system_date,'Printing Qty break down-- warning printingnumber missing')
				  end
	
				if @feedout_jobnumberalpha is null  
	 			 begin
					select @feedout_jobnumberalpha = ''
	 			 end

				if datalength(@feedout_jobnumberalpha) = 0
				  begin
					insert into feederror 										
					(isbn,batchnumber,processdate,errordesc)
					  values (@feedout_isbn10,'2',@feed_system_date,'Printing Qty break down-- warning jobnumberalpha missing')
				  end

		
				if @feedout_outlettypecode is null  
	 			 begin
					select @feedout_outlettypecode = 0
	 			 end

				if@feedout_outlettypecode > 0
				  begin
					insert into feederror 										
					(isbn,batchnumber,processdate,errordesc)
					  values (@feedout_isbn10,'2',@feed_system_date,'Printing Qty break down-- warning outlet type desc missing')
				  end
commit tran

***************************/
	
/*insert into temporary table*/
begin tran
			insert into bnmitsprintingqtybreakdownfeed (bookkey,printingkey,printingnumber,
				jobnumberalpha,outlettypecode,outlettype,outletcode,outletsubtype,qty,
				 mitsoutlettypecode, mitsoutletcode)
			values (@feedout_bookkey ,@feedout_printingkey,@feedout_printingnumber,
			  @feedout_jobnumberalpha,@feedout_outlettypecode,@feedout_outlettype,@feedout_outletcode,
				@feedout_outletsubtype,@feedout_bkdwn_qty,
				@feedout_outlettypeexternal, @feedout_outletexternal)
commit tran

		end /*comp status 2*/

			FETCH NEXT FROM feedout_qtybkdwn
				INTO @feedout_outlettypecode,@feedout_outletcode,@feedout_bkdwn_qty

 		select @i_key2  = @@FETCH_STATUS
	    end  /*comp status 1*/

		close feedout_qtybkdwn
		deallocate feedout_qtybkdwn
  
	  end /*printing >0*/

	end /*print comp status 2*/
	 
	FETCH NEXT FROM feedout_printings
		INTO @feedout_bookkey, @feedout_printingkey
 
	select @i_key  = @@FETCH_STATUS
	
end /*print comp 1*/

begin tran

select @feed_count = 0

select @feed_count = count(*) from bnmitsprintingqtybreakdownfeed
if @feed_count > 0
  begin
	insert into bnmitsprintingqtybreakdownfeed(bookkey,printingkey,printingnumber)
	  values (0,0,'Total Records '+ convert(varchar,@feed_count))
  end

if @feed_count = 0
  begin
	insert into bnmitsprintingqtybreakdownfeed(bookkey,printingkey,printingnumber)
	  values (0,0,'Total Records '+ '0')
  end


insert into feederror (batchnumber,processdate,errordesc)
 values ('2',@feed_system_date,'Printings Qty Break Down Completed')

commit tran

close feedout_printings
deallocate feedout_printings

select @statusmessage = 'END TMM FEED OUT Printings Qty Break Down AT ' + convert (char,getdate())
print @statusmessage

return 0



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

