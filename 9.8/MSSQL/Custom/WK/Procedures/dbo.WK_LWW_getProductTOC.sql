if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductTOC') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductTOC
GO

CREATE PROCEDURE dbo.WK_LWW_getProductTOC
--@bookkey int
AS
BEGIN

/*


Select * FROM WK_ORA.WKDBA.PRODUCT_FRONTMATTER

Select * FROM bookcomments
where commenttypecode = 3
and commenttypesubcode = 52

Select * FROM filelocation

dbo.WK_LWW_getProductTOC 566211



SELECT p.product_id intproductid,
pf.product_frontmatter_id intproducttocid,
cleanolstext
           (pf.frontmatter_text)
                                clbproducttoctext
FROM product_frontmatter pf
WHERE pf.common_product_id(+) = p.common_product_id

Select bookkey, Count(*)
FROM bookcomments
WHERE commenttypecode = 3
and commenttypesubcode in (52,59,60,61)
GROUP BY bookkey
ORDER BY COunt(*) DESC

Select * FROM subgentables
where tableid = 284 and datacode = 3
and datasubcode in (52,59,60,61)

dbo.WK_LWW_getProductTOC 566547

Select * FROM WK_ORA.WKDBA.PRODUCT_FRONTMATTER
WHERE PRODUCT_FRONTMATTER_ID IN
(85303,
85302,
85305,
85304)

*/

Select  
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL 
--OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
--ELSE [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') END) as intproductid,
--dbo.WK_getProductId(bookkey) as intproductid,
--bookkey as intproductid,
--Use bookkey + printingkey (1) + 3 (editorial commenttypecode) + commenttypesubcode for new titles if toc does not exist
--(CASE WHEN [dbo].[rpt_get_misc_value](bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](bookkey, 2, 'long') = '' THEN Cast(bookkey as varchar(20)) + '13' + Cast(commenttypesubcode as varchar(2))
--ELSE ( 
--CASE commenttypesubcode
--WHEN 52 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.TableOfContents') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.TableOfContents') ELSE Cast(bookkey as varchar(20)) + '13' + Cast(commenttypesubcode as varchar(2)) END)
--WHEN 59 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Foreword') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Foreword') ELSE Cast(bookkey as varchar(20)) + '13' + Cast(commenttypesubcode as varchar(2)) END)
--WHEN 60 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Contributors') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Contributors') ELSE Cast(bookkey as varchar(20)) + '13' + Cast(commenttypesubcode as varchar(2)) END)
--WHEN 61 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Preface') THEN (Select PRODUCT_FRONTMATTER_ID FROM dbo.WK_PRODUCT_FRONTMATTER WHERE COMMON_PRODUCt_ID = [dbo].[rpt_get_misc_value](bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.frontmatter.Preface') ELSE Cast(bookkey as varchar(20)) + '13' + Cast(commenttypesubcode as varchar(2)) END)
--END)
--END) as intproducttocid,
--Cast(bookkey as varchar(20)) + '3' + Cast(commenttypesubcode as varchar(2)) as intproducttocid,
(Case WHEN dbo.rpt_get_isbn(bc.bookkey, 16) = '' OR dbo.rpt_get_isbn(bc.bookkey, 16) IS NULL 
THEN (Select itemnumber from isbn i where i.bookkey = bc.bookkey)
ELSE dbo.rpt_get_isbn(bc.bookkey, 16) END) as strproductisbn,
commenttext as clbproducttoctext
FROM bookcomments bc
where --bookkey = bookkey
dbo.WK_IsEligibleforLWW(bc.bookkey) = 'Y'
and commenttypecode = 3
and commenttypesubcode in (52) --Just sent TOC not all frontmatter types.
--and commenttypesubcode in (52,59,60,61)
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0

END

