if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[purchaseorderstitlesview]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].purchaseorderstitlesview
GO

CREATE VIEW [dbo].[purchaseorderstitlesview] AS
SELECT DISTINCT r.taqprojectkey poprojectkey, r.relatedprojectkey printingprojectkey, ct.bookkey, ct.printingkey,p.printingnum,
  cp.projecttitle podisplayname, cp.projectparticipants poparticipants,
  cp.projecttypedesc potypedesc, cp.projectstatusdesc postatusdesc, 
  cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
  t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
  ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasonkey, ct.seasondesc, 
  ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
  CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
  dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc, ct.bestpubdate pubdate
FROM projectrelationshipview r 
  LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = r.taqprojectkey
  LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = r.relatedprojectkey
  LEFT OUTER JOIN coretitleinfo ct ON ct.bookkey = t.bookkey AND ct.printingkey = COALESCE(t.printingkey,1)
  LEFT OUTER JOIN printing p ON (t.bookkey = p.bookkey AND t.printingkey = p.printingkey)
 WHERE cp.searchitemcode = 15 and cp.usageclasscode in (1,2,3)
   and t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 3)
   and t.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 and qsicode = 7)

                                            
go

GRANT SELECT on purchaseorderstitlesview TO PUBLIC
go

