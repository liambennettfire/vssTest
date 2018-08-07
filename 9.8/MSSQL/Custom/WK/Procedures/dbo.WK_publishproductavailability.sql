if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_publishproductavailability') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_publishproductavailability
GO
CREATE PROCEDURE [dbo].[WK_publishproductavailability]
@bookkey int
AS
BEGIN
Select
[dbo].[get_gentables_desc](131,b.territoriescode, 'long') as availabilityRestrictionField,
[dbo].[rpt_get_misc_value](b.bookkey, 41, 'long') as contactInfoField, 
--dbo.WK_getID(bookkey, 'MARKETING_INFO', 0,0) as [idField] 
b.bookkey as [idField]
FROM book b
WHERE b.bookkey = @bookkey
END
