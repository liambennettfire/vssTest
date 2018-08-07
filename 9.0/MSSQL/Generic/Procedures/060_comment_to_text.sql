drop procedure dbo.comment_to_text
GO

CREATE  PROCEDURE dbo.comment_to_text
  @io_blob_part varchar(8000) output,
  @o_sec_adjust int output,
  @o_error_code int output,
  @o_error_desc varchar(2000) output
AS

BEGIN 
  DECLARE 
    @blob_pointer varbinary (16),
    @pos_start int,
    @pos_end  int,
    @v_del_len  int,
    @v_max_adjust  int,
    @v_uni_value  varchar(20),
    @v_uni_str varchar(25),
    @v_uni_char char(1),
    @del_len int,
    @v_replace varchar(8000),
    @loop int,
    @pos_to_remain int,
    @len_to_del int,
    @insert_offset int,
    @relative_pos_start int,
    @start_search_location int,
    @v_newline varchar(10),
    @v_exit_loop int,
    @v_sample_offset int,
    @v_sample_len int,
    @v_resample_len int,
    @v_resample_ptr int,
    @v_tag_open int,
    @v_contentind int,
    @v_tag varchar(2000),
    @v_string varchar(8000),
    @v_part_offset int,
    @v_invalidhtmlind int,
    @v_text varchar(8000),
    @v_part_ptr int,
    @v_cut_start int,
    @v_cut_end int,
    @v_cut_str varchar(8000),
    @v_char char(1)

-- Init variables
  set @v_exit_loop = 0
  set @v_sample_offset = 1
  set @v_sample_len = 7000
  set @v_resample_len = 7000
  set @v_resample_ptr = 0
  set @v_tag_open = 0
  set @v_contentind = 0
  set @v_tag = ''
  set @v_string = ''
  set @v_part_offset = 0
  set @v_newline = char(13)+char(10)
                            
--print 'start comment_to_text'+cast(coalesce(datalength(@io_blob_part),0) as varchar(20))

  if coalesce(@v_invalidhtmlind,0)<>1 
    begin
      set @v_text = ''
      set @v_part_ptr = 1
      set @v_text = substring(@io_blob_part,@v_sample_offset,@v_sample_len)
      set @v_part_offset = datalength(@v_text)
      set @io_blob_part = replace(@v_text,@v_newline,'')
    --remove unsed sections
      set @v_cut_start = 1
      set @v_cut_end = 1
      while @v_cut_start > 0 and  @v_cut_end > 0
        begin
          set @v_cut_start = coalesce(charindex('<HEAD',@v_text,1),0) 
          if @v_cut_start > 0
            begin 
              set @v_cut_end = coalesce(charindex('/HEAD>',@v_text,1),0) 
            end
          if @v_cut_start> 0 and @v_cut_start < @v_cut_end 
            begin
              set @v_cut_str = substring(@v_text,@v_cut_start, @v_cut_end - @v_cut_start + 6)
              set @v_text = replace(@v_text,@v_cut_str ,'')
              set @io_blob_part = @v_text
            end
          else 
            begin
              set @v_cut_end=0
            end
        end 
    end     
 
    while @v_exit_loop=0 
      begin
        set @v_char = substring(@v_text,@v_part_ptr,1)
        -- start of a new html tag
        if @v_char = '<'
          begin
            set @v_tag_open = 1
            set @v_tag = '<'
          end
      -- closing an html tag
        if @v_char = '>'
          begin
            set @v_tag_open = 0
            set @v_tag = @v_tag + @v_char
            if upper(@v_tag) in ('<BR>','<BR />')
              begin
                set @v_tag=@v_newline
                set @v_contentind = 0
              end 
            if upper(@v_tag) in ('</DIV>', '<DIV>', '<P>')  
              or upper(@v_tag) like '<DIV %'
              or upper(@v_tag) like '<P %'
              begin
                if @v_contentind = 1
                  begin
                    set @v_tag=@v_newline
                  end
                else
                  begin
                    set @v_tag=''
                  end 
                set @v_contentind = 0
              end  
            if upper(@v_tag) in ('</P>')
              begin
                set @v_tag=@v_newline
                set @v_contentind = 0
              end
            if @v_tag <> @v_newline 
              begin
                set @v_tag=''
              end
          end
                   
        if @v_tag_open = 0  
          begin 
            if @v_char not in (' ','>',char(13),char(10)) 
              begin
                set @v_contentind = 1
              end
            if @v_char = '>'
              begin
                set @v_string = @v_string + @v_tag
              end
            else 
              begin
                if @v_char not in (char(13),char(10))
                  begin
                    set @v_string = @v_string + @v_char
                  end
              end
          end
        else
          if @v_char not in ('<',char(13),char(10))
            begin
              set @v_tag = @v_tag + @v_char
            end
               
        set @v_part_ptr = @v_part_ptr + 1
        if @v_part_ptr > datalength(@io_blob_part)
          begin
--            set @io_blob_part = @v_text + dbo.RESOLVE_HTML_SPEC_CHARS(@v_string)
            set @io_blob_part = dbo.RESOLVE_HTML_SPEC_CHARS(@v_string)
            set @v_exit_loop = 1
          end

        if @v_char is null
          begin
            set @v_exit_loop = 1
          end
      
      end

  end 
GO

GRANT  EXECUTE  ON dbo.comment_to_text TO public
GO


