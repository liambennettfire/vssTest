SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[pubdate_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[pubdate_view]
GO


CREATE VIEW dbo.pubdate_view 
	(bookkey,printingkey,datetypecode,
	 activedate,actualind,recentchangeind,
	 lastuserid,lastmaintdate,estdate,
	 sortorder,bestdate)
as
select bookdates.bookkey,bookdates.printingkey,bookdates.datetypecode,
       bookdates.activedate,bookdates.actualind,bookdates.recentchangeind,
       bookdates.lastuserid,bookdates.lastmaintdate,
       bookdates.estdate,bookdates.sortorder,bookdates.bestdate from bookdates where datetypecode = 8


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[pubdate_view]  TO [public]
GO

