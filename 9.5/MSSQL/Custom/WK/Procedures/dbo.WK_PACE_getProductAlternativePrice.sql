if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getProductAlternativePrice') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getProductAlternativePrice
GO
CREATE PROCEDURE dbo.WK_PACE_getProductAlternativePrice
AS
/*

ITEMNUMBER	
TMM_ALTERNATEPRICEID	
CURRENCY	
PRICE TYPE	
PRICE

Select * FROM WK_ORA.WKDBA.ALTERNATE_PRICE

*/
BEGIN
Select 
dbo.WK_get_itemnumber_withdashes(bp.bookkey) as ITEMNUMBER,
bp.pricekey as TMM_ALTERNATEPRICEID,
[dbo].[get_gentables_desc](122,bp.currencytypecode, 'long') as CURRENCY,
g.alternatedesc2 as [PRICE TYPE],
COALESCE(finalprice, budgetprice) as PRICE

--bp.effectivedate as effectiveDateField,
--[dbo].[rpt_get_misc_value](bp.bookkey, 7, 'long') as effectiveQuantityField,
--
--NULL as previousEffectiveDateField,
--NULL as priceRestrictionField,
--g.alternatedesc2 as priceTypeField,
--(CASE WHEN dbo.wk_isPrepub(@bookkey) = 'Y' and bp.effectivedate > getdate() THEN 'price.status.prePublication'
--	 WHEN finalprice is not null and finalprice > 0 THEN 'price.status.final'
--	 WHEN budgetprice is not null and budgetprice > 0 THEN 'price.status.tentative'
--	 ELSE NULL END) as statusField,
FROM bookprice bp
JOIN gentables g
ON bp.pricetypecode = g.datacode 
where  
g.tableid = 306
and g.alternatedesc2 like '%AlternatePrice%'
and ((budgetprice is not null OR finalprice is not null) AND (budgetprice > 0 OR finalprice > 0))
and dbo.WK_get_itemnumber_withdashes(bp.bookkey) <> ''

END