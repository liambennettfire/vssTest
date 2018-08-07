SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].subordinate_to_primary_view') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[subordinate_to_primary_view]
GO
	CREATE VIEW subordinate_to_primary_view AS 
	--rpt_subordinate_to_primary_view
	SELECT    'bookkey' =  dbo.book.bookkey,  
		'primarytitle' = bw.title, 'primaryean' = bw.ean, 'primarypubdate' = bw.bestpubdate, 
		'primaryformat' = bw.formatname, 'primarystatus' = bw.bisacstatusdesc, 'primaryimprint' = bw.imprintname, 
		'primaryprice' = bw.tmmprice, 
		CASE WHEN bdw.simulpubind = 1 THEN 'Y' ELSE 'N' END AS primarysimulpub,
		CASE WHEN bookdetail.simulpubind = 1 THEN 'Y' ELSE 'N' END AS subordinatesimulpub, 
		CASE WHEN book.propagatefrombookkey IS NOT NULL THEN bp.ean ELSE '' END AS subordinateinfocopiedfrom,
		'subordinateean' = dbo.productnumber.productnumber, 'subordinatetitle' = dbo.book.title, 
		'subordinatepubdate' = bs.bestpubdate, 'subordinateformat' = bs.formatname, 
		'subordinatestatus' = bs.bisacstatusdesc, 'subordinateimprint' = bs.imprintname, 'subordinateprice' = bs.tmmprice 
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

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[subordinate_to_primary_view]  TO [public]
GO
