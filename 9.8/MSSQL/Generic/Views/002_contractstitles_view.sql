/****** Object:  View [dbo].[contractstitlesview]    Script Date: 12/14/2016 6:24:56 PM ******/
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
**  12/05/2016   Alan        Case 42081
**  02/14/2017   Jason       Added in primaryformatind to the view    
**  02/21/2018   Ben         Case 47787
*******************************************************************************/

CREATE VIEW [dbo].[contractstitlesview] AS
SELECT DISTINCT pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
  ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
  cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
  cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
  t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
  ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
  ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
  CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
  dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
  ct.productnumber, t.primaryformatind

FROM taqproject tp
LEFT OUTER JOIN projectrelationshipview pv ON tp.taqprojectkey = pv.taqprojectkey
LEFT OUTER JOIN titlemasterworkview tmw ON tmw.workprojectkey = pv.relatedprojectkey 
JOIN coretitleinfo ct ON ct.bookkey = tmw.bookkey AND ct.printingkey = 1
LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = pv.taqprojectkey
LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = pv.relatedprojectkey and t.bookkey = ct.bookkey

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
  ct.productnumber, t.primaryformatind

FROM taqproject tp
LEFT OUTER JOIN projectrelationshipview pv ON tp.taqprojectkey = pv.taqprojectkey
LEFT OUTER JOIN titlemasterworkview tmw ON tmw.workprojectkey = pv.relatedprojectkey 
JOIN coretitleinfo ct ON ct.bookkey = tmw.bookkey AND ct.printingkey = 1
LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = pv.taqprojectkey
LEFT OUTER JOIN taqprojecttitle t ON t.taqprojectkey = pv.relatedprojectkey and t.bookkey = ct.bookkey

WHERE pv.projectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 10) -- Contract
  AND pv.relatedprojectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND tmw.titleworksearchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND tmw.titleworkusageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Works
  AND COALESCE(tmw.masterworkprojectkey,0) = 0

UNION

SELECT DISTINCT tp.taqprojectkey contractprojectkey, t.workprojectkey workprojectkey,
b.bookkey, b.printingkey, tp.taqprojecttitle contractdisplayname, c.projectparticipants contractparticipants,
c.projecttypedesc contracttypedesc, c.projectstatusdesc AS contractstatusdesc,
c.projectowner, c.searchitemcode, c.usageclasscode, COALESCE(c.templateind,0) templateind,
tpt.keyind, tpt.titlerolecode, dbo.get_gentables_desc(605,tpt.titlerolecode,'long') titleroledesc,
b.title, b.productnumberx, b.altproductnumberx, b.authorname, b.seasondesc,
b.formatname, b.mediatypecode, b.mediatypesubcode,
CONVERT(VARCHAR,b.mediatypecode) + '|' + CONVERT(VARCHAR,b.mediatypesubcode) mediaformatkey,
dbo.get_gentables_desc(314,b.bisacstatuscode,'long') bisacstatusdesc,
b.productnumber, tpt.primaryformatind
 --tp.taqprojecttitle, tp.taqprojectkey, b.bookkey, b.title

FROM taqproject tp --Contract
JOIN projectrelationshipview tpr ON tp.taqprojectkey = tpr.taqprojectkey
--JOIN taqprojectrelationship tpr ON tp.taqprojectkey = tpr.taqprojectkey1 
--AND tpr.relationshipcode1 = 6 AND tpr.relationshipcode2 = 5 --Contract to Master Work
JOIN titlemasterworkview t ON tpr.relatedprojectkey = t.Masterworkprojectkey
--JOIN taqprojectrelationship tpr2 ON tpr.taqprojectkey2 = tpr2.taqprojectkey1 
--AND tpr2.relationshipcode1 = 31 AND tpr2.relationshipcode2 = 32 --Master Work to Subordinate Work 
--JOIN taqprojecttitle t ON tpr2.taqprojectkey2 = t.taqprojectkey --Subordinate Work to Titles
--LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = tpr.taqprojectkey
LEFT OUTER JOIN taqprojecttitle tpt ON tpt.taqprojectkey = tpr.relatedprojectkey
JOIN coretitleinfo b ON t.bookkey = b.bookkey
JOIN coreprojectinfo c on tp.taqprojectkey = c.projectkey

WHERE tpr.projectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 10) -- Contract
  AND tpr.relatedprojectsearchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Master Work
  AND tpr.relatedprojectusageclasscode = (SELECT datasubcode from subgentables where tableid = 550 AND qsicode = 53) -- Master Work
  AND t.titleworksearchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
  AND t.titleworkusageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Works
  AND COALESCE(t.masterworkprojectkey,0) <> 0


GO
GRANT SELECT on contractstitlesview TO PUBLIC
go
