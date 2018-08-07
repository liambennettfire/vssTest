 

/****** Object:  View [dbo].[DUP_Task_Alerts_View]    Script Date: 08/06/2015 13:55:04 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DUP_Task_Alerts_View]'))
DROP VIEW [dbo].[DUP_Task_Alerts_View]
GO
 

/****** Object:  View [dbo].[DUP_Task_Alerts_View]    Script Date: 08/06/2015 13:55:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE View [dbo].[DUP_Task_Alerts_View]
AS
Select taqprojecttask.taqprojectkey,taqprojecttask.globalcontactkey2,taqprojecttask.datetypecode,'TM Alert: ' + dbo.rpt_get_Task_Name(taqprojecttask.datetypecode) --+ --dbo.rpt_get_Task_Name(taqprojecttask.datetypecode) + ' on ' + IsNULL(CONVERT(varchar(19),dbo.rpt_get_project_task(taqprojectkey,taqprojecttask.datetypecode,'B'),101),'No Date Set Up') 
+ ' for '+ dbo.rpt_Get_Project_Title(taqprojectkey) as Subject,
/*+ CASE when dbo.dup_webfeed_rpt_get_related_projectkey(taqprojectkey,7)=0 then dbo.rpt_Get_Project_Title(taqprojectkey) else  dbo.rpt_Get_Project_Title(dbo.dup_webfeed_rpt_get_related_projectkey(taqprojectkey,7)) end  + ':' +
CASE WHEN dbo.dup_webfeed_rpt_get_related_projectkey(taqprojectkey,13)=0 then dbo.rpt_Get_Project_Title(taqprojectkey) else dbo.rpt_Get_Project_Title(dbo.dup_webfeed_rpt_get_related_projectkey(taqprojectkey,13)) end + ':' +
CASE WHEN dbo.dup_webfeed_rpt_get_related_projectkey(taqprojectkey,6)=0 then dbo.rpt_Get_Project_Title(taqprojectkey) else dbo.rpt_Get_Project_Title(dbo.dup_webfeed_rpt_get_related_projectkey(taqprojectkey,6)) end  as Subject, */
'Task completed: ' +  dbo.rpt_get_Task_Name(taqprojecttask.datetypecode) +  ' for '+ dbo.rpt_Get_Project_Title(taqprojectkey)  as Body,
dbo.rpt_get_contact_best_method_Modified(globalcontactkey2,3,1) as Email_Address
    from taqprojecttask 
    inner join taskviewdatetype on taqprojecttask.datetypecode=taskviewdatetype.datetypecode  where taskviewkey=2721328
    and globalcontactkey2 is not null
and taqprojectkey not in(Select taqprojectkey from taqproject where templateind=1)

and  actualind =1 and ActiveDate

between (Select CAST(Month(GETDATE()) AS VARCHAR(2))+ '/' +
CAST(Day(getDate()-1) AS VARCHAR(2)) + '/' +
CAST(YEAR(GETDATE()) AS VARCHAR(4))) and

(Select CAST(Month(GETDATE()) AS VARCHAR(2))+ '/' +
CAST(Day(getDate()) AS VARCHAR(2)) + '/' +
CAST(YEAR(GETDATE()) AS VARCHAR(4)))

GO


