if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_Amazon_JP_Feed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_Amazon_JP_Feed
GO

CREATE PROCEDURE dbo.WK_Amazon_JP_Feed



/*
•	ISBN or EAN or UPC
•	Internal article id of the supplier/vendor (VENDOR_STOCK_ID)
•	Article description (TITLE)
•	Quantity on hand (QTY_ON_HAND)
•	List price exclusive Tax (LIST_PRICE_EXCL_TAX)
•	List price including Tax (LIST_PRICE_INCL_TAX)
•	The cost to Amazon of the product (COST_PRICE)
•	The discount accorded to Amazon (DISCOUNT)
•	Currency code (ISO_CURRENCY_CODE)

1-ISBN|EAN|VENDOR_STOCK_ID|TITLE|QTY_ON_HAND|LIST_PRICE_EXCL_TAX|LIST_PRICE_INCL_TAX| COST_PRICE|DISCOUNT|ISO_CURRENCY_CODE

2-Article ID ISBN has to be sent in column 1, EAN in column 2, UPC in column 3.  
If you can not provide one of the defined Article IDs please provide an empty field 


3-If you can not provide a price field or the discount field, 
please send an empty field, not a zero.

4-Naming convention: RETAIL_FEED_?????_YYYYMMDD_00.TXT

5-Each vendor file must deliver a full catalog dump. QTY_ON_HAND has to be a numeric value. 
Items, which are currently not in stock but can be ordered, should be reported with quantity 0.

ISBN|EAN|UPC|VENDOR_STOCK_ID|TITLE|QTY_ON_HAND|LIST_PRICE_EXCL_TAX|LIST_PRICE_INCL_TAX|COST_PRICE|DISCOUNT|ISO_CURRENCY_CODE

--NEW REQUIREMENTS FROM SENTHIL ON 6/29/2010

SELECT DISTINCT standard_number_without_dashes, standard_number10, p.product_id, cp.title, 
p.qty_available,p.publication_status, 
pp.domestic_dollar, p.publication_date 
FROM 
product p,common_product cp,product_prices pps,product_price pp 
WHERE
publication_status NOT IN ('RO', 'DS', 'OP', 'OS') 
AND p.product_search_type NOT IN ('subElectronic', 'subPrint') 
AND pps.price_status = 'price.status.final' 
AND pp.price_type in ('price.type.basePrice','price.type.personalUsePrice')
AND p.common_product_id = cp.common_product_id 
AND pps.product_id = p.product_id 
AND pps.product_prices_id = pp.product_prices_id


-	ISBN is the ISBN10 and it should not have hyphens ( - ).

-	A product must be sent only if the EAN or ISBN 13 is not null, the publication date is not null and the length of the EAN or ISBN13 is equal to 13 ( as shown below).

If( ean != null && pubDate != null && ean.trim().length() == 13)

-	The UPC is not sent from PACE so just enter a | (pipe) after the EAN field.

-	Similarly the VENDOR STOCK ID is not sent from PACE so enter a pipe after the UPC field.

-	For a product with OD status apply the logic given below:

if publication date > Current Date, feed Qty Available = 0
if publication date <= today, feed Qty Available = 9999

-	For other products ( status other than OD ), 
Feed Qty Available = 9999 if qty_available is greater than ZERO else Feed Qty Available =0.

-	List Excl Price is the listPrice present in Firebrand.

-	There is no List Incl Price in Firebrand so it’s just passed as Pipe (|).

-	The Discount field should be passed just as 36.

-	The amazonCost is List_Excl_Price – ( 0.36 * List_Excl_Price ) and it should be limited to 3 decimals.

-	Currency Code should be passed as USD.



*/
AS
BEGIN
Select 
--dbo.rpt_get_isbn(b.bookkey, 10) as ISBN10,
dbo.rpt_get_isbn(b.bookkey, 17) as EAN,
--(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
--	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) as EAN,
title,
(CASE WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'OD'
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) > getdate() THEN 0
WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'OD'
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <= getdate() THEN 9999
ELSE 
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') IS NOT NULL AND
[dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') > 0  THEN 9999
ELSE 0 END)
END) as QTY_ON_HAND,
(Case WHEN [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') = '' OR 
[dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') = 0 THEN [dbo].[rpt_get_price](b.bookkey, 33, 6, 'A')
ELSE [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') END) as LIST_PRICE_INCL_TAX,
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') as PUBLICATION_STATUS
--,[dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') QTY
--(Case WHEN [dbo].[rpt_get_price](bookkey, 8, 6, 'B') = 0 OR [dbo].[rpt_get_price](bookkey, 8, 6, 'B') IS NULL OR [dbo].[rpt_get_price](bookkey, 8, 6, 'B') = '' THEN ''
--ELSE [dbo].[rpt_get_price](bookkey, 8, 6, 'B') END) as LIST_PRICE_INCL_TAX
--(Case WHEN [dbo].[rpt_get_price](bookkey, 8, 6, 'B') = 0 OR [dbo].[rpt_get_price](bookkey, 8, 6, 'B') IS NULL OR [dbo].[rpt_get_price](bookkey, 8, 6, 'B') = '' THEN ''
--ELSE ([dbo].[rpt_get_price](bookkey, 8, 6, 'B')*.36) END) as LIST_PRICE_INCL_TAX
FROM book b
JOIN bookdetail bd
ON b.bookkey = bd.bookkey
WHERE [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') NOT IN ('RO', 'DS', 'OP', 'OS') --, 'CA', 'OC')
--EAN can not be blank
AND dbo.rpt_get_isbn(b.bookkey, 17) IS NOT NULL
AND dbo.rpt_get_isbn(b.bookkey, 17) <> ''
AND dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',1) not in ('subElectronic', 'subPrint')
AND (Case WHEN [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') = '' OR 
[dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') = 0 THEN [dbo].[rpt_get_price](b.bookkey, 33, 6, 'A')
ELSE [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') END) <> ''
AND (Case WHEN [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') = '' OR 
[dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') = 0 THEN [dbo].[rpt_get_price](b.bookkey, 33, 6, 'A')
ELSE [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') END) > 0
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) <> '' --pubdate has to be assigned
AND [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) IS NOT NULL
END





Select bookkey, [dbo].[rpt_get_price](b.bookkey, 8, 6, 'A') from book b

select * FROM bookprice
where bookkey = 909097

DECLARE @f_finalprice     	FLOAT

SET @f_finalprice = NULL
SELECT  CAST(CONVERT(NUMERIC(9,2),@f_finalprice) AS VARCHAR(23))

Select [dbo].[rpt_get_price](909097, 8, 6, 'A') from book b
where bookkey = 909097

Select * FROM book
WHERE [dbo].[rpt_get_price](bookkey, 8, 6, 'A') = 0

Select [dbo].[rpt_get_best_pub_date](bd.bookkey, 1) FROM bookdetail bd

Select * FROM isbn


Select [dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') from book b

