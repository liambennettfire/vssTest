if exists (select * from dbo.sysobjects where id = Object_id('dbo.webbookout_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.webbookout_sp
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
create proc dbo.webbookout_sp   as


DECLARE @i_bookkey int
DECLARE @i_book_cursor_status int
DECLARE @i_output_onix_book int
DECLARE @c_lastname varchar (100)
DECLARE @i_workkey int

/* Truncate the output table in preparation for new feed */
truncate table webbookxmlfeed

/*CRM 1600 : only show 1 control record for all formats of a book
	get workkey along with bookkey so always get primary ISBN info for the
	control record*/

DECLARE cursor_book INSENSITIVE CURSOR
FOR
select lastname,w.bookkey,b.workkey from webbookkeys w,bookauthor ba, author a,
	book b
   where w.bookkey=ba.bookkey and w.bookkey=b.bookkey and ba.authorkey=a.authorkey 
    and primaryind =1 and sortorder = 1
	 order by lastname
FOR READ ONLY

OPEN cursor_book


FETCH NEXT FROM cursor_book
INTO @c_lastname,@i_bookkey,@i_workkey

select @i_book_cursor_status = @@FETCH_STATUS

while (@i_book_cursor_status<>-1 )
begin
	IF (@i_book_cursor_status<>-2)
	begin
	
		exec @i_output_onix_book=webbookdetail_sp @i_bookkey,@i_workkey
		if @i_output_onix_book <> 0
	      	   begin
			print 'error on book detail create'
		  end
	end

	FETCH NEXT FROM cursor_book
	INTO @c_lastname,@i_bookkey,@i_workkey
        select @i_book_cursor_status = @@FETCH_STATUS
end

close cursor_book
deallocate cursor_book

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO