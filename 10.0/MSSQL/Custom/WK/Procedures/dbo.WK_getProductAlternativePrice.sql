if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductAlternativePrice') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductAlternativePrice
GO

CREATE PROCEDURE dbo.WK_getProductAlternativePrice
@bookkey int
AS

		
BEGIN

/*

CURRENCY TABLEID = 122


currencyField
effectiveDateField
effectiveQuantityField
idField
nameField
previousEffectiveDateField
priceRestrictionField
priceTypeField
statusField
valueField

australianPriceField 41
domesticPriceField 6
euroPriceField 39
internationalPriceField 38
poundPriceField  37
yenPriceField  40



Select * FROM bookprice
where pricetypecode = 36
ORDER BY bookkey

WK_getProductAlternativePrice 567321

Select * FROM WK_ORA.WKDBA.ALTERNATE_PRICE
WHERE ALTERNATE_PRICE_ID = 62664

SElect * FROM WK_ORA.WKDBA.ALTERNATE_PRICE
WHERE PRODUCT_PRICES_ID = 62090

Select * FROM isbn where 
dbo.rpt_get_isbn(bookkey, 17) IN
('9781608317530',
'9781608315444',
'9781609136031')

dbo.WK_getProductAlternativePrice 584200

*/




--DECLARE @isPrepub char(1)
--DECLARE @isPOD char(1)
--SET @isPrepub = 'N'
--SET @isPOD = 'N'
--
--Select @isPrepub = (Case WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'ED' AND 
--[dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' 
--AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](bd.bookkey, 1)) <= 14
--THEN  'Y'
--ELSE 'N' END),
--@isPOD = (CASE WHEN [dbo].[rpt_get_carton_qty](bd.bookkey, 1) = 'OD' THEN 'Y' ELSE 'N' END)
--FROM bookdetail bd

Select [dbo].[get_gentables_desc](122,bp.currencytypecode, 'long') as currencyField,
bp.effectivedate as effectiveDateField,
[dbo].[rpt_get_misc_value](bp.bookkey, 7, 'long') as effectiveQuantityField,
--(Case WHEN @isPOD = 'Y' THEN 1 ELSE [dbo].[rpt_get_carton_qty](bp.bookkey, 1) END) as effectiveQuantityField,
--dbo.WK_getID(@bookkey, 'ALTERNATE_PRICE', 0,0) as idField,
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long')IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN bp.pricekey
--		ELSE (
--		CASE WHEN EXISTS (Select * FROM dbo.WK_PRODUCT_PRICES pp JOIN dbo.WK_ALTERNATE_PRICE ap ON pp.PRODUCT_PRICES_ID = ap.PRODUCT_PRICES_ID WHERE pp.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') AND ap.VALUE = COALESCE(finalprice, budgetprice))
--			 THEN (Select TOP 1 ALTERNATE_PRICE_ID FROM dbo.WK_PRODUCT_PRICES pp JOIN dbo.WK_ALTERNATE_PRICE ap ON pp.PRODUCT_PRICES_ID = ap.PRODUCT_PRICES_ID WHERE pp.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') AND ap.VALUE = COALESCE(finalprice, budgetprice) ORDER BY ALTERNATE_PRICE_ID DESC)
--			ELSE bp.pricekey END)
--END)  as idField,
bp.pricekey as idField,
g.datadesc as nameField,
NULL as previousEffectiveDateField,
NULL as priceRestrictionField,
g.alternatedesc2 as priceTypeField,
(CASE WHEN dbo.wk_isPrepub(@bookkey) = 'Y' and bp.effectivedate > getdate() THEN 'price.status.prePublication'
	 WHEN finalprice is not null and finalprice > 0 THEN 'price.status.final'
	 WHEN budgetprice is not null and budgetprice > 0 THEN 'price.status.tentative'
	 ELSE NULL END) as statusField,
COALESCE(finalprice, budgetprice) as valueField
FROM bookprice bp
JOIN gentables g
ON bp.pricetypecode = g.datacode where bp.bookkey = @bookkey  
--and bp.currencytypecode in (6,37,38,39,40,41)   --Not sure if we need to include Canadian Price
and g.tableid = 306
and g.alternatedesc2 like '%AlternatePrice%'
and ((budgetprice is not null OR finalprice is not null) AND (budgetprice > 0 OR finalprice > 0))



END

