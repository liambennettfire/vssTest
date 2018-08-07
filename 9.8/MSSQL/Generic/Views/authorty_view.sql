SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[authorty_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[authorty_view]
GO


CREATE VIEW authorty_view AS 
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
WHERE tableid=134 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[authorty_view]  TO [public]
GO

