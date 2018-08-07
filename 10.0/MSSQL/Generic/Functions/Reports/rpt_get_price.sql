
/****** Object:  UserDefinedFunction [dbo].[rpt_get_price]    Script Date: 03/24/2009 13:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_price') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_price
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

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @f_budgetprice      	FLOAT
DECLARE @f_finalprice     	FLOAT
DECLARE @RETURN       		VARCHAR(23)
DECLARE @gen2ind			INT

 

SELECT @f_budgetprice = budgetprice,
	@f_finalprice = finalprice
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND pricetypecode = @i_pricetypecode 
	AND currencytypecode = @i_currencytypecode
	AND activeind = 1
	
	
SELECT @gen2ind = COALESCE(gen2ind,0)  --Allow zero prices
	  FROM gentables 
	 WHERE tableid = 306
	   AND datacode = @i_pricetypecode


 
if @c_EstActBest = 'B' /* Return Best Price */
begin
	IF @f_finalprice > 0 OR (@gen2ind = 1 and @f_finalprice >= 0)
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE IF @f_budgetprice > 0 OR (@gen2ind = 1 and @f_budgetprice >= 0)
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END	
	ELSE -- IF @f_budgetprice = NULL OR @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = ''
		END	
end

if @c_EstActBest = 'E' /* Return Best Price */
begin
 IF @f_budgetprice > 0 OR (@gen2ind = 1 and @f_budgetprice >= 0)
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END	
	ELSE -- IF @f_budgetprice = NULL OR @f_budgetprice = 0
		BEGIN
			SELECT @RETURN = ''
		END	
end

if @c_EstActBest = 'A' /* Return Actual Price */
begin
	IF @f_finalprice > 0 OR (@gen2ind = 1 and @f_finalprice >= 0)
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE -- IF @f_finalprice = NULL OR @f_finalprice = 0
		BEGIN
			SELECT @RETURN = ''
		END	
end

RETURN @RETURN

END

go
Grant All on dbo.rpt_get_price to Public
go