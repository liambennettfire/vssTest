if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getAllProducts_XML') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getAllProducts_XML
GO

CREATE PROCEDURE dbo.WK_getAllProducts_XML
AS
/*
763916	9780781752312
763966	9780781752312
763971	9780781752312
764018	9780781752312
764106	9780781752312
764111	9780781752312
764116	9780781752312
764121	9780781752312
764215	9780781752312
764220	9780781752312

Select b.* FROM book b
join isbn i
ON b.bookkey = i.bookkey
where i.ean13 = '9780781752312'

Select * FROM isbn




*/

BEGIN

Select b.bookkey,
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) as itemnumber 
/*, title, 
dbo.rpt_get_media(bookkey, 'D') as Media,
dbo.rpt_get_format(bookkey, 'D') as Format,
dbo.qweb_get_BookSubjects(bookkey, 5,0,'E',1) as searchType,
dbo.qweb_get_BookSubjects(bookkey, 5,0,'E',2) as subType,
dbo.rpt_get_best_pub_date(bookkey, 1) as pubDateField,
dbo.qweb_get_BisacStatus(bookkey, 'D') as BisacStatus
*/
from book b
where 
--dbo.wk_isPrepub(bookkey) = 'Y' AND
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) IS NOT NULL
AND
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = b.bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) <> ''
--AND dbo.qweb_get_BookSubjects(bookkey, 5,0,'E',1) <> ''
--ORDER BY dbo.qweb_get_BisacStatus(bookkey, 'D')
END