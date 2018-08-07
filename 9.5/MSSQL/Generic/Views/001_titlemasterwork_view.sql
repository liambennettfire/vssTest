if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[titlemasterworkview]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[titlemasterworkview]
GO


/******************************************************************************
**  Name: titlemasterworkview
**  Desc: This will show the connection between a title, its work and that
**        work's master work. This view assumes that for one title, there is
**        one work and one master work. There will not always be a master work
**        even if a work exists but a work must exist for a master work to
**        exist.
**  Auth: Kusum
**  Date: 06/17/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
** 
*******************************************************************************/

CREATE VIEW [dbo].titlemasterworkview AS
select 
	b.bookkey "bookkey",
	tp.taqprojectkey "workprojectkey",
	tp.searchitemcode "titleworksearchitemcode",
	tp.usageclasscode "titleworkusageclasscode",
	pv1.taqprojectkey "Masterworkprojectkey",
	pv1.projectname "Masterworkprojectname"	,
	pv1.relationshipdesc "masterworkdesc",
	pv1.relationshipcode "masterworkrelationshipcode",
	pv1.projectsearchitemcode "masterworksearchitemcode",
	pv1.projectusageclasscode "masterworkusageclasscode"
  FROM book b, taqproject tp,  projectrelationshipview pv1
 WHERE b.workkey = tp.workkey
   AND tp.searchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
   AND tp.usageclasscode = (select datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Work
   AND pv1.relatedprojectkey = tp.taqprojectkey
   AND pv1.projectsearchitemcode = (select datacode FROM subgentables WHERE qsicode = 28) --  Work
   AND pv1.projectusageclasscode = (select datasubcode FROM subgentables WHERE qsicode = 53) -- Master Work
   AND pv1.relationshipcode = (select datacode FROM gentables WHERE tableid = 582 AND qsicode = 35) --Acq Proj (Work)
UNION
select 
	b.bookkey "bookkey",
	tp.taqprojectkey "workprojectkey",
	tp.searchitemcode "titleworksearchitemcode",
	tp.usageclasscode "titleworkusageclasscode",
	NULL "Masterworkprojectkey",
	NULL "Masterworkprojectname",
	NULL "masterworkdesc",
	NULL "masterworkrelationshipcode",
	NULL "masterworksearchitemcode",
	NULL  "masterworkusageclasscode"
 FROM book b, taqproject tp
 WHERE b.workkey = tp.workkey
   AND tp.searchitemcode = (select datacode FROM gentables WHERE tableid = 550 AND qsicode = 9) -- Work
   AND tp.usageclasscode = (select datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 28) -- Work
   AND tp.taqprojectkey NOT IN (SELECT relatedprojectkey FROM projectrelationshipview  WHERE projectrelationshipview.projectsearchitemcode = (select datacode FROM subgentables WHERE qsicode = 28) --  Work
   AND projectrelationshipview.projectusageclasscode = (select datasubcode FROM subgentables WHERE qsicode = 53) -- Master Work
   AND projectrelationshipview.relationshipcode = (select datacode FROM gentables WHERE tableid = 582 AND qsicode = 35)) --Acq Proj (Work)
   
go

GRANT SELECT on titlemasterworkview TO PUBLIC
go