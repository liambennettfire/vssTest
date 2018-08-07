SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_canadian_price') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_canadian_price
GO
CREATE FUNCTION [dbo].[rpt_get_best_canadian_price] 
            	(@i_bookkey 	INT,
            	@i_pricetype	INT)
		
 --The rpt_get_best_canadian_price function is used to retrieve the best price size from the book price
 --table for the price type parameter specified.  The function first determines if an actual price is stored, 
 --it will return the actual if greater than zero OR if pricetype allows zero prices,otherwise it will return 
 --the estimated.
 --The parameters are for the book key and printing key.  
RETURNS VARCHAR(20)
AS  
BEGIN 

	DECLARE @f_budgetprice     	FLOAT
	DECLARE @f_finalprice     	FLOAT
	DECLARE @RETURN       		VARCHAR(23)	
	DECLARE @gen2ind			INT

	SELECT @f_budgetprice = budgetprice,@f_finalprice = finalprice
	  FROM bookprice
	 WHERE bookkey = @i_bookkey 
	   AND pricetypecode = @i_pricetype 
	   AND currencytypecode = 11  -- Canadian Dollars
	   AND activeind = 1
	   
	SELECT @gen2ind = COALESCE(gen2ind,0)  --Allow zero prices
	  FROM gentables 
	 WHERE tableid = 306
	   AND datacode = @i_pricetype
	  
	IF @f_finalprice > 0 OR (@gen2ind = 1 and @f_finalprice >= 0) BEGIN
		SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
	END	
	ELSE IF @f_budgetprice > 0 OR (@gen2ind = 1 and @f_budgetprice >= 0)BEGIN
		SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
	END	
	ELSE BEGIN   -- IF @f_budgetprice = NULL OR @f_budgetprice = 0
		SELECT @RETURN = ''
	END	

	RETURN @RETURN
END

go
Grant All on dbo.rpt_get_best_canadian_price to Public
go