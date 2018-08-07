if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_AvailableProducts_RittenHouseFeed') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_AvailableProducts_RittenHouseFeed
GO

CREATE PROCEDURE dbo.WK_AvailableProducts_RittenHouseFeed
/*

EXEC dbo.WK_AvailableProducts_RittenHouseFeed

a.	Send Column L (EAN) in a text or CSV file.   
b.	The file should only contain products that are not RO, DS, OP, or OS (see column D) and quantity is greater than 0 (see column N).  
c.	This file is to be run on a daily basis at end of each day (7:30 p.m.) and posted on an ftp site (see communications section below).
d.	Exclude products with 0 quantity or negative quantity in US INV column
e.	Exclude products with  ***** in US INV column

*/
AS
BEGIN
Select 
-- dbo.rpt_get_isbn(b.bookkey, 17) as EAN
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) as itemnumberField
--,[dbo].[rpt_get_misc_value](b.bookkey, 7, 'long')
FROM book b
JOIN bookdetail bd
on b.bookkey = bd.bookkey
WHERE [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') NOT IN ('RO', 'DS', 'OP', 'OS') --, 'CA', 'OC')
AND [dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') > 0
--AND [dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') < 999999
AND (Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) <> ''
AND 
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) IS NOT NULL
END

