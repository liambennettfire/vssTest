if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_author_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_author_info]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

create proc dbo.feed_out_author_info 
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

DECLARE @feedout_bookkey  int
DECLARE @feedout_authorkey varchar(10)
DECLARE	@feedout_lastname varchar (75)
DECLARE	@feedout_firstname varchar (75)
DECLARE	@feedout_middlename varchar (75)
DECLARE @feedout_suffix varchar (75)
DECLARE @feedout_degree varchar (75)
DECLARE @feedout_sortorder int
DECLARE @feedout_primary varchar (1)
DECLARE @feedout_authortype varchar (40)
DECLARE @feedout_authorlastuserid varchar (30)
DECLARE @feedout_authorlastmaintdate datetime
DECLARE @feedout_bookauthorlastuserid varchar (30)
DECLARE @feedout_bookauthorlastmaintdate datetime

DECLARE @feed_authortypecode  int
DECLARE @feed_primary int

DECLARE @feed_count int


DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Author AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnmitstitleauthorfeed

DECLARE feedout_authors INSENSITIVE CURSOR
FOR
select ba.bookkey,a.authorkey,lastname,firstname,middlename, authorsuffix,authordegree,
	authortypecode,ba.sortorder,ba.primaryind, ba.lastuserid, ba.lastmaintdate, a.lastuserid, a.lastmaintdate
	from bnmitstitlefeed b,bookauthor ba,author a, isbn i
		where b.bookkey=i.bookkey and b.bookkey = ba.bookkey and ba.authorkey=a.authorkey
FOR READ ONLY
	

		
OPEN feedout_authors 

FETCH NEXT FROM feedout_authors 
	INTO @feedout_bookkey,@feedout_authorkey,@feedout_lastname,@feedout_firstname,@feedout_middlename,
		@feedout_suffix,@feedout_degree,@feed_authortypecode,@feedout_sortorder,@feed_primary,
		@feedout_bookauthorlastuserid, @feedout_bookauthorlastmaintdate, @feedout_authorlastuserid,
		@feedout_authorlastmaintdate
 
select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('1',@feed_system_date,'NO ROWS to PROCESS - Authors')
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

	select @feed_count = 0
	
	select @feedout_authortype = ''
	select @feedout_primary = ''

	if @feed_authortypecode  > 0
	  begin
		select  @feedout_authortype = datadesc
			from gentables where tableid= 134
			   and datacode=  @feed_authortypecode 
	  end 
	
	
	if @feed_primary = 1
	  begin
		select @feedout_primary = 'Y'
	  end
	else
	  begin
		select @feedout_primary ='N'
	  end 

begin tran
	if @feedout_lastname is null
	  begin
		insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		  values (@feedout_authorkey,'1',@feed_system_date,'Authors-- warning lastname missing')
	end

/*insert into temporary table*/

	insert into bnmitstitleauthorfeed 
		(bookkey ,authorkey,authorlastname,authorfirstname,
		authormiddlename,authorsuffix,authordegree,authortype,sortorder,primaryflag,
		bookauthorlastuserid, bookauthorlastmaintdate, authorlastuserid, authorlastmaintdate)
	values (@feedout_bookkey,@feedout_authorkey,@feedout_lastname,@feedout_firstname,@feedout_middlename,
		@feedout_suffix,@feedout_degree,@feedout_authortype,@feedout_sortorder,@feedout_primary,
		@feedout_bookauthorlastuserid, @feedout_bookauthorlastmaintdate, @feedout_authorlastuserid,
		@feedout_authorlastmaintdate)
commit tran
	
end /*isbn status 2*/

FETCH NEXT FROM feedout_authors 
	INTO  @feedout_bookkey,@feedout_authorkey,@feedout_lastname,@feedout_firstname,@feedout_middlename,
		@feedout_suffix,@feedout_degree,@feed_authortypecode,@feedout_sortorder,@feed_primary,
		@feedout_bookauthorlastuserid, @feedout_bookauthorlastmaintdate, @feedout_authorlastuserid,
		@feedout_authorlastmaintdate
select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/

begin tran

select @feed_count = 0
select @feed_count = count(*) from bnmitstitleauthorfeed
if @feed_count > 0
  begin
	insert into bnmitstitleauthorfeed(bookkey ,authorkey,authorlastname,authorfirstname)
	  values (0,0,null,'Total Records ' + convert(varchar,@feed_count))
  end
insert into feederror (batchnumber,processdate,errordesc)
 values ('1',@feed_system_date,'Authors Out Completed')

commit tran

close feedout_authors
deallocate feedout_authors

select @statusmessage = 'END TMM FEED OUT Author AT ' + convert (char,getdate())
print @statusmessage

return 0


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

