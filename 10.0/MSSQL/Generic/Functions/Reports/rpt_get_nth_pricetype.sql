
/****** Object:  UserDefinedFunction [dbo].[rpt_get_nth_price]    Script Date: 5/9/2016 4:32:13 PM ******/
if exists (select * from sys.objects where object_id=object_ID(N'[dbo].[rpt_get_nth_pricetype]') and type in (N'FN',N'IF',N'TF',N'FS',N'FT'))
DROP FUNCTION [dbo].[rpt_get_nth_pricetype]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_nth_price]    Script Date: 5/9/2016 4:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_nth_pricetype] 
            	(@i_bookkey 	INT, @i_history_order int, @i_type varchar(10))
		

 
/*
20160509	JDOE	CREATED rpt_get_nth_pricetype function

      The rpt_get_nth_pricetype function is used to retrieve the nth (history_order) price type.  

            The parameters are for the book key, history_order and the type of value representing PriceType from the user tables:
				E = ExternalDataCode
				B = BisacDataCode
				D = Datadesc

*/

RETURNS VARCHAR(255)

AS  

BEGIN 
declare @price_type varchar(255)
declare @price_code int
DECLARE @RETURN       		VARCHAR(255)

 -- select * from bookprice

SELECT @price_code = pricetypecode
FROM bookprice
WHERE bookkey = @i_bookkey 
	AND activeind = 1
	and history_order=@i_history_order


	if isNull(@i_type,'') = 'E' 
		select @return = externalcode
		from gentables where tableid=306 and datacode=@price_code
	else if isNull(@i_type,'') = 'B' 
		select @return = bisacdatacode
		from gentables where tableid=306 and datacode=@price_code
	else 	
		select @return = datadesc
		from gentables where tableid=306 and datacode=@price_code
	
RETURN @RETURN

END


GO
grant execute on [dbo].[rpt_get_nth_pricetype] to public

