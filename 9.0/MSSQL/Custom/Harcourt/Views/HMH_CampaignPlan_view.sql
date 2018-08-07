if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[campaignplan_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[campaignplan_view]
GO

CREATE VIEW campaignplan_view AS
	SELECT DISTINCT tp.taqprojectkey 'Plan ID',
		   tp2.taqprojectkey 'Campaign ID',
		   tp2.taqprojecttitle 'Description',
		   g3.datadesc 'Class',
		   g.datadesc 'Type',g2.datadesc 'Status',
		   SUM(tm.floatvalue) 'Budget',
		   tpl.bookkey 'Bookkey'
	  FROM taqproject tp
	  JOIN taqprojectrelationship ts ON ts.taqprojectkey1 = tp.taqprojectkey
	  JOIN taqproject tp2 ON ts.taqprojectkey2 = tp2.taqprojectkey 
	  JOIN gentables g ON (tp2.taqprojecttype = g.datacode)  AND g.tableid = 521  --Project Type
	  JOIN gentables g2 ON (tp2.taqprojectstatuscode = g2.datacode) AND g2.tableid = 522 --Project Status
	  LEFT OUTER JOIN taqprojectmisc tm ON (tp2.taqprojectkey = tm.taqprojectkey)
	  LEFT OUTER JOIN taqprojecttitle tpl ON tpl.taqprojectkey = tp2.taqprojectkey 
	  JOIN gentables g3 ON ts.relationshipcode2 = g3.datacode AND g3.tableid = 582
	 WHERE (tp.searchitemcode = 3 AND tp.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode = 10)) --Marketing Plan
	   AND (tp2.searchitemcode = 3 AND tp2.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode =9)) -- Marketing Campaign
	   AND ts.relationshipcode1 in (select datacode FROM gentables WHERE tableid = 582 AND datacode in (18,20)) --Marketing Plan,Marketing Campaign
  	   AND ts.relationshipcode2 in (select datacode FROM gentables WHERE tableid = 582 AND datacode in (18,20)) --Marketing Plan,Marketing Campaign
	   AND tp2.templateind = 0
	   --AND tpl.bookkey > 0
	 GROUP BY tp.taqprojectkey,tp2.taqprojectkey,tp2.taqprojecttitle,g.datadesc,g2.datadesc,tpl.bookkey,g3.datadesc
		    
  UNION

	SELECT DISTINCT tp.taqprojectkey 'Plan ID',
		   tp2.taqprojectkey 'Campaign ID',
		   tp2.taqprojecttitle 'Description',
		   g3.datadesc 'Class',
		   g.datadesc 'Type',g2.datadesc 'Status',
		   SUM(tm.floatvalue) 'Budget',
		   tpl.bookkey 'Bookkey'
	  FROM taqproject tp
	  JOIN taqprojectrelationship ts ON ts.taqprojectkey2 = tp.taqprojectkey
	  JOIN taqproject tp2 ON ts.taqprojectkey1 = tp2.taqprojectkey 
	  JOIN gentables g ON (tp2.taqprojecttype = g.datacode)  AND g.tableid = 521  --Project Type
	  JOIN gentables g2 ON (tp2.taqprojectstatuscode = g2.datacode) AND g2.tableid = 522 --Project Status
	  LEFT OUTER JOIN taqprojectmisc tm ON (tp2.taqprojectkey = tm.taqprojectkey)
	  LEFT OUTER JOIN taqprojecttitle tpl ON tpl.taqprojectkey = tp2.taqprojectkey 
	  JOIN gentables g3 ON ts.relationshipcode2 = g3.datacode AND g3.tableid = 582 
	 WHERE (tp.searchitemcode = 3 AND tp.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode = 10)) --Marketing Plan
	   AND (tp2.searchitemcode = 3 AND tp2.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode =9)) -- Marketing Campaign
	   AND ts.relationshipcode2 in (select datacode FROM gentables WHERE tableid = 582 AND datacode in (18,20))  --Marketing Plan,Marketing Campaign
	   AND ts.relationshipcode1 in (select datacode FROM gentables WHERE tableid = 582 AND datacode in (18,20))  --Marketing Plan,Marketing Campaign
	   AND tp2.templateind = 0
	   --AND tpl.bookkey > 0
	GROUP BY tp.taqprojectkey,tp2.taqprojectkey,tp2.taqprojecttitle,g.datadesc,g2.datadesc,tpl.bookkey,g3.datadesc
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[campaignplan_view]  TO [public]
GO

select * from [campaignplan_view]


	    
	