if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getFrontMatters') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getFrontMatters
GO
CREATE PROCEDURE dbo.WK_getFrontMatters
@bookkey int
/*

Select bookkey, Count(*)
FROM bookcomments
WHERE commenttypecode = 3
and commenttypesubcode in (52,59,60,61)
GROUP BY bookkey
ORDER BY COunt(*) DESC

dbo.WK_getFrontMatters 566547

Select * FROM WK_ORA.WKDBA.PRODUCT_FRONTMATTER
WHERE PRODUCT_FRONTMATTER_ID IN
(85303,
85302,
85305,
85304)


*/
AS
BEGIN
Select 
--Should we use bookkey+printingkey+commmenttypecode+commenttypesubcode as our new id?
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2))
--ELSE ( 
--CASE commenttypesubcode
--WHEN 52 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.TableOfContents') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.TableOfContents') ELSE Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) END)
--WHEN 59 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Foreword') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Foreword') ELSE Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) END)
--WHEN 60 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Contributors') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Contributors') ELSE Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) END)
--WHEN 61 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Preface') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Preface') ELSE Cast(@bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) END)
--END)
--END) as [idField],
Cast(@bookkey as varchar(20)) + Cast(commenttypesubcode as varchar(2)) as [idField],
commenttext as [textField],
(Case WHEN commenttypesubcode = 52 THEN 'com.lww.pace.domain.frontmatter.TableOfContents'
     WHEN commenttypesubcode = 59 THEN 'com.lww.pace.domain.frontmatter.Foreword'
     WHEN commenttypesubcode = 60 THEN 'com.lww.pace.domain.frontmatter.Contributors'
     WHEN commenttypesubcode = 61 THEN 'com.lww.pace.domain.frontmatter.Preface'
--     WHEN commenttypesubcode = 62 THEN 'com.lww.pace.domain.frontmatter.SalesStrategy'
	 END) as [typeField]
FROM bookcomments
where bookkey = @bookkey
and commenttypecode = 3
and commenttypesubcode in (52,59,60,61)
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
END

