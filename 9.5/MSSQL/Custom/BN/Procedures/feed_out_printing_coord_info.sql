if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_printing_coord_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_printing_coord_info]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



create proc dbo.feed_out_printing_coord_info
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

**/

/* CRM 02094: modification, add media, format, cartonqty,allocation,prod manager*/
/* CRM 02440: add coordinatorroletypecode */

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @i_key int
DECLARE @feed_count int

DECLARE @feedout_coordinatorrole  varchar(40)
DECLARE @feedout_coordinatorname varchar(80)  
DECLARE @feedout_coordinatorphonebookkey varchar (40) 

DECLARE @feed_roletype  int
DECLARE @feedout_bookkey  int
DECLARE @feedout_printingkey int

DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Printings Coordinators AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnmitsprintingcoordfeed

DECLARE feedout_printingcoords INSENSITIVE CURSOR
FOR

select bn.bookkey,bn.printingkey,
	roletypecode,displayname,externalcode
			from  bnpubprintingfeedkeys bn,bookcontributor b, person p
			  where bn.bookkey=b.bookkey
				and bn.printingkey=b.printingkey 
				and b.contributorkey = p.contributorkey 
/* table above created in job scheduler*/
	
FOR READ ONLY
		
OPEN feedout_printingcoords
FETCH NEXT FROM feedout_printingcoords
	INTO @feedout_bookkey,@feedout_printingkey,@feed_roletype,@feedout_coordinatorname,
	@feedout_coordinatorphonebookkey
 
select @i_key  = @@FETCH_STATUS

if @i_key <> 0 /*no printings*/
begin	
  begin tran
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('2',@feed_system_date,'NO ROWS to PROCESS - Printings - Coordinators')
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
	select @feedout_coordinatorrole = ''
	
/*coordinator*/

	if @feed_roletype> 0 
	  begin
		select  @feedout_coordinatorrole=  datadesc
			from gentables where tableid= 285
			   and datacode=  @feed_roletype
	  end 

	
/*insert into temporary table*/
begin tran
	insert into bnmitsprintingcoordfeed (bookkey,printingkey,coordinatorrole,coordinatorname,coordinatorphonebookkey,
		coordinatorroletypecode)
	values (@feedout_bookkey ,@feedout_printingkey,@feedout_coordinatorrole,@feedout_coordinatorname, 
	@feedout_coordinatorphonebookkey, @feed_roletype)

commit tran

end /*isbn status 2*/

FETCH NEXT FROM feedout_printingcoords 
	INTO @feedout_bookkey,@feedout_printingkey,@feed_roletype,@feedout_coordinatorname,
	@feedout_coordinatorphonebookkey

select @i_key  = @@FETCH_STATUS
end /*isbn status 1*/

begin tran


/* 8-24-04 move all deletes before count*/

select @feed_count = 0

select @feed_count = count(*) from bnmitsprintingcoordfeed
if @feed_count > 0
  begin
	insert into bnmitsprintingcoordfeed(bookkey,printingkey,coordinatorrole)
	  values (0,0,'Total Records '+ convert(varchar,@feed_count))
  end	

insert into feederror (batchnumber,processdate,errordesc)
 values ('2',@feed_system_date,'Printing Coordinators out Completed')

commit tran

close feedout_printingcoords
deallocate feedout_printingcoords

select @statusmessage = 'END TMM FEED OUT Printing Coordinators AT ' + convert (char,getdate())
print @statusmessage

return 0


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO