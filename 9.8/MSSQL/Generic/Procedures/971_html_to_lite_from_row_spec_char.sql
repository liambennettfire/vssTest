if exists (select * from dbo.sysobjects where id = Object_id('dbo.html_to_lite_from_row_spec_char') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.html_to_lite_from_row_spec_char 
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Desc: This stored procedure convert special characters to &#nnnn in  
**  bookcomments.htmllite ,qsicomments.bookcomments, bookcomments_ext.commentbody
**  or qsicomments_ext.commentbody
**    Auth: Anes Hrenovica
**    Date: 10/6/2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
CREATE          PROCEDURE dbo.html_to_lite_from_row_spec_char
		     @i_key int,
		     @i_print_key int,
		     @i_commenttypecode int,
		     @i_commenttypesubcode int,
		     @i_update_table_name varchar(100),	
		     @blob_pointer varbinary (16),
		     @i_commentstyle int

AS

BEGIN 
DECLARE 
@special_char_start int,
@pos_start int,
@v_length int,
@v_loop int,
@blob_portion varchar(max),
@v_char char(1),
@v_unicode varchar(20),
@v_char_converted varchar(20)


set @pos_start = 1
if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
	select @v_length = DATALENGTH(commenthtml) from bookcomments
	where bookkey = @i_key AND printingkey = @i_print_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode	
end
if upper(@i_update_table_name) = 'QSICOMMENTS' begin
	select @v_length = DATALENGTH(commenthtml) from qsicomments
	where commentkey = @i_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode	
end
if upper(@i_update_table_name) = 'BOOKCOMMENTS_EXT' begin
	select @v_length = DATALENGTH(commentbody) from bookcomments_ext
	where bookkey = @i_key AND printingkey = @i_print_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
end
if upper(@i_update_table_name) = 'QSICOMMENTS_EXT' begin
	select @v_length = DATALENGTH(commentbody) from qsicomments_ext
	where commentkey = @i_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
end
   WHILE @pos_start <= @v_length BEGIN
     if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
	select @blob_portion = commenthtml from bookcomments
	where bookkey = @i_key AND printingkey = @i_print_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode	
	select @blob_portion = substring(@blob_portion,@pos_start, datalength(@blob_portion) )
     end
     if upper(@i_update_table_name) = 'QSICOMMENTS' begin
	select @blob_portion = commenthtml from qsicomments
	where commentkey = @i_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode	
	select @blob_portion = substring(@blob_portion,@pos_start, datalength(@blob_portion) )
     end
     if upper(@i_update_table_name) = 'BOOKCOMMENTS_EXT' begin
	select @blob_portion = commentbody from bookcomments_ext
	where bookkey = @i_key AND printingkey = @i_print_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
	select @blob_portion = substring(@blob_portion,@pos_start, datalength(@blob_portion) )
     end
    if upper(@i_update_table_name) = 'QSICOMMENTS_EXT' begin
	select @blob_portion = commentbody from qsicomments_ext
	where commentkey = @i_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
	select @blob_portion = substring(@blob_portion,@pos_start, datalength(@blob_portion) )
     end
        set @pos_start = @pos_start + DATALENGTH(@blob_portion)
	
	set @v_loop = 0 
	WHILE @v_loop <= @v_length BEGIN
	  set @v_char = SUBSTRING(@blob_portion,@v_loop,1)
	  set @v_loop = @v_loop + 1 
	  set @v_unicode = UNICODE(@v_char)
	   if @v_unicode > 127 or @v_unicode = 11 begin
              if @v_unicode = 11 begin
		set @v_char_converted = '<BR>'
	      end else begin
	        set @v_char_converted = '&#' + @v_unicode + ';'
	        set @v_char_converted = ltrim(@v_char_converted)
	        set @v_char_converted = rtrim(@v_char_converted)
	      end
		if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
     		  select @special_char_start = PATINDEX ( '%' + @v_char + '%' , commenthtmllite )  from bookcomments
                  where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
		  if @special_char_start = 0  continue  
		  set @special_char_start = @special_char_start -1
		  updatetext bookcomments.commenthtmllite @blob_pointer @special_char_start 1 @v_char_converted
		 end
		if upper(@i_update_table_name) = 'QSICOMMENTS' begin
     		  select @special_char_start = PATINDEX ( '%' + @v_char + '%' , commenthtmllite )  from qsicomments
                  where commentkey = @i_key  and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
		  if @special_char_start = 0  continue 
		  set @special_char_start = @special_char_start -1
		  updatetext qsicomments.commenthtmllite @blob_pointer @special_char_start 1 @v_char_converted
		 end
		if upper(@i_update_table_name) = 'BOOKCOMMENTS_EXT' begin
     		  select @special_char_start = PATINDEX ( '%' + @v_char + '%' , commentbody )  from bookcomments_ext
                  where bookkey = @i_key AND printingkey = @i_print_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
		  if @special_char_start = 0  continue 
		  set @special_char_start = @special_char_start -1
		  updatetext bookcomments_ext.commentbody @blob_pointer @special_char_start 1 @v_char_converted
		 end
		if upper(@i_update_table_name) = 'QSICOMMENTS_EXT' begin
     		  select @special_char_start = PATINDEX ( '%' + @v_char + '%' , commentbody )  from qsicomments_ext
                  where commentkey = @i_key AND commenttypecode = @i_commenttypecode AND commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
		  if @special_char_start = 0  continue 
		  set @special_char_start = @special_char_start -1
		  updatetext qsicomments_ext.commentbody @blob_pointer @special_char_start 1 @v_char_converted
		 end
	   end

	 END	
   END


END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.html_to_lite_from_row_spec_char TO PUBLIC
GO



