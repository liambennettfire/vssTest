
GO

/****** Object:  View [dbo].[rpt_get_Project_Report_View]    Script Date: 02/10/2017 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Project_Report_View]'))
DROP VIEW [dbo].[rpt_get_Project_Report_View]
GO


CREATE View [dbo].[rpt_get_Project_Report_View]  
As  
  
Select t.taqprojectkey as taqprojectkey,
isnull(p.primaryformatseasondesc,'N\A') SeasonDesc,
taqprojecttitle as title, taqprojectsubtitle as subtitle, 
dbo.rpt_get_gentables_field(522,t.taqprojectstatuscode,'D') as titlestatuscode,   
dbo.rpt_get_gentables_desc(521,t.taqprojecttype,'long') as ProjectType,
dbo.rpt_get_project_misc_value(t.taqprojectkey,210,'long') AS p_projecttype,
dbo.rpt_get_gentables_desc(327,t.taqprojectseriescode,'long') AS series,
isnull((select a.displayname from rpt_oup_Get_TaqAuthors_View a where a.reorder = 1 and a.taqprojectkey = t.taqprojectkey),'') as author1,  
isnull((select a.displayname from rpt_oup_Get_TaqAuthors_View a where a.reorder = 2 and a.taqprojectkey = t.taqprojectkey),'') as author2,
isnull((select a.displayname from rpt_oup_Get_TaqAuthors_View a where a.reorder = 3 and a.taqprojectkey = t.taqprojectkey),'') as author3,
isnull((select a.displayname from rpt_oup_Get_TaqAuthors_View a where a.reorder = 4 and a.taqprojectkey = t.taqprojectkey),'') as author4,
isnull((select a.displayname from rpt_oup_Get_TaqAuthors_View a where a.reorder = 5 and a.taqprojectkey = t.taqprojectkey),'') as author5,
isnull(b.name,'') as Reader1,
isnull(b2.name,'') as Reader2,
isnull(b3.name,'') as Reader3,
isnull(b4.name,'') as Reader4,
isnull(b5.name,'') as Reader5,
b.ReviewDueDate as ReviewDue1,
b2.ReviewDueDate as ReviewDue2,
b3.ReviewDueDate as ReviewDue3,
b4.ReviewDueDate as ReviewDue4,
b5.ReviewDueDate as ReviewDue5,
b.ReviewReceivedDate as ReviewReceived1,
b2.ReviewReceivedDate as ReviewReceived2,
b3.ReviewReceivedDate as ReviewReceived3,
b4.ReviewReceivedDate as ReviewReceived4,
b5.ReviewReceivedDate as ReviewReceived5,
dbo.rpt_get_project_participant_by_role (t.taqprojectkey,23,'D') as AE,
dbo.rpt_get_project_participant_by_role (t.taqprojectkey,69,'D') as ME,
dbo.rpt_get_project_participant_by_role (t.taqprojectkey,40,'D') as EA,
dbo.rpt_get_project_task (t.taqprojectkey,500,'B') as EdCommDate,
dbo.rpt_get_project_task (t.taqprojectkey,550,'B') as FABDate,
dbo.rpt_get_project_task (t.taqprojectkey,571,'B') as MSDue_Contract,
dbo.rpt_get_project_task (t.taqprojectkey,573,'B') as MSDue_Latest,
dbo.rpt_get_project_task (t.taqprojectkey,572,'B') as FinalMSRec,
dbo.rpt_get_project_task (t.taqprojectkey,565,'B') as MSTransRec,
dbo.rpt_get_project_task (t.taqprojectkey,566,'B') as MSTransmitted
from taqproject t  
left join coreprojectinfo p on p.projectkey = t.taqprojectkey
left outer join rpt_get_oup_taqreaders_view b on b.taqprojectkey = t.taqprojectkey and b.reorder = 1
left outer join rpt_get_oup_taqreaders_view b2 on b2.taqprojectkey = t.taqprojectkey and b2.reorder = 2
left outer join rpt_get_oup_taqreaders_view b3 on b3.taqprojectkey = t.taqprojectkey and b3.reorder = 3
left outer join rpt_get_oup_taqreaders_view b4 on b4.taqprojectkey = t.taqprojectkey and b4.reorder = 4
left outer join rpt_get_oup_taqreaders_view b5 on b5.taqprojectkey = t.taqprojectkey and b5.reorder = 5
where ((t.searchitemcode=3 and t.usageclasscode=1) or t.searchitemcode=9)
--and p.primaryformatseasondesc = 'Spring 2016'

Go
Grant all on rpt_get_Project_Report_View to public


