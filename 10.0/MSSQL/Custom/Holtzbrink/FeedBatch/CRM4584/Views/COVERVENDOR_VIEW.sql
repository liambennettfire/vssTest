if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[COVERVENDOR_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[COVERVENDOR_VIEW]
GO
create view dbo.COVERVENDOR_VIEW(BOOKKEY, COVERVENDORLONGNAME, COVERVENDORSHORTNAME)  AS 
  SELECT cs.BOOKKEY, v.NAME, v.SHORTDESC
    FROM dbo.COVERSPECS cs
       LEFT JOIN dbo.VENDOR v  ON (cs.VENDORKEY = v.VENDORKEY)
    WHERE (cs.PRINTINGKEY = 1)


go
GRANT SELECT ON COVERVENDOR_VIEW TO public
go