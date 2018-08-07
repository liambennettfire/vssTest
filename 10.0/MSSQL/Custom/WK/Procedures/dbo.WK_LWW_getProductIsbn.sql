if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductIsbn') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductIsbn
GO

CREATE PROCEDURE dbo.WK_LWW_getProductIsbn
--@bookkey int
/*
INTPRODUCTID               NUMBER,
  STRFUTURESTANDARDNUMBER    VARCHAR2(50 BYTE),
  STRPREVIOUSSTANDARDNUMBER  VARCHAR2(50 BYTE),
  STRPRODUCTRANKING          VARCHAR2(50 BYTE),
  STRDISCOUNTCODE            VARCHAR2(50 BYTE)

Select [dbo].[rpt_get_misc_value](bd.bookkey, 43, 'long') from bookdetail bd
WHERE [dbo].[rpt_get_misc_value](bd.bookkey, 43, 'long') IS NOT NULL

Select * FROM Rankings

Select Distinct Product_Ranking FROM WK_ORA.WKDBA.PRODUCT

Select *  FROM WK_ORA.WKDBA.PRODUCT

Select DISTINCT DISCOUNT_CODE  FROM WK_ORA.WKDBA.DISCOUNT_MAP

Select * FROM bookdetail

--FUTURE_STANDARD_NUMBER  (4,4)
--PREVIOUS_STANDARD_NUMBER (4,3)


*/
AS
BEGIN

Select
--dbo.WK_getProductId(bd.bookkey) as intproductid,
bd.bookkey as intproductid,
--bd.nextisbn as STRFUTURESTANDARDNUMBER,
(Select TOP 1 isbn from associatedtitles WHERE bookkey = bd.bookkey and associationtypecode = 4 and associationtypesubcode = 4 ORDER BY sortorder) as STRFUTURESTANDARDNUMBER,
--bd.preveditionisbn as STRPREVIOUSSTANDARDNUMBER,
(Select TOP 1 isbn from associatedtitles WHERE bookkey = bd.bookkey and associationtypecode = 4 and associationtypesubcode = 3 ORDER BY sortorder) as STRPREVIOUSSTANDARDNUMBER,
[dbo].[rpt_get_misc_value](bd.bookkey, 43, 'long') as STRPRODUCTRANKING, --UPDATE AFTER ENHANCEMENT IS IN PLACE
--(Select TOP 1 externalcode from subgentables 
--where tableid = 525 and 
--datadesc = [dbo].[rpt_get_misc_value](bd.bookkey, 6, 'long') ORDER BY externalcode) as STRDISCOUNTCODE
dbo.rpt_get_discount(bd.bookkey, 'D') as STRDISCOUNTCODE
FROM bookdetail bd
WHERE dbo.WK_IsEligibleforLWW(bd.bookkey) = 'Y'
and dbo.rpt_get_discount(bd.bookkey, 'D') <> ''

END




