SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[bisacsub_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[bisacsub_view]
GO


CREATE VIEW bisacsub_view AS 
SELECT subgentables.tableid,
	subgentables.datacode,
	subgentables.datasubcode,
	subgentables.datadesc,
	subgentables.deletestatus,
	subgentables.applid,
	subgentables.sortorder,
	subgentables.tablemnemonic,
	subgentables.externalcode,
	subgentables.datadescshort,
	subgentables.lastuserid,
	subgentables.lastmaintdate,
	subgentables.numericdesc1,
	subgentables.numericdesc2,
	subgentables.bisacdatacode
FROM subgentables 
WHERE tableid=339 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[bisacsub_view]  TO [public]
GO

