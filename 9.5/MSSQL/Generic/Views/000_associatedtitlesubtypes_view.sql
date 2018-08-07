if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[associatedtitlesubtypes_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[associatedtitlesubtypes_view]
GO

CREATE VIEW associatedtitlesubtypes_view AS
	SELECT dbo.subgentables.*
	FROM dbo.subgentables
	WHERE tableid = 440
go

GRANT SELECT ON associatedtitlesubtypes_view TO public
go