if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getPhysicalDesign') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getPhysicalDesign
GO
CREATE PROCEDURE dbo.WK_getPhysicalDesign
@bookkey INT
AS
BEGIN
/*
PhysicalDesign	
bindingTypeField	CSIString
heightField	CSIString
idField	CSIString
mediaTypeField	CSIString
pageCountField	CSIInt
systemRequirementsField	CSIString -->COMMENT (3,66)
volumeSetTypeField	CSIString  -->COMMENT (3,65)
weightField	CSIDouble
widthField	CSIString

--18269
Select * FROM WK_ORA.WKDBA.PHYSICAL_SPECIFICATIONS

--18265
Select DISTINCT PRODUCT_ID FROM WK_ORA.WKDBA.PHYSICAL_SPECIFICATIONS

Select PRODUCT_ID, COunt(*) FROM WK_ORA.WKDBA.PHYSICAL_SPECIFICATIONS
GROUP BY PRODUCT_ID
HAVING COUNT(*) > 1

Select * FROM WK_ORA.WKDBA.PHYSICAL_SPECIFICATIONS
where product_id in (91991,
97397,
77130)

DELETE THESE DUPLICATES???

Select [dbo].[get_BestTrimSize](bookkey, 1), 
(CASE WHEN [dbo].[get_BestTrimSize](bookkey, 1) IS NOT NULL AND CHARINDEX('x',[dbo].[get_BestTrimSize](bookkey, 1)) > 0 
	THEN SUBSTRING([dbo].[get_BestTrimSize](bookkey, 1), CHARINDEX('x',[dbo].[get_BestTrimSize](bookkey, 1))+1, LEN([dbo].[get_BestTrimSize](bookkey, 1)) - CHARINDEX('x',[dbo].[get_BestTrimSize](bookkey, 1))) 
ELSE NULL END) trimwidth from wk..book

Select * FROM printing

tmmacutal/esttrimlength

tmmactualtrimlength - esttrimsizelength
tmmactualtrimwidth - esttrimsizewidth

TEST PROC
Select * FROM WK_ORA.WKDBA.PHYSICAL_SPECIFICATIONS

Select bookkey FROM bookmisc
where misckey = 1 and longvalue = 4065 --569531

EXEC dbo.WK_getPhysicalDesign 569531

*/


Select 
--dbo.WK_getID(@bookkey, 'PHYSICAL_SPECIFICATIONS', 0,0) as [idField],
@bookkey as [idField],
--dbo.WK_getBindingMediaType(bookkey, 'B', ',') as [bindingTypeField],
[dbo].[rpt_get_subgentables_field](312, bd.mediatypecode, bd.mediatypesubcode, '1') as [bindingTypeField],
(CASE 
	WHEN trimsizelength IS NOT NULL and trimsizelength <> '' THEN trimsizelength
	WHEN tmmactualtrimlength IS NOT NULL and tmmactualtrimlength <> '' THEN tmmactualtrimlength
	 WHEN esttrimsizelength IS NOT NULL AND esttrimsizelength <> '' THEN esttrimsizelength
	 ELSE NULL END) as heightField,
(CASE 
	WHEN trimsizewidth IS NOT NULL and trimsizewidth <> '' THEN trimsizewidth
	WHEN tmmactualtrimwidth IS NOT NULL and tmmactualtrimwidth <> '' THEN tmmactualtrimwidth
	 WHEN esttrimsizewidth IS NOT NULL AND esttrimsizewidth <> '' THEN esttrimsizewidth
	 ELSE NULL END) as widthField,
--@MEDIA_TYPE as [mediaTypeField],
--dbo.WK_getBindingMediaType(bookkey, 'M', ',') as [mediaTypeField],
[dbo].[rpt_get_subgentables_field](312, bd.mediatypecode, bd.mediatypesubcode, '2') as [mediaTypeField],
[dbo].[rpt_get_best_page_count](@bookkey, 1) as [pageCountField],
--[dbo].[rpt_get_book_comment](@bookkey, 3, 65, 3) as volumeSetTypeField,
[dbo].[rpt_get_misc_value](@bookkey, 37, 'long') as volumeSetTypeField,
[dbo].[rpt_get_book_comment](@bookkey, 3, 66, 3) as systemRequirementsField,
(Select bookweight from booksimon where bookkey = @bookkey) as weightField
FROM printing p
JOIN bookdetail bd
ON p.bookkey = bd.bookkey
WHERE p.bookkey = @bookkey

END
