DROP  Procedure  dbo.convert_update_html_to_lite
GO

CREATE PROCEDURE dbo.convert_update_html_to_lite
  @i_html  text, 
  @i_key int,
  @i_print_key int,
  @i_commenttypecode int,
  @i_commenttypesubcode int,
  @i_update_table_name varchar(100),
  @o_error_code     int     output,
  @o_error_desc     varchar(2000) output
AS

BEGIN 
  DECLARE 
    @v_invalidhtmlind int,
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
    @v_length_org int,
    @v_sec_length int,
    @v_sec_point int,
    @v_sec_adjust int,
    @v_complete int,
    @v_loop int,
    @v_loop_infi int,
    @v_char char(1),
    @v_char_converted char(20),
    @v_unicode varchar(20),
    @v_pbind  varchar(20),
    @v_html_len int,
    @v_cnt int,
    @v_tag  varchar(8000),
    @v_char_next char(1),
    @v_loop_done int

select @v_pbind =  SUBSTRING(@i_html, 1, 2)

if  @v_pbind <> 'PB' begin
-- invalidate commenthtml looks like html
  exec check_valid_html @i_html,@i_key,@i_print_key,@i_commenttypecode,@i_commenttypesubcode,@i_update_table_name,0,1,  @v_invalidhtmlind output
  if @v_invalidhtmlind = 1
    return
end 

--Init variables
  set @v_loop_infi = 0
  set @loop = 0
  set @insert_offset = 0
  set @relative_pos_start = 0
  set @start_search_location = 0
  set @v_sec_length = 7000
  set @v_sec_point = 0
  set @v_complete = 0
  set @v_cnt = 0
  set @v_loop_done = 0
  set @insert_offset = 0

--Check for required parametars
  set @i_update_table_name = ltrim(@i_update_table_name)
  set @i_update_table_name = rtrim(@i_update_table_name)

