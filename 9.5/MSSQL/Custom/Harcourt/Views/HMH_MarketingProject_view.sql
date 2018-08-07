if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[marketingproject_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[marketingproject_view]
GO

CREATE VIEW marketingproject_view AS
	SELECT rv.relatedprojectkey 'Campaign ID',
		   rv.taqprojectkey 'Marketing Project ID',
		   rv.projectname 'Description',
		   g.datadesc 'Type',
		   rv.project2status 'Status',
		   tm.floatvalue 'Original $',
		   tm2.floatvalue 'Revised $'
	  FROM projectrelationshipview rv
	  JOIN taqproject tp ON rv.taqprojectkey = tp.taqprojectkey
	  JOIN taqproject tp2 ON tp2.taqprojectkey = rv.relatedprojectkey
	  LEFT OUTER JOIN taqprojectmisc tm ON (tp.taqprojectkey = tm.taqprojectkey) 
	   AND tm.misckey = (SELECT miscitemkey1 FROM taqrelationshiptabconfig where relationshiptabcode = (select datacode FROM gentables WHERE tableid = 583
	     and datadesc = 'Mktg Projects (Campaign)'))
	  -- changed to LEFT JOIN as per Michelle's email
	  LEFT OUTER JOIN taqprojectmisc tm2 ON (tp.taqprojectkey = tm2.taqprojectkey) AND 
	    tm2.misckey = (SELECT miscitemkey2 FROM taqrelationshiptabconfig where relationshiptabcode = (select datacode FROM gentables WHERE tableid = 583
	     and datadesc = 'Mktg Projects (Campaign)'))
	  LEFT OUTER JOIN bookmiscitems bi ON (tm.misckey = bi.misckey)
	  LEFT OUTER JOIN bookmiscitems bi2 ON (tm2.misckey = bi2.misckey)
	  JOIN gentables g ON (tp.taqprojecttype = g.datacode) AND g.tableid = 521
	  WHERE (tp.searchitemcode = 3 AND tp.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode = 3)) --Marketing Project
	   AND (tp2.searchitemcode = 3 AND tp2.usageclasscode = (SELECT datasubcode FROM subgentables
		WHERE tableid = 550 and datacode = 3 and qsicode = 9)) -- Marketing Campaign
	   AND tp2.templateind <> 1
	   AND rv.relationshipcode in (select datacode FROM gentables WHERE tableid = 582 AND datacode in (17,19))  --Marketing Campaign,Marketing Project
  	   

GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[marketingproject_view]  TO [public]
GO

select * from [marketingproject_view]