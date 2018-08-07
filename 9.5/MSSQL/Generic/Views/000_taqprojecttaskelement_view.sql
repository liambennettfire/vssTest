if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqprojecttaskelement_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqprojecttaskelement_view]
GO

CREATE VIEW taqprojecttaskelement_view AS
-- override rows
SELECT DISTINCT tpt.taqtaskkey AS taqtaskkey, tpto.taqelementkey AS taqelementkey, 
       tpt.taqelementkey AS taskelementkey,
       1 AS overridetableind, 
       tpt.taqprojectkey AS taqprojectkey,tpt.bookkey AS bookkey,tpt.orgentrykey AS orgentrykey,
       tpt.globalcontactkey AS globalcontactkey, tpt.rolecode AS rolecode,
       tpt.globalcontactkey2 AS globalcontactkey2, tpt.rolecode2 AS rolecode2,
       CASE WHEN tpto.scheduleind IS NOT NULL THEN tpto.scheduleind ELSE tpt.scheduleind END AS scheduleind, 
       tpt.stagecode AS stagecode, tpt.datetypecode AS datetypecode, tpt.startdate AS startdate,
       tpt.startdateactualind AS startdateactualind, tpt.duration AS duration, tpt.activedate AS activedate,
       CASE WHEN tpto.lag IS NOT NULL THEN tpto.lag ELSE tpt.lag END AS lag, 
       tpt.actualind AS actualind, tpt.keyind AS keyind, tpt.originaldate AS originaldate,
       tpt.taqtasknote AS taqtasknote, tpt.decisioncode AS decisioncode, tpt.paymentamt AS paymentamt,
       tpt.taqtaskqty as taqtaskqty, 
       CASE WHEN tpto.sortorder IS NOT NULL THEN tpto.sortorder ELSE tpt.sortorder END AS sortorder, 
       tpt.taqprojectformatkey AS taqprojectformatkey,tpt.lockind AS lockind, tpt.lastuserid AS lastuserid,
       tpt.lastmaintdate AS lastmaintdate, 
  --   tpt.taqprojectcontactrolekey AS taqprojectcontactrolekey,
       tpt.printingkey AS printingkey, tpt.transactionkey AS transactionkey, tpt.cseventid AS cseventid, 
       tpt.reviseddate AS reviseddate
  FROM taqprojecttask tpt, taqprojecttaskoverride tpto
 WHERE tpt.taqtaskkey = tpto.taqtaskkey
   --and COALESCE(tpt.taqelementkey,0) = 0
UNION
-- no override rows
SELECT DISTINCT tpt.taqtaskkey AS taqtaskkey, tpt.taqelementkey AS taqelementkey, 
       tpt.taqelementkey AS taskelementkey,
       0 AS overridetableind, 
       tpt.taqprojectkey AS taqprojectkey,tpt.bookkey AS bookkey,tpt.orgentrykey AS orgentrykey,
       tpt.globalcontactkey AS globalcontactkey, tpt.rolecode AS rolecode,
       tpt.globalcontactkey2 AS globalcontactkey2, tpt.rolecode2 AS rolecode2,
       tpt.scheduleind AS scheduleind, 
       tpt.stagecode AS stagecode, tpt.datetypecode AS datetypecode, tpt.startdate AS startdate,
       tpt.startdateactualind AS startdateactualind, tpt.duration AS duration, tpt.activedate AS activedate,
       tpt.lag AS lag, 
       tpt.actualind AS actualind, tpt.keyind AS keyind, tpt.originaldate AS originaldate,
       tpt.taqtasknote AS taqtasknote, tpt.decisioncode AS decisioncode, tpt.paymentamt AS paymentamt,
       tpt.taqtaskqty as taqtaskqty, 
       tpt.sortorder AS sortorder, 
       tpt.taqprojectformatkey AS taqprojectformatkey,tpt.lockind AS lockind, tpt.lastuserid AS lastuserid,
       tpt.lastmaintdate AS lastmaintdate, 
  --   tpt.taqprojectcontactrolekey AS taqprojectcontactrolekey,
       tpt.printingkey AS printingkey, tpt.transactionkey AS transactionkey, tpt.cseventid AS cseventid, 
       tpt.reviseddate AS reviseddate
  FROM taqprojecttask tpt
 WHERE tpt.taqelementkey IS NOT NULL
--       ORDER BY tpt.taqtaskkey,tpt.taqelementkey
 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqprojecttaskelement_view]  TO [public]
GO