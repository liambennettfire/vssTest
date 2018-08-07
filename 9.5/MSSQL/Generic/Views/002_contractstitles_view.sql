if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contractstitlesview]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[contractstitlesview]
GO

/******************************************************************************
**  Name: contractstitlesview
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  03/17/2016   UK          Case 36930
**  06/22/2016   Kusum       Case 37228
*******************************************************************************/

CREATE VIEW dbo.contractstitlesview AS
SELECT DISTINCT pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
  ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
  cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
  cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
  t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
  ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
  ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
  CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
  dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
  ct.productnumber
FROM taqproject tp
LEFT OUTER JOIN projectrelationshipview pv ON tp.taqprojectkey = pv.taqprojectkey
LEFT OUTER JOIN titlemasterworkview tmw ON tmw.workprojectkey = pv.relatedprojectkey 
JOIN coretitleinfo ct ON ct.bookkey = tmw.bookkey AND ct.printingkey = 1
LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = pv.taqprojectkey
LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = pv.relatedprojectkey
WHERE pv.projectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 10) -- Contract
  AND pv.relatedprojectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND tmw.titleworksearchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND tmw.titleworkusageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Works
  AND COALESCE(tmw.masterworkprojectkey,0) > 0
  AND tmw.masterworksearchitemcode = (select datacode FROM gentables where tableid = 550 AND qsicode = 9)  --  Work
  AND tmw.masterworkusageclasscode = (select datasubcode FROM subgentables where tableid = 550 AND qsicode = 53)  -- Master Work
UNION 
SELECT DISTINCT pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
  ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
  cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
  cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
  t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
  ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
  ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
  CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
  dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
  ct.productnumber
FROM taqproject tp
LEFT OUTER JOIN projectrelationshipview pv ON tp.taqprojectkey = pv.taqprojectkey
LEFT OUTER JOIN titlemasterworkview tmw ON tmw.workprojectkey = pv.relatedprojectkey 
JOIN coretitleinfo ct ON ct.bookkey = tmw.bookkey AND ct.printingkey = 1
LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = pv.taqprojectkey
LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = pv.relatedprojectkey
WHERE pv.projectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 10) -- Contract
  AND pv.relatedprojectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND tmw.titleworksearchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND tmw.titleworkusageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Works
  AND COALESCE(tmw.masterworkprojectkey,0) = 0
go

GRANT SELECT on contractstitlesview TO PUBLIC
go

