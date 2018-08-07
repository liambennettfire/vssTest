if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[origpubhouse_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[origpubhouse_view]
GO


CREATE VIEW origpubhouse_view AS 
  SELECT *
  FROM gentables
  WHERE tableid = 126

GO

GRANT SELECT ON [dbo].[origpubhouse_view]  TO [public]
GO

