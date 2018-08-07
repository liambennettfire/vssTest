SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[printing1]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[printing1]
GO


CREATE VIEW printing1 AS
select printing.bookkey,
         printing.printingkey,
         bookdates30.bestdate boundbookdate,
         bookdates47.bestdate warehousedate,
	 bookdates387.bestdate prodboundbookdate,
         printing.tentativeqty,
         printing.trimfamily,
         printing.pagecount,
         printing.creationdate,
         printing.nastaind,
         printing.statelabelind,
         printing.statuscode,
         printing.trimsizewidth,
         printing.trimsizelength,
         printing.lastuserid,
         printing.lastmaintdate,
         printing.specind,
         printing.printingjob,
         prodpoperson_view.roletypecode productionmgrcode,
         prodperson2_view.roletypecode productionedcode,
         prodperson3_view.roletypecode editorcode,
	 printing.ccestatus,
 	 printing.dateccefinalized,
 	 printing.printingnum,
	 printing.jobnum,
	 printing.requeststatuscode,
         printing.impressionnumber
     FROM printing 
LEFT OUTER JOIN bookdates30 ON printing.bookkey = bookdates30.bookkey AND printing.printingkey = bookdates30.printingkey 
LEFT OUTER JOIN bookdates387 ON printing.bookkey = bookdates387.BOOKKEY AND printing.printingkey = bookdates387.PRINTINGKEY 
LEFT OUTER JOIN prodpoperson_view ON printing.bookkey = prodpoperson_view.bookkey AND printing.printingkey = prodpoperson_view.printingkey 
LEFT OUTER JOIN prodperson3_view ON printing.bookkey = prodperson3_view.bookkey AND printing.printingkey = prodperson3_view.printingkey 
LEFT OUTER JOIN prodperson2_view ON printing.bookkey = prodperson2_view.bookkey AND printing.printingkey = prodperson2_view.printingkey 
LEFT OUTER JOIN bookdates47 ON printing.bookkey = bookdates47.bookkey AND printing.printingkey = bookdates47.printingkey   

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[printing1]  TO [public]
GO


