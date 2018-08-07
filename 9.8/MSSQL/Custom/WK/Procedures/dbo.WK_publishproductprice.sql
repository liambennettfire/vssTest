if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_publishproductprice') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_publishproductprice
GO
CREATE PROCEDURE dbo.WK_publishproductprice
@bookkey int
AS
BEGIN
Select pricekey, bp.bookkey, g.datadescshort,
[dbo].[get_gentables_desc](122,bp.currencytypecode, 'long') as currency,
bp.activeind, bp.budgetprice, bp.finalprice, bp.effectivedate, bp.expirationdate, 
bp.sortorder, g.alternatedesc2, dbo.qweb_get_BisacStatus(bp.bookkey, 'D') as [BisacStatus],
[dbo].[rpt_get_carton_qty](bp.bookkey, 1) as CartonQty,
dbo.qweb_get_BookSubjects(bp.bookkey, 5,0,'D',1) as [PRODUCT_SEARCH_TYPE],
dbo.qweb_get_BookSubjects(bp.bookkey, 5,0,'D',2) as [PRODUCT_SUB_TYPE]
FROM bookprice bp
JOIN gentables g
ON bp.pricetypecode = g.datacode
where g.tableid = 306
and (g.datacode in (8) --LIST PRICE
OR g.alternatedesc2 = 'ALT')
and bookkey = @bookkey
ORDER BY bp.sortorder
END
