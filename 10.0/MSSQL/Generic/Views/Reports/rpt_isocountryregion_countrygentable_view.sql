if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_isocountryregion_countrygentable_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_isocountryregion_countrygentable_view]
GO

CREATE VIEW [dbo].rpt_isocountryregion_countrygentable_view AS
select tag, name
   from cloudregion 
  where tag not in (select eloquencefieldtag from gentables where tableid = 114)
go
Grant select on dbo.rpt_isocountryregion_countrygentable_view to Public
go