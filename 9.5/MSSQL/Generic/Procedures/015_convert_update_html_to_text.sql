DROP PROCEDURE dbo.convert_update_html_to_text
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE  PROCEDURE dbo.convert_update_html_to_text
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
    @v_pbind  varchar(20)

select @v_pbind =  SUBSTRING(@i_html, 1, 2)

if  @v_pbind <> 'PB' begin
-- invalidate commenthtml looks like html
  exec check_valid_html @i_html,@i_key,@i_print_key,@i_commenttypecode,@i_commenttypesubcode,@i_update_table_name,0,1,  @v_invalidhtmlind output
  if @v_invalidhtmlind = 1 begin
    return
  end
end 


--Init variables
  select @v_loop_infi = 0
  select @loop = 0
  select @insert_offset = 0
  select @relative_pos_start = 0
  select @start_search_location = 0
  set @v_sec_length = 7000
  set @v_sec_point = 0
  set @v_complete = 0

--Check for required parametars
  select @i_update_table_name = ltrim(@i_update_table_name)
  select @i_update_table_name = rtrim(@i_update_table_name)

if  @v_pbind <> 'PB' begin
  if @i_key = 0 or @i_key =  null or 
    @i_commenttypecode = 0 or @i_commenttypecode = null or 
    @i_commenttypesubcode = 0 or @i_commenttypesubcode = null or 
    @i_update_table_name = '' or @i_update_table_name = null  
    begin
      select @o_error_desc = 'commenttypecode, commenttypesubcode, update_table_name are Required Parametars'
      return -1
    end 
end

--Reset blob value in table and get blob pointer
  if upper(@i_update_table_name) = 'BOOKCOMMENTS'
    begin
      update bookcomments
        set commenttext = ''
        WHERE bookkey = @i_key
          AND printingkey = @i_print_key
          AND commenttypecode = @i_commenttypecode
          AND commenttypesubcode = @i_commenttypesubcode  
      select @blob_pointer = textptr(commenttext)
        from bookcomments
        where bookkey = @i_key
          AND printingkey = @i_print_key  
          AND commenttypecode = @i_commenttypecode  
          AND commenttypesubcode = @i_commenttypesubcode  
    end 
 
  if upper(@i_update_table_name) = 'QSICOMMENTS' 
    begin
      update qsicomments
        set commenttext = ''
       WHERE commentkey = @i_key 
         AND commenttypecode = @i_commenttypecode 
         AND commenttypesubcode = @i_commenttypesubcode  
      select @blob_pointer = textptr(commenttext)
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
      select @blob_pointer = textptr(htmldata)
        from temp_blob
        where keyid = @i_key
    end 


 if  @v_pbind = 'PB' 
   begin                    
   select @blob_portion =  SUBSTRING(htmldata, 1, @v_sec_length) from temp_blob where keyid =  @i_key + 20000
   end
  else
   begin
   set @blob_portion =  SUBSTRING(@i_html, 1, @v_sec_length) 
  end

  set @v_length_org = len(@blob_portion+'x')-1
                  
  WHILE @v_complete = 0
    BEGIN -- loop full comment 
                    
      WHILE @loop = 0
        BEGIN -- loop comment part
             
          exec comment_to_text @blob_portion output, @v_sec_adjust output,@o_error_code output,@o_error_desc output
print @v_sec_adjust
                         
          if upper(@i_update_table_name) = 'BOOKCOMMENTS'  
            begin  
              updatetext bookcomments.commenttext @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+len(@blob_portion+'x')-1
            end
          if upper(@i_update_table_name) = 'QSICOMMENTS' 
            begin  
              updatetext qsicomments.commenttext @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+len(@blob_portion+'x')-1
            end
          if upper(@i_update_table_name) = 'TEMP_BLOB'
            begin  
              updatetext temp_blob.htmldata @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+len(@blob_portion+'x')-1
            end
                          
          if @v_length_org < @v_sec_length
            begin
              set @blob_portion = dbo.comment_trim(@blob_portion,'TEXT')
              set @v_complete = 1 --nothing left to read
              break
            end
          else 
            begin

              set @v_sec_point = @v_sec_point + @v_sec_length

	      if  @v_pbind = 'PB'  	
                begin
		select @blob_portion =  SUBSTRING(htmldata, @v_sec_point+1, @v_sec_length) from temp_blob where keyid = @i_key + 20000 

		end 
	      else
		begin
		select @blob_portion =  SUBSTRING(@i_html, @v_sec_point+1, @v_sec_length) 
		end

              set @v_length_org = len(@blob_portion+'x')-1
              if @v_length_org  = 0
                begin
                  set @v_complete = 1
                  break
                end 
            end 
        end  -- loop comment part
    END -- loop full comment
                        
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GO
GRANT EXEC ON convert_update_html_to_text TO PUBLIC
GO


