if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getDescription') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getDescription
GO
CREATE PROCEDURE dbo.WK_getDescription
@bookkey int
AS
BEGIN


/*
Description	
advantageFullTitleField	CSIString, misckey =3
advantageShortTitleField	CSIString, misckey =4
idField	CSIString
longDescriptionField	CSIString bookcomments(3,8)
noteToBooksellersField	CSIString bookcomments(3,7)
subTitle1Field	CSIString 
subTitle2Field	CSIString
titleField	CSIString

dbo.WK_getDescription 911802

Select * FROM bookcomments
WHERE commenttypecode = 3 and commenttypesubcode = 8

Select * FROM WK_ORA.wkdba.DESCRIPTION

Select * FROM WK_ORA.wkdba.COMMON_PRODUCT
where title = 'Platinum Vignettes&#8482;'

Select * FROM book
where subtitle like '%Transferred to Blackwell%'

Select * FROM book
where subtitle like '% -- %'

Select * FROM bookmisc
where misckey in (3,4)

Select * FROM bookcomments
where commenttypecode = 3 and commenttypesubcode = 8

Select MAX(DESCRIPTION_ID) FROM WK_ORA.WKDBA.DESCRIPTION --380687

Select Max(bookkey) from book --764787

Safe to use bookkey as DESCRIPTION_ID for new titles

Select * FROM WK_ORA.WKDBA.PRODUCT
WHERE ADVANTAGE_SHORT_TITLE IS NOT NULL

Select * FROM WK_ORA.WKDBA.PRODUCT
WHERE ADVANTAGE_FULL_TITLE IS NOT NULL

*/

Select 
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN bookkey
--WHEN EXISTS(Select * FROM dbo.WK_COMMON_PRODUCT WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') AND DESCRIPTION_ID IS NOT NULL) THEN (Select TOP 1 DESCRIPTION_ID FROM dbo.WK_COMMON_PRODUCT WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') AND DESCRIPTION_ID IS NOT NULL ORDER BY DESCRIPTION_ID DESC) --In case we have multiples, use the most recent one 
--ELSE bookkey
--END) as [idField],
bookkey as [idfield],
(CASE WHEN [dbo].[rpt_get_misc_value](bookkey, 3, '') IS NULL OR [dbo].[rpt_get_misc_value](bookkey, 3, '') = '' THEN NULL
ELSE UPPER([dbo].[rpt_get_misc_value](bookkey, 3, '')) END) as [advantageFullTitleField] ,
(CASE WHEN [dbo].[rpt_get_misc_value](bookkey, 4, '') IS NULL OR [dbo].[rpt_get_misc_value](bookkey, 4, '') = '' THEN NULL
ELSE UPPER([dbo].[rpt_get_misc_value](bookkey, 4, '')) END) as [advantageShortTitleField],
[dbo].[rpt_get_book_comment](bookkey, 3, 8, 3) as [longDescriptionField],
[dbo].[rpt_get_book_comment](bookkey, 3, 64, 3) as [noteToBooksellersField],
title as [titlefield],
dbo.WK_getSubTitles(bookkey, 1) as subtitle1Field, 
dbo.WK_getSubTitles(bookkey, 2) as subtitle2Field 
--(CASE WHEN CHARINDEX(' -- ', subtitle, 0) > 0 THEN LTRIM(RTRIM(SUBSTRING(subtitle, 1, CHARINDEX(' -- ', subtitle, 0) -1)))
--	   ELSE subtitle END) as subtitle1Field,
--(CASE WHEN ltrim(rtrim(subtitle)) = '--' OR subtitle = '  --  ' OR LEN(ltrim(rtrim(subtitle))) = 2 THEN NULL
--		WHEN CHARINDEX(' -- ', subtitle, 0) > 0 THEN LTRIM(RTRIM(SUBSTRING(subtitle, CHARINDEX(' -- ', subtitle, 0) + 3, (LEN(subtitle) - CHARINDEX(' -- ', subtitle, 0)-2))))
--	   ELSE NULL END) as subtitle2Field
FROM book
where bookkey = @bookkey


END

