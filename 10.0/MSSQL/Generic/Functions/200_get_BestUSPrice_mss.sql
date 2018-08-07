if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_BestUSPrice]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[get_BestUSPrice]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




CREATE FUNCTION [dbo].[get_BestUSPrice] 
            	(@i_bookkey 	INT,
            	@i_pricetype	INT)
		

 
/*      The get_BestUSPrice function is used to retrieve the best price size from the book price
        table.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @f_budgetprice      	FLOAT
DECLARE @f_finalprice     	FLOAT
DECLARE @RETURN       		VARCHAR(23)

 

SELECT @f_budgetprice = budgetprice,
	@f_finalprice = finalprice
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND pricetypecode = @i_pricetype 
	AND currencytypecode = 6  -- US Dollars
	AND activeind = 1


 

	IF @f_finalprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE IF @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END	
	ELSE -- IF @f_budgetprice = NULL OR @f_budgetprice = 0
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

GRANT ALL ON [dbo].[get_BestUSPrice] TO PUBLIC