SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestUSPriceAndType]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestUSPriceAndType]
GO





CREATE FUNCTION [dbo].[qweb_get_BestUSPriceAndType] 
            	(@i_bookkey 	INT)
          
		

 
/*      The qweb_get_BestUSPriceAndType function is used to retrieve the best price  from the book price
        table that is in US Dollars.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.  
	It is assumed by the user of this function that there will only be 1 US Price type, but it may differ by publisher

            The parameters are for the book key.  

*/

RETURNS FLOAT

AS  

BEGIN 

DECLARE @f_budgetprice      	FLOAT

DECLARE @f_finalprice     	FLOAT
DECLARE @RETURN       		NUMERIC(9,2)

 

SELECT @f_budgetprice = budgetprice,
	@f_finalprice = finalprice
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND currencytypecode = 6  -- US Dollars
	AND activeind = 1


 

	IF @f_finalprice > 0
		BEGIN
			SELECT @RETURN = CONVERT(NUMERIC(9,2),@f_finalprice)
		END	
	ELSE IF @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = @f_budgetprice
		END	
	ELSE IF @f_budgetprice = NULL OR @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = 0
		END	
		

RETURN @RETURN

END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

