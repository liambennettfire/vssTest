SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[releasedate_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[releasedate_view]
GO


CREATE VIEW releasedate_view 
(bookkey,printingkey,datetypecode,activedate,actualind,recentchangeind,lastuserid,lastmaintdate,estdate,
sortorder,bestdate) 
AS SELECT BOOKKEY,PRINTINGKEY,DATETYPECODE,ACTIVEDATE,
ACTUALIND,RECENTCHANGEIND,LASTUSERID,LASTMAINTDATE,ESTDATE,
SORTORDER,BESTDATE from bookdates
   WHERE datetypecode = 32


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[releasedate_view]  TO [public]
GO

