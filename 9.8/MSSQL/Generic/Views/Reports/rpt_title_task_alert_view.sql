
/****** Object:  View [dbo].[rpt_title_task_alert_view]    Script Date: 03/24/2009 13:40:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_title_task_alert_view') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_title_task_alert_view
GO
CREATE view [dbo].[rpt_title_task_alert_view] as
select q.notificationkey, q.sender_userid, q.recipient_globalcontactkey1,
q.objectkey1 as taqtaskkey, 
q.objectkey2 as datetypecode,
q.createdate as alertdate,
q.lastuserid as alertuser,
v.* 
from qsi_notification q, taqprojecttask t, rpt_title_task_view v
where q.objectkey1=t.taqtaskkey
and q.objectkey1 =  v.taskkey
go
Grant All on dbo.rpt_title_task_alert_view to Public
go