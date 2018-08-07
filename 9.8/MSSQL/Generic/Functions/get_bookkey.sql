/****** Object:  UserDefinedFunction [dbo].[get_bookkey]    Script Date: 02/06/2013 08:54:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_bookkey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[get_bookkey]
GO


GO

/****** Object:  UserDefinedFunction [dbo].[get_bookkey]    Script Date: 02/06/2013 08:54:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[get_bookkey]
(
  @IsbnOrEAN varchar(40) --EAN or EAN13 or ISBN10 or ISBN13
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	declare @bookkey int
	set @bookkey =0
	if(left(@IsbnOrEAN,3)='978')
		begin
		if (len(@IsbnOrEAN)=13)
			begin
				Select @bookkey = bookkey from isbn where ean13=@IsbnOrEAN
			end
		else
			begin
				Select @bookkey = bookkey from isbn where ean=@IsbnOrEAN
			end
		end
	else begin
		if (len(@IsbnOrEAN)=13)
				begin
					Select @bookkey = bookkey from isbn where isbn=@IsbnOrEAN
				end
		else
			begin
					Select @bookkey = bookkey from isbn where isbn10=@IsbnOrEAN
			end
			
	end

	
	-- Return the result of the function
	RETURN @bookkey

END

GO


grant all on [dbo].[get_bookkey] to public