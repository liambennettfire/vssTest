
GO

/****** Object:  StoredProcedure [dbo].[WK_getProductPrice]    Script Date: 10/30/2013 15:47:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WK_getProductPrice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WK_getProductPrice]
GO


GO

/****** Object:  StoredProcedure [dbo].[WK_getProductPrice]    Script Date: 10/30/2013 15:47:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WK_getProductPrice]
@bookkey int
AS
	
BEGIN

/*

CURRENCY TABLEID = 122

australianPriceField 41
domesticPriceField 6
effectiveDateField
effectiveQuantityField
euroPriceField 39
idField
internationalPriceField 38
poundPriceField  37
previousEffectiveDateField
priceRestrictionField
priceTypeField
statusField
yenPriceField  40



Select bookkey, Count(*) FROM bookprice
WHERE pricetypecode = 8
GROUP BY bookkey
HAVING COUNT(*) >1

dbo.WK_getProductPrice 909096

Select * FROM bookprice
WHERE bookkey = 909096 and pricetypecode = 8

Select * FROM bookmisc
where misckey = 7 and bookkey = 909096

Select * FROM bookprice
where bookkey not in (Select Distinct bookkey from bookprice where activeind = 1 and pricetypecode = 8)
ORDER BY bookkey

dbo.WK_getProductPrice 909097

Select * FROM bookprice
WHERE bookkey = 909097 


dbo.WK_getProductPrice 914243

Select * FROM bookprice
WHERE bookkey = 914243 

*/

CREATE TABLE #tmp(
idField int,
australianPriceField float,
domesticPriceField float,
effectiveDateField datetime,
effectiveQuantityField int,
euroPriceField float,
internationalPriceField float,
poundPriceField float,
previousEffectiveDateField datetime,
priceRestrictionField varchar(100),
priceTypeField varchar(100),
statusField varchar(100),
yenPriceField float,
pesopricefield float
)

IF EXISTS (Select * FROM bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)))
	BEGIN
--		DECLARE @EffectiveDate datetime
--		DECLARE @budgetprice float
--		DECLARE @finalprice float
--		--BUSINESS RULE? get the effectivedate from the first LIST price type
--		SET @EffectiveDate = (Select TOP 1 effectivedate from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1)
--		--BUSINESS RULE? decide on price status based on the budget and finalprice of the first LIST price type?
--		SET @budgetprice = (Select TOP 1 budgetprice from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1)
--		SET @finalprice = (Select TOP 1 finalprice from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1)

		INSERT INTO #tmp
		Select TOP 1
--		dbo.WK_getID(@bookkey, 'PRODUCT_PRICE', 0,0) as idField,
		--we might need to send other pricetypes to CSI in the future, so append pricetypecode to bookkey
		--to come up with a unique key 
		Cast(@bookkey as varchar(20)) + '8' as [idField],
		--Zero prices are valid as per the discussion with Angela and Paul's response on 7/13/2010, don't send NULL if 
		--price is 0, send 0 instead. 
--		(Case WHEN [dbo].[rpt_get_price](@bookkey, 8, 41, 'B') = 0 THEN NULL
--		ELSE [dbo].[rpt_get_price](@bookkey, 8, 41, 'B') END)  
		[dbo].[rpt_get_price](@bookkey, 8, 41, 'B') as australianPriceField,
--		(Case WHEN [dbo].[rpt_get_price](@bookkey, 8, 6, 'B') = 0 THEN NULL
--		ELSE [dbo].[rpt_get_price](@bookkey, 8, 6, 'B') END) 
		[dbo].[rpt_get_price](@bookkey, 8, 6, 'B') as domesticPriceField,
		effectivedate as effectiveDateField,
		
		1 as effectiveQuantityField,
		
		--The below was commented out on 10/30/2013 as per N Steager. Defaulted to 1 (above)
		--(CASE WHEN (Select [dbo].[rpt_get_gentables_field](314, bisacstatuscode, 'E') from bookdetail where bookkey = @bookkey) = 'OD' THEN 1
		--ELSE [dbo].[rpt_get_misc_value](@bookkey, 7, 'long') END)  as effectiveQuantityField,


