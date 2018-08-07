SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bookdates30]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bookdates30]
GO


CREATE VIEW dbo.bookdates30 
	(bookkey,printingkey,datetypecode,
	 activedate,actualind,recentchangeind,
	 lastuserid,lastmaintdate,estdate,
	 sortorder,bestdate)
as select bookkey,printingkey,datetypecode,
	 activedate,actualind,recentchangeind,
	 lastuserid,lastmaintdate,estdate,
	 sortorder,bestdate from bookdates
   where datetypecode = 30


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT  ON [dbo].[bookdates30]  TO [public]
GO


