if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[html_to_lite_from_row]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[html_to_lite_from_row]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE     PROCEDURE dbo.html_to_lite_from_row
		     @i_key int,
		     @i_print_key int,
		     @i_commenttypecode int,
		     @i_commenttypesubcode int,
		     @i_update_table_name varchar(100),
		     @o_error_code     int 		output,
		     @o_error_desc     varchar(2000) output

AS

BEGIN 
DECLARE 
@blob_pointer varbinary (16),
@pos_start int,
@pos_end   int,
@blob_portion varchar(8000),
@v_trim varchar(8000),
@del_len int,
@loop int,
@pos_to_remain int,
@len_to_del int,
@insert_offset int,
@relative_pos_start int,
@start_search_location int,
@v_del_len int,
@div_start int,
@div_end int,
@substr_blob varchar(8000), 
@v_replace varchar(8000),
@v_length int,
@v_loop int,
@v_char char(1),
@v_char_converted char(20),
@v_unicode varchar(20),
@v_cnt integer,
@v_set_invalid_html_ind integer,
@v_infin_loop int,
@v_del_length int





--Init variables
select @loop = 0
select @insert_offset = 0
select @relative_pos_start = 0
select @start_search_location = 0
select @v_infin_loop = 8001
select @v_set_invalid_html_ind = 0


--Check for required parametars
select @i_update_table_name = ltrim(@i_update_table_name)
select @i_update_table_name = rtrim(@i_update_table_name)



--Reset blob value in table and get blob pointer
if upper(@i_update_table_name) = 'TEMP_BLOB'  begin

	update temp_blob
	set htmldata = ''
	where keyid = 100
	select @o_error_code = @@error 

        select @blob_pointer =  textptr(htmldata) 
        from temp_blob
        where keyid = 100  

end	


if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin

	update bookcomments
	set commenthtmllite = ''
	WHERE bookkey = @i_key AND
	printingkey = @i_print_key AND
	commenttypecode = @i_commenttypecode AND
	commenttypesubcode = @i_commenttypesubcode	

	select @blob_pointer = textptr(commenthtmllite)
	from bookcomments
	where bookkey = @i_key AND
	printingkey = @i_print_key AND
	commenttypecode = @i_commenttypecode AND
	commenttypesubcode = @i_commenttypesubcode	
end	
if  upper(@i_update_table_name) = 'QSICOMMENTS' begin

	update qsicomments
	set commenthtmllite = ''
	WHERE commentkey = @i_key AND
	commenttypecode = @i_commenttypecode AND
	commenttypesubcode = @i_commenttypesubcode	


	select @blob_pointer = textptr(commenthtmllite)
	from qsicomments
	where commentkey = @i_key AND
	commenttypecode = @i_commenttypecode AND
	commenttypesubcode = @i_commenttypesubcode
end 



if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
    select @blob_portion =  SUBSTRING(commenthtml, 1, 8000) 
      from bookcomments
      WHERE bookkey = @i_key 
        AND printingkey = @i_print_key
        AND commenttypecode = @i_commenttypecode
        AND commenttypesubcode = @i_commenttypesubcode
  end
if upper(@i_update_table_name) = 'QSICOMMENTS' begin
    select @blob_portion =  SUBSTRING(commenthtml, 1, 8000) 
      from qsicomments
      WHERE commentkey = @i_key 
        AND commenttypecode = @i_commenttypecode
        AND commenttypesubcode = @i_commenttypesubcode
  end

if upper(@i_update_table_name) = 'TEMP_BLOB'  begin
         select @blob_portion =  SUBSTRING(htmldata, 1, 8000) 
         from temp_blob
         where keyid = @i_key  
end	



