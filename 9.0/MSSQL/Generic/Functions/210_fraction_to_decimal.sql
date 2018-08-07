if exists (select * from dbo.sysobjects where id = object_id(N'dbo.fraction_to_decimal') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.fraction_to_decimal
GO

CREATE FUNCTION dbo.fraction_to_decimal
 (@i_fraction varchar(40))

RETURNS float

BEGIN

DECLARE
  @lv_input          varchar(40),
  @lv_whole          varchar(40),
  @lv_fraction       varchar(40),
  @lv_numerator      varchar(40),
  @lv_denominator    varchar(40),
  @lv_wholepart      float,
  @lv_fractionalpart float,
  @lv_string_len     int,
  @lv_decimal	     float,
  @lv_pos            int,
  @lv_isnumeric      int

  SET @lv_input = ltrim(rtrim(@i_fraction))
  SET @lv_string_len = len(@lv_input) + 1
	 
  -- replace dashes with spaces
  SET @lv_input = replace(@lv_input, '-', ' ')

  -- replace double quotes with spaces
  SET @lv_input = replace(@lv_input, '"', ' ')

  SET @lv_input = ltrim(rtrim(@lv_input))
	 
  -- find space between whole number and fraction
  SET @lv_pos = charindex(' ',@lv_input)
	 
  -- break into whole number and fraction	 
  if @lv_pos = 0 begin
    SET @lv_pos = charindex('/',@lv_input)
    if @lv_pos > 0 begin
      -- fraction only
      SET @lv_whole = '0'
      SET @lv_fraction = rtrim(ltrim(@lv_input))
    end
    else begin
      -- no fraction
      SET @lv_whole = rtrim(ltrim(@lv_input))
      SET @lv_fraction = ''
    end
  end
  else begin 
    SET @lv_whole = rtrim(ltrim(substring(@lv_input, 1, @lv_pos)))
    SET @lv_fraction = ltrim(rtrim(substring(@lv_input, @lv_pos, @lv_string_len)))
  end
	 
  -- validate whole number
  SET @lv_isnumeric = isnumeric(@lv_whole)
  if @lv_isnumeric = 0 begin
    return -1
  end
 
  -- if only whole number, convert and go
  SET @lv_wholepart = CAST(@lv_whole as numeric)

  if @lv_fraction is null OR @lv_fraction = '' begin
    return(CAST(@lv_whole as numeric))
  end
	
  -- split fraction into numerator and denominator
  SET @lv_pos = charindex('/',@lv_fraction)

  if @lv_pos = 0 begin
    return -1
  end
  else begin 
    SET @lv_numerator = rtrim(ltrim(substring(@lv_fraction, 1, @lv_pos-1)))
    SET @lv_denominator = ltrim(rtrim(substring(@lv_fraction, @lv_pos+1, (len(@lv_fraction)+1))))

    if isnumeric(@lv_numerator) = 0 OR isnumeric(@lv_denominator) = 0 begin
      return -1
    end
     	   
    SET @lv_fractionalpart = CAST(@lv_numerator as numeric) / CAST(@lv_denominator as numeric)
  end
	
  SET @lv_decimal = @lv_wholepart + @lv_fractionalpart

  return(@lv_decimal)

END
GO

GRANT EXEC ON dbo.fraction_to_decimal TO public
GO
