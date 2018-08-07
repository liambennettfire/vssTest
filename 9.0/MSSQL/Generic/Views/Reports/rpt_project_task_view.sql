
/****** Object:  View [dbo].[rpt_project_task_view]    Script Date: 03/24/2009 13:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_project_task_view') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_project_task_view
GO
CREATE VIEW [dbo].[rpt_project_task_view]
AS
SELECT     dbo.taqproject.taqprojectkey, dbo.taqprojecttask.taqtaskkey AS taskkey, 
dbo.taqproject.taqprojecttitle, dbo.rpt_get_element_desc(dbo.taqprojecttask.taqelementkey) AS elementdesc, 
dbo.datetype.description AS tasktype, 
dbo.taqprojecttask.activedate, 
dbo.taqprojecttask.originaldate, 
dbo.rpt_get_yes_no(dbo.taqprojecttask.actualind) AS actualind, 
dbo.rpt_get_yes_no(dbo.taqprojecttask.keyind) AS keyind, 
datediff (d,getdate(),taqprojecttask.activedate) as duedays,
dbo.taqprojecttask.globalcontactkey, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'F') AS contactfirstname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'L') AS contactlastname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'S') AS contactshortname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'D') 
                      AS contactdisplayname, 
dbo.rpt_get_gentables_desc(285, dbo.taqprojecttask.rolecode, 'long') AS roledesc, 
dbo.taqprojecttask.globalcontactkey2, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'F') AS contactfirstname2, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'L') AS contactlastname2, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'S') AS contactshortname2, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'D') 
                      AS contactdisplayname2, 
dbo.rpt_get_gentables_desc(285, dbo.taqprojecttask.rolecode2, 'long') AS roledesc2, 

dbo.taqprojecttask.taqtasknote AS tasknote, 

'http://he.firebrandtech.com/DEMO/Projects/ProjectSummary.aspx?Projectkey=' + CONVERT(varchar(100), dbo.taqprojecttask.taqprojectkey) 
                       AS projectlink, 


'BUILD THIS LINK FOR PROJECT TASK LINK' 
/*CONVERT(varchar(100), dbo.taqprojecttask.bookkey) 
                      + '&QsiCode=4'*/ AS projecttasklink
FROM         
dbo.datetype, 
dbo.taqprojecttask,
dbo.taqproject

where dbo.datetype.datetypecode = dbo.taqprojecttask.datetypecode 
and  
dbo.taqprojecttask.taqprojectkey = dbo.taqproject.taqprojectkey


go
Grant All on dbo.rpt_project_task_view to Public
go