--		(CASE WHEN [dbo].[rpt_get_price](@bookkey, 8, 39, 'B') = 0 THEN NULL ELSE 
--		[dbo].[rpt_get_price](@bookkey, 8, 39, 'B') END) 
		[dbo].[rpt_get_price](@bookkey, 8, 39, 'B') as euroPriceField,
--		(Case WHEN [dbo].[rpt_get_price](@bookkey, 8, 38, 'B') = 0 THEN NULL
--		ELSE [dbo].[rpt_get_price](@bookkey, 8, 38, 'B') END) 
		[dbo].[rpt_get_price](@bookkey, 8, 38, 'B') as internationalPriceField,
--		(Case WHEN [dbo].[rpt_get_price](@bookkey, 8, 37, 'B') = 0 THEN NULL
--		ELSE [dbo].[rpt_get_price](@bookkey, 8, 37, 'B') END) 
		[dbo].[rpt_get_price](@bookkey, 8, 37, 'B') as poundPriceField,
		NULL as previousEffectiveDateField,
		NULL as priceRestrictionField,
		'price.type.basePrice' as priceTypeField,
		(CASE WHEN [dbo].[wk_isPrepub](@bookkey) = 'Y' AND effectivedate IS NOT NULL and effectivedate <> '' and effectivedate > = getdate() THEN 'price.status.prePublication'
			 WHEN finalprice is not null and finalprice >= 0 THEN  'price.status.final'
			 WHEN budgetprice is not null and budgetprice > = 0 THEN 'price.status.tentative'
			 ELSE NULL END) as statusField,
--		(Case WHEN [dbo].[rpt_get_price](@bookkey, 8, 40, 'B') = 0 THEN NULL
--			ELSE [dbo].[rpt_get_price](@bookkey, 8, 40, 'B') END) 
		[dbo].[rpt_get_price](@bookkey, 8, 40, 'B') as yenPriceField,
		dbo.rpt_get_price(@bookkey,8,42,'B') as pesoPriceField
		FROM bookprice  
		where bookkey = @bookkey and pricetypecode = 8 and activeind = 1 
		AND (budgetprice is not null OR finalprice is not null)
		ORDER BY sortorder
	END
ELSE
	BEGIN
		IF EXISTS (Select * FROM bookprice bp JOIN gentables g ON bp.pricetypecode = g.datacode where bp.bookkey = @bookkey and g.tableid = 306 and g.alternatedesc1 like '%basePrice%' and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)))
			BEGIN
--				DECLARE @EffectiveDate datetime
--				DECLARE @budgetprice float
--				DECLARE @finalprice float
--				--BUSINESS RULE? get the effectivedate from the first LIST price type
--				SET @EffectiveDate = (Select TOP 1 effectivedate from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1)
--				--BUSINESS RULE? decide on price status based on the budget and finalprice of the first LIST price type?
--				SET @budgetprice = (Select TOP 1 budgetprice from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1)
--				SET @finalprice = (Select TOP 1 finalprice from bookprice where bookkey = @bookkey and pricetypecode = 8 and activeind = 1)

				INSERT INTO #tmp
				Select TOP 1
				Cast(@bookkey as varchar(20)) + Cast(bp.pricetypecode as varchar(3)) as [idField],
--				(Case WHEN [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 41, 'B') = 0 THEN NULL
--				ELSE [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 41, 'B') END)  
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 41, 'B') as australianPriceField,
--				(Case WHEN [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 6, 'B') = 0 THEN NULL
--				ELSE [dbo].[rpt_get_price](@bookkey, 8, bp.pricetypecode, 'B') END) 
				[dbo].[rpt_get_price](@bookkey,  bp.pricetypecode, 6, 'B') as domesticPriceField,
				bp.effectivedate as effectiveDateField,
				1 as effectiveQuantityField,
		
		--The below was commented out on 10/30/2013 as per N Steager. Defaulted to 1 (above)
		--(CASE WHEN (Select [dbo].[rpt_get_gentables_field](314, bisacstatuscode, 'E') from bookdetail where bookkey = @bookkey) = 'OD' THEN 1
		--ELSE [dbo].[rpt_get_misc_value](@bookkey, 7, 'long') END)  as effectiveQuantityField,
		
