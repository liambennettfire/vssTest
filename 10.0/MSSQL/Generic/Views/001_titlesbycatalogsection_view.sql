/*This sql sets up the Title By Catalog Section view that allows us to search for Titles by Catalog Section */

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[titlesbycatalogsection_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[titlesbycatalogsection_view]
GO

CREATE VIEW titlesbycatalogsection_view AS
SELECT DISTINCT tpt.taqprojectkey 'catalogsectionkey', tp.taqprojecttitle 'catalogsectionname', cs.catalogkey, cs. catalogname, tpt.bookkey, tpt.printingkey, b.title
  FROM taqprojecttitle tpt
         INNER JOIN taqproject tp ON (tpt.taqprojectkey = tp.taqprojectkey)     
         INNER JOIN book b on (tpt.bookkey = b.bookkey)
	 LEFT OUTER JOIN   catalogsectionbycatalog_view cs ON (tp.taqprojectkey = cs.catalogsectionkey)
 WHERE tp.usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 and datacode = 3 and qsicode =20)
   
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[titlesbycatalogsection_view]  TO [public]
GO

select * from [titlesbycatalogsection_view]