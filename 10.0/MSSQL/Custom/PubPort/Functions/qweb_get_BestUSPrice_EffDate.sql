SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestUSPrice_EffDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestUSPrice_EffDate]
GO









CREATE FUNCTION [dbo].[qweb_get_BestUSPrice_EffDate] 
            	(@i_bookkey 	INT,
            	@i_pricetype	INT)
		

 
/*      The qweb_get_BestUSPrice function is used to retrieve the best price size from the book price
        table.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.

            The parameters are for the book key and price type.  

*/

RETURNS VARCHAR(10)

AS  

BEGIN 

DECLARE @d_effectivedate	DATETIME
DECLARE @RETURN       		VARCHAR(10)

 

SELECT @d_effectivedate = effectivedate
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND pricetypecode = @i_pricetype 
	AND currencytypecode = 6  -- US Dollars
	AND activeind = 1


 

	IF COALESCE(@d_effectivedate,0)<> 0
		BEGIN
			SELECT @RETURN = CONVERT(VARCHAR,@d_effectivedate,101)
		END	
	ELSE 
		BEGIN
			SELECT @RETURN = ''
		END

		

RETURN @RETURN

END









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

