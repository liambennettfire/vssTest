if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qutl_jobsummary_by_userid') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].qutl_jobsummary_by_userid
GO

CREATE FUNCTION dbo.qutl_jobsummary_by_userid (@i_userfilter varchar(30))

RETURNS @jobsummarytable TABLE(
  jobkey int, 
  reviewind int, 
  errorind int, 
  jobtypecode int, 
  showintmind int,
	jobtypedesc varchar(255), 
  jobtypesubcode int, 
  jobtypesubdesc varchar(255), 
  jobdesc varchar(2000), 
  jobdescshort varchaR(255), 
  startdatetime datetime, 
  stopdatetime datetime, 
  userid varchar(30), 
  statuscode int,
	statusdesc varchar(255), 
  summarymessage varchar(4000),
  lastuserid varchar(30), 
  lastmaintdate datetime
	)
AS

/*********************************************************************************************************************
**  Name: qutl_jobsummary_by_userid
**  Desc: This functional table returns job summary info based on a userid
**        NOTE: pass 'all' as the userid to get job summary for all users
**
**  Auth: Alan Katzen
**  Date: May 18, 2018
**
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date        Author  Description
**	--------    ------  -----------
** 
**********************************************************************************************************************/
BEGIN
  DECLARE 
    @v_errmsg_datacode int,
    @v_summarymsg_datacode int,
    @v_completedjob_datacode int

  SELECT @v_errmsg_datacode = datacode FROM gentables WHERE tableid=539 AND qsicode=2
  SELECT @v_summarymsg_datacode = datacode FROM gentables WHERE tableid=539 AND qsicode=6
  SELECT @v_completedjob_datacode = datacode FROM gentables WHERE tableid=544 AND qsicode=3

  IF rtrim(ltrim(@i_userfilter)) = '' or lower(@i_userfilter) = 'all' BEGIN
    INSERT INTO @jobsummarytable (jobkey,reviewind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc, 
      jobdesc,jobdescshort,startdatetime,stopdatetime,userid,statuscode,statusdesc,lastuserid,lastmaintdate, errorind,summarymessage)
    SELECT DISTINCT j.qsijobkey as jobkey, j.reviewind, j.jobtypecode, g.gen1ind as showintmind,
	    g.datadesc as jobtypedesc, j.jobtypesubcode, s.datadesc as jobtypesubdesc, j.jobdesc, j.jobdescshort, 
      j.startdatetime, j.stopdatetime, j.runuserid as userid, j.statuscode,
	    g2.datadesc as statusdesc, j.lastuserid, j.lastmaintdate,
      CASE WHEN (SELECT top 1 m.qsijobmessagekey FROM qsijobmessages m WHERE m.qsijobkey = j.qsijobkey AND m.messagetypecode = @v_errmsg_datacode) > 0 THEN 1 ELSE 0 END,
      CASE WHEN (j.statuscode = @v_completedjob_datacode) 
        THEN (SELECT top 1 m.messagelongdesc FROM qsijobmessages m WHERE m.qsijobkey = j.qsijobkey AND m.messagetypecode = @v_summarymsg_datacode) 
        ELSE 'Job Not Completed. Job Started at ' + CAST(j.startdatetime as varchar) END
    FROM qsijob j
      JOIN gentables g ON (g.datacode = j.jobtypecode)
      LEFT JOIN subgentables s ON (s.tableid = 543 AND s.datacode = j.jobtypecode AND s.datasubcode = j.jobtypesubcode)
      JOIN gentables g2 ON (g2.datacode = statuscode)
    WHERE g.tableid = 543
	    AND g2.tableid = 544
  END
  ELSE BEGIN
    INSERT INTO @jobsummarytable (jobkey,reviewind,jobtypecode,showintmind,jobtypedesc,jobtypesubcode,jobtypesubdesc, 
      jobdesc,jobdescshort,startdatetime,stopdatetime,userid,statuscode,statusdesc,lastuserid,lastmaintdate, errorind,summarymessage)
    SELECT DISTINCT j.qsijobkey as jobkey, j.reviewind, j.jobtypecode, g.gen1ind as showintmind,
	    g.datadesc as jobtypedesc, j.jobtypesubcode, s.datadesc as jobtypesubdesc, j.jobdesc, j.jobdescshort, 
      j.startdatetime, j.stopdatetime, j.runuserid as userid, j.statuscode,
	    g2.datadesc as statusdesc, j.lastuserid, j.lastmaintdate,
      CASE WHEN (SELECT top 1 m.qsijobmessagekey FROM qsijobmessages m WHERE m.qsijobkey = j.qsijobkey AND m.messagetypecode = @v_errmsg_datacode) > 0 THEN 1 ELSE 0 END,
      CASE WHEN (j.statuscode = @v_completedjob_datacode) 
        THEN (SELECT top 1 m.messagelongdesc FROM qsijobmessages m WHERE m.qsijobkey = j.qsijobkey AND m.messagetypecode = @v_summarymsg_datacode) 
        ELSE 'Job Not Completed. Job Started at ' + CAST(j.startdatetime as varchar) END
    FROM qsijob j
      JOIN gentables g ON (g.datacode = j.jobtypecode)
      LEFT JOIN subgentables s ON (s.tableid = 543 AND s.datacode = j.jobtypecode AND s.datasubcode = j.jobtypesubcode)
      JOIN gentables g2 ON (g2.datacode = statuscode)
    WHERE g.tableid = 543
	    AND g2.tableid = 544
      AND j.runuserid = @i_userfilter
  END

  --UPDATE jst 
  --   SET errorind = CASE WHEN COALESCE(m.qsijobmessagekey, 0) > 0 THEN 1 ELSE 0 END 
  --  FROM @jobsummarytable jst INNER JOIN 
  --       qsijobmessages m ON (m.qsijobkey = jst.jobkey AND m.messagetypecode = @v_errmsg_datacode)

  --UPDATE jst 
  --   SET summarymessage = CASE WHEN jst.statuscode = @v_completedjob_datacode THEN m.messagelongdesc ELSE 'Job Not Completed. Job Started at ' + CAST(jst.startdatetime as varchar) END 
  --  FROM @jobsummarytable jst INNER JOIN 
  --       qsijobmessages m ON (m.qsijobkey = jst.jobkey AND m.messagetypecode = @v_summarymsg_datacode)

  RETURN
END
GO

GRANT SELECT ON dbo.qutl_jobsummary_by_userid TO PUBLIC
GO