if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_majsub_info') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.feed_out_majsub_info
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
create proc dbo.feed_out_majsub_info 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

4-12-04 Feedout out CISPUB.. make sure only get rows that are ready; this will be set 
in a custom field
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

DECLARE @feed_majorsubjectcode int
DECLARE @feed_majorsubjectsubcode int

DECLARE @feedout_isbn varchar (10)   
DECLARE @feedout_subject varchar (220)
DECLARE @feedout_subject2 varchar (120)

DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Major Subj AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

delete from feedout_majorsubj


DECLARE feedout_majsub INSENSITIVE CURSOR
FOR

select i.isbn10,categorycode,categorysubcode
	from bookcustom b, isbn i, booksubjectcategory bs
		where b.bookkey = i.bookkey 
			and b.bookkey= bs.bookkey
			and customcode09 = 2 /*ready to transmit*/
	
FOR READ ONLY
		
OPEN feedout_majsub

FETCH NEXT FROM feedout_majsub 
	INTO @feedout_isbn, @feed_majorsubjectcode,@feed_majorsubjectsubcode
 
select @i_isbn  = @@FETCH_STATUS

if @i_isbn <> 0 /*no isbn*/
begin	
	insert into feederror 										
		(isbn,batchnumber,processdate,errordesc)
		values (@feedout_isbn,'1',@feed_system_date,'NO ROWS to PROCESS - Author')
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

	select @feedout_subject = '' 
	select @feedout_subject2 = '' 

/*majorsubjectcode */

	if @feed_majorsubjectcode is not null
	  begin
		select  @feedout_subject = rtrim(externalcode)
			from gentables where tableid=412
			   and datacode=  @feed_majorsubjectcode
	  end 


	if @feed_majorsubjectsubcode is not null
	  begin
		select  @feedout_subject2 = rtrim(externalcode)
			from subgentables where tableid=412
			   and datacode =  @feed_majorsubjectcode
			   and datasubcode = @feed_majorsubjectsubcode 
	  end 

	if @feedout_subject2 is null
	  begin
		select @feedout_subject2 =''
	 end
	if datalength(@feedout_subject2) > 0	
	  begin
		select @feedout_subject = @feedout_subject +' - '+ @feedout_subject2
	  end

/*insert into temporary table*/
	insert into feedout_majorsubj (isbn,majorsubjects)
	values (@feedout_isbn,@feedout_subject)
	
end /*isbn status 2*/

FETCH NEXT FROM feedout_majsub
	INTO @feedout_isbn, @feed_majorsubjectcode,@feed_majorsubjectsubcode


select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/


insert into feederror (batchnumber,processdate,errordesc)
 values ('1',@feed_system_date,'Major Subject Out Completed')

close feedout_majsub
deallocate feedout_majsub

select @statusmessage = 'END TMM FEED OUT Major Subj AT ' + convert (char,getdate())
print @statusmessage

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO