if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ESTCOST_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[ESTCOST_VIEW]
GO
create view dbo.ESTCOST_VIEW(ESTKEY, VERSIONKEY, COMPONENT, SORTORDER, COSTDESCRIPTION, COSTTYPE, POTAG1, POTAG2, UNITCOST, TOTALCOST)  AS 
  SELECT 
      ev.ESTKEY, 
      ev.VERSIONKEY, 
      ct.COMPDESC AS COMPONENT, 
      ct.SORTORDER, 
      cd.EXTERNALDESC AS COSTDESCRIPTION, 
      cd.COSTTYPE, 
      ec.POTAG1, 
      ec.POTAG2, 
      ec.UNITCOST, 
      ec.TOTALCOST
    FROM dbo.ESTVERSION ev, dbo.COMPTYPE ct, dbo.ESTCOST ec
       LEFT JOIN dbo.CDLIST cd  ON (ec.CHGCODECODE = cd.INTERNALCODE)
    WHERE ((ev.ESTKEY = ec.ESTKEY) AND 
            (ev.VERSIONKEY = ec.VERSIONKEY) AND 
            (ec.COMPKEY = ct.COMPKEY))


go
GRANT SELECT ON ESTCOST_VIEW TO public
go