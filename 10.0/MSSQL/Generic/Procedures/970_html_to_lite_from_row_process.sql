if exists (select * from dbo.sysobjects where id = Object_id('dbo.html_to_lite_from_row_process') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.html_to_lite_from_row_process 
end
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



/******************************************************************************
**  Desc: This stored procedure replace remain, or remove html passed html tag 
**  in blob. Temp_blbo table is used for processing of special paste in html ocx 
**  control
**  Auth: Anes Hrenovica
**  Date: 10/6/2006
*******************************************************************************
**  Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
CREATE             PROCEDURE dbo.html_to_lite_from_row_process
		     @i_key int,
		     @i_print_key int,
		     @i_commenttypecode int,
		     @i_commenttypesubcode int,
		     @i_update_table_name varchar(100),	
		     @o_openingtag  varchar(100),
		     @o_replacewith  varchar(max),
		     @o_closingtag varchar(100),
		     @blob_pointer varbinary (16),
		     @o_putbackind int,
		     @o_remain int,
		     @i_commentstyle int,
		     @v_invalid int out

AS

BEGIN 
DECLARE 
@loop int,
@v_del_len int,
@div_start int,
@div_end int,
@v_del_length int,
@pos_start int,
@v_part varchar(max),
@v_cnt int,
@v_checktag varchar(max),
@v_found_extra_opening int,
@v_found_extra_closing int,
@lite  varchar(max)



set @loop = 0
set @v_invalid = 0

set @o_openingtag = '%' + @o_openingtag + '%'
set @v_cnt = 0

WHILE @loop = 0  BEGIN
set @v_cnt = @v_cnt + 1 
if @v_cnt > 10000 begin
set @v_invalid = 1
break
end

set @div_start = 0
set @div_end = 0
   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
      select @div_start = PATINDEX ( @o_openingtag , commenthtmllite )  from bookcomments
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
   end
   if upper(@i_update_table_name)='QSICOMMENTS' begin
      select @div_start = PATINDEX ( @o_openingtag , commenthtmllite )  from qsicomments
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
   end
   if upper(@i_update_table_name)='TEMP_BLOB' begin
      select @div_start = PATINDEX ( @o_openingtag , htmldata)  from temp_blob
      where keyid = @i_key
   end
   if upper(@i_update_table_name)='BOOKCOMMENTS_EXT' begin
      select @div_start = PATINDEX ( @o_openingtag , commentbody)  from bookcomments_ext
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   end
   if upper(@i_update_table_name)='QSICOMMENTS_EXT' begin
      select @div_start = PATINDEX ( @o_openingtag , commentbody)  from qsicomments_ext
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   end

   if @div_start = 0 begin
      break
   end	

   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
      select @v_part = commenthtmllite from bookcomments
      where bookkey = @i_key and printingkey = @i_print_key  and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
      
      select @v_part = substring(@v_part, @div_start, datalength(@v_part)) 
      set @div_end = CHARINDEX(@o_closingtag, @v_part, 0) + @div_start - 1 
      if @div_start > @div_end  begin
	 set @v_invalid = 1
	 break
      end

      if @o_putbackind = 0 and @o_remain = 0 begin
	 select @lite = commenthtmllite from bookcomments
	 where bookkey = @i_key and printingkey = @i_print_key  and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
	 select @lite = substring(@lite, @div_start + 1, @div_end - @div_start -1) 
	 set @v_found_extra_opening = CHARINDEX ( '&&L' , @v_checktag) 
	 set @v_found_extra_closing = CHARINDEX ( '&&R' , @v_checktag) 
	 if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	    set @v_invalid = 1
	        break
	 end
      end


      if @o_putbackind <> 1 and @div_end > 0 and len(@o_closingtag) = 1 begin
	select @v_checktag = commenthtmllite from bookcomments
	where bookkey = @i_key and printingkey = @i_print_key  and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
	select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1)
	set @v_found_extra_opening = CHARINDEX ( '<' , @v_checktag) 
	set @v_found_extra_closing = CHARINDEX ( '>' , @v_checktag) 
	if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	   set @v_invalid = 1
	       break
	end
     end
   end

   if upper(@i_update_table_name)='QSICOMMENTS' begin
      select @v_part = commenthtmllite from qsicomments
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode 
        
      select @v_part = substring(@v_part, @div_start, datalength(@v_part))
      set @div_end = CHARINDEX(@o_closingtag, @v_part, 0) + @div_start - 1 
      if @div_start > @div_end begin
	 set @v_invalid = 1
	 break
      end

      if @o_putbackind = 0 and @o_remain = 0 begin
	select @v_checktag = commenthtmllite from qsicomments
	where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
	select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1)
	 set @v_found_extra_opening = CHARINDEX ( '&&L' , @v_checktag) 
	 set @v_found_extra_closing = CHARINDEX ( '&&R' , @v_checktag) 
	 if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	    set @v_invalid = 1
	        break
	 end
      end

      if @o_putbackind <> 1 and @div_end > 0 and len(@o_closingtag) = 1 begin
	select @v_checktag = commenthtmllite from qsicomments
	where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
	select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1)
	set @v_found_extra_opening = CHARINDEX ( '<' , @v_checktag) 
	set @v_found_extra_closing = CHARINDEX ( '>' , @v_checktag) 
	if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	   set @v_invalid = 1
	       break
	end
     end
   end	

   if upper(@i_update_table_name)='TEMP_BLOB' begin
      select @v_part = htmldata from temp_blob
      where keyid = @i_key
      select @v_part = substring(@v_part, @div_start, datalength(@v_part))
      set @div_end = CHARINDEX(@o_closingtag, @v_part, 0) + @div_start - 1 
   end	
   if upper(@i_update_table_name)='BOOKCOMMENTS_EXT' begin
      select @v_part = commentbody from bookcomments_ext
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
      select @v_part = substring(@v_part, @div_start, datalength(@v_part))
      set @div_end = CHARINDEX(@o_closingtag, @v_part, 0) + @div_start - 1 
      if @div_start > @div_end begin
	 set @v_invalid = 1
	 break
      end

      if @o_putbackind = 0 and @o_remain = 0 begin
	select @v_checktag = commentbody from bookcomments_ext
	where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
	select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1)
	 set @v_found_extra_opening = CHARINDEX ( '&&L' , @v_checktag) 
	 set @v_found_extra_closing = CHARINDEX ( '&&R' , @v_checktag) 
	 if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	    set @v_invalid = 1
	        break
	 end
      end

        if @o_putbackind <> 1 and @div_end > 0 and len(@o_closingtag) = 1 begin
	select @v_checktag = commentbody from bookcomments_ext
	where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
	select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1)
	set @v_found_extra_opening = CHARINDEX ( '<' , @v_checktag) 
	set @v_found_extra_closing = CHARINDEX ( '>' , @v_checktag) 
	if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	   set @v_invalid = 1
	       break
	end
     end
   end	
   if upper(@i_update_table_name)='QSICOMMENTS_EXT' begin
      select @v_part = commentbody from qsicomments_ext
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
      select @v_part = substring(@v_part, @div_start, datalength(@v_part))
      set @div_end = CHARINDEX(@o_closingtag, @v_part, 0) + @div_start - 1
      if @div_start > @div_end begin
	 set @v_invalid = 1
	 break
      end

      if @o_putbackind = 0 and @o_remain = 0 begin
	select @v_checktag = commentbody from qsicomments_ext
        where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1) 
	 set @v_found_extra_opening = CHARINDEX ( '&&L' , @v_checktag) 
	 set @v_found_extra_closing = CHARINDEX ( '&&R' , @v_checktag) 
	 if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	    set @v_invalid = 1
	        break
	 end
      end

      if @o_putbackind <> 1 and @div_end > 0 and len(@o_closingtag) = 1 begin
	select @v_checktag = commentbody from qsicomments_ext
        where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
	select @v_checktag = substring(@v_checktag, @div_start + 1, @div_end - @div_start -1) 
	set @v_found_extra_opening = CHARINDEX ( '<' , @v_checktag) 
	set @v_found_extra_closing = CHARINDEX ( '>' , @v_checktag) 
	if @v_found_extra_opening > 0 or @v_found_extra_closing > 0 begin
	   set @v_invalid = 1
	       break
	end
     end 
   end	

   if @div_end = 0 begin
      set @v_invalid = 1
      break
   end	

   set @v_del_length = @div_end - @div_start + len(@o_closingtag)
   set @div_start = @div_start - 1

  if @o_remain = 1 and @o_putbackind <> 1 begin
   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
      select @o_replacewith = commenthtmllite
      from bookcomments
      where bookkey = @i_key and printingkey = @i_print_key  and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
      select @o_replacewith = substring(@o_replacewith, @div_start + 1, @div_end - @div_start + len(@o_closingtag)-1)
   end 
   if upper(@i_update_table_name)='QSICOMMENTS' begin
      select @o_replacewith = commenthtmllite
      from qsicomments
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode 
      select @o_replacewith = substring(@o_replacewith, @div_start + 1, @div_end - @div_start + len(@o_closingtag)-1)
   end 
   if upper(@i_update_table_name)='TEMP_BLOB' begin
      select @o_replacewith = htmldata
      from temp_blob
      where keyid = @i_key
      select @o_replacewith = substring(@o_replacewith, @div_start + 1, @div_end - @div_start + len(@o_closingtag)-1)
   end 
   if upper(@i_update_table_name)='BOOKCOMMENTS_EXT' begin
      select @o_replacewith = commentbody
      from bookcomments_ext
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
      select @o_replacewith = substring(@o_replacewith, @div_start + 1, @div_end - @div_start + len(@o_closingtag)-1)
   end 
   if upper(@i_update_table_name)='QSICOMMENTS_EXT' begin
      select @o_replacewith = commentbody
      from qsicomments_ext
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
      select @o_replacewith = substring(@o_replacewith, @div_start + 1, @div_end - @div_start + len(@o_closingtag)-1)
   end 
   if upper(@o_openingtag) = '%<P CLASS=%' begin
      set @o_replacewith  = replace(@o_replacewith, 'class=MsoNormal ', '')
      set @o_replacewith  = replace(@o_replacewith, 'class=Body1 ', '') 
      set @o_replacewith  = replace(@o_replacewith, 'class=MsoPlainText ', '')
      set @o_replacewith  = replace(@o_replacewith, 'class=MsoBodyText ', '')
      set @o_replacewith  = replace(@o_replacewith, 'class=MsoBodyText2 ', '')
   end

   set @o_replacewith = replace(@o_replacewith, '<', '&&L')
   set @o_replacewith = replace(@o_replacewith, '>', '&&R')
  end 

  if @o_putbackind <> 1 begin
   set @o_replacewith = replace(@o_replacewith, '<', '&&L')
   set @o_replacewith = replace(@o_replacewith, '>', '&&R')
  end 

   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
      updatetext bookcomments.commenthtmllite @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
   if upper(@i_update_table_name)='QSICOMMENTS' begin
      updatetext qsicomments.commenthtmllite @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
   if upper(@i_update_table_name)='TEMP_BLOB' begin
      updatetext temp_blob.htmldata @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
   if upper(@i_update_table_name)='BOOKCOMMENTS_EXT' begin
      updatetext bookcomments_ext.commentbody @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
   if upper(@i_update_table_name)='QSICOMMENTS_EXT' begin
      updatetext qsicomments_ext.commentbody @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
END	


if upper(@i_update_table_name)='BOOKCOMMENTS' begin
   if @v_invalid = 1 begin
      update bookcomments set invalidhtmlind = 1, commenthtmllite = '<DIV></DIV>'
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
   end else begin
      update bookcomments set invalidhtmlind= 0 
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
   end
end
if upper(@i_update_table_name)='QSICOMMENTS' begin
   if @v_invalid = 1 begin
      update qsicomments set invalidhtmlind = 1, commenthtmllite = '<DIV></DIV>' 
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
   end else begin
      update qsicomments set invalidhtmlind = 0 
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
   end
end
if upper(@i_update_table_name)='BOOKCOMMENTS_EXT' begin
   if @v_invalid = 1 begin
      update bookcomments_ext set invalidhtmlind= 1, commentbody = '<DIV></DIV>' 
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   end else begin
      update bookcomments_ext set invalidhtmlind= 0 
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   end
end
if upper(@i_update_table_name)='QSICOMMENTS_EXT' begin
   if @v_invalid = 1 begin
      update qsicomments_ext set invalidhtmlind= 1, commentbody = '<DIV></DIV>' 
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   end else begin
      update qsicomments_ext set invalidhtmlind= 0 
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode and commentstyle = @i_commentstyle
   end
end

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.html_to_lite_from_row_process TO PUBLIC
GO










