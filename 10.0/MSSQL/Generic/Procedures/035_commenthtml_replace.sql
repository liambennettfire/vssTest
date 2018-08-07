DROP  Procedure  dbo.commenthtml_replace
GO

CREATE PROCEDURE dbo.commenthtml_replace
  @i_bookkey int,
  @i_printingkey int,
  @i_commenttypecode int,
  @i_commenttypesubcode int,
  @i_from_str varchar(100),
  @i_to_str varchar(100)
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
    @v_workkey int,
    @v_char char(1),
    @v_char_converted char(20),
    @v_unicode varchar(20),
    @v_scr_ptr binary(16),
    @v_dst_ptr binary(16),
    @v_errcode int,
    @v_errmsg varchar(500)


--Init variables
  select @v_loop_infi = 0
  select @loop = 0
  select @insert_offset = 0
  select @relative_pos_start = 0
  select @start_search_location = 0
  set @v_sec_length = 7000
  set @v_sec_point = 0
  set @v_complete = 0

--move comment to work table
  select @v_workkey = coalesce(max(commentkey),0)+1
    from commentwork
  insert into commentwork
    (commentkey,commenttext)
    values
    (@v_workkey,'')
  SELECT @v_scr_ptr = TEXTPTR(commenthtml) 
    FROM bookcomments
    where bookkey = @i_bookkey
      AND printingkey = @i_printingkey
      AND commenttypecode = @i_commenttypecode
      AND commenttypesubcode = @i_commenttypesubcode  
  SELECT @v_dst_ptr = TEXTPTR(commenttext) 
    FROM commentwork
    where commentkey = @v_workkey
  updatetext commentwork.commenttext @v_dst_ptr 0 0  bookcomments.commenthtml @v_scr_ptr
      
--Reset blob value in table and get blob pointer
  update bookcomments
    set commenthtml = ''
    WHERE bookkey = @i_bookkey
      AND printingkey = @i_printingkey
      AND commenttypecode = @i_commenttypecode
      AND commenttypesubcode = @i_commenttypesubcode  
  select @blob_pointer = textptr(commenthtml)
    FROM bookcomments
    WHERE bookkey = @i_bookkey
      AND printingkey = @i_printingkey
      AND commenttypecode = @i_commenttypecode
      AND commenttypesubcode = @i_commenttypesubcode  
  select @blob_portion = SUBSTRING(commenttext, 1, @v_sec_length) 
    FROM commentwork
    where commentkey = @v_workkey
              
  set @v_length_org = len(coalesce(@blob_portion,'')+'x')-1
  WHILE @v_complete = 0
    BEGIN -- loop full comment 
                    
      WHILE @loop = 0
        BEGIN -- loop comment part
                  
          set @blob_portion=replace(@blob_portion,@i_from_str,@i_to_str)
                      
          updatetext bookcomments.commenthtml @blob_pointer @insert_offset null  @blob_portion
          set @insert_offset = @insert_offset+len(@blob_portion+'x')-1
                          
          if @v_length_org < @v_sec_length
            begin
              set @v_complete = 1 --nothing left to read
              break
            end
          else 
            begin
              set @v_sec_point = @v_sec_point +@v_sec_length - @v_sec_adjust
              --  get next section of html to be converted
              select @blob_portion = SUBSTRING(commenttext, @v_sec_point, @v_sec_length) 
                FROM commentwork
                where commentkey = @v_workkey
              set @v_length_org = len(coalesce(@blob_portion,'')+'x')-1
              if @v_length_org  = 0
                begin
                  set @v_complete = 1
                  break
                end 
            end 
        end  -- loop comment part
    END -- loop full comment
                       
  delete from commentwork where commentkey=@v_workkey
  exec html_to_lite_from_row @i_bookkey,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
  exec html_to_text_from_row @i_bookkey,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
                        
end
GO
GRANT EXEC ON commenthtml_replace TO PUBLIC
GO
