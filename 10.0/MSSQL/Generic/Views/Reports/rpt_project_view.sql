IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_gentables_desc') and OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.get_gentables_desc
GO

/****** Object:  View [dbo].[rpt_project_view]    Script Date: 04/27/2009 11:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter view [dbo].[rpt_project_view] as
select 
taqprojectkey as projectkey,
taqprojecttitle as projecttitle,
dbo.rpt_get_subgentables_desc (550,searchitemcode,usageclasscode,'D') as projectclass,
taqprojecttype as projecttypecode,
dbo.rpt_get_gentables_desc (521,taqprojecttype,'D') as projecttype,
taqprojectstatuscode as projectstatuscode,
dbo.rpt_get_gentables_desc(522, taqprojectstatuscode, 'long') AS projectstatuslong,
dbo.rpt_get_gentables_desc(522, taqprojectstatuscode, 'short') AS projectstatusshort,
dbo.rpt_get_project_owner (taqprojectkey,'D') as projectownerdisplayname,
dbo.rpt_get_project_owner (taqprojectkey,'F') as projectownerfirstname,
dbo.rpt_get_project_owner (taqprojectkey,'L') as projectownerlastname

from taqproject
where templateind=0
go
grant select on rpt_project_view to public