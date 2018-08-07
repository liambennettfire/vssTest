SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[get_BestEuroPrice] 
            	(@i_bookkey 	INT,
            	@i_pricetype	INT)
		

 
/*      The get_BestEuroPrice function is used to retrieve the best price size from the book price   */
/*      table.  The function first determines if an actual price is stored, it will return the actual       */
/*  	if greater than zero, otherwise it will return the estimated.                                               */
/*      The parameters are for the book key and printing key.                                                    */

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
	AND currencytypecode = 38  -- European Union Euro
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








