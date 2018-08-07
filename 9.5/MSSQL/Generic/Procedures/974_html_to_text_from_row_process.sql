if exists (select * from dbo.sysobjects where id = Object_id('dbo.html_to_text_from_row_process') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.html_to_text_from_row_process 
end
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
/******************************************************************************
**  Desc: This stored procedure will pupulate commenttext column
**        replacing, html tags specified in htmltexttags table
**    Auth: Anes Hrenovica
**    Date: 10/6/2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
CREATE            PROCEDURE dbo.html_to_text_from_row_process
		     @i_key int,
		     @i_print_key int,
		     @i_commenttypecode int,
		     @i_commenttypesubcode int,
		     @i_update_table_name varchar(100),	
		     @o_openingtag  varchar(100),
		     @o_replacewith  varchar(max),
		     @o_closingtag varchar(100),
		     @blob_pointer varbinary (16)


AS

BEGIN 
DECLARE 
@loop int,
@v_del_len int,
@div_start int,
@div_end int,
@v_del_length int,
@v_invalid int,
@pos_start int,
@v_substring varchar(max),
@v_cnt int

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

   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
      select @div_start = PATINDEX ( @o_openingtag , commenttext )  from bookcomments
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
   end
   if upper(@i_update_table_name)='QSICOMMENTS' begin
      select @div_start = PATINDEX ( @o_openingtag , commenttext )  from qsicomments
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
   end
   if @div_start = 0 begin
      break
   end	

   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
--print '***************************************************'
--print '@i_key ' + cast(@i_key as varchar)
--print '@i_print_key ' + cast(@i_print_key as varchar)
--print '@i_commenttypecode ' + cast(@i_commenttypecode as varchar)
--print '@i_commenttypesubcode ' + cast(@i_commenttypesubcode as varchar)
--print '@i_update_table_name ' + @i_update_table_name
--print '@o_openingtag ' + @o_openingtag
--print '@o_closingtag ' + @o_closingtag

      select @v_substring = commenttext  from bookcomments
      where bookkey = @i_key and printingkey = @i_print_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode
      select @v_substring = substring(@v_substring, @div_start, datalength(@v_substring))
      select @div_end = CHARINDEX(@o_closingtag, @v_substring, 1)
   end

   if upper(@i_update_table_name)='QSICOMMENTS' begin
      select @v_substring = commenttext  from qsicomments
      where commentkey = @i_key and commenttypecode = @i_commenttypecode and commenttypesubcode = @i_commenttypesubcode   
      select @v_substring = substring(@v_substring, @div_start, datalength(@v_substring))
      select @div_end = CHARINDEX(@o_closingtag, @v_substring, 1)
   end

   if @div_end = 0 begin
      set @v_invalid = 1
      break
   end	

   set @div_end = @div_start + @div_end
   set @v_del_length = @div_end - @div_start + len(@o_closingtag) - 1
   set @div_start = @div_start - 1

--print '@div_start ' + cast(@div_start as varchar)
--print '@div_end ' + cast(@div_end as varchar)
--print '@v_del_length ' + cast(@v_del_length as varchar)
--print '@o_replacewith ' + @o_replacewith
--print '@v_substring ' + @v_substring
--
--print '***************************************************'

   if upper(@i_update_table_name)='BOOKCOMMENTS' begin
      updatetext bookcomments.commenttext @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
   if upper(@i_update_table_name)='QSICOMMENTS' begin
      updatetext qsicomments.commenttext @blob_pointer @div_start  @v_del_length  @o_replacewith
   end 
END	

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.html_to_text_from_row_process TO PUBLIC
GO



