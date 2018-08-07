if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_countrygentable_isocountrytable_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_countrygentable_isocountrytable_view]
GO

CREATE VIEW [dbo].rpt_countrygentable_isocountrytable_view AS
select datadesc, eloquencefieldtag
   from gentables 
 where tableid = 114
   and eloquencefieldtag not in (select tag from cloudregion)
   and deletestatus in ('N','n')

go
Grant select on dbo.rpt_countrygentable_isocountrytable_view to Public
go