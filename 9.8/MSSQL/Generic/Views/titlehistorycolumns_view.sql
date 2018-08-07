if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[titlehistorycolumns_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[titlehistorycolumns_view]
GO

CREATE VIEW titlehistorycolumns_view AS
SELECT columnkey,columndescription, tablename,columnname,exporteloquenceind, workfieldind
FROM titlehistorycolumns


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[titlehistorycolumns_view]  TO [public]
GO