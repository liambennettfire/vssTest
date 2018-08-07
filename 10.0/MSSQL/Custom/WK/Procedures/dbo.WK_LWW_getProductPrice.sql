if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductPrice') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductPrice
GO

CREATE PROCEDURE dbo.WK_LWW_getProductPrice
--@bookkey int
AS
BEGIN

/*

MULTISET (SELECT op.intproductid,
                               op.intproductpricingid intproductpricingid,
                               op.dbldomesticprice, op.dbldomindividualprice,
                               op.dbldominstitutionalprice,
                               op.dbldomintrainingprice,
                               op.dbldomsingleissueprice,
                               op.dblinternationalprice,
                               op.dblintindividualprice,
                               op.dblintinstitutionalprice,
                               op.dblintintrainingprice,
                               op.dblintsingleissueprice,
			       DBLAUSTRALIANDOLLARPRICE, DBLEURO, DBLPOUND, DBLYEN
                          FROM ols_pricing_spl op
                         WHERE op.intproductid(+) = p.product_id
                       ) AS pricelist_spl
             ) AS productprice,

Select bookkey, Count(*) FROM bookprice
GROUP By bookkey
HAVING Count(*) > 4
ORDER BY Count(*) DESC

dbo.WK_LWW_getProductPrice 569381
573254

Select * FROM WK_ORA.WKDBA.PRODUCT_PRICE
WHERE PRODUCT_PRICES_ID = 70416

Select * FROM WK_ORA.WKDBA.PRODUCT_PRICES
WHERE PRODUCT_PRICES_ID = 70416



Select * FROM WK_ORA.WKDBA.PRODUCT_PRICES
WHERE PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long')

--WE SHOULD BE ABLE TO USE THE BOOKKEY FOR PRICE ID FIELD FOR THE NEW TITLES IN TMM !
Select Max(PRODUCT_PRICES_ID) FROM WK_ORA.WKDBA.PRODUCT_PRICES

Select Max(bookkey) FROM book


*/

Select 
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL 
--OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
--ELSE [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') END) as intproductid, --p.product_id intproductid,
--dbo.WK_getProductId(bookkey) as intproductid,
bookkey as intproductid,
--which pricekey do we use? pricekey for domestic LIST pricetype if exists?
--If not, use domestic individual pricetype? Assuming this is a subscription?
--(CASE WHEN [dbo].[rpt_get_price](@bookkey, 8, 6, 'B') IS NOT NULL AND [dbo].[rpt_get_price](@bookkey, 8, 6, 'B') > 0 THEN 
--(Select TOP 1 pricekey from bookprice 
--where bookkey = @bookkey and pricetypecode = 8 and currencytypecode = 6 and activeind =  1)
--ELSE (Select TOP 1 pricekey from bookprice where bookkey = @bookkey and pricetypecode = 14 and currencytypecode = 6 and activeind =  1
--ORDER by sortorder ) END) as intproductpricingid,

--****************************************************************************
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
--ELSE (
--CASE WHEN EXISTS (Select * FROM dbo.WK_PRODUCT_PRICES WHERE PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long'))
--	 THEN (Select PRODUCT_PRICES_ID FROM dbo.WK_PRODUCT_PRICES WHERE PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long'))
--    ELSE @bookkey END)
--END) as intproductpricingid,

--dbo.WK_getID(bookkey, 'PRODUCT_PRICE', 0,0) as intproductpricingid,
bookkey as intproductpricingid,
[dbo].[rpt_get_price](bookkey, 8, 6, 'B') as dbldomesticprice,
[dbo].[rpt_get_price](bookkey, 14, 6, 'B') as dbldomindividualprice,
[dbo].[rpt_get_price](bookkey, 17, 6, 'B') as dbldominstitutionalprice,
[dbo].[rpt_get_price](bookkey, 21, 6, 'B') as dbldomintrainingprice,
[dbo].[rpt_get_price](bookkey, 27, 6, 'B') as dbldomsingleissueprice,
[dbo].[rpt_get_price](bookkey, 8, 38, 'B') as dblinternationalprice,
[dbo].[rpt_get_price](bookkey, 14, 38, 'B') as dblintindividualprice,
[dbo].[rpt_get_price](bookkey, 17, 38, 'B') as dblintinstitutionalprice,
[dbo].[rpt_get_price](bookkey, 21, 38, 'B') as dblintintrainingprice,
[dbo].[rpt_get_price](bookkey, 27, 38, 'B') as dblintsingleissueprice,
[dbo].[rpt_get_price](bookkey, 8, 41, 'B') as DBLAUSTRALIANDOLLARPRICE,
[dbo].[rpt_get_price](bookkey, 8, 39, 'B') as DBLEURO,
[dbo].[rpt_get_price](bookkey, 8, 37, 'B') as DBLPOUND,
[dbo].[rpt_get_price](bookkey, 8, 40, 'B') as DBLYEN
FROM book
WHERE dbo.WK_IsEligibleforLWW(bookkey) = 'Y'

--where bookkey = @bookkey
END





                               
                               
                   












