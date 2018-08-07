/****** Object:  View [dbo].[jobsummary_view]    Script Date: 03/15/2013 15:00:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[jobsummary_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
	drop view [dbo].[jobsummary_view]
GO

CREATE VIEW [dbo].[jobsummary_view] AS

SELECT DISTINCT j.qsijobkey as jobkey, j.reviewind, CASE WHEN COALESCE(m.jobmessagekey, 0) > 0 THEN 1 ELSE 0 END as errorind, j.jobtypecode, g.gen1ind as showintmind,
	g.datadesc as jobtypedesc, j.jobtypesubcode, s.datadesc as jobtypesubdesc, j.jobdesc, j.jobdescshort, j.startdatetime, j.stopdatetime, j.runuserid as userid, j.statuscode,
	g2.datadesc as statusdesc, CASE WHEN g2.qsicode = 3 THEN m2.messagelongdesc ELSE 'Job Not Completed. Job Started at ' + CAST(j.startdatetime as varchar) END as summarymessage,
	j.lastuserid, j.lastmaintdate
FROM qsijob j
JOIN gentables g ON (g.datacode = j.jobtypecode)
LEFT JOIN subgentables s ON (s.tableid = 543 AND s.datacode = j.jobtypecode AND s.datasubcode = j.jobtypesubcode)
JOIN gentables g2 ON (g2.datacode = statuscode)
LEFT JOIN jobmessages_view m ON (m.jobkey = j.qsijobkey AND m.messagetypecode IN (SELECT datacode FROM gentables WHERE tableid=539 AND qsicode=2)) --error message
LEFT JOIN jobmessages_view m2 ON (m2.jobkey = j.qsijobkey AND m2.messagetypecode IN (SELECT datacode FROM gentables WHERE tableid=539 AND qsicode=6)) --summary message
WHERE g.tableid = 543
	AND g2.tableid = 544

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[jobsummary_view]  TO [public]
GO