WHILE @loop = 0 
 BEGIN

	WHILE @loop = 0 
	 BEGIN
	      select @blob_portion = REPLACE ( @blob_portion , '<STRONG>' , '&BOLD&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</STRONG>' , '&/BOLD&' )
	      select @blob_portion = REPLACE ( @blob_portion , '<EM>' , '&ITALIC&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</EM>' , '&/ITALIC&' )
	      select @blob_portion = REPLACE ( @blob_portion , '<U>' , '&UNDERLINE&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</U>' , '&/UNDERLINE&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</DIV>' , '&/DIV&' )
	      select @blob_portion = REPLACE ( @blob_portion , '<BR>' , '&BR&' )
	      select @blob_portion = REPLACE ( @blob_portion , '<BR/>' , '&BR&' )--mk:2012.11.01> CASE 21305
	      select @blob_portion = REPLACE ( @blob_portion , '<BR />' , '&BR&' )--mk:2012.11.01> CASE 21305
	      select @blob_portion = REPLACE ( @blob_portion , '<I>' , '&I&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</I>' , '&/I&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</B>' , '&/B&' )
	      select @blob_portion = REPLACE ( @blob_portion , '</P>' , '&/P&' )



	set @v_cnt = 0
	WHILE @loop = 0 
	 BEGIN
	     set @v_cnt = @v_cnt + 1
	     if @v_cnt > @v_infin_loop begin
	        set @v_set_invalid_html_ind = 1
		goto set_invalid_html_ind
	     end
	     select @div_start =  CHARINDEX('<DIV', @blob_portion, 1)
	     if @div_start = 0 begin
		break
	     end	
	     if @div_end = 0 begin
		goto set_invalid_html_ind
		break
	     end		
	     select @div_end = CHARINDEX('>', @blob_portion, @div_start)
	     select @substr_blob = SUBSTRING (@blob_portion, @div_start , @div_end - @div_start + 1) 
	     select @blob_portion = REPLACE (@blob_portion , @substr_blob , '&LLDIV&RR' )

	END	

	set @v_cnt = 0
	WHILE @loop = 0 
	 BEGIN
	     set @v_cnt = @v_cnt + 1
	     if @v_cnt > @v_infin_loop begin
	        set @v_set_invalid_html_ind = 1
		goto set_invalid_html_ind
	     end

	     select @div_start =  CHARINDEX('<DIV', @blob_portion, 1)
	     if @div_start = 0 begin
		break
	     end	
	     if @div_end = 0 begin
		goto set_invalid_html_ind
		break
	     end		
	     select @div_end = CHARINDEX('>', @blob_portion, @div_start)
	     select @substr_blob = SUBSTRING (@blob_portion, @div_start , @div_end - @div_start + 1) 
	     select @v_trim = REPLACE(@substr_blob, '<', '&LL')
	     select @v_trim = REPLACE(@v_trim, '>', '&RR')
	     select @blob_portion = REPLACE (@blob_portion , @substr_blob , @v_trim )
	END	

	set @v_cnt = 0
	WHILE @loop = 0 
	 BEGIN
	     set @v_cnt = @v_cnt + 1
	     if @v_cnt > @v_infin_loop begin
	        set @v_set_invalid_html_ind = 1
		goto set_invalid_html_ind
	     end
	     select @div_start =  CHARINDEX('<B', @blob_portion, 1)
	     select @div_end = CHARINDEX('>', @blob_portion, @div_start)
	     if @div_start = 0 begin
		break
	     end	
	     if @div_end = 0 begin
		goto set_invalid_html_ind
		break
	     end	
	     select @substr_blob = SUBSTRING (@blob_portion, @div_start , @div_end - @div_start + 1) 
	     select @blob_portion = REPLACE (@blob_portion , @substr_blob , '&LLB&RR')

	END		

	set @v_cnt = 0
	WHILE @loop = 0 
	 BEGIN
	     set @v_cnt = @v_cnt + 1
	     if @v_cnt > @v_infin_loop begin
	        set @v_set_invalid_html_ind = 1
		goto set_invalid_html_ind
	     end
	     select @div_start =  CHARINDEX('<P', @blob_portion, 1)
	     select @div_end = CHARINDEX('>', @blob_portion, @div_start)
	     if @div_start = 0 begin
		break
	     end	
	     if @div_end = 0 begin
		goto set_invalid_html_ind
		break
	     end	
	     select @substr_blob = SUBSTRING (@blob_portion, @div_start , @div_end - @div_start + 1) 
	     select @blob_portion = REPLACE (@blob_portion , @substr_blob , '&LLP&RR')

	END	

	set @v_cnt = 0
	WHILE @loop = 0 
	 BEGIN
	     set @v_cnt = @v_cnt + 1
	     if @v_cnt > @v_infin_loop begin
	        set @v_set_invalid_html_ind = 1
		goto set_invalid_html_ind
	     end
	     select @div_start =  CHARINDEX('<', @blob_portion)
	     select @div_end =  CHARINDEX('>', @blob_portion)
	     if @div_start = 0 begin
		break
	     end	
	     if @div_end = 0 begin
		goto set_invalid_html_ind
		break
	     end	

	     select @v_del_len = @div_end + 1 - @div_start
	     if @v_del_len < 0 begin
		goto set_invalid_html_ind
		break
	     end	

	     select @v_replace = SUBSTRING(@blob_portion, @div_start, @v_del_len)
	     select @blob_portion = REPLACE(@blob_portion, @v_replace, '')
	END	


	 select @blob_portion = REPLACE ( @blob_portion , '>', '&RR' )
	 SELECT @pos_start = CHARINDEX('<', @blob_portion, @start_search_location)
	 SELECT @pos_end = CHARINDEX('>', @blob_portion, @start_search_location)
	 if @pos_end = 0 and @pos_start > 0 begin
	 select @blob_portion = SUBSTRING(@blob_portion, 1, @pos_start - 1)
	 break
	 end	
	 if @pos_end = 0 begin
	 break
	 end
	
	 select @start_search_location = @pos_start
	 select @del_len = @pos_end + 1 - @pos_start
	 select @relative_pos_start = @relative_pos_start + @del_len
	 select @blob_portion = STUFF(@blob_portion, @pos_start, @del_len, '')

		
