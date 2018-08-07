if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BOOKJOINTVENTURE_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[BOOKJOINTVENTURE_VIEW]
GO
create view dbo.BOOKJOINTVENTURE_VIEW(ORGENTRYKEY, ORGLEVELKEY, ORGENTRYDESC, ORGENTRYPARENTKEY, ORGENTRYSHORTDESC, DELETESTATUS, LASTUSERID, LASTMAINTDATE, BOOKKEY)  AS 
  SELECT 
      dbo.ORGENTRY.ORGENTRYKEY, 
      dbo.ORGENTRY.ORGLEVELKEY, 
      dbo.ORGENTRY.ORGENTRYDESC, 
      dbo.ORGENTRY.ORGENTRYPARENTKEY, 
      dbo.ORGENTRY.ORGENTRYSHORTDESC, 
      dbo.ORGENTRY.DELETESTATUS, 
      dbo.ORGENTRY.LASTUSERID, 
      dbo.ORGENTRY.LASTMAINTDATE, 
      dbo.BOOKORGENTRY.BOOKKEY
    FROM dbo.ORGENTRY, dbo.BOOKORGENTRY
    WHERE ((dbo.ORGENTRY.ORGLEVELKEY = 1) AND 
            (dbo.BOOKORGENTRY.ORGENTRYKEY = dbo.ORGENTRY.ORGENTRYKEY))


go
GRANT SELECT ON BOOKJOINTVENTURE_VIEW TO public
go