if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_ProductsBySortCriteria') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].qweb_ecf_ProductsBySortCriteria
GO



CREATE View [dbo].[qweb_ecf_ProductsBySortCriteria]
AS
/*
created to allow sorting by authore_last and pubdate on extended search screen
if additional fields need to be added first add those fields to the view 
then update ProductSearchByAdvancedFilterNew stored proc

We can have more than one sku per title. 
Do a group by and select Min(author_last) because we're sorting author in ascending order
We're selecting max pub date to "ORDER BY PubDate DESC" because we'd like to 
show the most recent books first


*/
		Select   s.ProductId as ProductId, 
			Max(Case WHEN COALESCE(YEAR(PubDate), SKU_PubYear) <> 0 THEN COALESCE(YEAR(PubDate), SKU_PubYear)
			ELSE NULL
			END) as PubYear,
		--MIN(stf.SKU_PubYear) as PubYear, 
		MIN(ltrim(stf.author_last)) as author_last FROM SKUEx_Title_By_Format stf
		JOIN SKU s
		ON stf.ObjectId = s.SkuId
		WHERE s.Visible = 1
		GROUP BY s.ProductId
		--ORDER BY s.ProductId
		UNION 
		Select  s.ProductId as ProductId, 
		Max((Case WHEN SKU_PubYear <>'' OR SKU_PubYear IS NULL THEN SKU_PubYear
			ELSE NULL
			END)) as PubYear, 
		MIN(ltrim(sjp.author_last)) as author_last 
		FROM SKUEx_Journal_By_PriceType sjp
		JOIN SKU s
		ON sjp.ObjectId = s.SkuId
		WHERE s.Visible = 1
		GROUP BY s.ProductId
