SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mediatypesub_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[mediatypesub_view]
GO


CREATE VIEW mediatypesub_view AS 
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
WHERE tableid=312 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[mediatypesub_view]  TO [public]
GO

