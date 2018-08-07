IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[contractstitlesview]'))
DROP VIEW [dbo].[contractstitlesview]
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
**  04/24/2017	 Joshua		 Case 44642
*******************************************************************************/

CREATE VIEW dbo.contractstitlesview AS
SELECT 
	pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
	ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
	cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
	cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
	t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
	ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
	ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
	CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
	dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
	ct.productnumber,t.primaryformatind
FROM 
	projectrelationshipview pv 
LEFT JOIN titlemasterworkview tmw
	ON pv.relatedprojectkey =  tmw.workprojectkey 
LEFT JOIN coretitleinfo ct
	ON ct.bookkey = tmw.bookkey 
	AND ct.printingkey = 1
LEFT JOIN coreprojectinfo cp 
	ON cp.projectkey = pv.taqprojectkey
LEFT JOIN taqprojecttitle t	
	ON t.taqprojectkey = pv.relatedprojectkey 
	AND t.bookkey = ct.bookkey
WHERE pv.relatedprojectusageclasscode = (SELECT sub.dataSubCode FROM subgentables sub WHERE sub.tableid = 550 AND sub.qsiCode = 28)
	AND pv.projectsearchitemcode = (SELECT gen.dataCode	FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 10)
	AND pv.relatedprojectsearchitemcode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 9)
UNION
SELECT 
	pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
	ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
	cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
	cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
	t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
	ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
	ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
	CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
	dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
	ct.productnumber,t.primaryformatind
FROM 
	 projectrelationshipview pv 
LEFT JOIN titlemasterworkview tmw
	ON pv.relatedprojectkey = tmw.MasterWorkProjectKey
LEFT JOIN coretitleinfo ct
	ON ct.bookkey = tmw.bookkey 
	AND ct.printingkey = 1
LEFT JOIN coreprojectinfo cp 
	ON cp.projectkey = pv.taqprojectkey
LEFT JOIN taqprojecttitle t	
	ON t.taqprojectkey = pv.relatedprojectkey 
	AND t.bookkey = ct.bookkey
WHERE pv.relatedprojectusageclasscode = (SELECT sub.dataSubCode FROM subgentables sub WHERE sub.tableid = 550 AND sub.qsiCode = 53)
	AND pv.projectsearchitemcode = (SELECT gen.dataCode	FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 10)
	AND pv.relatedprojectsearchitemcode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 9)
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[contractstitlesview]  TO [public]
GO