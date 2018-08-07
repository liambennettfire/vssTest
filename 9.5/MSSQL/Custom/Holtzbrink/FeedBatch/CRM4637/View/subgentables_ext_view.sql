SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[subgentables_ext_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[subgentables_ext_view]
GO


create view dbo.subgentables_ext_view(tableid, datacode, datasubcode, datadesc, deletestatus, applid, sortorder, tablemnemonic, alldivisionsind, externalcode, datadescshort, lastuserid, lastmaintdate, numericdesc1, numericdesc2, bisacdatacode, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, eloquencefieldtag, alternatedesc1, alternatedesc2, subgen3ind, qsicode, onixsubcode, otheronixcode, otheronixcodedesc, onixsubcodedefault, onixversion)  as

  /*****
  *  INFO ORA2MS-6002 line: 4 col: 1: WHERE clause was transformed to the join's conditions in the FROM clause.
  *****/

  SELECT 
      s.TABLEID, 
      s.DATACODE, 
      s.DATASUBCODE, 
      s.DATADESC, 
      s.DELETESTATUS, 
      s.APPLID, 
      s.SORTORDER, 
      s.TABLEMNEMONIC, 
      s.ALLDIVISIONSIND, 
      s.EXTERNALCODE, 
      s.DATADESCSHORT, 
      s.LASTUSERID, 
      s.LASTMAINTDATE, 
      s.NUMERICDESC1, 
      s.NUMERICDESC2, 
      s.BISACDATACODE, 
      s.SUBGEN1IND, 
      s.SUBGEN2IND, 
      s.ACCEPTEDBYELOQUENCEIND, 
      s.EXPORTELOQUENCEIND, 
      s.LOCKBYQSIIND, 
      s.LOCKBYELOQUENCEIND, 
      s.ELOQUENCEFIELDTAG, 
      s.ALTERNATEDESC1, 
      s.ALTERNATEDESC2, 
      s.SUBGEN3IND, 
      s.QSICODE, 
      se.ONIXSUBCODE, 
      se.OTHERONIXCODE, 
      se.OTHERONIXCODEDESC, 
      se.ONIXSUBCODEDEFAULT, 
      se.ONIXVERSION
    FROM dbo.SUBGENTABLES s
       LEFT JOIN dbo.SUBGENTABLES_EXT se  ON ((s.TABLEID = se.TABLEID) AND 
              (s.DATACODE = se.DATACODE) AND 
              (s.DATASUBCODE = se.DATASUBCODE))

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

