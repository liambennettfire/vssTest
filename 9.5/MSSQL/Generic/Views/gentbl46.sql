SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[gentbl46]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[gentbl46]
GO


CREATE VIEW gentbl46 AS 
SELECT TABLEID,
	DATACODE,
	DATADESC,
	DELETESTATUS,
	APPLID,
	SORTORDER,
	TABLEMNEMONIC,
	EXTERNALCODE,
	DATADESCSHORT,
	LASTUSERID,
	LASTMAINTDATE,
	NUMERICDESC1,
	NUMERICDESC2,
	BISACDATACODE,
	GEN1IND,
	GEN2IND,
	ACCEPTEDBYELOQUENCEIND,
	EXPORTELOQUENCEIND,
	LOCKBYQSIIND,
	LOCKBYELOQUENCEIND,
	ELOQUENCEFIELDTAG 
FROM GENTABLES WHERE TABLEID = 46 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[gentbl46]  TO [public]
GO

