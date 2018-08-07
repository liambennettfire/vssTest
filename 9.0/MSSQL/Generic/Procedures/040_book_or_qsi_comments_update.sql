SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'book_or_qsi_comments_update')
	BEGIN
		PRINT 'Dropping Procedure book_or_qsi_comments_update'
		DROP  Procedure  book_or_qsi_comments_update
	END

GO

PRINT 'Creating Procedure book_or_qsi_comments_update'
GO


CREATE      PROCEDURE dbo.book_or_qsi_comments_update
		     @i_html  text, 
		     @i_key int,
		     @i_print_key int,
		     @i_commenttypecode int,
		     @i_commenttypesubcode int,
		     @i_update_table_name varchar(100),
		     @o_error_code     int 		output,
		     @o_error_desc     varchar(2000) output



AS

/* Anes Hrenovica 12/0/04 Innitial development
   Description: Update QSICOMMENTS ot BOOKCOMMENTS cblob fileds
   Procedure convert_update_html_to_text, convert_update_html_to_text
   used to convert html clob
*/

DECLARE 
@error int,
@count int 

BEGIN 

if @i_update_table_name = null begin
	select @o_error_desc = 'Table name is required parametar'
	return -1
end 

-- Initial row needed in order for the row update to work as expected.
if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
  Select @count=count(*) from bookcomments where bookkey = @i_key and
        printingkey = @i_print_key and
        commenttypecode = @i_commenttypecode and 
        commenttypesubcode = @i_commenttypesubcode
  print 'count'
  print @count
  if @count = 0 begin
    insert into bookcomments (bookkey, printingkey, commenttypecode, commenttypesubcode) VALUES (@i_key, @i_print_key, @i_commenttypecode, @i_commenttypesubcode)
  end
end

if upper(@i_update_table_name) = 'QSICOMMENTS' begin
  Select @count=count(*) from qsicomments where 
	commentkey = @i_key and
        commenttypecode = @i_commenttypecode and 
        commenttypesubcode = @i_commenttypesubcode
  print 'count'
  print @count
  if @count = 0 begin
    insert into qsicomments (commentkey, commenttypecode, commenttypesubcode) VALUES (@i_key, @i_commenttypecode, @i_commenttypesubcode)
  end


end

execute convert_update_html_to_lite  @i_html , @i_key , @i_print_key , @i_commenttypecode , @i_commenttypesubcode, @i_update_table_name, @o_error_code output, @o_error_desc output

execute convert_update_html_to_text  @i_html , @i_key , @i_print_key , @i_commenttypecode , @i_commenttypesubcode, @i_update_table_name, @o_error_code output, @o_error_desc output


if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
  update bookcomments
  set commenthtml = @i_html
  where bookkey = @i_key and
        printingkey = @i_print_key and
        commenttypecode = @i_commenttypecode and 
        commenttypesubcode = @i_commenttypesubcode
end 

if upper(@i_update_table_name) = 'QSICOMMENTS' begin
  update qsicomments
  set commenthtml = @i_html
  where commentkey = @i_key and
        commenttypecode = @i_commenttypecode and 
        commenttypesubcode = @i_commenttypesubcode;
end


 END
GO

GRANT EXEC ON book_or_qsi_comments_update TO PUBLIC
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