--Reset blob value in table and get blob pointer
  if upper(@i_update_table_name) = 'BOOKCOMMENTS'
    begin
      update bookcomments
        set commenthtmllite = ''
        WHERE bookkey = @i_key
          AND printingkey = @i_print_key
          AND commenttypecode = @i_commenttypecode
          AND commenttypesubcode = @i_commenttypesubcode  
     -- set @insert_offset = @insert_offset+datalength('<div>')
      select @blob_pointer = textptr(commenthtmllite)
        from bookcomments
        where bookkey = @i_key
          AND printingkey = @i_print_key  
          AND commenttypecode = @i_commenttypecode  
          AND commenttypesubcode = @i_commenttypesubcode  
    end 
 
  if upper(@i_update_table_name) = 'QSICOMMENTS' 
    begin
      update qsicomments
        set commenthtmllite = ''
       WHERE commentkey = @i_key 
         AND commenttypecode = @i_commenttypecode 
         AND commenttypesubcode = @i_commenttypesubcode  
    --  set @insert_offset = @insert_offset+datalength('<div>')
      select @blob_pointer = textptr(commenthtmllite)
        from qsicomments
        where commentkey = @i_key 
          AND commenttypecode = @i_commenttypecode  
          AND commenttypesubcode = @i_commenttypesubcode
    end 

  if  upper(@i_update_table_name) = 'TEMP_BLOB' 
    begin
      update temp_blob
        set htmldata = ''
        where keyid = @i_key
    -- set @insert_offset = @insert_offset+datalength('<div>')
      select @blob_pointer = textptr(htmldata)
        from temp_blob
        where keyid = @i_key
    end 


  if  @v_pbind = 'PB' 
	begin
   	select @blob_portion =  SUBSTRING(htmldata, 1, @v_sec_length) from temp_blob where keyid = @i_key + 20000 
	end
  else
        begin
  	set @blob_portion =  SUBSTRING(@i_html, 1, @v_sec_length) 
        end

  set @v_length_org = datalength(@blob_portion)
                
  WHILE @v_complete = 0
    BEGIN -- loop full comment 
                    
      WHILE @loop = 0
        BEGIN -- loop comment part
                  
         exec comment_to_lite @blob_portion output, @v_sec_adjust  output,@o_error_code output,@o_error_desc output


              set @v_loop_infi = 0
              set @v_length = datalength(@blob_portion)
              set @v_loop = 1
              WHILE @v_loop <= @v_length
                BEGIN  -- loop part for unicodes
                  set @v_char = SUBSTRING(@blob_portion,@v_loop,1)
                  set @v_loop = @v_loop + 1 
                  set @v_unicode = UNICODE(@v_char)
                  if @v_unicode > 127
                    begin
                      set @v_char_converted = '&#' + @v_unicode + ';'
                      set @blob_portion = REPLACE ( @blob_portion , @v_char , @v_char_converted )
                      set @v_length = datalength(@blob_portion)
                    end
                  set @v_loop_infi = @v_loop_infi + 1
                  if  @v_loop_infi > 20000 
                    begin
                      break  
                    end  
                end  -- loop part for unicodes


	   --remove all <BR> from the end of html if is paste process  
	   if upper(@i_update_table_name) = 'TEMP_BLOB'  begin
		   if len(@blob_portion) < 7000 begin
			set @v_html_len = len(@blob_portion)
			   while @v_loop_done = 0 begin
				    set @v_char = substring(@blob_portion, @v_html_len - @v_cnt, 1)
				    set @v_tag = @v_char + @v_tag
				        if @v_char = '<'  begin
				           set @v_char_next = substring(@blob_portion, @v_html_len - (@v_cnt + 1), 1)
				           if @v_char_next <> '>' begin
				              set @blob_portion = substring(@blob_portion, 1, @v_html_len - len(@v_tag))
				              set @v_tag = replace(@v_tag, '<br>' , '')
				              set @blob_portion = @blob_portion +  @v_tag
				              set @v_loop_done = 1
				            end
				         end        
				    set @v_cnt = @v_cnt + 1
			   end 
		   end
	     end


          if upper(@i_update_table_name) = 'BOOKCOMMENTS'  
            begin  
              updatetext bookcomments.commenthtmllite @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+datalength(@blob_portion)
            end
          if upper(@i_update_table_name) = 'QSICOMMENTS' 
            begin  
              updatetext qsicomments.commenthtmllite @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+datalength(@blob_portion)
            end
          if upper(@i_update_table_name) = 'TEMP_BLOB'
            begin  
              updatetext temp_blob.htmldata @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+datalength(@blob_portion)
            end
                          
          if @v_length_org < @v_sec_length
            begin
              set @v_complete = 1 --nothing left to read
              break
            end
          else 
            begin
              set @v_sec_point = @v_sec_point +@v_sec_length - @v_sec_adjust

	  if  @v_pbind = 'PB'
		begin
	   	select @blob_portion =  SUBSTRING(htmldata, @v_sec_point+1, @v_sec_length) from temp_blob where keyid = @i_key + 20000 
		end
	  else
	        begin
		select @blob_portion =  SUBSTRING(@i_html, @v_sec_point+1, @v_sec_length) 
	        end
	
		     set @v_length_org = datalength(@blob_portion)
	              if @v_length_org  = 0
	                begin
	                  set @v_complete = 1
	                  break
	                end 
	            end 
        end  -- loop comment part
    END -- loop full comment
 /*                    
    if upper(@i_update_table_name) = 'BOOKCOMMENTS'  
      begin  
        updatetext bookcomments.commenthtmllite @blob_pointer @insert_offset 0  '</div>'
          set @insert_offset = @insert_offset+datalength('</div>')
      end
    if upper(@i_update_table_name) = 'QSICOMMENTS' 
      begin  
        updatetext qsicomments.commenthtmllite @blob_pointer @insert_offset 0  '</div>'
          set @insert_offset = @insert_offset+datalength('</div>')
      end

    if upper(@i_update_table_name) = 'TEMP_BLOB' 
      begin  
        updatetext temp_blob.htmldata @blob_pointer @insert_offset 0  '</div>'
          set @insert_offset = @insert_offset+datalength('</div>')
      end
*/
                   
end

GO
GRANT EXEC ON convert_update_html_to_lite TO PUBLIC
GO








