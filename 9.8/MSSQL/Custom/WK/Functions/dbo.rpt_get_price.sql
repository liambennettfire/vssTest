/****** Object:  UserDefinedFunction [dbo].[rpt_get_price]    Script Date: 10/27/2015 10:50:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_price]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_price]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_price]    Script Date: 10/27/2015 10:50:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_price] 
            	(@i_bookkey 	INT,
            	@i_pricetypecode INT,
				@i_currencytypecode INT,
				@c_EstActBest char (1))
		
/*      The get_PriceEst function is used to retrieve the Estimated price  from the book price
        table based on the pricetype and currency passed parameters.  
The function first determines if a price is stored, 
if greater than zero the price will be returned, otherwise it will return blank.

The parameters are:
book key, 
pricetypecode  = pricetypecode i.e. MSR=8. Net Item=9
currencytypecode: US=6, Canadian=11, UK=37
@c_EstActBest: Estimated Price (Budget) = 'E', Actual Price (Final) ='A', Best='B'
*/

RETURNS FLOAT

AS  

BEGIN 

DECLARE @f_budgetprice      	FLOAT
DECLARE @f_finalprice     	FLOAT
DECLARE @RETURN       		FLOAT

 

SELECT @f_budgetprice = budgetprice,
	@f_finalprice = finalprice
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND pricetypecode = @i_pricetypecode 
	AND currencytypecode = @i_currencytypecode
	AND activeind = 1


 
if @c_EstActBest = 'B' /* Return Best Price */
begin

	IF @f_finalprice IS NOT NULL AND  @f_finalprice> 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE IF @f_budgetprice IS NOT NULL AND @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END	
	ELSE IF @f_finalprice IS NOT NULL AND @f_finalprice = 0
		BEGIN
			SELECT @RETURN = 0
		END	
	ELSE IF @f_budgetprice IS NOT NULL AND @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = 0
		END
	ELSE -- IF @f_budgetprice = NULL OR @f_budgetprice = NULL
		BEGIN
			SELECT @RETURN = NULL
		END	
end

if @c_EstActBest = 'E' /* Return Estimated Price */
begin
 IF @f_budgetprice IS NOT NULL AND @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END
	ELSE IF @f_budgetprice IS NOT NULL AND @f_budgetprice = 0
			BEGIN
				SELECT @RETURN = 0
			END
	ELSE -- IF @f_budgetprice = NULL OR @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = NULL
		END	
end

if @c_EstActBest = 'A' /* Return Actual Price */
begin
	IF @f_finalprice IS NOT NULL AND @f_finalprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE IF @f_finalprice IS NOT NULL AND @f_finalprice = 0
		BEGIN
			SELECT @RETURN = 0
		END	
	ELSE -- IF @f_finalprice = NULL 
		BEGIN
			SELECT @RETURN = NULL
		END	
end

RETURN @RETURN

END


GO


Grant all on dbo.rpt_get_price to public