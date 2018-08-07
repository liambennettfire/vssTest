if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductReviews') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_LWW_getProductReviews
GO
CREATE PROCEDURE dbo.WK_LWW_getProductReviews
AS
/*
  COLUMN	DATATYPE
  INTPRODUCTREVIEWID	NUMBER(38)            NOT NULL
  INTPRODUCTID	NUMBER(38)            NOT NULL
  DTPRODUCTREVIEWDATE	DATE
  INTPRODUCTREVIEWISSUE	NUMBER(38)
  STRPRODUCTREVIEWTYPE	VARCHAR2(40 BYTE)
  STRPRODUCTREVIEWSOURCE	VARCHAR2(40 BYTE)
  STRPRODUCTREVIEWTEXT	VARCHAR2(4000 BYTE)
  STRPRODUCTREVIEWERNAME	VARCHAR2(40 BYTE)


select rv.review_id,p.PRODUCT_ID,
rv.review_date,
rv.review_issue_num,
substring(rv.type,1,40),
substring(rv.source,1,40),
substring(rv.review_text,1,4000),
substring(rv.reviewer,1,40)
from wk_ora.wkdba.review rv,wk_ora.wkdba.product p
where rv.COMMON_PRODUCT_ID = p.COMMON_PRODUCT_ID
and rv.common_product_id is not null
and rv.review_text is not null;

Select * FROM citation


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
c.citationkey as INTPRODUCTREVIEWID,
c.bookkey as INTPRODUCTID,
c.citationdate as DTPRODUCTREVIEWDATE,
NULL as INTPRODUCTREVIEWISSUE,
NULL as STRPRODUCTREVIEWTYPE,
(Case WHEN citationsource = 'n/a' OR citationauthor is NULL then NULL
     ELSE SUBSTRING(c.citationsource, 1, 40) END) as STRPRODUCTREVIEWSOURCE, 
--q.commenttext as STRPRODUCTREVIEWTEXT,
(CASE WHEN c.citationdesc like '%Issue%' OR c.citationdesc like '%Volume%' THEN Cast(q.commenttext as varchar(max)) + '<BR><BR>' + c.citationdesc
ELSE q.commenttext END) as STRPRODUCTREVIEWTEXT,
(Case WHEN citationauthor = 'n/a' OR citationauthor is NULL then NULL
     ELSE SUBSTRING(c.citationauthor, 1, 40) END) as STRPRODUCTREVIEWERNAME
FROM citation c join qsicomments q on c.qsiobjectkey = q.commentkey  
WHERE --dbo.WK_IsEligibleforLWW(c.bookkey) = 'Y' and 
q.commenttypecode = 1 and q.commenttypesubcode = 1
and q.commenttext is not null and LEN(Cast(q.commenttext as varchar(max))) > 0
END



