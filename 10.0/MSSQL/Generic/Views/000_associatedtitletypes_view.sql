if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[associatedtitletypes_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[associatedtitletypes_view]
GO

CREATE VIEW associatedtitletypes_view AS
	SELECT dbo.gentables.*
	FROM dbo.gentables
	WHERE tableid = 440
go

GRANT SELECT ON associatedtitletypes_view TO public
go