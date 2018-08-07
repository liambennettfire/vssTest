if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[marketingplan_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[marketingplan_view]
GO

CREATE VIEW marketingplan_view AS
	SELECT tp.taqprojectkey 'Plan ID',tp.taqprojecttitle 'Description',
    sg.datadesc 'Class',
    --g.datadesc 'Type',
    g2.datadesc 'Status',
	SUM(tm.floatvalue) 'Budget'
	   	  FROM taqproject tp
	   --INNER JOIN gentables g ON (tp.taqprojecttype = g.datacode)  AND g.tableid = 521   --Project Type
	   INNER JOIN gentables g2 ON (tp.taqprojectstatuscode = g2.datacode) AND g2.tableid = 522 --Project Status
	   JOIN taqprojectmisc tm ON (tp.taqprojectkey = tm.taqprojectkey)
	   JOIN subgentables sg ON (tp.usageclasscode = sg.datasubcode) AND sg.tableid = 550 AND sg.qsicode = 10 
	   WHERE searchitemcode = 3 AND usageclasscode = (SELECT datasubcode FROM subgentables
				WHERE tableid = 550 and datacode = 3 and qsicode = 10) --Marketing Plan
	    GROUP BY tp.taqprojectkey,tp.taqprojecttitle,g2.datadesc,sg.datadesc
	    
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[marketingplan_view]  TO [public]
GO

select * from [marketingplan_view]