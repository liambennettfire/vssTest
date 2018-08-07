SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[gentables_ext_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[gentables_ext_view]
GO

create view dbo.gentables_ext_view(tableid, datacode, datadesc, deletestatus, applid, sortorder, tablemnemonic, externalcode, datadescshort, lastuserid, lastmaintdate, numericdesc1, numericdesc2, bisacdatacode, gen1ind, gen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, eloquencefieldtag, alternatedesc1, alternatedesc2, qsicode, onixcode, onixcodedefault, onixversion)  AS


  SELECT 
      g.TABLEID, 
      g.DATACODE, 
      g.DATADESC, 
      g.DELETESTATUS, 
      g.APPLID, 
      g.SORTORDER, 
      g.TABLEMNEMONIC, 
      g.EXTERNALCODE, 
      g.DATADESCSHORT, 
      g.LASTUSERID, 
      g.LASTMAINTDATE, 
      g.NUMERICDESC1, 
      g.NUMERICDESC2, 
      g.BISACDATACODE, 
      g.GEN1IND, 
      g.GEN2IND, 
      g.ACCEPTEDBYELOQUENCEIND, 
      g.EXPORTELOQUENCEIND, 
      g.LOCKBYQSIIND, 
      g.LOCKBYELOQUENCEIND, 
      g.ELOQUENCEFIELDTAG, 
      g.ALTERNATEDESC1, 
      g.ALTERNATEDESC2, 
      g.QSICODE, 
      ge.ONIXCODE, 
      ge.ONIXCODEDEFAULT, 
      ge.ONIXVERSION
    FROM dbo.GENTABLES g
       LEFT JOIN dbo.GENTABLES_EXT ge  ON ((g.TABLEID = ge.TABLEID) AND 
              (g.DATACODE = ge.DATACODE))
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
