SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[eloflatout_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[eloflatout_sp]
GO


create proc dbo.eloflatout_sp as


DECLARE @i_bookkey int
/**DECLARE @i_onixlevel int **/
DECLARE @c_currentdate varchar (10)
DECLARE @d_currentdate datetime
DECLARE @i_book_cursor_status int
DECLARE @i_output_onix_book int

/* Truncate the output table in preparation for new feed */
truncate table eloflatfeed

DECLARE cursor_book INSENSITIVE CURSOR
FOR
select distinct bookkey from eloflatbookkeys
FOR READ ONLY

OPEN cursor_book

print 'Total Number of Books Exporting: ' + convert (char(10),@@CURSOR_ROWS)


FETCH NEXT FROM cursor_book
INTO @i_bookkey

select @i_book_cursor_status = @@FETCH_STATUS

while (@i_book_cursor_status<>-1 )
begin
	IF (@i_book_cursor_status<>-2)
	begin
	
	exec @i_output_onix_book=eloflatoutbook_sp @i_bookkey
	end

	FETCH NEXT FROM cursor_book
	INTO @i_bookkey
        select @i_book_cursor_status = @@FETCH_STATUS
end

close cursor_book
deallocate cursor_book

/** Output Final ONIX Message Ending **/





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

