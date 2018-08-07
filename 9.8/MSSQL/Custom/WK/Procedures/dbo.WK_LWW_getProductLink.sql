if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductLink') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductLink
GO

CREATE PROCEDURE dbo.WK_LWW_getProductLink
--@bookkey int
AS
BEGIN

/*
(MULTISET (SELECT NVL (pl.product_link_id, 0) intproductlinkid,
                               pl.product_id intproductid,
                               pl.link_url strproductlink,
                               pl.link_text strproductlinktext
                          FROM product_link pl
                         WHERE pl.product_id(+) = p.product_id
                       ) AS linklist
             ) AS productlink,

Select * FROM WK_ORA.WKDBA.PRODUCT_LINK
WHERE LINK_URL not like 'http%' OR LINK_URL not like '%www%'

Select * FROM filelocation
where filetypecode = 3
and sortorder > 1

dbo.WK_LWW_getProductLink 573892

Select * FROM WK_ORA.WKDBA.PRODUCT_LINK pl 
WHERE pl.PRODUCT_ID = 5183

Select * FROM WK_ORA.WKDBA.PRODUCT
WHERE PRODUCT_ID = 5183

Select * FROM WK_ORA.WKDBA.COMMON_PRODUCT
WHERE COMMON_PRODUCT_ID = 68937

Select * FROM WK_ORA.WKDBA.PRODUCT_LINK pl WHERE pl.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') AND pl.DISPLAY_SEQUENCE = fl.sortorder)

--WE SHOULD BE ABLE TO USE BOOKKEY + SORTORDER for new PRODUCT LINK IDs
--WE MIGHT HAVE MULTIPLE PRODUCT LINKS PER TITLE

Select Max(PRODUCT_LINK_ID) FROM WK_ORA.WKDBA.PRODUCT_LINK

Select Max(bookkey) FROM book

Select * FROM filelocation
WHERE filetypecode = 8


*/

Select
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN fl.filelocationgeneratedkey
--ELSE (
--CASE WHEN EXISTS (Select * FROM WK_ORA.WKDBA.PRODUCT_LINK pl WHERE pl.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') AND pl.DISPLAY_SEQUENCE = fl.sortorder)
--	 THEN (Select PRODUCT_LINK_ID FROM WK_ORA.WKDBA.PRODUCT_LINK pl WHERE pl.PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') AND pl.DISPLAY_SEQUENCE = fl.sortorder)
--    ELSE fl.filelocationgeneratedkey END)
--END) as intproductlinkid,
--dbo.WK_getID(fl.bookkey, 'PRODUCT_LINK', sortorder,filelocationgeneratedkey) as intproductlinkid,
fl.filelocationgeneratedkey as intproductlinkid,

--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL 
--OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
--ELSE [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') END) as intproductid, --p.product_id intproductid,
--dbo.WK_getProductId(fl.bookkey) as intproductid,
fl.bookkey as intproductid,

fl.pathname as strproductlink,
fl.filedescription as strproductlinktext,
(Case WHEN dbo.rpt_get_isbn(fl.bookkey, 16) = '' OR dbo.rpt_get_isbn(fl.bookkey, 16) IS NULL 
THEN (Select itemnumber from isbn i where i.bookkey = fl.bookkey)
ELSE dbo.rpt_get_isbn(fl.bookkey, 16) END) as strproductisbn
from filelocation fl
where 
--fl.bookkey = @bookkey and 
fl.filetypecode = 8
and dbo.WK_IsEligibleforLWW(fl.bookkey) = 'Y'
--ORDER BY dbo.WK_getID(fl.bookkey, 'PRODUCT_LINK', sortorder,filelocationgeneratedkey), fl.sortorder
ORDER BY fl.filelocationgeneratedkey, fl.sortorder

END