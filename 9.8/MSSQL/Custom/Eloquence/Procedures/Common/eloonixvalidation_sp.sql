drop proc eloonixvalidation_sp 
go
create proc dbo.eloonixvalidation_sp @i_severitycode int, @i_bookkey int, @c_message varchar (255)
as

/* @i_severitycode:  1 = Error, 2= Warning, 3 = Information */

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/


DECLARE @c_validationtitle varchar (100)
DECLARE @c_validationimprint varchar (40)
DECLARE @c_validationisbn varchar (13)
DECLARE @c_validationmessage varchar (255)
DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_information int
DECLARE @c_severitymessage varchar (100)
DECLARE @c_messagetext varchar (100)

/** Constants for Validation Errors **/
select @i_error = 1
select @i_warning = 2
select @i_information = 3

if @i_severitycode = @i_error
begin
	select @c_severitymessage = 'Error      '
end
else if @i_severitycode = @i_warning
begin
	select @c_severitymessage = 'Warning    '
end
else if @i_severitycode = @i_information
begin
	select @c_severitymessage = 'Information'
end


select @c_validationtitle = title, @c_validationisbn = isbn 
from book , isbn
where book.bookkey = @i_bookkey and isbn.bookkey=book.bookkey

select @c_validationimprint = 
orgentrykey from orgentry where orgentrykey = 
(select distinct orgentrykey from bookorgentry where orglevelkey=3 and bookkey = @i_bookkey)

select @c_messagetext = @c_message
/* insert into eloerrors ( imprint, isbn, title, severitylevel,message) select @c_validationimprint, @c_validationisbn, @c_validationtitle, @C_severitymessage, @c_messagetext
print @ierror 'inserted' */

/* CT -  below is for old error log, and commented out */
/*select @c_validationmessage = @c_severitymessage + ': ' + @c_message
print @c_validationmessage
select @c_validationmessage =  'ISBN: ' 
+ @c_validationisbn 
print @c_validationmessage
select @c_validationmessage ='Title: ' + @c_validationtitle 
print @c_validationmessage
select @c_validationmessage = 'Bookkey: ' 
+ convert (varchar (15),@i_bookkey) 
print @c_validationmessage
print ' '*/

select @c_validationmessage = convert (varchar (15),@i_bookkey) + '; ' + convert(char(1),@i_severitycode) + '; ' + @c_message
print @c_validationmessage
return 0

GO