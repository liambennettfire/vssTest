drop procedure dbo.check_valid_html
go

create procedure dbo.check_valid_html(
  @i_html varchar(8000),
  @i_key int,
  @i_print_key int,
  @i_commenttypecode int,
  @i_commenttypesubcode int,
  @i_update_table_name varchar(100),
  @i_fromrowind int,
  @i_set_invalidhtmlind int,
  @o_invalidhtmlind int output)
as
BEGIN
declare @v_check_total int
declare @v_html varchar(8000)
declare @v_left int
declare @v_right int
declare @v_part int
declare @v_loop int
declare @loop int
declare @blob_portion varchar(8000)
declare @v_length int
declare @v_char char(1)

  set @o_invalidhtmlind = 0
  set @v_check_total = 0
  if @i_fromrowind = 1 
    begin
      if upper(@i_update_table_name)='BOOKCOMMENTS' 
        begin
          select @v_html = cast(commenthtml as varchar(8000)) 
            from bookcomments
            where bookkey = @i_key 
              and printingkey = @i_print_key 
              and commenttypecode = @i_commenttypecode 
              and commenttypesubcode = @i_commenttypesubcode   

        end
      if upper(@i_update_table_name)='QSICOMMENTS' 
        begin
          select @v_html = cast(commenthtml as varchar(8000))  
            from qsicomments
            where commentkey = @i_key 
              and commenttypecode = @i_commenttypecode 
              and commenttypesubcode = @i_commenttypesubcode   
        end
    end
  else
      begin
        set @v_html = @i_html 
      end

  --look for signs of html --
  if charindex('<DIV',@v_html,1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('<HTML',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('<HEAD',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('<P',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('<B',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('<I',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('<U',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('</',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end
  if charindex('&#',upper(@v_html),1) > 0 
    begin
      set @v_check_total = @v_check_total + 1
    end

  if @v_check_total > 0
    begin 
      set @o_invalidhtmlind = 0
    end 
  else
    begin 
      set @o_invalidhtmlind = 1
      goto set_invalid_html_ind
    end



--#######################################################
-- check that all opening brackets have closing brackets
--#######################################################
set @v_left = 0 
select @loop = 0
set @v_right = 0 
set @v_part = 7000

if @i_fromrowind = 1 begin
	if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
	    select @blob_portion =  SUBSTRING(commenthtml, 1, @v_part) 
	      from bookcomments
	      WHERE bookkey = @i_key 
	        AND printingkey = @i_print_key
	        AND commenttypecode = @i_commenttypecode
	        AND commenttypesubcode = @i_commenttypesubcode
	end
	if upper(@i_update_table_name) = 'QSICOMMENTS' begin
	    select @blob_portion =  SUBSTRING(commenthtml, 1, @v_part) 
	      from qsicomments
	      WHERE commentkey = @i_key 
	        AND commenttypecode = @i_commenttypecode
	        AND commenttypesubcode = @i_commenttypesubcode
	end
end else begin
	if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
	    select @blob_portion =  SUBSTRING(@i_html, 1, @v_part) 
	end
	if upper(@i_update_table_name) = 'QSICOMMENTS' begin
	    select @blob_portion =  SUBSTRING(@i_html, 1, @v_part) 
	end
end


WHILE @loop = 0 
 BEGIN
set @v_length = LEN(@blob_portion)
set @v_loop = 1
WHILE @v_loop <= @v_length
 BEGIN
     set @v_char = SUBSTRING(@blob_portion,@v_loop,1)

     set @v_loop = @v_loop + 1 
     if @v_char = '<' begin
	set @v_right = @v_right + 1
     end
     if @v_char = '>' begin
	set @v_left = @v_left + 1
     end
END	
	if @i_fromrowind = 1 begin
	    if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
	      select @blob_portion =  SUBSTRING(commenthtml, @v_part + 1, 7000) 
	      from bookcomments
	      WHERE bookkey = @i_key 
	        AND printingkey = @i_print_key
	        AND commenttypecode = @i_commenttypecode
	        AND commenttypesubcode = @i_commenttypesubcode
	    end
	   if upper(@i_update_table_name) = 'QSICOMMENTS' begin
	      select @blob_portion =  SUBSTRING(commenthtml, @v_part + 1, 7000) 
	      from qsicomments
	      WHERE commentkey = @i_key 
	        AND commenttypecode = @i_commenttypecode
	        AND commenttypesubcode = @i_commenttypesubcode
	   end
	end else begin
	   if upper(@i_update_table_name) = 'BOOKCOMMENTS' begin
	      select @blob_portion =  SUBSTRING(@i_html, @v_part + 1, 7000) 
	    end
	   if upper(@i_update_table_name) = 'QSICOMMENTS' begin
	      select @blob_portion =  SUBSTRING(@i_html, @v_part + 1, 7000) 
	   end
	end
	
	     set @v_part = @v_part + 7000
	
	     if @blob_portion = ' ' begin
		break
	     end
END
--print @v_right
--print @v_left
if @v_right <> @v_left
    begin 
      set @o_invalidhtmlind = 1
      goto set_invalid_html_ind
    end 
  else
    begin 
      set @o_invalidhtmlind = 0
   end






set_invalid_html_ind:
if @o_invalidhtmlind is null begin
  set @o_invalidhtmlind = 0 
end
  if @i_set_invalidhtmlind = 1 
    begin
      if upper(@i_update_table_name)='BOOKCOMMENTS' 
        begin
          update bookcomments
            set invalidhtmlind= @o_invalidhtmlind 
            where bookkey = @i_key 
              and printingkey = @i_print_key 
              and commenttypecode = @i_commenttypecode 
              and commenttypesubcode = @i_commenttypesubcode   
        end 
    if upper(@i_update_table_name)='QSICOMMENTS' 
      begin
        update qsicomments
          set invalidhtmlind= @o_invalidhtmlind 
          where commentkey = @i_key 
            and commenttypecode = @i_commenttypecode 
            and commenttypesubcode = @i_commenttypesubcode   
      end
  end

END 

