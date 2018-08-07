SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_us_retail_price') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_us_retail_price
GO
CREATE FUNCTION [dbo].[rpt_get_best_us_retail_price] 
            	(@i_bookkey 	INT)
 
  --   The rpt_get_best_us_retail_price function is used to retrieve the best price from the book price
  --   table that is in US Dollars for Manufacturers Suggested Retail.  
  --   The function first determines if an actual price is stored, it will return the actual 
  --   if greater than zero or zero if pricetype gen2ind = 1 (Allow zero prices), otherwise it will return the estimated.  
  --   It is assumed by the user of this function that there will only be 1 US Price type, but it may differ by publisher
  --   The parameters are book key.  
RETURNS FLOAT
AS  
BEGIN 

	DECLARE @f_budgetprice     	FLOAT
	DECLARE @f_finalprice     	FLOAT
	DECLARE @RETURN       		NUMERIC(9,2)
	DECLARE @gen2ind			INT

	SELECT @f_budgetprice = budgetprice,@f_finalprice = finalprice
	  FROM bookprice
	 WHERE bookkey = @i_bookkey 
	   AND pricetypecode = 8
	   AND currencytypecode = 6  -- US Dollars
	   AND activeind = 1
	   
	SELECT @gen2ind = COALESCE(gen2ind,0)  --Allow zero prices
	  FROM gentables 
	 WHERE tableid = 306
	   AND datacode = 8

	IF @f_finalprice > 0 OR (@gen2ind = 1 AND @f_finalprice >= 0) BEGIN
		SELECT @RETURN = CONVERT(NUMERIC(9,2),@f_finalprice)
	END	
	ELSE IF @f_budgetprice > 0 OR (@gen2ind = 1 AND @f_budgetprice >= 0)BEGIN
		SELECT @RETURN = @f_budgetprice
	END	
	ELSE BEGIN
		SELECT @RETURN = 0
	END	
	RETURN @RETURN
END
go

Grant All on dbo.rpt_get_best_us_retail_price to Public
go