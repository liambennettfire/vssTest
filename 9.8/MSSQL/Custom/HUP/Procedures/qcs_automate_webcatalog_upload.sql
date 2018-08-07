SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF EXISTS (SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID('dbo.qcs_automate_webcatalog_upload')
	AND (type = 'P'
	OR type = 'RF'))
BEGIN
	DROP PROC dbo.qcs_automate_webcatalog_upload
END

GO

CREATE PROC dbo.qcs_automate_webcatalog_upload
AS

	DECLARE @i_projectkey INT
	DECLARE @i_userid VARCHAR(30)
	DECLARE @i_pendingStatusCode INTEGER
	DECLARE @i_runningJobs INTEGER
	DECLARE @i_jobTypeCode INTEGER
	DECLARE @o_error_code INTEGER
	DECLARE @o_error_desc VARCHAR(2000)

	-- Set userid 
	SET @i_userid = 'webcatalog-upload-bot'

	-- Set current catalog project key
	SET @i_projectkey = '567870'

	-- Check to see if we already have a WebCatalog upload running already.

	SELECT
		@i_pendingStatusCode = datacode
	FROM gentables g
	WHERE g.tableid = 544
	AND g.qsicode = 4
	SELECT
		@i_jobTypeCode = datacode
	FROM gentables g
	WHERE g.tableid = 543
	AND qsicode = 13

	SELECT
		@i_runningJobs = COUNT(q.qsijobkey)
	FROM qsijob q
	WHERE q.jobtypecode = @i_jobTypeCode
	AND statuscode = @i_pendingStatusCode

	IF @i_runningJobs < 0
	BEGIN
		EXEC dbo.[qcs_upload_project]	@i_projectkey,
										@i_userid,
										@o_error_code,
										@o_error_desc
	END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO