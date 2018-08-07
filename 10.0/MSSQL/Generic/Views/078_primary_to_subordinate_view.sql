/****** Object:  View [dbo].[primary_to_subordinate_view]    Script Date: 05/02/2011 13:09:22 ******/
/* altered by Ben Todd 2011/05/02 to add subordinatebookkey to the view */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_primary_to_subordinate_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_primary_to_subordinate_view]
GO

CREATE VIEW [dbo].[rpt_primary_to_subordinate_view] AS 
--rpt_primary_to_subordinate_view
SELECT TOP 100 PERCENT 
	'bookkey' = bw.bookkey,
	'subordinatebookkey' = bs.bookkey, 
	'subordinateean' = dbo.productnumber.productnumber, 'subordinatetitle' = dbo.book.title, 
	'subordinatepubdate' = bs.bestpubdate, 'subordinateformat' = bs.formatname, 
	'subordinatestatus' = bs.bisacstatusdesc, 'subordinateimprint' = bs.imprintname, 'subordinateprice' = bs.tmmprice, 
	CASE WHEN bookdetail.simulpubind = 1 THEN 'Y' ELSE 'N' END AS subordinatesimulpub, 
	CASE WHEN bdw.simulpubind = 1 THEN 'Y' ELSE 'N' END AS primarysimulpub,
	CASE WHEN book.propagatefrombookkey IS NOT NULL THEN bp.ean ELSE '' END AS subordinateinfocopiedfrom,
	'primarytitle' = bw.title, 'primaryean' = bw.ean, 'primarypubdate' = bw.bestpubdate, 
	'primaryformat' = bw.formatname, 'primarystatus' = bw.bisacstatusdesc, 'primaryimprint' = bw.imprintname, 
	'primaryprice' = bw.tmmprice
FROM dbo.book 
	INNER JOIN dbo.productnumber 
	ON dbo.book.bookkey = dbo.productnumber.bookkey 
	INNER JOIN dbo.bookdetail 
	ON dbo.book.bookkey = dbo.bookdetail.bookkey
	left outer join coretitleinfo bs
	on dbo.book.bookkey = bs.bookkey
	left outer join coretitleinfo bw
	on dbo.book.workkey = bw.bookkey
	and bw.printingkey = 1
	left outer join isbn bp
	on dbo.book.propagatefrombookkey = bp.bookkey
	left outer join bookdetail bdw
	on bw.bookkey = bdw.bookkey
where dbo.book.workkey <> dbo.book.bookkey
or (dbo.book.propagatefrombookkey is not null and dbo.book.propagatefrombookkey <> dbo.book.bookkey)
order by bw.bookkey
GO

GRANT ALL ON rpt_primary_to_subordinate_view TO PUBLIC
Go

