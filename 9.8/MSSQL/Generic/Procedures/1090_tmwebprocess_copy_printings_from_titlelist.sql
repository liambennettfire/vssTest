IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmwebprocess_copy_printings_from_titlelist]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[tmwebprocess_copy_printings_from_titlelist]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmwebprocess_copy_printings_from_titlelist]
	(@i_background_process	tinyint,
	 @o_error_code		integer output,
	 @o_error_desc		varchar(2000) output)
AS

/*************************************************************************************************************************
**  Name: tmwebprocess_copy_printings_from_titlelist
**  Desc: This stored procedure is run preiodically via a job and checks for tmwebprocess requests to copy printings from 
**		  a list of titles and executes them. All of the bookkeys from the list should already be made available as
**		  tmwebprocessinstanceitem records.
**
**    Auth: Dustin Miller
**    Date: 23 June 2016
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  08/24/17    Colman    Case 46785
**************************************************************************************************************************/
DECLARE @v_bookkey INT,
		@v_userkey INT,
		@v_processinstancekey INT,
		@v_jobkey INT,
		@v_batchkey INT,
		@v_userid VARCHAR(30),
		@v_tabcode INT,
		@v_gentablesrelationshipkey INT,
		@v_jobtypecode INT,
		@v_processcode INT,
		@v_copy_projectkey INT,
		@v_projectname VARCHAR(255),
		@o_new_projectkey INT,
		@v_msgtype_started INT,
		@v_msgtype_error INT,
		@v_msgtype_warning INT,
		@v_msgtype_completed INT,
		@v_clientdefaultvalue INT,
		@v_dateformat_value VARCHAR(40),
		@v_dateformat_conversionvalue INT,
		@v_curdatetime VARCHAR(255),
		@v_datacode INT,
		@v_startpos INT,
		@v_msglongdesc VARCHAR(4000),
		@v_msgshortdesc VARCHAR(255),
		@v_newprojkeys VARCHAR(MAX),
		@o_listkey INT,
		@v_max_printingnum INT,
		@v_printingnum INT,
		@v_newprintingkey INT,
		@v_prtg_itemtype INT,
		@v_prtg_usageclass INT,
		@v_projectrole INT,
		@v_datagroup_string VARCHAR(2000)

BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @v_tabcode = datacode
	FROM gentables
	WHERE tableid = 583
	  AND qsicode = 31

	SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
	FROM gentablesrelationships
	WHERE gentable1id = 604 and gentable2id = 583

	SELECT @v_msgtype_started = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 1

	SELECT @v_msgtype_error = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 2
		
	SELECT @v_msgtype_warning = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 3

	SELECT @v_msgtype_completed = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 6

	SELECT @v_jobtypecode = datacode
	FROM gentables
	WHERE tableid = 543
		AND qsicode = 21

	SELECT @v_processcode = datacode
	FROM gentables
	WHERE tableid = 669
	  AND qsicode = 1

	SELECT @v_prtg_itemtype = datacode, @v_prtg_usageclass = datasubcode
	FROM subgentables
	WHERE tableid = 550 AND qsicode = 40  --Printing/Printing

	SELECT @v_projectrole = datacode FROM gentables WHERE tableid = 604 AND qsicode = 3

	SET @v_datagroup_string = ''

	SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80
	SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
	SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode

	DECLARE @currentjobstable TABLE
	(
		jobkey INT,
		batchkey INT
	)

	DECLARE @currentprocesstable TABLE
	(
		processinstancekey INT
	)

	SET @v_newprojkeys = ''

	DECLARE webproc_cur CURSOR FOR
	SELECT twp.processinstancekey, twpi.key1 as jobkey,
	twpi.key2 as batchkey, twpi.key3 as bookkey, twpi.key4 as userkey
	FROM tmwebprocessinstance twp
	JOIN tmwebprocessinstanceitem twpi
	ON (twp.processinstancekey = twpi.processinstancekey)
	WHERE twp.processcode = @v_processcode
	  AND ((COALESCE(@i_background_process, 0) = 0 AND COALESCE(twpi.key5, 0) = 0) OR (@i_background_process = 1 AND twpi.key5 = 1))
	ORDER BY twp.processinstancekey, twpi.sortorder

	OPEN webproc_cur

	FETCH NEXT FROM webproc_cur INTO @v_processinstancekey, @v_jobkey, @v_batchkey, @v_bookkey, @v_userkey

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		SELECT @v_userid = userid
		FROM [qsiusers]
		WHERE userkey = @v_userkey
		
		IF (SELECT COUNT(*) FROM @currentjobstable WHERE jobkey = @v_jobkey) = 0
		BEGIN
			--generate job message to indicate the job has started
			INSERT INTO @currentjobstable
			(jobkey, batchkey)
			VALUES
			(@v_jobkey, @v_batchkey)

			SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1  
			SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')
			SET @v_msglongdesc = 'Job Execution Started ' + @v_curdatetime
			SET @v_msgshortdesc = 'Job Execution Started'
			PRINT @v_msglongdesc

			EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0, @v_msgtype_started,
				@v_msglongdesc, @v_msgshortdesc, NULL, NULL, @o_error_code output, @o_error_desc output
		END

		IF (SELECT COUNT(*) FROM @currentprocesstable WHERE processinstancekey = @v_processinstancekey) = 0
		BEGIN
			--keep track of all the of the processinstancekeys that are getting processed
			INSERT INTO @currentprocesstable
			(processinstancekey)
			VALUES
			(@v_processinstancekey)
		END

		SET @o_error_code = 0
		SET @o_error_desc = ''

		BEGIN TRY

			SELECT @v_max_printingnum = COALESCE(MAX(printingnum), 0)
			FROM printing
			WHERE bookkey = @v_bookkey
  
			SELECT @v_printingnum = COALESCE(nextprintingnbr, @v_max_printingnum + 1, 1)
			FROM book
			WHERE bookkey = @v_bookkey

			--We will end up copying latest existing printing project
			SELECT TOP 1 @v_copy_projectkey = taqprojectkey 
			FROM taqprojecttitle 
			WHERE bookkey = @v_bookkey AND projectrolecode = @v_projectrole
			ORDER BY printingkey DESC

			EXEC get_next_key @v_userid, @v_newprintingkey OUTPUT

			--Printing Insert leverages printing_create_prtgproj trigger to create the printing project and associated data via SP qprinting_prtgproj_from_prtgtbl

			INSERT INTO printing
			(bookkey, printingkey, tentativeqty, tentativepagecount, [pagecount], trimfamily, trimsizewidth, trimsizelength, esttrimsizewidth, esttrimsizelength, printingnum,
			 jobnum, printingjob, issuenumber, pubmonthcode, pubmonth, slotcode, firstprintingqty, specind, creationdate, nastaind, statelabelind, statuscode, seasonkey, estseasonkey,
			 servicearea, notekey, conversionind, ccestatus, dateccefinalized, bookbulk, origreprintind, copycostsversionkey, projectedsales, announcedfirstprint, estimatedinsertillus,
			 actualinsertillus, requestdatetime, requestbyname, requestid, requestcomment, requeststatuscode, approvedqty, approvedondate, requestbatchid, lastuserid, lastmaintdate,
			 pceqty1, pceqty2, estannouncedfirstprint, estprojectedsales, spinesize, tmmactualtrimwidth, tmmactualtrimlength, tmmpagecount, impressionnumber, qtyreceived, printingcloseddate, jobnumberalpha,
			 boardtrimsizewidth, boardtrimsizelength, lasttemplatecopiedbookkey, barcodeid1, barcodeposition1, barcodeid2, barcodeposition2, printcode, turnaroundtypecode, bookweight,
			 trimsizeunitofmeasure, spinesizeunitofmeasure, bookweightunitofmeasure)
			SELECT TOP 1 bookkey, @v_newprintingkey, tentativeqty, tentativepagecount, [pagecount], trimfamily, trimsizewidth, trimsizelength, esttrimsizewidth, esttrimsizelength, @v_printingnum,
				jobnum, printingjob, issuenumber, pubmonthcode, pubmonth, slotcode, firstprintingqty, specind, creationdate, nastaind, statelabelind, statuscode, seasonkey, estseasonkey,
				servicearea, notekey, conversionind, ccestatus, dateccefinalized, bookbulk, origreprintind, copycostsversionkey, projectedsales, announcedfirstprint, estimatedinsertillus,
				actualinsertillus, requestdatetime, requestbyname, requestid, requestcomment, requeststatuscode, approvedqty, approvedondate, requestbatchid, @v_userid, GETDATE(),
				pceqty1, pceqty2, estannouncedfirstprint, estprojectedsales, spinesize, tmmactualtrimwidth, tmmactualtrimlength, tmmpagecount, impressionnumber, qtyreceived, printingcloseddate, jobnumberalpha,
				boardtrimsizewidth, boardtrimsizelength, lasttemplatecopiedbookkey, barcodeid1, barcodeposition1, barcodeid2, barcodeposition2, printcode, turnaroundtypecode, bookweight,
				trimsizeunitofmeasure, spinesizeunitofmeasure, bookweightunitofmeasure
			FROM printing
			WHERE bookkey = @v_bookkey
			ORDER BY printingkey DESC

			SELECT @o_new_projectkey = taqprojectkey
			FROM taqprojectprinting_view
			WHERE bookkey = @v_bookkey AND printingkey = @v_newprintingkey

			IF @v_copy_projectkey > 0
			BEGIN
				-- Form the datagroup string - list of all Project data Group datacodes (gentable 598) valid for Printing projects -
				-- sort on gentablesitemtype.sortorder first, then gentables.sortorder and datadesc
				DECLARE datagroup_cur CURSOR FOR
					SELECT i.datacode
					FROM gentablesitemtype i, gentables g 
					WHERE i.tableid = g.tableid AND i.datacode = g.datacode AND g.tableid = 598 
					AND itemtypecode = @v_prtg_itemtype AND COALESCE(itemtypesubcode,0) IN (0,@v_prtg_usageclass)
					ORDER BY i.sortorder, g.sortorder, g.datadesc

				OPEN datagroup_cur 

				FETCH datagroup_cur INTO @v_datacode

				WHILE (@@FETCH_STATUS=0)
				BEGIN

					IF COALESCE(@v_datagroup_string,'') = ''
					SET @v_datagroup_string = CONVERT(VARCHAR, @v_datacode)
					ELSE
					SET @v_datagroup_string = @v_datagroup_string + ',' + CONVERT(VARCHAR, @v_datacode)
    
					FETCH datagroup_cur INTO @v_datacode
				END

				CLOSE datagroup_cur
				DEALLOCATE datagroup_cur

				EXEC qproject_copy_project @v_copy_projectkey, 0, @o_new_projectkey, @v_datagroup_string, '', 0, 0, 0, @v_userid, NULL, --last param (null) was @v_prtg_title
					@o_new_projectkey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

				IF @o_error_code <> 0 BEGIN
					SET @o_error_desc = 'Failed to copy from project ' + CONVERT(VARCHAR, @v_copy_projectkey) + ': ' + @o_error_desc
					RAISERROR(@o_error_desc, 16, 1)
				END
        
        -- Update the default taqversionformatyear row that gets created with printingnum hardcoded to 1
        UPDATE taqversionformatyear SET printingnumber = @v_printingnum
        WHERE taqversionformatyearkey = (
          SELECT taqversionformatyearkey FROM taqversionformatyear WHERE taqprojectformatkey IN (
            SELECT taqprojectformatkey FROM taqversionformat WHERE taqprojectkey = @o_new_projectkey))
			END


			IF (LEN(@v_newprojkeys) > 0)
			BEGIN
				SET @v_newprojkeys = @v_newprojkeys + ','
			END
			SET @v_newprojkeys = @v_newprojkeys + CAST(@o_new_projectkey AS VARCHAR(20))

			UPDATE qsijob
			SET qtycompleted = COALESCE(qtycompleted, 0) + 1
			WHERE qsijobkey = @v_jobkey
		END TRY
		BEGIN CATCH
			IF @o_error_desc = ''
			BEGIN
				SET @o_error_desc = NULL
			END

			SET @v_msglongdesc = 'Job encountered an error while creating a printing for bookkey: ' + CAST(@v_bookkey AS VARCHAR(20)) + ', ' + LEFT(COALESCE(@o_error_desc, ERROR_MESSAGE()), 4000)
			SET @v_msgshortdesc = 'Job encountered an error while creating a printing'
			PRINT @v_msglongdesc

			IF @o_error_desc IS NULL
			BEGIN
				SET @o_error_desc = ''
			END

			EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, @v_bookkey, NULL, NULL, @v_userid, 0, 0, 0, @v_msgtype_error,
				@v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output

		END CATCH
		FETCH NEXT FROM webproc_cur INTO @v_processinstancekey, @v_jobkey, @v_batchkey, @v_bookkey, @v_userkey
	END

	CLOSE webproc_cur 
    DEALLOCATE webproc_cur

	DECLARE job_cur CURSOR FOR
	SELECT jobkey, batchkey
	FROM @currentjobstable

	OPEN job_cur

	FETCH NEXT FROM job_cur INTO @v_jobkey, @v_batchkey

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1  
		SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')
		SET @v_msglongdesc = 'Job Completed ' + @v_curdatetime
		SET @v_msgshortdesc = 'Job Completed'

		EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, 0, 0, 0, @v_msgtype_completed,
			@v_msglongdesc, @v_msgshortdesc, NULL, 6, @o_error_code output, @o_error_desc output

		FETCH NEXT FROM job_cur INTO @v_jobkey, @v_batchkey
	END

	CLOSE job_cur 
    DEALLOCATE job_cur

	--cleanup the tmwebprocessinstance now that all have been processed
	PRINT 'Cleaning up web process records...'

	DELETE FROM tmwebprocessinstanceitem
	WHERE processinstancekey IN (SELECT processinstancekey FROM @currentprocesstable)

	DELETE FROM tmwebprocessinstance
	WHERE processinstancekey IN (SELECT processinstancekey FROM @currentprocesstable)

	IF LEN(@v_newprojkeys) > 0
	BEGIN
		PRINT 'Createing list for new printings...'
		EXEC qutl_create_working_list_with_keys @v_newprojkeys, 28, @v_userkey, @o_listkey output, @o_error_code output, @o_error_desc output
	END

END
GO

GRANT EXEC ON tmwebprocess_copy_printings_from_titlelist TO PUBLIC
GO