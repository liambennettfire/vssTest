if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getFeatures') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getFeatures
GO
CREATE PROCEDURE dbo.WK_getFeatures
@bookkey int
/*

Select TOP 1 FEATURE_ID FROM WK_ORA.WKDBA.FEATURE
WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long')
ORDER BY DISPLAY_SEQUENCE 

Select * FROM bookcomments
where commenttypecode = 3 and commenttypesubcode = 57

dbo.WK_getFeatures 566199

Select * FROM WK_ORA.WKDBA.FEATURE
WHERE COMMON_PRODUCT_ID = 78805

Select * FROM WK_ORA.WKDBA.FEATURE
WHERE FEATURE_ID = 78809



*/
AS
BEGIN
Select
--Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) as [idField],
Cast(@bookkey as varchar(20)) + Cast(commenttypesubcode as varchar(2)) as [idField],
commenttext as [textField],
1 as [sequenceField]
FROM bookcomments
WHERE bookkey = @bookkey
and commenttypecode = 3 and commenttypesubcode = 57
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
--Select dbo.rpt_get_book_comment(@bookkey, 3, 57, 1)
END


