SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bookdates47]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bookdates47]
GO


CREATE VIEW dbo.bookdates47 
	(bookkey,printingkey,datetypecode,
	 activedate,actualind,recentchangeind,
	 lastuserid,lastmaintdate,estdate,
	 sortorder,bestdate)
as select bookkey,printingkey,datetypecode,
	 activedate,actualind,recentchangeind,
	 lastuserid,lastmaintdate,estdate,
	 sortorder,bestdate from bookdates
   where datetypecode = 47


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[bookdates47]  TO [public]
GO


