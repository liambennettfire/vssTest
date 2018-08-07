if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BESTRELDATE_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[BESTRELDATE_VIEW]
GO

create view dbo.BESTRELDATE_VIEW(BOOKKEY, PRINTINGKEY, BESTRELDATE)  AS 
  SELECT dbo.PRINTING.BOOKKEY, dbo.PRINTING.PRINTINGKEY, CASE dbo.BOOKDATES.ACTIVEDATE WHEN  NULL THEN dbo.BOOKDATES.ESTDATE ELSE dbo.BOOKDATES.ACTIVEDATE END AS BESTRELDATE
    FROM dbo.BOOKDATES, dbo.PRINTING
    WHERE ((dbo.BOOKDATES.BOOKKEY = dbo.PRINTING.BOOKKEY) AND 
            (dbo.BOOKDATES.PRINTINGKEY = dbo.PRINTING.PRINTINGKEY) AND 
            (dbo.BOOKDATES.DATETYPECODE = 32))



go
GRANT SELECT ON BESTRELDATE_VIEW TO public
go