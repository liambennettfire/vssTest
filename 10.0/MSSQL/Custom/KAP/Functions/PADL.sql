 -- Returns a string from an expression, padded with spaces or characters to a specified length on the left or right sides, or both.
 -- PADL similar to the Oracle function PL/SQL  LPAD 
CREATE function PADL  (@cString nvarchar(4000), @nLen smallint, @cPadCharacter nvarchar(4000) = ' ' )
returns nvarchar(4000)
as
  begin
        declare @length smallint, @lengthPadCharacter smallint
        if @cPadCharacter is NULL or  datalength(@cPadCharacter) = 0
           set @cPadCharacter = space(1) 
        select  @length = datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,'BaseType') when 'nvarchar' then 2  else 1 end) -- for unicode
        select  @lengthPadCharacter = datalength(@cPadCharacter)/(case SQL_VARIANT_PROPERTY(@cPadCharacter,'BaseType') when 'nvarchar' then 2  else 1 end) -- for unicode

        if @length >= @nLen
           set  @cString = left(@cString, @nLen)
        else
	       begin
              declare @nLeftLen smallint
              set @nLeftLen = @nLen - @length  -- Quantity of characters, added at the left
              set @cString = left(replicate(@cPadCharacter, ceiling(@nLeftLen/@lengthPadCharacter) + 2), @nLeftLen)+ @cString
           end

    return (@cString)
  end
