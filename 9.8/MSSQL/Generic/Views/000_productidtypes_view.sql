if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[productidtypes_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[productidtypes_view]
GO

CREATE VIEW productidtypes_view AS
	SELECT dbo.gentables.*
	FROM dbo.gentables
	WHERE tableid = 551
go

GRANT SELECT ON productidtypes_view TO public
go