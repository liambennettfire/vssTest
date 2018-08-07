IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_processbackgroundjobmessages]') AND type in (N'P', N'PC'))   
DROP PROCEDURE [dbo].[qutl_processbackgroundjobmessages]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_processbackgroundjobmessages]
(
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)
AS

/**************************************************************************************************************************
**  Name: qutl_processbackgroundjobmessages
**  Desc:
**
**  Auth: Joshua
**  Date: April 10 2017
****************************************************************************************************************************
**  Change History
****************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
****************************************************************************************************************************/

DECLARE 
	@v_user VARCHAR(50),
	@v_jobKey INT,
	@v_batchKey INT,
	@v_messageKey INT,
	@v_counter INT,
	@v_jobtypecode INT,
	@v_startdatetime DATETIME,
	@v_stopdatetime DATETIME,
	@v_countRows INT,
	@v_countRowsReturn INT,
	@v_numMsgCounts INT,
	@v_statusCode INT,
	@v_jobDesc VARCHAR(2000),
	@v_jobDescShort VARCHAR(255),
	@v_failedCode INT,
	@v_completedMessageKey INT,
	@v_returnMsgDesc VARCHAR(MAX),
	@v_completedMsg INT,
	@v_writeMessages INT

BEGIN 
	SET @v_MessageKey = 0
	SET @v_JobKey = 0
	SET @v_user = 'backgroundJobMsg'
	SET @v_numMsgCounts = 0
	SET @v_statusCode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 544 AND gen.qsiCode = 3)
	SET @v_failedCode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 539 AND gen.qsicode = 2)
	SET @v_completedMsg = (SELECT datacode FROM gentables WHERE tableid=539 AND qsicode=6)

	SELECT
		jobTypeCode
	INTO 
		#tmp_jobsToUpdate
	FROM
		backgroundProcessJobTracker
	WHERE 
		GETDATE() > DATEADD(mi,minuteIntervalBtwJobs,jobLastCreated) 

	-- If the current time is greater than jobLastCreated + minuteIntervalBtwJobs then update jobLastCreated to current datetime
	UPDATE 
		bt
	SET 
		bt.jobLastCreated = GETDATE()
	FROM
		BackgroundProcessJobTracker bt
	INNER JOIN #tmp_jobsToUpdate tu
		ON bt.jobTypeCode = tu.jobTypeCode


	SELECT
		bpt.*,
		CAST(NULL AS DATETIME) AS startdatetime,
		CAST(NULL AS DATETIME) AS stopdatetime,
		CAST(NULL AS INT) AS countRows,
		CAST(NULL AS INT) AS countRowsReturn,
		CASE WHEN (standardMsgSubCode IS NOT NULL
					AND NULLIF(standardmsgcode,0) IS NOT NULL)
					 OR NULLIF(returnmsgdesc,'') IS NOT NULL
			THEN 1 ELSE 0 
		END writeMessages
	INTO
		#tmp_backgroundHistory
	FROM
		BackgroundProcess_History bpt
	INNER JOIN #tmp_jobsToUpdate tu
		ON bpt.jobTypeCode = tu.jobTypeCode
	WHERE
		ISNULL(bpt.jobKey,0) = 0

	SET @v_counter = @@ROWCOUNT

	IF (@v_counter = 0)
	BEGIN
		PRINT 'Nothing to Process'
		RETURN
	END

	;WITH CTE_dates
	AS
	(
		SELECT 
			jobTypeCode,
			MIN(processeddate) AS startdatetime,
			MAX(processeddate) AS stopdatetime,
			COUNT(1) counts,
			SUM(CASE WHEN ISNULL(returncode,0) = 1 THEN 1 ELSE 0 END) AS countRowsReturn
		FROM  #tmp_backgroundHistory
		GROUP BY jobtypecode
	)
	UPDATE 
		tmp 
	SET 
		tmp.startdatetime = ct.startdatetime,
		tmp.stopdatetime = ct.stopdatetime,
		tmp.countRows = ct.counts,
		tmp.countRowsReturn = ct.countRowsReturn
	FROM #tmp_backgroundHistory tmp
	INNER JOIN CTE_dates ct
		ON tmp.jobTypeCode = ct.jobTypeCode


DECLARE csr_qsiJob CURSOR FAST_FORWARD FOR
SELECT DISTINCT jobtypecode,startdatetime,stopdatetime,countRows,countRowsReturn--,returnmsgdesc,writeMessages
FROM #tmp_backgroundHistory