--				(CASE WHEN [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 39, 'B') = 0 THEN NULL ELSE 
--				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 39, 'B') END)
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 39, 'B') as euroPriceField,
--				(Case WHEN [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 38, 'B') = 0 THEN NULL
--				ELSE [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 38, 'B') END) 
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 38, 'B') as internationalPriceField,
--				(Case WHEN [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 37, 'B') = 0 THEN NULL
--				ELSE [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 37, 'B') END) 
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 37, 'B') as poundPriceField,
				NULL as previousEffectiveDateField,
				NULL as priceRestrictionField,
				g.alternatedesc2 as priceTypeField,
				(CASE WHEN [dbo].[wk_isPrepub](@bookkey) = 'Y' AND bp.effectivedate IS NOT NULL and bp.effectivedate <> '' and bp.effectivedate > = getdate() THEN 'price.status.prePublication'
					 WHEN bp.finalprice is not null and  bp.finalprice >= 0 THEN  'price.status.final'
					 WHEN bp.budgetprice is not null and bp.budgetprice>0 THEN 'price.status.tentative'
					 ELSE NULL END) as statusField,
--				(Case WHEN [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 40, 'B') = 0 THEN NULL
--					ELSE [dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 40, 'B') END) 
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 40, 'B') as yenPriceField,
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 42, 'B') as pesoPriceField
				FROM bookprice bp 
				JOIN gentables g 
				ON bp.pricetypecode = g.datacode 
				where bp.bookkey = @bookkey and g.tableid = 306 and g.alternatedesc1 like '%basePrice%' and bp.activeind = 1 
				AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0))
				ORDER BY bp.sortorder
		END
	END

/*Business rule updated on 9/16/2010
If base prices do not exist then we will send the min sortorder price type if it exists in bookprice 
table for the given bookkey
*/
IF NOT EXISTS (Select * FROM #tmp) AND EXISTS(Select * FROM bookprice  where bookkey = @bookkey and activeind = 1 AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0)))
		BEGIN
				INSERT INTO #tmp
				Select TOP 1
				Cast(@bookkey as varchar(20)) + Cast(bp.pricetypecode as varchar(3)) as [idField],
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 41, 'B') as australianPriceField,
				[dbo].[rpt_get_price](@bookkey,  bp.pricetypecode, 6, 'B') as domesticPriceField,
				bp.effectivedate as effectiveDateField,
				1 as effectiveQuantityField,
		
		--The below was commented out on 10/30/2013 as per N Steager. Defaulted to 1 (above)
		--(CASE WHEN (Select [dbo].[rpt_get_gentables_field](314, bisacstatuscode, 'E') from bookdetail where bookkey = @bookkey) = 'OD' THEN 1
		--ELSE [dbo].[rpt_get_misc_value](@bookkey, 7, 'long') END)  as effectiveQuantityField,
		
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 39, 'B') as euroPriceField,
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 38, 'B') as internationalPriceField,
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 37, 'B') as poundPriceField,
				NULL as previousEffectiveDateField,
				NULL as priceRestrictionField,
				g.alternatedesc2 as priceTypeField,
				(CASE WHEN [dbo].[wk_isPrepub](@bookkey) = 'Y' AND bp.effectivedate IS NOT NULL and bp.effectivedate <> '' and bp.effectivedate > = getdate() THEN 'price.status.prePublication'
					 WHEN bp.finalprice is not null and  bp.finalprice >= 0 THEN  'price.status.final'
					 WHEN bp.budgetprice is not null and bp.budgetprice>0 THEN 'price.status.tentative'
					 ELSE NULL END) as statusField,
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 40, 'B') as yenPriceField,
				[dbo].[rpt_get_price](@bookkey, bp.pricetypecode, 42, 'B') as pesoPriceField
				FROM bookprice bp 
				JOIN gentables g 
				ON bp.pricetypecode = g.datacode 
				where bp.bookkey = @bookkey and g.tableid = 306 and bp.activeind = 1 
				AND ((budgetprice is not null OR finalprice is not null) AND (budgetprice >= 0 OR finalprice >= 0))
				ORDER BY bp.sortorder

		END

Select * FROM #tmp

DROP TABLE #tmp

END



grant all on WK_getProductPrice to public

GO

