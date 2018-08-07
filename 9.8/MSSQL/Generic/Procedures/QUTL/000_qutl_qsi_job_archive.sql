IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_qsi_job_archive')
  DROP PROCEDURE  qutl_qsi_job_archive
GO

CREATE PROCEDURE qutl_qsi_job_archive
(
  @i_daysToKeep	INT,
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
)
AS

/****************************************************************************************************************************************
**  Name: qutl_qsi_job_archive
**  Desc: This stored procedure will archive old job and job message data
**
**  Summary: 
**  CASE: 41947 Archive Job tables 1074 Firebrand Technologies : TM Internal Enhancements
**		1. Find every job on qsijobs that has startdatetime > # of days to keep + todays date
**			-> Move that qsijob row to qsijob_archive (new table that needs to be setup mirroring qsijob plus an archive datetime)
**			-> Move all qsimessages rows with that qsijobkey to qsimessages_archive (new table that needs to be setup
**				mirroring qsimessages plus an archive datetime)
**
**  Paramaters:
**		@o_error_code output param, not used but required
**		@o_error_desc output param, not used but required
**		@i_daysToKeep input param, if null will default to 90 days
**
**  Auth: Joshua Granville
**  Date: 29 November 2016
*****************************************************************************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

DECLARE 
	@v_date_end DATETIME,
	@v_archive_date DATETIME

--If the optional param is passed we will use it otherwise we default to 90
SET @v_date_end = DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0) - ISNULL(@i_daysToKeep,90)
SET @v_archive_date = GETDATE()
SET @o_error_code = 0
SET @o_error_desc = ''


----------------------------------------------------------------
-- Create tables if this is the first run
----------------------------------------------------------------
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
				WHERE TABLE_NAME = 'qsijob_archive')
				
CREATE TABLE [dbo].[qsijob_archive](
	[qsijobkey] [int] NOT NULL,
	[qsibatchkey] [int] NOT NULL,
	[jobtypecode] [smallint] NULL,
	[jobtypesubcode] [smallint] NULL,
	[jobdesc] [varchar](2000) NULL,
	[jobdescshort] [varchar](255) NULL,
	[startdatetime] [datetime] NULL,
	[stopdatetime] [datetime] NULL,
	[runuserid] [varchar](30) NULL,
	[statuscode] [smallint] NULL,
	[lastuserid] [varchar](30) NULL,
	[lastmaintdate] [datetime] NULL,
	[reviewind] [tinyint] NULL,
	[qtyprocessed] [int] NULL,
	[qtycompleted] [int] NULL,
	[runtimeemailsent] [datetime] NULL,
	[lasterroremailsent] [datetime] NULL,
	[numberoferroremails] [int] NULL,
	[archiveDate] [datetime] NULL,
 CONSTRAINT [PK_qsijob_archive] PRIMARY KEY NONCLUSTERED 
(
	[qsijobkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
	

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
				WHERE TABLE_NAME = 'qsijobmessages_archive')

CREATE TABLE [dbo].[qsijobmessages_archive](
	[qsijobmessagekey] [int] NOT NULL,
	[qsijobkey] [int] NOT NULL,
	[referencekey1] [int] NOT NULL DEFAULT (0),
	[referencekey2] [int] NOT NULL DEFAULT (0),
	[referencekey3] [int] NOT NULL DEFAULT (0),
	[messagetypecode] [smallint] NULL,
	[messagelongdesc] [varchar](4000) NULL,
	[messageshortdesc] [varchar](255) NULL,
	[lastuserid] [varchar](30) NULL,
	[lastmaintdate] [datetime] NULL,
	[messagecode] [int] NULL,
	[standardmsgcode] [int] NULL,
	[standardmsgsubcode] [int] NULL,
	[archiveDate] [datetime] NULL
) ON [PRIMARY]



----------------------------------------------------------------
-- Gather all qsiJobKeys
----------------------------------------------------------------
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
				WHERE TABLE_NAME = 'qutl_tmp_jobArchiveKeys')
DROP TABLE qutl_tmp_jobArchiveKeys

SELECT
	qsijobkey,
	startdatetime
INTO
	qutl_tmp_jobArchiveKeys
FROM
	qsijob
WHERE
	startdatetime <= @v_date_end

CREATE CLUSTERED INDEX idx1 ON qutl_tmp_jobArchiveKeys(qsijobkey);

----------------------------------------------------------------
-- Load Archive Tables
----------------------------------------------------------------
INSERT INTO qsijob_archive --WITH(TABLOCK)
(
	qsijobkey,
	qsibatchkey,
	jobtypecode,
	jobtypesubcode,
	jobdesc,
	jobdescshort,
	startdatetime,
	stopdatetime,
	runuserid,
	statuscode,
	lastuserid,
	lastmaintdate,
	reviewind,
	qtyprocessed,
	qtycompleted,
	runtimeemailsent,
	lasterroremailsent,
	numberoferroremails,
	archiveDate
)
SELECT
	qj.qsijobkey,
	qj.qsibatchkey,
	qj.jobtypecode,
	qj.jobtypesubcode,
	qj.jobdesc,
	qj.jobdescshort,
	qj.startdatetime,
	qj.stopdatetime,
	qj.runuserid,
	qj.statuscode,
	qj.lastuserid,
	qj.lastmaintdate,
	qj.reviewind,
	qj.qtyprocessed,
	qj.qtycompleted,
	qj.runtimeemailsent,
	qj.lasterroremailsent,
	qj.numberoferroremails,	
	@v_archive_date
FROM
	qsijob qj 
INNER JOIN qutl_tmp_jobArchiveKeys ja
	ON qj.qsijobkey = ja.qsijobkey

INSERT INTO qsijobmessages_archive --WITH(TABLOCK)
(
	qsijobmessagekey,
	qsijobkey,
	referencekey1,
	referencekey2,
	referencekey3,
	messagetypecode,
	messagelongdesc,
	messageshortdesc,
	lastuserid,
	lastmaintdate,
	messagecode,
	standardmsgcode,
	standardmsgsubcode,
	archiveDate
)
SELECT
	qj.qsijobmessagekey,
	qj.qsijobkey,
	qj.referencekey1,
	qj.referencekey2,
	qj.referencekey3,
	qj.messagetypecode,
	qj.messagelongdesc,
	qj.messageshortdesc,
	qj.lastuserid,
	qj.lastmaintdate,
	qj.messagecode,
	qj.standardmsgcode,
	qj.standardmsgsubcode,
	@v_archive_date
FROM
	qsijobmessages qj 
INNER JOIN qutl_tmp_jobArchiveKeys ja
	ON qj.qsijobkey = ja.qsijobkey


----------------------------------------------------------------
-- Remove old data
----------------------------------------------------------------
DELETE	
	qj 
FROM 
	qsijob qj 
INNER JOIN qutl_tmp_jobArchiveKeys ja
	ON qj.qsijobkey = ja.qsijobkey

DELETE 
	qj 
FROM 
	qsijobmessages qj 
INNER JOIN qutl_tmp_jobArchiveKeys ja
	ON qj.qsijobkey = ja.qsijobkey