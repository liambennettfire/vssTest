if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_getProductPriceMiscFields]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.[WK_getProductPriceMiscFields]
GO
CREATE PROCEDURE [dbo].[WK_getProductPriceMiscFields]
@bookkey int
AS

/*
dbo.WK_getProductPriceMiscFields 566167

Select * FROm booksubjectcategory
where categorytableid = 432

*/
BEGIN

DECLARE @effectivedate datetime
DECLARE @isPrepub char(1)
SET @effectivedate = NULL
--BUSINESS RULE: If retail price exist then get the effective date from min sortorder
IF EXISTS(Select * FROM bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)))
	BEGIN
		SET @effectivedate = (Select TOP 1 effectivedate from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)) ORDER BY sortorder)
	END
ELSE
	BEGIN
		IF EXISTS (Select * FROM bookprice bp JOIN gentables g ON bp.pricetypecode = g.datacode where bp.bookkey = @bookkey and g.tableid = 306 and g.alternatedesc1 like '%basePrice%' and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)) )
			BEGIN
				SET @effectivedate = (Select TOP 1 effectivedate FROM bookprice bp JOIN gentables g ON bp.pricetypecode = g.datacode where bp.bookkey = @bookkey and g.tableid = 306 and g.alternatedesc1 like '%basePrice%' and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)) ORDER BY bp.sortorder )
			END
	END

SET @isPrepub = dbo.WK_IsPrepub(@bookkey)


Select (Case WHEN @effectivedate is not null and @isPrepub='Y' AND @effectivedate > getdate() THEN 'Y'
		ELSE 'N' END) as futurePriceEffectiveField, 
dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',1) as searchTypeField,
dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',2) as subTypeField
FROM book b
--join bookdetail bd
--on b.bookkey = bd.bookkey
WHERE b.bookkey = @bookkey

END




