

GO

/****** Object:  View [dbo].[rpt_Get_TaqReaders_View]    Script Date: 02/10/2017 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_TaqReaders_View]'))
DROP VIEW [dbo].[rpt_Get_TaqReaders_View]
GO

CREATE view [dbo].[rpt_Get_TaqReaders_View] as    
SELECT c.taqprojectkey,g.datadesc,
g2.globalcontactkey, c.sortorder,
g2.displayname, g2.firstname, g2.lastname, g2.middlename,
dbo.rpt_get_contact_name (g2.globalcontactkey,'C') as fullname,
dbo.rpt_GET_QSI_Comment (g2.globalcontactkey,10,0) as readerbio,
dbo.rpt_oup_get_max_project_task (dbo.rpt_oup_get_latest_taqtaskkey(
dbo.rpt_oup_get_taqprojectkey(c.taqprojectkey),548,18,g2.globalcontactkey),'B'
) as ReviewDueDate,
dbo.rpt_oup_get_max_project_task (dbo.rpt_oup_get_latest_taqtaskkey(
dbo.rpt_oup_get_taqprojectkey(c.taqprojectkey),549,18,g2.globalcontactkey),'B'
) as ReviewReceivedDate,
dbo.rpt_get_project_task(c.taqprojectkey,500,'A') as EdComm,
dbo.rpt_get_project_task(c.taqprojectkey,569,'A') as EdComm2,
dbo.rpt_get_project_task(c.taqprojectkey,550,'A') as FAB,
dbo.rpt_get_project_task(c.taqprojectkey,570,'A') as FAB2,
EdCommRB = 
case 
when
isnull(dbo.rpt_get_project_task(c.taqprojectkey,570,'A'),0) <> 0
and dbo.rpt_oup_get_max_project_task (dbo.rpt_oup_get_latest_taqtaskkey(
c.taqprojectkey,549,18,g2.globalcontactkey),'B') > dbo.rpt_get_project_task(c.taqprojectkey,550,'A')
then 'FAB2'
when
isnull(dbo.rpt_get_project_task(c.taqprojectkey,550,'A'),0) <> 0
then 'FAB'
when 
isnull(dbo.rpt_get_project_task(c.taqprojectkey,569,'A'),0) <> 0
and dbo.rpt_oup_get_max_project_task (dbo.rpt_oup_get_latest_taqtaskkey(
c.taqprojectkey,549,18,g2.globalcontactkey),'A') > dbo.rpt_get_project_task(c.taqprojectkey,500,'A')
and isnull(dbo.rpt_get_project_task(c.taqprojectkey,550,'A'),0) = 0
then 'EdComm2'
else 'EdComm'
end
 
FROM taqprojectcontact c, taqprojectcontactrole r, gentables g,globalcontact g2    
   WHERE c.taqprojectkey = r.taqprojectkey     
and c.taqprojectcontactkey = r.taqprojectcontactkey     
and g.tableid = 285     
and g.datacode = r.rolecode    
and c.globalcontactkey = g2.globalcontactkey    
and qsicode=3 

Go
Grant all on rpt_Get_TaqReaders_View to PUBLIC