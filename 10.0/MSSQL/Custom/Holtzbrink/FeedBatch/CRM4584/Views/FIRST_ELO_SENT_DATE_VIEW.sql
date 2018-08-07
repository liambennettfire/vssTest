if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FIRST_ELO_SENT_DATE_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[FIRST_ELO_SENT_DATE_VIEW]
GO
create view dbo.FIRST_ELO_SENT_DATE_VIEW(BOOKKEY, FIRSTELOQUENCESENDDATE)  AS 
  SELECT dbo.FILEPROCESSCATALOG.BOOKKEY, min(dbo.FILEPROCESSCATALOG.LASTMAINTDATE) AS FIRSTELOQUENCESENDDATE
    FROM dbo.FILEPROCESSCATALOG
    GROUP BY dbo.FILEPROCESSCATALOG.BOOKKEY

go
GRANT SELECT ON FIRST_ELO_SENT_DATE_VIEW TO public
go