OPEN csr_qsiJob
FETCH NEXT FROM csr_qsiJob INTO @v_jobtypecode,@v_startdatetime,@v_stopdatetime,@v_countRows,@v_countRowsReturn--,@v_returnMsgDesc,@v_writeMessages

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @v_jobDesc = (SELECT gen.dataDesc FROM gentables gen WHERE gen.tableid = 543 AND gen.datacode = @v_jobtypecode)
	SET @v_jobDescShort = (SELECT ISNULL(gen.datadescshort,LEFT(gen.datadesc,255)) FROM gentables gen WHERE gen.tableid = 543 AND gen.datacode = @v_jobtypecode)
	EXEC get_next_key @v_user, @v_jobKey OUT
	EXEC get_next_key @v_user, @v_batchKey OUT

	INSERT INTO dbo.qsijob (qsijobkey,qsibatchkey,jobtypecode,startdatetime,stopdatetime,runuserid,lastuserid,lastmaintdate,qtyprocessed,qtycompleted,jobdesc,jobdescshort,statusCode)
	VALUES(	@v_jobkey,@v_batchKey,@v_jobtypecode,@v_startdatetime,@v_stopdatetime,@v_user,@v_user,GETDATE(),@v_countRows,@v_countRowsReturn,@v_jobDesc,@v_jobDescShort,@v_statusCode)

	UPDATE #tmp_backgroundHistory
	SET jobkey = @v_jobKey
	WHERE jobtypecode = @v_jobtypecode

	--Job completed row if there will be messages
	IF EXISTS(SELECT 1 FROM #tmp_backgroundHistory WHERE writeMessages = 1 AND jobkey = @v_jobKey)
	BEGIN
		IF EXISTS(SELECT 1 FROM #tmp_backgroundHistory WHERE writeMessages = 1 AND jobkey = @v_jobKey AND returncode = -1)
		BEGIN
			SET @v_returnMsgDesc = 'Job Completed with Errors'
		END
		ELSE
		BEGIN
			SET @v_returnMsgDesc = 'Job Completed'
		END

		EXEC get_next_key @v_user, @v_completedMessageKey OUT

		INSERT INTO qsijobmessages(qsijobmessagekey,qsijobkey,messagelongdesc,messageshortdesc,lastuserid,lastmaintdate,messagetypecode)
		VALUES (@v_completedMessageKey,@v_jobKey,@v_returnMsgDesc,@v_returnMsgDesc,@v_user,GETDATE(),@v_completedMsg)
	END

FETCH NEXT FROM csr_qsiJob INTO @v_jobtypecode,@v_startdatetime,@v_stopdatetime,@v_countRows,@v_countRowsReturn--,@v_returnMsgDesc,@v_writeMessages
END
CLOSE csr_qsiJob
DEALLOCATE csr_qsiJob

	--Messages
	SET @v_numMsgCounts = (SELECT COUNT(1) FROM #tmp_backgroundHistory 
								WHERE (standardMsgSubCode IS NOT NULL
								AND NULLIF(standardmsgcode,0) IS NOT NULL)
								OR NULLIF(returnmsgdesc,'') IS NOT NULL)
	SET @v_messageKey = (SELECT MAX(generickey) + 1 FROM keys)

	IF (ISNULL(@v_numMsgCounts,0) > 0)
	BEGIN
		UPDATE keys
		SET generickey = @v_numMsgCounts + generickey,
			lastuserid = @v_user,
			lastmaintdate = GETDATE()
	END



	--Job Message rows
	INSERT INTO dbo.qsijobmessages
	 ( 
		qsijobmessagekey,
	    qsijobkey,
	    referencekey1,
	    referencekey2,
	    referencekey3,
		standardmsgcode,
		standardmsgsubcode,
	    messagelongdesc,
	    lastuserid,
	    lastmaintdate,
		messagetypecode
	  )
	  SELECT
		ROW_NUMBER() OVER(ORDER BY backgroundprocesskey) + @v_messageKey AS qsijobmessagekey,
		jobkey,
		key1,
		ISNULL(key2,0),
		ISNULL(key3,0),
		standardmsgcode,
		standardmsgsubcode,
		returnmsgdesc,
		@v_user,
		GETDATE(),
		CASE WHEN returncode = -1 THEN @v_failedCode ELSE @v_completedMsg END
	  FROM 
		#tmp_backgroundHistory
	  WHERE writeMessages = 1


	UPDATE bh
	SET bh.jobkey = t.jobkey
	FROM dbo.backgroundprocess_history bh
	INNER JOIN #tmp_backgroundHistory t
		ON t.backgroundprocesskey = bh.backgroundprocesskey
END
GO

GRANT EXEC on qutl_processbackgroundjobmessages TO PUBLIC
GO