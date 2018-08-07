if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixbwkout_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixbwkout_sp]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE proc dbo.eloonixbwkout_sp as


DECLARE @i_bookkey int

DECLARE @c_currentdate varchar (10)
DECLARE @d_currentdate datetime
DECLARE @i_book_cursor_status int
DECLARE @i_output_onix_book int



/* Truncate the output table in preparation for new feed */
truncate table eloonixfeed

/* Create Header Information for Onix Feed */


insert into eloonixfeed (feedtext) select 
'<?xml version="1.0" encoding="UTF-16"?>' 
/*Without encoding '<?xml version="1.0"?>'  */



insert into eloonixfeed (feedtext) select 
'<!DOCTYPE ONIXmessage SYSTEM "http://www.editeur.org/onix/2.0/short/onix-international.dtd" >'


insert into eloonixfeed (feedtext) select 
'<ONIXmessage>'


insert into eloonixfeed (feedtext) select 
'<m174>Eloquence</m174>'

insert into eloonixfeed (feedtext) select 
'<m175>Catherine Toolan 978-657-5055 ctoolan@qsolution.com</m175>'



/* Call the Date conversion function, 
then retrieve the resuling date from eloconverteddate */
select @d_currentdate=getdate()
exec eloformatdateYYYYMMDD_sp @d_currentdate
select @c_currentdate=converteddate from eloconverteddate
	

insert into eloonixfeed (feedtext) select 
'<m182>'+ @c_currentdate + '</m182>'


insert into eloonixfeed (feedtext) select 
'<m185>01</m185>'

insert into eloonixfeed (feedtext) select 
'<m186>USD</m186>'

insert into eloonixfeed (feedtext) select 
'<m187>in</m187>'


DECLARE cursor_book INSENSITIVE CURSOR
FOR
select bookkey from eloonixbookkeys
FOR READ ONLY

OPEN cursor_book

print 'ONIX 2.0 Total Number of Books Exporting: ' + convert (char(10),@@CURSOR_ROWS)




FETCH NEXT FROM cursor_book
INTO @i_bookkey

select @i_book_cursor_status = @@FETCH_STATUS

while (@i_book_cursor_status<>-1 )
begin
	IF (@i_book_cursor_status<>-2)
	begin
	
	exec @i_output_onix_book=eloonixbwkoutbook_sp @i_bookkey
	end

	FETCH NEXT FROM cursor_book
	INTO @i_bookkey
        select @i_book_cursor_status = @@FETCH_STATUS
end

close cursor_book
deallocate cursor_book

/** Output Final ONIX Message Ending **/

insert into eloonixfeed (feedtext) select 
'</ONIXmessage>'

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

