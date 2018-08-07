DROP  Procedure  dbo.html_to_text_from_row
GO

CREATE PROCEDURE dbo.html_to_text_from_row
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
    @v_html_test varchar(8000),
    @v_invalidhtmlind int

--Init variables
  select @v_loop_infi = 0
  select @loop = 0
  select @insert_offset = 0
  select @relative_pos_start = 0
  select @start_search_location = 0
  set @v_sec_length = 7000
  set @v_sec_point = 0
  set @v_complete = 0

-- invalidate commenthtml looks like html
  select @v_html_test = cast(commenthtml as varchar(8000))
    from bookcomments
    where bookkey = @i_key
      and printingkey = @i_print_key
      and commenttypecode = @i_commenttypecode
      and commenttypesubcode = @i_commenttypesubcode 
  exec check_valid_html @v_html_test,@i_key,@i_print_key,@i_commenttypecode,@i_commenttypesubcode,@i_update_table_name,1,1,  @v_invalidhtmlind output
  if @v_invalidhtmlind = 1
    return

--Check for required parametars
  select @i_update_table_name = ltrim(@i_update_table_name)
  select @i_update_table_name = rtrim(@i_update_table_name)

  if @i_commenttypesubcode = null begin
    set @i_commenttypesubcode = 0
  end

  if @i_key = 0 or @i_key =  null or 
    @i_commenttypecode = 0 or @i_commenttypecode = null or 
    @i_update_table_name = '' or @i_update_table_name = null  
    begin
      select @o_error_desc = 'commenttypecode, update_table_name are Required Parametars'
      return -1
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
        where keyid = 1
      select @blob_pointer = textptr(htmldata)
        from temp_blob
        where keyid = 1
    end 
                      
   --  get first section of html to be converted
  if upper(@i_update_table_name) = 'BOOKCOMMENTS'
    begin
      select @blob_portion = SUBSTRING(commenthtml, 1, @v_sec_length) 
        from bookcomments
        where bookkey = @i_key   
          AND printingkey = @i_print_key  
          AND commenttypecode = @i_commenttypecode  
          AND commenttypesubcode = @i_commenttypesubcode  
    end 
  if upper(@i_update_table_name) = 'QSICOMMENTS' 
    begin
      select @blob_portion = SUBSTRING(commenthtml, 1, @v_sec_length) 
        from qsicomments
        where commentkey = @i_key 
          AND commenttypecode = @i_commenttypecode  
          AND commenttypesubcode = @i_commenttypesubcode
    end 
--  if  upper(@i_update_table_name) = 'TEMP_BLOB' 
--    begin
--      select @blob_pointer = SUBSTRING(commenthtml, 1, @v_sec_length) 
--        from temp_blob
--        where keyid = 1
--    end 
--print 'datalength(@blob_portion) first section '+cast(datalength(@blob_portion) as varchar(20))

  set @v_length_org = datalength(@blob_portion)
                  
  WHILE @v_complete = 0
    BEGIN -- loop full comment 
                    
      WHILE @loop = 0
        BEGIN -- loop comment part
                  
          exec comment_to_text @blob_portion output, @v_sec_adjust  output,@o_error_code output,@o_error_desc output
             
          if upper(@i_update_table_name) = 'BOOKCOMMENTS'  
            begin  
              updatetext bookcomments.commenttext @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+datalength(@blob_portion)
            end
          if upper(@i_update_table_name) = 'QSICOMMENTS' 
            begin  
              updatetext qsicomments.commenttext @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+datalength(@blob_portion)
            end
          if upper(@i_update_table_name) = 'TEMP_BLOB'
            begin  
              updatetext temp_blob.htmldata @blob_pointer @insert_offset 0  @blob_portion
              set @insert_offset = @insert_offset+datalength(@blob_portion)
            end
--print 'get next section...'                          
          if @v_length_org < @v_sec_length
            begin
              set @blob_portion = dbo.comment_trim(@blob_portion,'TEXT')
--print 'datalength(@blob_portion) post trim '+cast(coalesce(datalength(@blob_portion),0) as varchar(20))
              set @v_complete = 1 --nothing left to read
              break
            end
          else 
            begin
--print '@v_sec_point '+cast(coalesce(@v_sec_point,999) as varchar(20))
--print '@v_sec_length '+cast(coalesce(@v_sec_length,999) as varchar(20))
--print '@v_sec_adjust '+cast(coalesce(@v_sec_adjust,999) as varchar(20))

              set @v_sec_point = @v_sec_point +@v_sec_length - coalesce(@v_sec_adjust,0)
-- old              select @blob_portion =  SUBSTRING(commenthtml, @v_sec_point+1, @v_sec_length) 
              --  get next section of html to be converted
--print '...for sure...'
--print upper(@i_update_table_name)
              if upper(@i_update_table_name) = 'BOOKCOMMENTS'
                begin
--print '@v_sec_point '+cast(coalesce(@v_sec_point,0) as varchar(20))
                  select @blob_portion = SUBSTRING(commenthtml, @v_sec_point , @v_sec_length) 
                    from bookcomments
                    where bookkey = @i_key
                      AND printingkey = @i_print_key  
                      AND commenttypecode = @i_commenttypecode  
                      AND commenttypesubcode = @i_commenttypesubcode   
                end  
              if upper(@i_update_table_name) = 'QSICOMMENTS' 
                begin
                  select @blob_portion = SUBSTRING(commenthtml, @v_sec_point , @v_sec_length) 
                    from qsicomments
                    where commentkey = @i_key 
                      AND commenttypecode = @i_commenttypecode  
                      AND commenttypesubcode = @i_commenttypesubcode
--print 'datalength(@blob_portion) next section '+cast(datalength(@blob_portion) as varchar(20))

                end 
--              if upper(@i_update_table_name) = 'TEMP_BLOB' 
--                begin
--                  select @blob_pointer = SUBSTRING(commenthtml, @v_sec_point , @v_sec_length) 
--                    from temp_blob
--                    where keyid = 1 
--                  end 
              set @v_length_org = datalength(@blob_portion)
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
GRANT EXEC ON dbo.html_to_text_from_row TO PUBLIC
GO