END


	select @blob_portion = REPLACE ( @blob_portion , '&BOLD&', '<STRONG>' )
	select @blob_portion = REPLACE ( @blob_portion , '&/BOLD&', '</STRONG>' )
        select @blob_portion = REPLACE ( @blob_portion , '&ITALIC&' , '<EM>' )
	select @blob_portion = REPLACE ( @blob_portion , '&/ITALIC&' , '</EM>' )
        select @blob_portion = REPLACE ( @blob_portion , '&UNDERLINE&' , '<U>' )
	select @blob_portion = REPLACE ( @blob_portion , '&/UNDERLINE&' , '</U>' )
        select @blob_portion = REPLACE ( @blob_portion , '&/DIV&' , '</DIV>' )
        select @blob_portion = REPLACE ( @blob_portion , '&LL' , '<' )
        select @blob_portion = REPLACE ( @blob_portion , '&RR' , '>' )
        select @blob_portion = REPLACE ( @blob_portion , '&BR&' , '<BR>' )
        select @blob_portion = REPLACE ( @blob_portion , '&I&' , '<I>' )
        select @blob_portion = REPLACE ( @blob_portion , '&/I&' , '</I>' )
        select @blob_portion = REPLACE ( @blob_portion , '&/B&' , '</B>' )
        select @blob_portion = REPLACE ( @blob_portion , '&/P&' , '</P>' )


	set @v_length = LEN(@blob_portion)
	set @v_loop = 1
	WHILE @v_loop <= @v_length
	 BEGIN
	     set @v_char = SUBSTRING(@blob_portion,@v_loop,1)
	     set @v_loop = @v_loop + 1 
	     set @v_unicode = UNICODE(@v_char)
		if @v_unicode > 127 begin
		    set @v_char_converted = '&#' + @v_unicode + ';'
		    set @blob_portion = REPLACE ( @blob_portion , @v_char , @v_char_converted )
		    set @v_length = LEN(@blob_portion)
		end
	END	

	if len(@blob_portion) < @insert_offset begin
	break
	end

	if  upper(@i_update_table_name) = 'BOOKCOMMENTS'  begin	
		updatetext bookcomments.commenthtmllite @blob_pointer @insert_offset 0  @blob_portion
		select @insert_offset = len(@blob_portion) + 1
	end
	if  upper(@i_update_table_name) = 'QSICOMMENTS'  begin	
		updatetext qsicomments.commenthtmllite @blob_pointer @insert_offset 0  @blob_portion
		select @insert_offset = len(@blob_portion) + 1
	end

	if upper(@i_update_table_name) = 'TEMP_BLOB'  begin
		updatetext temp_blob.htmldata @blob_pointer @insert_offset 0  @blob_portion
		select @insert_offset = len(@blob_portion) + 1
	end 

		
	if @pos_start = 0 and @pos_end = 0 begin
	 break
	end 

