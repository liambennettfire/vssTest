if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[projectrelationshipview]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[projectrelationshipview]
GO


/******************************************************************************
**  Name: projectrelationshipview
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  06/17/2016   Kusum       Case 37228
*******************************************************************************/

CREATE VIEW [dbo].projectrelationshipview AS
select
  taqprojectrelationshipkey,
  taqprojectkey1 "taqprojectkey",
  tp.taqprojecttitle "projectname",
  taqprojectkey2 "relatedprojectkey",
  tp2.taqprojecttitle "relatedprojectname",
  relationshipcode2 "relationshipcode",
  g.datadesc "relationshipdesc",
  cp.projectstatusdesc "project2status",
  cp.projectparticipants "project2participants",
  relationshipaddtldesc "relationshipaddtldescription",
  tpr.keyind,
  tpr.sortorder,
  tpr.indicator1,
  tpr.indicator2,
  tpr.quantity1,
  tpr.quantity2,
  tpr.lastuserid,
  tpr.lastmaintdate,
  tp.searchitemcode  "projectsearchitemcode",
  tp2.searchitemcode "relatedprojectsearchitemcode",
  tp.usageclasscode  "projectusageclasscode",
  tp2.usageclasscode "relatedprojectusageclasscode"
  from taqprojectrelationship tpr, taqproject tp, taqproject tp2, gentables g, coreprojectinfo cp
  where tpr.taqprojectkey1=tp.taqprojectkey
     and tpr.taqprojectkey2=tp2.taqprojectkey  
     and g.tableid=582
     and relationshipcode2=g.datacode
     and tpr.taqprojectkey2=cp.projectkey
union
select
  taqprojectrelationshipkey,
  taqprojectkey2 "taqprojectkey",
  tp.taqprojecttitle "projectname",
  taqprojectkey1 "relatedprojectkey",
  tp2.taqprojecttitle "relatedprojectname",
  relationshipcode1 "relationshipcode",
  g.datadesc "relationshipdesc",
  cp.projectstatusdesc "project2status",
  cp.projectparticipants "project2participants",
  relationshipaddtldesc "relationshipaddtldescription",
  tpr.keyind,
  tpr.sortorder,
  tpr.indicator1,
  tpr.indicator2,
  tpr.quantity1,
  tpr.quantity2,
  tpr.lastuserid,
  tpr.lastmaintdate,
  tp.searchitemcode  "projectsearchitemcode",
  tp2.searchitemcode "relatedprojectsearchitemcode",
  tp.usageclasscode  "projectusageclasscode",
  tp2.usageclasscode "relatedprojectusageclasscode"
  from taqprojectrelationship tpr, taqproject tp, taqproject tp2, gentables g, coreprojectinfo cp
  where tpr.taqprojectkey2=tp.taqprojectkey
     and tpr.taqprojectkey1=tp2.taqprojectkey  
     and g.tableid=582
     and relationshipcode1=g.datacode
     and tpr.taqprojectkey2=cp.projectkey
     and tpr.taqprojectkey2 is not null
union
select
  taqprojectrelationshipkey,
  taqprojectkey2 "taqprojectkey",
  tp.taqprojecttitle "projectname",
  taqprojectkey1 "relatedprojectkey",
  tp2.taqprojecttitle "relatedprojectname",
  relationshipcode1 "relationshipcode",
  g.datadesc "relationshipdesc",
  cp.projectstatusdesc "project2status",
  cp.projectparticipants "project2participants",
  relationshipaddtldesc "relationshipaddtldescription",
  tpr.keyind,
  tpr.sortorder,
  tpr.indicator1,
  tpr.indicator2,
  tpr.quantity1,
  tpr.quantity2,
  tpr.lastuserid,
  tpr.lastmaintdate,
  tp.searchitemcode  "projectsearchitemcode",
  tp2.searchitemcode "relatedprojectsearchitemcode",
  tp.usageclasscode  "projectusageclasscode",
  tp2.usageclasscode "relatedprojectusageclasscode"
  from taqprojectrelationship tpr, taqproject tp, taqproject tp2, gentables g, coreprojectinfo cp
  where tpr.taqprojectkey2=tp.taqprojectkey
     and tpr.taqprojectkey1=tp2.taqprojectkey  
     and g.tableid=582
     and relationshipcode1=g.datacode
     and tpr.taqprojectkey2=cp.projectkey
     and tpr.taqprojectkey2 is null
go

grant select on projectrelationshipview to public
go


