IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'qcs_process_scheduled_resends') AND type in (N'P', N'PC'))
DROP PROCEDURE qcs_process_scheduled_resends
GO

CREATE PROCEDURE qcs_process_scheduled_resends
AS
BEGIN
/*********************************************************************************
**   Modified: Dustin Miller
**       Date: October 3 2016
**       Case: 39989 Partner Specific Pricing and ReSend Outbox
**
**********************************************************************************/

	DECLARE @v_count INT,
			@v_count2 INT,
			@v_id INT,
			@v_bookkey INT,
			@v_templatekey INT,
			@v_assetkey INT,
			@v_actualassetkey INT,
			@v_userid VARCHAR(30),
			@v_partnerkey INT,
			@v_qsijobkey INT,
			@v_qsibatchkey INT,
			@v_jobtypecode INT,
			@v_jobdesc VARCHAR(2000),
			@v_jobdesc_short VARCHAR(255),
			@v_referencekey1  INT,
			@v_referencekey2  INT,
			@v_referencekey3  INT,
			@v_messagecode INT,
			@v_messagetypecode INT,
			@v_messagetypeqsicode INT,
			@v_messagelongdesc VARCHAR(4000),
			@v_messageshortdesc VARCHAR(255),
			@o_error_code INT,
			@o_error_desc VARCHAR(300),
			@v_startpos INT,
			@v_dateformat_value VARCHAR(40),
			@v_dateformat_conversionvalue INT,
			@v_clientdefaultvalue INT,
			@v_datacode INT,
			@v_curdatetime VARCHAR(255),
			@v_cloud_approval_send_code INT,
			@v_job_started_code INT,
			@v_job_error_code INT,
			@v_job_warning_code INT,
			@v_job_information_code INT,
			@v_job_aborted_code INT,
			@v_job_completed_code INT,
			@v_job_pending_code INT,
			@v_to_automatically_process INT,
			@v_sendqty_processed INT,
			@v_has_partners TINYINT

	SELECT @v_count = COUNT(*)
	FROM cloudscheduleforresend

	IF @v_count = 0
	BEGIN
		RETURN
	END

	SELECT @v_cloud_approval_send_code = datacode FROM gentables WHERE tableid = 543 AND qsicode = 7
	SELECT @v_to_automatically_process = datacode FROM gentables WHERE tableid = 652 AND qsicode = 1
	SELECT @v_job_pending_code = datacode FROM gentables WHERE tableid = 539 AND qsicode = 7
	SELECT @v_job_completed_code = datacode FROM gentables WHERE tableid = 539 AND qsicode = 6
	SELECT @v_job_warning_code = datacode FROM gentables WHERE tableid = 539 AND qsicode = 3
	SELECT @v_job_error_code = datacode FROM gentables WHERE tableid = 539 AND qsicode = 2

	DECLARE @resends TABLE
	(
		id INT,
		bookkey INT,
		templatekey INT,
		assetkey INT,
		lastuserid VARCHAR(30),
		lastmaintdate DATETIME
	)

	DECLARE user_cur CURSOR FAST_FORWARD FOR
    SELECT DISTINCT lastuserid
    FROM cloudscheduleforresend
 
	OPEN user_cur

	FETCH NEXT FROM user_cur INTO @v_userid

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		SET @v_sendqty_processed = 0

		SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80
		SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
		SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode	
		SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1    
		SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')  
		-- create the job for "Cloud Resend"
		SET @v_qsijobkey = NULL
		SET @v_jobtypecode = @v_cloud_approval_send_code
		SET @v_jobdesc = 'Cloud Resend ' + @v_curdatetime
		SET @v_jobdesc_short = 'Cloud Resend ' + @v_curdatetime
		SET @v_referencekey1 = 0
		SET @v_referencekey2 = 0
		SET @v_referencekey3 = 0
		SET @v_messagetypecode = @v_job_pending_code
		SET @v_messagetypeqsicode = 7
		SET @v_messagelongdesc = 'Job Created; waiting for send process to start ' + @v_curdatetime
		SET @v_messageshortdesc = 'Job Created'
		SET @v_messagecode = NULL
		SET @o_error_code = 0
		SET @o_error_desc = ''

		EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
		 @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
		 @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
		 @o_error_code output, @o_error_desc output
	
		--Insert job start row
		INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey, partnercontactkey,processstatuscode,jobstartind,jobendind, lastuserid, lastmaintdate)
		  VALUES(@v_qsijobkey,NULL,NULL,0,NULL,@v_to_automatically_process,1,0,@v_userid,getdate())

		DELETE FROM @resends

		INSERT INTO @resends
		SELECT id, bookkey, templatekey, assetkey, lastuserid, lastmaintdate
		FROM cloudscheduleforresend
		WHERE lastuserid = @v_userid

		DECLARE resend_cur CURSOR FAST_FORWARD FOR
		SELECT id, bookkey, templatekey, assetkey
		  FROM @resends
 
		OPEN resend_cur

		FETCH NEXT FROM resend_cur INTO @v_id, @v_bookkey, @v_templatekey, @v_assetkey

		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			IF ([dbo].qcs_get_csapproved(@v_bookkey) = 1)
			BEGIN
				SET @v_has_partners = 0

				DECLARE partner_cur CURSOR FOR
				SELECT DISTINCT partnercontactkey
				FROM csdistributiontemplatepartner
				WHERE templatekey = @v_templatekey

				----NOTE: if we decide to go off of distributiontype within the template, use the below logic instead of the above
				--DECLARE partner_cur CURSOR FOR
				--SELECT DISTINCT cp.partnercontactkey
				--FROM csdistributiontemplatepartner dtp
				--JOIN customerpartner cp
				--ON dtp.distributiontypecode = cp.distributiontype
				--  AND dtp.templatekey = @v_templatekey

				OPEN partner_cur

				FETCH NEXT FROM partner_cur INTO @v_partnerkey

				WHILE (@@FETCH_STATUS = 0) 
				BEGIN
					IF @v_partnerkey > 0
					BEGIN
						SET @v_has_partners = 1

						DECLARE asset_cur CURSOR FOR
						SELECT DISTINCT assetkey
						FROM taqprojectelementpartner
						WHERE bookkey = @v_bookkey
						  AND partnercontactkey = @v_partnerkey
						  AND (COALESCE(@v_assetkey, 0) = 0 OR assetkey = @v_assetkey)
						  AND resendind = 1

						OPEN asset_cur

						FETCH NEXT FROM asset_cur INTO @v_actualassetkey

						WHILE (@@FETCH_STATUS = 0) 
						BEGIN
							INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, lastuserid, lastmaintdate)
							VALUES(@v_qsijobkey, @v_bookkey, @v_assetkey, @v_templatekey, @v_partnerkey, @v_to_automatically_process, 0, 0, @v_userid,getdate())

							SELECT @v_sendqty_processed = @v_sendqty_processed + 1

							FETCH NEXT FROM asset_cur INTO @v_actualassetkey
						END

						CLOSE asset_cur
						DEALLOCATE asset_cur
					END

					FETCH NEXT FROM partner_cur INTO @v_partnerkey
				END

				CLOSE partner_cur
				DEALLOCATE partner_cur

				IF @v_has_partners = 0
				BEGIN
					-- Display warning that no partner(s) have been specified for this template
					SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1    
					SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')  
					SET @v_jobtypecode = NULL
					SET @v_jobdesc = NULL
					SET @v_jobdesc_short = NULL
					SET @v_referencekey1 = @v_bookkey
					SET @v_referencekey2 = 0
					SET @v_referencekey3 = @v_partnerkey
					SET @v_messagetypecode = @v_job_error_code
					SET @v_messagetypeqsicode = 2
					SET @v_messagelongdesc = 'No Partner has been specified for templatekey ' + CAST(@v_templatekey AS VARCHAR(20)) + ', ' + @v_curdatetime + '.'
					SET @v_messageshortdesc = 'No Partner specified for Template'
					SET @v_messagecode = NULL
					SET @o_error_code = 0
					SET @o_error_desc = ''

					EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
						@v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
						@v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
						@o_error_code output, @o_error_desc output
				END
			END

			DELETE FROM cloudscheduleforresend
			WHERE id = @v_id

			FETCH NEXT FROM resend_cur INTO @v_id, @v_bookkey, @v_templatekey, @v_assetkey
		END

		CLOSE resend_cur
		DEALLOCATE resend_cur

		-- Write a Job End row for the Cloud Send Job
		INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey,partnercontactkey,processstatuscode, jobstartind,jobendind, lastuserid, lastmaintdate)
		VALUES(@v_qsijobkey, NULL, NULL, 0, NULL, @v_to_automatically_process, 0, 1, @v_userid, getdate())

		UPDATE qsijob
		SET qtyprocessed = @v_sendqty_processed
		WHERE qsijobkey = @v_qsijobkey

		FETCH NEXT FROM user_cur INTO @v_userid
	END

	CLOSE user_cur
	DEALLOCATE user_cur

END
GO

GRANT EXEC ON qcs_process_scheduled_resends TO PUBLIC
GO