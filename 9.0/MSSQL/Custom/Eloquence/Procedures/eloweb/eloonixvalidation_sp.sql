SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixvalidation_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixvalidation_sp]
GO


create proc dbo.eloonixvalidation_sp @i_severitycode int, @i_bookkey int, @c_message varchar (255)
as

/* @i_severitycode:  1 = Error, 2= Warning, 3 = Information */

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/


DECLARE @c_validationtitle varchar (100)
DECLARE @c_validationisbn varchar (13)
DECLARE @c_validationmessage varchar (255)
DECLARE @i_error int
DECLARE @i_warning int
DECLARE @i_information int
DECLARE @c_severitymessage varchar (100)

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

select @c_validationmessage = @c_severitymessage + ': ' + @c_message
print @c_validationmessage
select @c_validationmessage =  'ISBN: ' 
+ @c_validationisbn 
print @c_validationmessage
select @c_validationmessage ='Title: ' + @c_validationtitle 
print @c_validationmessage
select @c_validationmessage = 'Bookkey: ' 
+ convert (varchar (15),@i_bookkey) 
print @c_validationmessage
print ' '

return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

