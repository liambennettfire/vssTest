if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductNewFeature') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductNewFeature
GO

CREATE PROCEDURE dbo.WK_getProductNewFeature
@bookkey int
AS
/*
Select * FROM WK_ORA.WKDBA.NEW_FEATURE

Select * FROM bookcomments
where commenttypesubcode = 58

dbo.WK_getProductNewFeature 566205

*/
BEGIN
Select
--Should we use bookkey+printingkey+commmenttypecode+commenttypesubcode as our new id?
--Cast(bookkey as varchar(10)) + '13' + Cast(commenttypesubcode as varchar(2)) as [idField],
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2))
--ELSE (
--CASE WHEN EXISTS (Select * FROM dbo.WK_NEW_FEATURE WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long'))
--	 THEN ( Select TOP 1 NEW_FEATURE_ID FROM dbo.WK_NEW_FEATURE WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') ORDER BY DISPLAY_SEQUENCE )
--    ELSE Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) END)
--END) as [idField],
Cast(bookkey as varchar(20)) + Cast(commenttypesubcode as varchar(2)) as [idField],
commenttext as [textField],
1 as [sequenceField]
FROM bookcomments
WHERE bookkey = @bookkey
and commenttypecode = 3 and commenttypesubcode = 58
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
END
