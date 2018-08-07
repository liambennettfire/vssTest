/*This sql sets up a view that shows all catalogs and their corresponging catalog sections.  It will be used for dropdowns in Title Search for CAtalog section search criteria */

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[catalogsectionbycatalog_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[catalogsectionbycatalog_view]
GO

CREATE VIEW catalogsectionbycatalog_view AS

SELECT DISTINCT tp.taqprojectkey 'catalogkey', tp.taqprojecttitle 'catalogname', p.relatedprojectkey 'catalogsectionkey', p.relatedprojectname 'catalogsectionname'          
  FROM projectrelationshipview p
   INNER    JOIN   taqproject tp ON ((tp.taqprojectkey = p.taqprojectkey)
						AND (tp.usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 and datacode = 3 and qsicode =19 )))
   INNER JOIN taqproject tp2 ON  ((tp2.taqprojectkey = p.relatedprojectkey)
						AND (tp2.usageclasscode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 and datacode = 3 and qsicode =20 )))
               
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[catalogsectionbycatalog_view]  TO [public]
GO