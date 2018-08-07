if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ponote_gpo_project_conversion_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[ponote_gpo_project_conversion_view]
GO

CREATE VIEW ponote_gpo_project_conversion_view 
AS

select 
distinct(g.gponumber), t.taqprojectkey, g.notekey 
from gpo g inner join taqproductnumbers t 
on ltrim(rtrim(t.productnumber))=ltrim(rtrim(g.gponumber)) and t.productidcode=3 and coalesce(g.notekey,0)<>0
inner join note n on g.notekey=n.notekey
--order by g.gponumber,t.taqprojectkey
go
grant select on dbo.ponote_gpo_project_conversion_view to public
go

GRANT SELECT ON dbo.ponote_gpo_project_conversion_view to public
go












				
