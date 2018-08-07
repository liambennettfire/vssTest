if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductMarketingInfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductMarketingInfo
GO

CREATE PROCEDURE dbo.WK_getProductMarketingInfo
@bookkey int
AS
/*

Select * FROM WK_ORA.WKDBA.MARKETING_INFO

Select bookkey, [dbo].[rpt_get_misc_value](bookkey, 41, 'long') from book
WHERE  [dbo].[rpt_get_misc_value](bookkey, 41, 'long') IS NOT NULL

dbo.WK_getProductMarketingInfo 584195

Select * FROM book

*/
BEGIN
Select
[dbo].[get_gentables_desc](131,b.territoriescode, 'long') as availabilityRestrictionField,
[dbo].[rpt_get_misc_value](b.bookkey, 41, 'long') as contactInfoField, 
--dbo.WK_getID(bookkey, 'MARKETING_INFO', 0,0) as [idField] 
b.bookkey as [idField]
FROM book b
WHERE b.bookkey = @bookkey
END