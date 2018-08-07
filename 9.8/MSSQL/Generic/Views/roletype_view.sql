SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[roletype_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[roletype_view]
GO


CREATE VIEW roletype_view AS 
SELECT gentables.tableid,
	gentables.datacode, 
	gentables.datadesc,
	gentables.deletestatus, 
	gentables.applid,
	gentables.sortorder, 
	gentables.tablemnemonic, 
	gentables.externalcode,
	gentables.datadescshort, 
	gentables.lastuserid,
	gentables.lastmaintdate, 
	gentables.numericdesc1, 
	gentables.numericdesc2 
FROM gentables 
WHERE tableid=285 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[roletype_view]  TO [public]
GO

