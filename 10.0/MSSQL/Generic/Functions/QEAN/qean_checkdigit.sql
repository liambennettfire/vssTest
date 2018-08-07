if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qean_checkdigit') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qean_checkdigit
GO

CREATE FUNCTION qean_checkdigit (
  @passed_string  as varchar(50),
  @type	as int)

RETURNS CHAR(1)

/**********************************************************************************************
**  @type = 0  - Generate check digit for ISBN-10
**  @type = 1  - Generate check digit for EAN/ISBN-13
**  @type = 2  - Generate check digit for GTIN
**********************************************************************************************/

BEGIN
  DECLARE	
  @checkdigit char(1),
  @j 		int,
  @multiplier	int,
  @hash		int,
  @module		int,
  @ean_no_dashes  varchar(40),
  @weighted_total_first int,
  @weighted_total_second int,
  @string_len	int,
  @remainder	int,
  @weighted_total int
  
  --init variables 
  select @j = 0
  select @multiplier = 1
  select @hash = 0
  select @module = 0
  select @string_len = len(@passed_string) + 1
  select @weighted_total = 0
  select @weighted_total_first = 0
  select @weighted_total_second = 0

  -- **** generate check digit for ISBN-10 ****
  if @type = 0 begin
    while 1=1 begin
      select @j = @j + 1
      if @j > @string_len break
      if substring(@passed_string, @j, 1) = '-' continue
      select @hash = @hash + (substring(@passed_string, @j, 1) * @multiplier )
      select @multiplier  = @multiplier + 1
    end

    select @module = @hash % 11
    if @module = 10
      SET @checkdigit = 'X'
    else
      SET @checkdigit = substring(convert(varchar(50), @module), 1, 1)    
  end


  -- **** generate check digit for EAN/ISBN-13 ****
  if @type = 1 begin
    SET @ean_no_dashes = REPLACE(@passed_string, '-', '')

    SET @j = 0
    SET @string_len = len(@ean_no_dashes) + 1
    while 1=1 begin
      SET @j = @j + 1
      if @j > @string_len break
      SET @module = @j % 2
      if @module <> 0
        SET @weighted_total_second = @weighted_total_second + (convert(int, SUBSTRING(@ean_no_dashes, @j, 1)) * 1)
      else
        SET @weighted_total_first = @weighted_total_first + (convert(int, SUBSTRING(@ean_no_dashes, @j, 1)) * 3)
    end

    SET @weighted_total = @weighted_total_first + @weighted_total_second
    SET @module = @weighted_total % 10

    if @module > 0
      begin
        SET @checkdigit = convert(varchar(10), 10 - @module)
        if @checkdigit = '10'
          SET @checkdigit = 'X'
      end
    else
      SET @checkdigit = '0'
  end


  -- **** generate check digit for GTIN ****
  if  @type = 2 begin
    SET @ean_no_dashes = replace(@passed_string, '-', '')

    SET @j = 0
    SET @string_len = len(@ean_no_dashes) + 1
    while 1=1 begin
      SET @j = @j + 1
      if @j > @string_len break
      SET @module = @j % 2
      if @module <> 0
        SET @weighted_total_first = @weighted_total_first + (convert(int, SUBSTRING(@ean_no_dashes, @j, 1)) * 3)
      else
        SET @weighted_total_second = @weighted_total_second + (convert(int, SUBSTRING(@ean_no_dashes, @j, 1)) * 1)
    end

    SET @weighted_total = @weighted_total_first + @weighted_total_second
    SET @module = @weighted_total % 10

    if @module > 0
      begin
        SET @checkdigit = convert(varchar(10), 10 - @module)
        if @checkdigit = '10'
          SET @checkdigit = 'X'
      end 
    else
      SET @checkdigit = '0'
  end
  
  RETURN @checkdigit  
END
GO

GRANT EXEC ON dbo.qean_checkdigit TO PUBLIC
GO
