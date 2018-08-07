if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_out_author_info') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.feed_out_author_info
end

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

DECLARE @feed_authorkey  int
DECLARE @feed_middlename varchar(40)
DECLARE @feed_authortypecode int

DECLARE @feedout_isbn varchar (10)  
DECLARE @feedout_lastname varchar (100)  
DECLARE @feedout_firstname varchar (100)  
DECLARE @feedout_role varchar (40)  

DECLARE @c_message  varchar(255)

select @statusmessage = 'BEGIN TMM FEED OUT Author AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

delete from feedout_authors


DECLARE feedout_authors INSENSITIVE CURSOR
FOR

select i.isbn10,a.lastname,a.firstname, a.middlename,authortypecode
	from bookcustom b, isbn i, bookauthor ba , author a
		where b.bookkey=  i.bookkey
			and b.bookkey = ba.bookkey 
			and ba.authorkey = a.authorkey
			and customcode09 = 2 /*ready to transmit*/
	
FOR READ ONLY
		
OPEN feedout_authors 

FETCH NEXT FROM feedout_authors 
	INTO @feedout_isbn, @feedout_lastname,@feedout_firstname, @feed_middlename,@feed_authortypecode
 
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

	select @feedout_role = '' 

/*authortypecode */

	if @feed_authortypecode is not null
	  begin
		if @feed_authortypecode <> 12 /*if type not author output*/
		  begin
			select  @feedout_role = externalcode
			from gentables where tableid=134
			   and datacode=  @feed_authortypecode
	  	end 
	  end 

	if @feed_middlename is null 
	  begin
		select @feed_middlename = ''
	  end

	if datalength(@feed_middlename) > 0
	  begin
		select @feedout_firstname = @feedout_firstname + ' ' + @feed_middlename
	  end


/*insert into temporary table*/

	insert into feedout_authors (isbn,authlastname,authfirstname,authrole)
	values (@feedout_isbn,@feedout_lastname,@feedout_firstname,@feedout_role)
	
end /*isbn status 2*/

FETCH NEXT FROM feedout_authors
	INTO @feedout_isbn, @feedout_lastname,@feedout_firstname, @feed_middlename,@feed_authortypecode

select @i_isbn  = @@FETCH_STATUS
end /*isbn status 1*/


insert into feederror (batchnumber,processdate,errordesc)
 values ('1',@feed_system_date,'Authors Out Completed')

close feedout_authors
deallocate feedout_authors

select @statusmessage = 'END TMM FEED OUT Authors AT ' + convert (char,getdate())
print @statusmessage

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO