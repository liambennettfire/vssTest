if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_related_titles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_related_titles_view]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_associated_titles_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_associated_titles_view]
GO

CREATE VIEW [dbo].[rpt_related_titles_view]  AS
  SELECT * FROM associatedtitles_view
go

grant select on [dbo].[rpt_related_titles_view] to public
go