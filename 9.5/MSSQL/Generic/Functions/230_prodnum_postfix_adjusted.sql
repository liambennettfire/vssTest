drop FUNCTION dbo.prodnum_postfix_adjusted
go

CREATE FUNCTION dbo.prodnum_postfix_adjusted
  (@i_prefix varchar(20),@i_postfix varchar(20),@i_type int)
   RETURNS varchar(50)
/*
 Adjusts the ISBN10 postfix depending on setup for use with qean_generate_ean procedure
   @i_type = 0  - Generate check digit for ISBN-10
   @i_type = 1  - Generate check digit for EAN/ISBN-13
   @i_type = 2  - Generate check digit for GTIN
*/
BEGIN

  declare 
    @v_prefix varchar(20),
    @v_postfix varchar(20),
    @v_postfix_part varchar(20),
    @v_isbn_part varchar(20),
    @v_check_digit char(1),
    @v_product_type varchar(10),
    @o_new_postfix varchar(50)

  set @v_prefix=replace(@i_prefix,'-','')
  set @v_postfix=replace(@i_postfix,'-','')
  select @v_product_type=columnname
    from productnumlocation
    where productnumlockey=1

  if @v_product_type='isbn'
    begin
      if @i_type=0
        begin
          set @o_new_postfix=@i_postfix
        end
      else
        begin
          set @v_isbn_part=@v_prefix+@v_postfix
          set @v_isbn_part=substring(@v_isbn_part,1,len(@v_isbn_part)-1)
          set @v_check_digit=dbo.qean_checkdigit(@v_isbn_part,0)
          set @o_new_postfix=substring(@v_isbn_part,len(@v_prefix)+1,20)+@v_check_digit
        end
    end
  else
    if @v_product_type='gtin'
      begin
        if @i_type=2
          begin
            set @o_new_postfix=@i_postfix
          end
        else
          begin
            set @v_isbn_part='0978'+@v_prefix+@v_postfix
            set @v_isbn_part=substring(@v_isbn_part,1,len(@v_isbn_part)-1)
            set @v_check_digit=dbo.qean_checkdigit(@v_isbn_part,2)
            set @o_new_postfix=substring(@v_isbn_part,len('0978'+@v_prefix)+1,20)+@v_check_digit
          end
      end
    else  -- default to EAN
      begin
        if @i_type=1
          begin
            set @o_new_postfix=@i_postfix
          end
        else
          begin
            set @v_isbn_part='978'+@v_prefix+@v_postfix
            set @v_isbn_part=substring(@v_isbn_part,1,len(@v_isbn_part)-1)
            set @v_check_digit=dbo.qean_checkdigit(@v_isbn_part,1)
            set @o_new_postfix=substring(@v_isbn_part,len('978'+@v_prefix)+1,20)+@v_check_digit
          end
      end

  RETURN @o_new_postfix 

END 
go

GRANT EXEC ON dbo.prodnum_postfix_adjusted TO public
GO
