SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[commenttypesub_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[commenttypesub_view]
GO


CREATE VIEW commenttypesub_view AS 
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
	subgentables.numericdesc2 
FROM subgentables 
WHERE tableid=284 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[commenttypesub_view]  TO [public]
GO

