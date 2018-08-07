if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getReviews') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getReviews
GO
CREATE PROCEDURE dbo.WK_getReviews
@bookkey int
AS
/*
Select * FROM WK_ORA.WKDBA.REVIEW

Select * FROM citation

WK_getReviews 567518

*/
BEGIN
--	Select c.citationkey as [id],
Select
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN c.citationkey
--ELSE (
--CASE WHEN EXISTS (Select * FROM dbo.WK_REVIEW WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') AND DISPLAY_SEQUENCE = c.sortorder)
--	 THEN ( Select TOP 1 REVIEW_ID FROM dbo.WK_REVIEW WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') AND DISPLAY_SEQUENCE = c.sortorder ORDER BY DISPLAY_SEQUENCE )
--    ELSE c.citationkey END)
--END) as [idField],
c.citationkey as [idField],
c.citationdate as [reviewDateField],
c.citationauthor as [reviewerField],
q.commenttext as [reviewTextField],
c.citationsource as [sourceField] 
FROM citation c join qsicomments q on c.qsiobjectkey = q.commentkey  
WHERE c.bookkey = @bookkey
and q.commenttypecode = 1 and q.commenttypesubcode = 1
and q.commenttext is not null and LEN(Cast(q.commenttext as varchar(max))) > 0
END



