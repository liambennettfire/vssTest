CREATE function PADR  (@cString nvarchar(4000), @nLen smallint, @cPadCharacter nvarchar(4000) = ' ' )
returns nvarchar(4000)
as
   begin
       declare @length smallint, @lengthPadCharacter smallint
       if @cPadCharacter is NULL or  datalength(@cPadCharacter) = 0
          set @cPadCharacter = space(1) 
       select  @length  = datalength(@cString)/(case SQL_VARIANT_PROPERTY(@cString,'BaseType') when 'nvarchar' then 2  else 1 end) -- for unicode
       select  @lengthPadCharacter  = datalength(@cPadCharacter)/(case SQL_VARIANT_PROPERTY(@cPadCharacter,'BaseType') when 'nvarchar' then 2  else 1 end) -- for unicode

       if @length >= @nLen
          set  @cString = left(@cString, @nLen)
       else
          begin
             declare  @nRightLen smallint
             set @nRightLen  =  @nLen - @length -- Quantity of characters, added on the right
             set @cString =  @cString + left(replicate(@cPadCharacter, ceiling(@nRightLen/@lengthPadCharacter) + 2), @nRightLen)
	  end

     return (@cString)
    end
GO
