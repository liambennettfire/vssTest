
/****** Object:  View [dbo].[rpt_title_task_contact_union_view]    Script Date: 03/24/2009 13:40:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_title_task_contact_union_view') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_title_task_contact_union_view
GO
CREATE VIEW [dbo].[rpt_title_task_contact_union_view]
AS
SELECT     dbo.book.bookkey, dbo.taqprojecttask.taqtaskkey AS taskkey, 
dbo.book.title, dbo.rpt_get_element_desc(dbo.taqprojecttask.taqelementkey) AS elementdesc, 
dbo.datetype.description AS tasktype, 
dbo.taqprojecttask.activedate, 
dbo.taqprojecttask.originaldate, 
dbo.rpt_get_yes_no(dbo.taqprojecttask.actualind) AS actualind, 
dbo.rpt_get_yes_no(dbo.taqprojecttask.keyind) AS keyind, 
datediff (d,getdate(),taqprojecttask.activedate) as duedays,
dbo.taqprojecttask.globalcontactkey, 
'contact 1' as whichcontact,
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'F') AS contactfirstname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'L') AS contactlastname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'S') AS contactshortname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey, 'D') 
                      AS contactdisplayname, 
dbo.rpt_get_gentables_desc(285, dbo.taqprojecttask.rolecode, 'long') AS roledesc, 

dbo.taqprojecttask.taqtasknote AS tasknote, 

                      'http://iti.firebrandtech.com/ITI/TitleSummary/TitleSummary.aspx?BookKey=' + CONVERT(varchar(100), dbo.taqprojecttask.bookkey) 
                      + '&PrintingKey=1' AS titlesummarylink, 'http://iti.firebrandtech.com/ITI/Projects/TaskTracking.aspx?BookKey=' + CONVERT(varchar(100), 
                      dbo.taqprojecttask.bookkey) + '&PrintingKey=1&TaskViewKey=0&ItemKey=' + CONVERT(varchar(100), dbo.taqprojecttask.bookkey) 
                      + '&QsiCode=4' AS titletasklink
FROM         
dbo.datetype, 
dbo.taqprojecttask,
dbo.book 

where dbo.datetype.datetypecode = dbo.taqprojecttask.datetypecode 
and  
dbo.taqprojecttask.bookkey = dbo.book.bookkey
UNION
SELECT     dbo.book.bookkey, dbo.taqprojecttask.taqtaskkey AS taskkey, 
dbo.book.title, dbo.rpt_get_element_desc(dbo.taqprojecttask.taqelementkey) AS elementdesc, 
dbo.datetype.description AS tasktype, 
dbo.taqprojecttask.activedate, 
dbo.taqprojecttask.originaldate, 
dbo.rpt_get_yes_no(dbo.taqprojecttask.actualind) AS actualind, 
dbo.rpt_get_yes_no(dbo.taqprojecttask.keyind) AS keyind, 
datediff (d,getdate(),taqprojecttask.activedate) as duedays,
dbo.taqprojecttask.globalcontactkey2, 
'contact 2' as whichcontact,
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'F') AS contactfirstname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'L') AS contactlastname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'S') AS contactshortname, 
dbo.rpt_get_contact_name(dbo.taqprojecttask.globalcontactkey2, 'D') 
                      AS contactdisplayname, 
dbo.rpt_get_gentables_desc(285, dbo.taqprojecttask.rolecode2, 'long') AS roledesc, 

dbo.taqprojecttask.taqtasknote AS tasknote, 

                      'http://iti.firebrandtech.com/ITI/TitleSummary/TitleSummary.aspx?BookKey=' + CONVERT(varchar(100), dbo.taqprojecttask.bookkey) 
                      + '&PrintingKey=1' AS titlesummarylink, 'http://iti.firebrandtech.com/ITI/Projects/TaskTracking.aspx?BookKey=' + CONVERT(varchar(100), 
                      dbo.taqprojecttask.bookkey) + '&PrintingKey=1&TaskViewKey=0&ItemKey=' + CONVERT(varchar(100), dbo.taqprojecttask.bookkey) 
                      + '&QsiCode=4' AS titletasklink
FROM         
dbo.datetype, 
dbo.taqprojecttask,
dbo.book 

where dbo.datetype.datetypecode = dbo.taqprojecttask.datetypecode 
and  
dbo.taqprojecttask.bookkey = dbo.book.bookkey
and dbo.taqprojecttask.globalcontactkey2 is not null

go
Grant All on dbo.rpt_title_task_contact_union_view to Public
go