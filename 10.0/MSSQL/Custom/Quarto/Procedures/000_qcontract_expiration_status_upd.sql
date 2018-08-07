IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qcontract_expiration_status_upd') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qcontract_expiration_status_upd
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_expiration_status_upd
(
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output
)
AS

/****************************************************************************************************************************
**  Name: qcontract_expiration_status_upd
**  Desc: We needed a timed procedure (generic sql) that will update the status of a Contract based the Expiration date. 
**			If the contract has expired set the Status to Expired and set the canceled ind on taqproject for this project. 
**			This procedure should also create a job message saying what contracts have been expired and when.
**
**  Auth: Josh G
**  Date: 24 January 2017
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
*****************************************************************************************************************************/
DECLARE
	@v_contractDataCode INT,
	@v_expiredStatusCode INT,
	@v_jobType INT,
	@v_expiredDateCode INT,
	@v_messageLongDesc VARCHAR(MAX),
	@v_messageShortDesc VARCHAR(255),
	@v_lastUserID VARCHAR(30),
	@v_qsiJobKey INT,
	@v_qsiMsgKey INT,
	@v_qsiBatchKey INT,
	@v_errorCode INT,
	@v_errorDesc VARCHAR(MAX),
	@v_jobStartCode INT,
	@v_jobEndCode INT,
	@v_taqProjectKey INT,
	@v_taqprojectstatuscode INT,
	@v_statusDescNew VARCHAR(255),
	@v_statusDescOld VARCHAR(255),
	@v_rowCount INT

SET @v_contractDataCode = (SELECT TOP 1 gen.dataCode FROM gentables gen WHERE gen.tableid = 550 AND qsiCode = 10)
SET @v_expiredStatusCode = (SELECT TOP 1 gen.dataCode FROM gentables gen WHERE gen.tableID = 522 AND qsiCode = 23)
SET @v_jobType = (SELECT TOP 1 gen.dataCode FROM gentables gen WHERE gen.tableID = 543 AND qsiCode = 23)
SET @v_expiredDateCode = (SELECT TOP 1 dt.dateTypeCode FROM dateType dt WHERE dt.qsiCode = 15)
SET @v_messageLongDesc = 'Contract Expiration Job'
SET @v_messageShortDesc = 'Contract Expiration Job'
SET @v_lastUserID = 'contact_exp_job'
SET @v_jobStartCode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 544 AND qsiCode = 1)
SET @v_jobEndCode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 544 AND qsiCode = 3)
SET @v_rowCount = 0

BEGIN

--Insert job record
EXEC get_next_key @v_lastUserID, @v_qsiMsgKey OUT  
EXEC get_next_key @v_lastUserID, @v_qsiJobKey OUT  
EXEC get_next_key @v_lastUserID, @v_qsiBatchKey OUT  

INSERT INTO qsijob ( qsijobkey, qsibatchkey, jobtypecode, jobtypesubcode, jobdesc, jobdescshort, startdatetime, runuserid, statuscode, lastuserid, lastmaintdate)   
 values (@v_qsiJobKey,@v_qsiBatchKey,@v_jobType,0,@v_messageShortDesc,@v_messageShortDesc,getdate(),@v_lastUserID,@v_jobStartCode,@v_lastUserID,getdate())  

INSERT INTO qsijobmessages (qsijobmessagekey,qsijobkey,messagetypecode, messagelongdesc, messageshortdesc, lastuserid, lastmaintdate)   
 values (@v_qsiMsgKey, @v_qsiJobKey,@v_jobStartCode ,@v_messageShortDesc + ' -- STARTED -- ='+convert(varchar(255),cast(getDate() as date)),@v_messageShortDesc,@v_lastUserID,getdate())  
  
--Find all contracts that have expired
SELECT
	taq.taqProjectKey,
	taq.taqprojectstatuscode,
	'Expired' AS statusDescNew,
	gen.dataDesc AS statusDescOld
INTO
	#fbt_expiredContracts
FROM
	taqProject taq
INNER JOIN gentables gen --get old status desc
	ON gen.dataCode = taq.taqprojectstatuscode
	AND gen.tableid = 522 --Contracts
WHERE
	taq.searchitemcode = @v_contractDataCode 
AND taq.taqprojectstatuscode != @v_expiredStatusCode
AND EXISTS(SELECT 1 FROM taqprojecttask task
				WHERE taq.taqprojectkey = task.taqprojectkey
				AND task.datetypecode = @v_expiredDateCode
				AND task.activedate <= GETDATE())

--Update status
--We have to loop since some clients may have triggers other than the basic ones on taqProject
DECLARE csr_updateRecs CURSOR FAST_FORWARD FOR 
SELECT taqProjectKey, taqprojectstatuscode, statusDescNew,statusDescOld FROM #fbt_expiredContracts

OPEN csr_updateRecs
FETCH NEXT FROM csr_updateRecs INTO @v_taqProjectKey, @v_taqprojectstatuscode, @v_statusDescNew, @v_statusDescOld
WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE 
		taq 
	SET 
		taq.taqprojectstatuscode = @v_expiredStatusCode
	FROM 
		taqProject taq
	WHERE
		taq.taqProjectKey = @v_taqProjectKey

	SET @v_rowCount = @@ROWCOUNT + @v_rowCount
	--Load qsiJobMessage
	EXEC get_next_key @v_lastUserID, @v_qsiMsgKey OUT 

	INSERT INTO qsijobmessages (qsijobmessagekey,qsijobkey,referencekey1,messagetypecode,messagelongdesc,messageshortdesc,lastuserid,lastmaintdate)
	VALUES(@v_qsiMsgKey,@v_qsiJobKey,@v_taqProjectKey,@v_jobEndCode, @v_messageLongDesc + '  Old Status: '+@v_statusDescOld + '  New Status: '+@v_statusDescNew,@v_messageShortDesc,@v_lastUserID,getdate())

	FETCH NEXT FROM csr_updateRecs INTO @v_taqProjectKey, @v_taqprojectstatuscode, @v_statusDescNew, @v_statusDescOld
END
CLOSE csr_updateRecs
DEALLOCATE csr_updateRecs

UPDATE	
	qsijob 
SET 
	stopdatetime=getdate(),
	lastmaintdate=getdate(),
	statuscode=@v_jobEndCode,
	qtycompleted=@v_rowCount 
WHERE 
	qsijobkey = @v_qsiJobKey  
 
EXEC get_next_key @v_lastUserID, @v_qsiMsgKey OUT 
INSERT INTO qsijobmessages (qsijobmessagekey,qsijobkey,messagetypecode, messagelongdesc, messageshortdesc, lastuserid, lastmaintdate)   
VALUES (@v_qsiMsgKey, @v_qsiJobKey,@v_jobEndCode,@v_messageShortDesc + ' -- ENDED -- ='+convert(varchar(255),cast(getDate() as date)),@v_messageShortDesc,@v_lastUserID,getdate())  

 
END
GO

GRANT EXEC ON qcontract_expiration_status_upd TO PUBLIC
GO


DECLARE @v_errorCode INT, @v_errorDesc VARCHAR(MAX)
EXEC qcontract_expiration_status_upd @v_errorCode OUTPUT, @v_errorDesc OUTPUT
GO
