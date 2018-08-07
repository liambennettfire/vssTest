SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloonixout_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloonixout_sp]
GO


CREATE proc dbo.eloonixout_sp @i_onixlevel int as


DECLARE @i_bookkey int
/**DECLARE @i_onixlevel int **/
DECLARE @c_currentdate varchar (10)
DECLARE @d_currentdate datetime
DECLARE @i_book_cursor_status int
DECLARE @i_output_onix_book int

/******* ONIX LEVEL Parameter (1,2 or 32)   ********/
/** Onix Level is set as parameter. Level 1 and 2 are Onix compliant. **/
/** Level 3 is a custom stored procedure for QSI Web Sites **/



/* Truncate the output table in preparation for new feed */
truncate table eloonixfeed

/* Create Header Information for Onix Feed */


insert into eloonixfeed (feedtext) select 
'<?xml version="1.0" encoding="UTF-8"?>' 
/*Without encoding '<?xml version="1.0"?>'  */



if @i_onixlevel = 1 or @i_onixlevel = 2 /** Do not output DTD line for QSI Web **/
begin
	insert into eloonixfeed (feedtext) select 
	'<!DOCTYPE ONIXmessage SYSTEM "http://www.editeur.org/onix/1.2.1/short/onix-international.dtd" >'
end

insert into eloonixfeed (feedtext) select 
'<ONIXmessage>'


insert into eloonixfeed (feedtext) select 
'<m174>Eloquence</m174>'

insert into eloonixfeed (feedtext) select 
'<m175>Doug Lessing  631-363-2515 dlessing@qsolution.com</m175>'


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

/**  Guilford test title
DECLARE cursor_book INSENSITIVE CURSOR
FOR
select bookkey from book where bookkey=60040
FOR READ ONLY
**/

/** All Updated Titles for Bowker
select distinct (bookkey) from bookedipartner 
where lastmaintdate>='10/16/2000')
**/

/** All Sterling Titles
DECLARE cursor_book INSENSITIVE CURSOR
FOR
select bookkey from bookorgentry where orgentrykey=60224 and orglevelkey=1
FOR READ ONLY
**/

/** Sterling Titles - Spring 2001 
select bo.bookkey from bookorgentry bo,printing p 
where bo.orgentrykey=60224 and bo.orglevelkey=1 and
p.bookkey=bo.bookkey and p.seasonkey=68034
**/

/** All Guilford titles
select bo.bookkey from bookorgentry bo
where bo.orgentrykey=60158 and bo.orglevelkey=1
**/

/** All Harcourt titles
select bo.bookkey from bookorgentry bo
where bo.orgentrykey=74725 and bo.orglevelkey=1
**/

DECLARE cursor_book INSENSITIVE CURSOR
FOR
select bookkey from eloonixbookkeys
FOR READ ONLY

OPEN cursor_book

print 'Total Number of Books Exporting: ' + convert (char(10),@@CURSOR_ROWS)
print 'Onix Level = ' + convert (char (10),@i_onixlevel)



FETCH NEXT FROM cursor_book
INTO @i_bookkey

select @i_book_cursor_status = @@FETCH_STATUS

while (@i_book_cursor_status<>-1 )
begin
	IF (@i_book_cursor_status<>-2)
	begin
	
	exec @i_output_onix_book=eloonixoutbook_sp @i_bookkey, @i_onixlevel
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

