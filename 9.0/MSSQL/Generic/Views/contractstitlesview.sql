if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contractstitlesview]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[contractstitlesview]
GO

CREATE VIEW dbo.contractstitlesview AS
SELECT r.taqprojectkey1 contractprojectkey, r.taqprojectkey2 workprojectkey, ct.bookkey, ct.printingkey,
  cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
  cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
  cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
  t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
  ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
  ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
  CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
  dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc
FROM taqprojectrelationship r 
  LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = r.taqprojectkey1
  LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = r.taqprojectkey2
  JOIN coretitleinfo ct ON ct.bookkey = t.bookkey AND ct.printingkey = COALESCE(t.printingkey,1)
WHERE relationshipcode1 IN 
  (SELECT code1 FROM gentablesrelationshipdetail 
  WHERE code2 = (SELECT datacode FROM gentables WHERE tableid = 583 AND qsicode = 23) AND
    gentablesrelationshipkey IN (SELECT COALESCE(gentablesrelationshipkey,0) FROM gentablesrelationships 
                                 WHERE gentable1id = 582 AND gentable2id = 583) )
UNION
SELECT r.taqprojectkey2 contractprojectkey, r.taqprojectkey1 workprojectkey, ct.bookkey, ct.printingkey,
  cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
  cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
  cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
  t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
  ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
  ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
  CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
  dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatuscode
FROM taqprojectrelationship r 
  LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = r.taqprojectkey2
  LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = r.taqprojectkey1
  JOIN coretitleinfo ct ON ct.bookkey = t.bookkey AND ct.printingkey = COALESCE(t.printingkey,1)
WHERE relationshipcode2 IN 
  (SELECT code1 FROM gentablesrelationshipdetail 
  WHERE code2 = (SELECT datacode FROM gentables WHERE tableid = 583 AND qsicode = 23) AND
    gentablesrelationshipkey IN (SELECT COALESCE(gentablesrelationshipkey,0) FROM gentablesrelationships 
                                 WHERE gentable1id = 582 AND gentable2id = 583) )            

go

GRANT SELECT on contractstitlesview TO PUBLIC
go

