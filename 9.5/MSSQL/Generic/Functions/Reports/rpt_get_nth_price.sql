

/****** Object:  UserDefinedFunction [dbo].[rpt_get_nth_price]    Script Date: 5/9/2016 4:32:13 PM ******/
if exists (select * from sys.objects where object_id=object_ID(N'[dbo].[rpt_get_nth_price]') and type in (N'FN',N'IF',N'TF',N'FS',N'FT'))
DROP FUNCTION [dbo].[rpt_get_nth_price]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_nth_price]    Script Date: 5/9/2016 4:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_nth_price] 
            	(@i_bookkey 	INT, @i_history_order int)
		

 
/*
20160509	JDOE	CREATED rpt_get_nth_price function

      The rpt_get_nth_price function is used to retrieve the nth (history_order) price from the book price
        table.  The function first determines if an actual price is stored, it will return the actual 
	if greater than zero, otherwise it will return the estimated.

            The parameters are for the book key.  

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
	AND activeind = 1
	and history_order=@i_history_order

	
 

	IF @f_finalprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))
		END	
	ELSE IF @f_budgetprice > 0
		BEGIN
			SELECT @RETURN = CAST(CONVERT(NUMERIC(9,2),@f_budgetprice) AS VARCHAR(23))
		END	

		

RETURN @RETURN

END


GO

grant execute on [dbo].[rpt_get_nth_price] to public 
