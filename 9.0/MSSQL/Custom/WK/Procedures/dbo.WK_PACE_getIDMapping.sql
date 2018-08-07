if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getIDMapping') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getIDMapping
GO
CREATE PROCEDURE dbo.WK_PACE_getIDMapping
AS
/*

ITEMNUMBER	
PACE_PRODUCTID	
TMM_PRODUCT_ID	
PACE_COMMON_PRODUCT_ID	
TMM_COMMON_PRODUCT_ID

Select * FROM book
where bookkey <> workkey

*/
BEGIN
Select 
dbo.WK_get_itemnumber_withdashes(b.bookkey) as ITEMNUMBER,
[dbo].[rpt_get_misc_value](b.bookkey, 1, 'long') as PaceProductId,
bookkey as TMM_ProductId,
[dbo].[rpt_get_misc_value](b.bookkey, 2, 'long') as PACE_COMMON_PRODUCT_ID,
workkey as TMM_COMMON_PRODUCT_ID
FROM Book b
WHERE dbo.WK_get_itemnumber_withdashes(b.bookkey) <> ''

END
