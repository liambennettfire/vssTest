SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
**  Name: imp_Email_Notification
**  Desc: IKE send email 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  6/5/2016	 DONOVAN	The Drop create of the imp_Notifications was not happening within the prcedure because there was no Go statement between
**							the drop and create, needed to move it outside of the creation of the imp_Email_Notification procedure
*******************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_Notifications]') AND type in (N'U'))
DROP TABLE imp_Notifications
	
CREATE TABLE imp_Notifications  (ROWNUM INT, EAN13 VARCHAR(MAX),RuleKey VARCHAR(MAX), Result VARCHAR(MAX), NewTitle VARCHAR(MAX), HTML VARCHAR(MAX))
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_Email_Notification]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_Email_Notification]
GO
--jason
CREATE PROCEDURE [dbo].[imp_Email_Notification]
	(@szRECIPIENTS AS VARCHAR(MAX)
	,@szPROFILE_NAME AS VARCHAR(MAX)
	,@iTEMPLATEKEY INT
	,@bINCLUDE_SUCCESS INT=0
	,@szEmailHeaderName VARCHAR(MAX)=NULL)
AS
BEGIN
	--SAMPLE USAGE
	--EXECUTE imp_Email_Notification
	--'Paul@firebrandtech.com;marcus@firebrandtech.com'   --.... notice the SEMICOLON ... comma wont work :(
	--,'FWFeedMail'
	--,1000
	--,0	
		--Select * from imp_Notifications
	--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_Notifications]') AND type in (N'U'))
	--DROP TABLE imp_Notifications
	
	--CREATE TABLE imp_Notifications  (ROWNUM INT, EAN13 VARCHAR(MAX),RuleKey VARCHAR(MAX), Result VARCHAR(MAX), NewTitle VARCHAR(MAX), HTML VARCHAR(MAX))
	
	DECLARE @EAN TABLE (ROWNUM INT, EAN13 VARCHAR(MAX))
	DECLARE @szOUTPUT varchar(max)
	DECLARE @szSUBJECT varchar(max)
	DECLARE @iMaxBatchKey INT
	
	--GET THE LAST BATCH THAT WAS RUN
	SELECT @iMaxBatchKey=MAX(batchkey)
	FROM imp_batch_master
	WHERE templatekey = @iTEMPLATEKEY
	
	--FIGURE OUT ALL THE EANs THAT FAILED
	INSERT INTO imp_Notifications (ROWNUM,EAN13,RuleKey,Result,NewTitle,HTML)
	SELECT DISTINCT row_id, NULL, RuleKey,'ERROR: ' + feedbackmsg, NULL,NULL
	FROM imp_feedback
	WHERE serverity > 1 
		AND batchkey = @iMaxBatchKey
		AND rulekey IS NOT NULL
		AND feedbackmsg not like '%update not performed:%'
	
	--THE EANs NOT IN THE LIST ABOVE SUCCEEDED
	IF @bINCLUDE_SUCCESS=1
	BEGIN
		INSERT INTO imp_Notifications (ROWNUM,EAN13,RuleKey,Result,NewTitle,HTML)
		
		SELECT DISTINCT row_id, originalvalue, NULL, 'Successful Import', NULL, NULL
		FROM imp_batch_detail f
		LEFT JOIN imp_Notifications n ON f.row_id = n.ROWNUM
		WHERE batchkey = @iMaxBatchKey
		and elementkey=100010003
		and n.ROWNUM IS NULL
				
		--SELECT DISTINCT row_id, NULL, NULL, 'Successful Import', NULL, NULL
		--FROM imp_feedback f
		--LEFT JOIN imp_Notifications n ON f.row_id = n.ROWNUM
		--WHERE serverity = 1
		--	AND batchkey = @iMaxBatchKey
		--	AND n.ROWNUM IS NULL
	END		
	
	INSERT INTO @EAN
	SELECT DISTINCT row_id,originalvalue
	FROM imp_batch_detail d
	WHERE d.batchkey = @iMaxBatchKey
		AND d.elementkey = 100010003
		
	UPDATE n
	SET n.EAN13 = ean.EAN13
	FROM @EAN ean
	INNER JOIN imp_Notifications n ON n.rownum = ean.ROWNUM

	DELETE FROM imp_Notifications 
	WHERE EAN13 IS NULL 

	--FIGURE OUT IF NEW OR NOT
	UPDATE n
	SET NewTitle = 
		CASE 
			WHEN ISBN.bookkey IS NULL OR b.bookkey IS NULL THEN 'NOT IN TMM'
			WHEN GETDATE() - .5 < b.creationdate THEN 'NEW TITLE'
			ELSE '' 
		END
	FROM imp_Notifications n
		LEFT JOIN ISBN ON n.EAN13=ISBN.ean13
		LEFT JOIN book b ON ISBN.bookkey=b.bookkey 

	--Build Out the HTML
	UPDATE imp_Notifications 
	SET ROWNUM=0 
	WHERE ROWNUM IS NULL
	
	UPDATE imp_Notifications 
	SET HTML='<tr><td width = 5%>' 
		+ CAST(COALESCE(ROWNUM,'') AS VARCHAR(MAX))
		+ '</td><td width = 10%>' 
		+ COALESCE(NewTitle,'') 
		+ '</td><td width = 10%>' 
		+ RTRIM(LTRIM(COALESCE(EAN13,''))) 
		+ '</td><td width = 10%>' 
		+ RTRIM(LTRIM(COALESCE(RuleKey,''))) 
		+ '</td><td width = 65%>' 
		+ RTRIM(LTRIM(COALESCE(RESULT,''))) 
		+ '</td></tr>'
	INSERT INTO imp_Notifications (ROWNUM,EAN13,RuleKey,Result,NewTitle,HTML) SELECT -1, NULL,NULL, NULL, NULL,'<HTML><BR />'+COALESCE(@szEmailHeaderName + ': ','')+'BATCH# '+CAST(@iMaxBatchKey as VARCHAR(MAX))+'<TABLE border="1" width=100%>'
	INSERT INTO imp_Notifications (ROWNUM,EAN13,RuleKey,Result,NewTitle,HTML) SELECT 100000000, NULL,NULL, NULL, NULL,'</TABLE></HTML>'
	
	SET @szSUBJECT=COALESCE(@szEmailHeaderName,'IKE Notification - ' + Convert(VARCHAR(100), getdate(), 1))

	IF NOT EXISTS(SELECT TOP 1 * FROM imp_Notifications  where ROWNUM NOT IN (-1,100000000))
	BEGIN
		SET @szOUTPUT = 'SUCCESSFUL IMPORT for '+COALESCE(@szEmailHeaderName + ': ','')+'BatckKey: ' + CAST(@iMaxBatchKey as VARCHAR(MAX)) + ' on: ' + CAST(getdate() AS VARCHAR(40))
		EXEC MSDB.DBo.sp_send_dbmail @profile_name = @szPROFILE_NAME
			,@recipients = @szRECIPIENTS
			,@subject = @szSUBJECT
			,@body = @szOUTPUT		
	
	END ELSE BEGIN

		--SET @szOUTPUT = 'See Attachment' + CAST(getdate() AS VARCHAR(40))
		SELECT @szOUTPUT = COALESCE(@szOUTPUT,'') + HTML FROM DBO.imp_Notifications ORDER BY ROWNUM ASC
		EXEC MSDB.DBo.sp_send_dbmail @profile_name = @szPROFILE_NAME
		,@recipients = @szRECIPIENTS
		,@subject = @szSUBJECT
		,@body = @szOUTPUT		
		,@body_format = 'HTML'
		--,@query='SELECT HTML AS [IKE Notification Report] FROM DBO.imp_Notifications ORDER BY ROWNUM ASC'
		--,@attach_query_result_as_file=1
		--,@query_attachment_filename='IKE_Notification.HTML'
		--,@query_result_no_padding=1
		--,@execute_query_database='FW'

	END


END
