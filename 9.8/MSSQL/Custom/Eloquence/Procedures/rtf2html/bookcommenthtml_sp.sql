PRINT 'STORED PROCEDURE : dbo.bookcommenthtml_sp'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.bookcommenthtml_sp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.bookcommenthtml_sp
end

GO

create proc dbo.bookcommenthtml_sp @i_allbooksind int as
/** This procedure will convert all specified bookcommentrtf rows to HTML
Set allbooksind=1 to convert all rows in bookcommentrtf
Set allbooksind=0 to convert rows specified in the control table 'converthtmlbookkeys'
It is assumed that rtf2htmlbookkeys will be preloaded prior to running this procedure
**/

DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_commenttypecode int
DECLARE @i_commenttypesubcode int
DECLARE @i_book_cursor_status int


if @i_allbooksind = 1 /* Select all rows from Bookcommentrtf */
begin
	DECLARE cursor_book INSENSITIVE CURSOR
	FOR
	select bookkey,printingkey,commenttypecode,commenttypesubcode from bookcommentrtf
	FOR READ ONLY
end
else /* Convert only rows preloaded in rtf2htmlbookkeys */
begin
	DECLARE cursor_book INSENSITIVE CURSOR
	FOR
	select bookkey,printingkey,commenttypecode,commenttypesubcode from rtf2htmlbookkeys
	FOR READ ONLY
end

OPEN cursor_book

print 'AllBooksInd Parameter = ' + convert (char (10),@i_allbooksind)
print 'Total Number of Book Comments Being Converted: ' + convert (char(10),@@CURSOR_ROWS)



FETCH NEXT FROM cursor_book
INTO @i_bookkey, @i_printingkey, @i_commenttypecode, @i_commenttypesubcode

select @i_book_cursor_status = @@FETCH_STATUS

while (@i_book_cursor_status<>-1 )
begin
	IF (@i_book_cursor_status<>-2)
	begin
		/* Clear out the temp table */
		truncate table rtf2htmltext
		
		/* Insert the RTF text to be converted into the temp table */
		insert into rtf2htmltext (commenttext) select commenttext 
		from bookcommentrtf
		where bookkey = @i_bookkey
		and printingkey = @i_printingkey
		and commenttypecode = @i_commenttypecode
		and commenttypesubcode = @i_commenttypesubcode

		/* Call the rft2html stored proc */
		exec rtf2html_sp

		/* Delete any existing bookcommenthtml row */
		delete from bookcommenthtml 
		where bookkey = @i_bookkey
		and printingkey= @i_printingkey
		and commenttypecode = @i_commenttypecode
		and commenttypesubcode = @i_commenttypesubcode		

		/* Insert the new row by selecting the converted html text */
		/* from the temp table */
		insert  into bookcommenthtml
		(bookkey,printingkey,commenttypecode,commenttypesubcode,
		commenttext,lastuserid,lastmaintdate)
		select 
		@i_bookkey,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,
		commenttext,'rtf2html',getdate() from rtf2htmltext
			
	end

	FETCH NEXT FROM cursor_book
	INTO @i_bookkey, @i_printingkey, @i_commenttypecode, @i_commenttypesubcode
        select @i_book_cursor_status = @@FETCH_STATUS
end

close cursor_book
deallocate cursor_book
gO

