if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BINDVENDOR_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[BINDVENDOR_VIEW]
GO
create view dbo.BINDVENDOR_VIEW(BOOKKEY, BINDVENDORLONGNAME, BINDVENDORSHORTNAME)  AS 
  SELECT bs.BOOKKEY, v.NAME, v.SHORTDESC
    FROM dbo.BINDINGSPECS bs
       LEFT JOIN dbo.VENDOR v  ON (bs.VENDORKEY = v.VENDORKEY)
    WHERE (bs.PRINTINGKEY = 1)


go
GRANT SELECT ON BINDVENDOR_VIEW TO public
go