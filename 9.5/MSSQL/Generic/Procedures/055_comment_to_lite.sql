drop procedure [dbo].[comment_to_lite]
GO

CREATE PROCEDURE dbo.comment_to_lite
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
    @v_sec_length int,
    @v_sec_point int,
    @v_loop int,
    @v_char char(1),
    @v_char_converted char(20),
    @v_unicode varchar(20),
    @v_exit_loop int,
    @v_part_ptr int,
    @v_tag_open int,
    @v_tag varchar(20),
    @v_contentind int,
    @v_string varchar(8000),
    @v_contains int

--Init variables
  set @loop = 0
  set @insert_offset = 0
  set @relative_pos_start = 0
  set @start_search_location = 0
  set @v_sec_length = 7000
  set @v_sec_point = 1
  set @o_sec_adjust = 0
  set @v_exit_loop = 0
  set @v_part_ptr = 1
  set @v_contentind = 0
  set @v_string = ''
  set @v_tag_open = 0
  while @v_exit_loop = 0
    begin
     ----find out if html is comming from MS Word and treat <p> diferently
     set @v_contains = CHARINDEX('<P CLASS', upper(@io_blob_part), 1)
-- set @v_contains = 10
      set @v_char = coalesce(substring(@io_blob_part,@v_part_ptr,1),'')
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
              set @v_tag='<br>'
              set @v_contentind = 0
            end  
	
          if upper(@v_tag) in ('<P>')
            begin
              if @v_contentind = 1 
                begin
 		  if @v_contains > 0
		    begin
                  	set @v_tag='<br>'
		    end
		    else
		       begin
			set @v_tag='<br><br>'
		    end
                end
              else
                begin
                  set @v_tag=''
                end
              set @v_contentind = 0
            end  
/*
         if upper(@v_tag) in ('<DIV>', '</DIV>')
            begin
              if @v_contentind = 1 
                begin
                  set @v_tag='<br>'
                end
              else
                begin
                  set @v_tag=''
                end
              set @v_contentind = 0
            end  
*/


	 if upper(@v_tag) in ('<DIV>')
	   begin
	     set @v_tag='<div>'
	 end

	 if upper(@v_tag) in ('</DIV>')
	   begin
	     set @v_tag='</div>'
	 end

         if upper(@v_tag) in ('</P>') 
            begin
 		  if @v_contains > 0
		    begin
                  	set @v_tag='<br>'
		    end
		    else
		       begin
			set @v_tag='<br><br>'
		    end
            end
          if upper(@v_tag) in ('<EM>','<I>') or upper(@v_tag) like '<I %' 
            begin
              set @v_tag='<i>'
            end
          if upper(@v_tag) in ('</EM>','</I>') 
            begin
              set @v_tag='</i>'
            end
          if upper(@v_tag) in ('<STRONG>','<B>') or upper(@v_tag) like '<B %'
            begin
              set @v_tag='<b>'
            end 
          if upper(@v_tag) in ('</STRONG>','</B>') 
            begin
              set @v_tag='</b>'
            end
          if upper(@v_tag) = '<U>' or upper(@v_tag) like '<U %'
            begin
              set @v_tag='<u>'
            end
          if upper(@v_tag) = '</U>'  
            begin
              set @v_tag='</u>'
            end
          if @v_tag not in ('<br><br>', '<br>','<i>','</i>','<b>','</b>','<u>','</u>', '</div>', '<div>')
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
                set @v_string = @v_string + @v_char
              end
          end
        else
          if @v_char not in ('<',char(13),char(10))
            begin 
              set @v_tag = @v_tag + @v_char
            end
--      end
        
      set @v_part_ptr = @v_part_ptr + 1
      if @v_part_ptr > datalength(@io_blob_part)
        begin
          if @v_tag_open = 1
            begin 
              set @o_sec_adjust = coalesce(datalength(@v_tag),0)
            end
          set @io_blob_part =  @v_string
          set @v_exit_loop = 1
        end
    end

  END  

GO

GRANT  EXECUTE  ON dbo.comment_to_lite TO public
GO