-- old	select @blob_portion =  SUBSTRING(@i_html, @relative_pos_start -1, 8000) 
        if upper(@i_update_table_name) = 'BOOKCOMMENTS'   begin
            select @blob_portion =  SUBSTRING(commenthtml, @relative_pos_start -1, 8000) 
              from bookcomments
              WHERE bookkey = @i_key 
                AND printingkey = @i_print_key
                AND commenttypecode = @i_commenttypecode
                AND commenttypesubcode = @i_commenttypesubcode
        end
	
	if upper(@i_update_table_name) = 'QSICOMMENTS'  begin
            select @blob_portion =  SUBSTRING(commenthtml, @relative_pos_start -1, 8000) 
              from qsicomments
              WHERE commentkey = @i_key 
                AND commenttypecode = @i_commenttypecode
                AND commenttypesubcode = @i_commenttypesubcode
        end
      
	if upper(@i_update_table_name) = 'TEMP_BLOB'  begin
         select @blob_portion =  SUBSTRING(htmldata,  @relative_pos_start -1, 8000) 
           from temp_blob
           WHERE keyid = @i_key 
        end

    END

        --remove other vendor specific characters
--	if  upper(@i_update_table_name) = 'QSICOMMENTS'  begin	
--		updatetext qsicomments.commenthtmllite @blob_pointer @insert_offset 0  @blob_portion
--		select @insert_offset = len(@blob_portion) + 1
--	end

	set @v_cnt = 0
	WHILE @loop = 0 
	 BEGIN
	     set @v_cnt = @v_cnt + 1
	     if @v_cnt > @v_infin_loop begin
	        set @v_set_invalid_html_ind = 1
		goto set_invalid_html_ind
	     end

	if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin	
	    select @div_start = PATINDEX ( '%<P CLASS%' , commenthtmllite ) 
	    from bookcomments
	    where bookkey = @i_key
	    and printingkey = @i_print_key
	    and commenttypecode = @i_commenttypecode
	    and commenttypesubcode = @i_commenttypesubcode

	     if @div_start = 0 begin
		break
	     end	

	    select @div_end = CHARINDEX('>', commenthtmllite, @div_start)
	    from bookcomments
	    where bookkey = @i_key
	    and printingkey = @i_print_key
	    and commenttypecode = @i_commenttypecode
	    and commenttypesubcode = @i_commenttypesubcode

	     if @div_end = 0 begin
	        goto set_invalid_html_ind
		break
	     end	
	end 
	if upper(@i_update_table_name) = 'QSICOMMENTS' begin	
	    select @div_start = PATINDEX ( '%<P CLASS%' , commenthtmllite ) 
	    from qsicomments
	    where commentkey = @i_key AND
	    commenttypecode = @i_commenttypecode AND
	    commenttypesubcode = @i_commenttypesubcode
	     if @div_start = 0 begin
		break
	     end	

	    select @div_end = CHARINDEX('>', commenthtmllite, @div_start)
	    from qsicomments
	    where commentkey = @i_key AND
	    commenttypecode = @i_commenttypecode AND
	    commenttypesubcode = @i_commenttypesubcode

	     if @div_end = 0 begin
	        goto set_invalid_html_ind
		break
	     end	
	end 
	set @v_del_length = @div_end - @div_start + 1
        set @div_start = @div_start - 1

       if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin	
	  updatetext bookcomments.commenthtmllite @blob_pointer @div_start  @v_del_length  '<P>'
       end	
       if upper(@i_update_table_name) = 'QSICOMMENTS' begin	
	  updatetext qsicomments.commenthtmllite @blob_pointer @div_start  @v_del_length  '<P>'
       end	

         END	


set_invalid_html_ind:
if upper(@i_update_table_name)='BOOKCOMMENTS' 
begin
  update bookcomments
    set invalidhtmlind= @v_set_invalid_html_ind 
    where bookkey = @i_key 
      and printingkey = @i_print_key 
      and commenttypecode = @i_commenttypecode 
      and commenttypesubcode = @i_commenttypesubcode   
end 
if upper(@i_update_table_name)='QSICOMMENTS' 
begin
update qsicomments
  set invalidhtmlind= @v_set_invalid_html_ind 
  where commentkey = @i_key 
    and commenttypecode = @i_commenttypecode 
    and commenttypesubcode = @i_commenttypesubcode   
end
END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


