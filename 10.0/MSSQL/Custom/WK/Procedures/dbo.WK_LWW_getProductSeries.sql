if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductSeries') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_LWW_getProductSeries
GO
CREATE PROCEDURE dbo.WK_LWW_getProductSeries

AS
/*
select cp.series_ID,lower(p.STANDARD_NUMBER_WITHOUT_DASHES)
from wk_ora.wkdba.common_product cp,
wk_ora.wkdba.product p
where cp.series_id is not null
and p.COMMON_PRODUCT_ID = cp.COMMON_PRODUCT_ID
ORDER BY LEN(p.STANDARD_NUMBER_WITHOUT_DASHES)

Select * FROM bookdetail
WHERE seriescode is not NULL

  Column	DataType
  SERIES_ID  NUMBER(15) NOT NULL	
  STRISBN    VARCHAR2(20 BYTE)	

*/
BEGIN

Select
seriescode as SERIES_ID,
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) as STRISBN
FROM bookdetail b
WHERE dbo.WK_IsEligibleforLWW(b.bookkey) = 'Y'
and seriescode is not NULL

END



