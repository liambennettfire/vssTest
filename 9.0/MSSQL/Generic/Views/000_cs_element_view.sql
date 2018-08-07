if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CS_element_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CS_element_view]
GO

CREATE VIEW [dbo].[CS_element_view] AS 
SELECT *
FROM gentables 
WHERE tableid = 287 AND gen1ind = 1
go

GRANT SELECT ON CS_element_view TO public
go
