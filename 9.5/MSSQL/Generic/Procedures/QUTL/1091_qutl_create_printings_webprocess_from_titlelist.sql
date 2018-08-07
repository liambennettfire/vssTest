IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_create_printings_webprocess_from_titlelist]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qutl_create_printings_webprocess_from_titlelist]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qutl_create_printings_webprocess_from_titlelist]
	(@i_title_listkey	integer,
	 @i_userkey			integer,
	 @i_background_process tinyint,
	 @o_error_code		integer output,
	 @o_error_desc		varchar(2000) output)
AS

/*************************************************************************************************************************
**  Name: qutl_create_printings_webprocess_from_titlelist
**  Desc: This stored creates tmwebprocessinstance and qsijob records for the creation of printings based off a title list.
**		  The webprocess will utilize the qproject_copy_printings_from_titlelist to create printings via background processing
**
**    Auth: Dustin Miller
**    Date: 24 June 2016
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  
**************************************************************************************************************************/
DECLARE @v_userid VARCHAR(30),
		@v_jobkey INT,
		@v_batchkey INT,
		@v_processinstancekey INT,
		@v_processcode INT,
		@v_bookkey INT,
		@v_jobtypecode INT,
		@v_msgtype_started INT,
		@v_msgtype_error INT,
		@v_msgtype_warning INT,
		@v_msgtype_info INT,
		@v_msgtype_aborted INT,
		@v_msgtype_pending INT,
		@v_msglongdesc VARCHAR(4000),
		@v_msgshortdesc VARCHAR(255),
		@v_clientdefaultvalue INT,
		@v_dateformat_value VARCHAR(40),
		@v_dateformat_conversionvalue INT,
		@v_curdatetime VARCHAR(255),
		@v_datacode INT,
		@v_startpos INT,
		@v_jobdesc VARCHAR(255)

BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @v_userid = userid
	FROM [qsiusers]
	WHERE userkey = @i_userkey

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
		
	SELECT @v_msgtype_info = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 4
		
	SELECT @v_msgtype_aborted = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 5

	SELECT @v_msgtype_pending = datacode
	FROM gentables
	WHERE tableid = 539
		AND qsicode = 7

	SELECT @v_jobtypecode = datacode
	FROM gentables
	WHERE tableid = 543
		AND qsicode = 21

	SELECT @v_processcode = datacode
	FROM gentables
	WHERE tableid = 669
	  AND qsicode = 1
		
	SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80		
	SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
	SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode								  	 
	SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1  
	SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')

	SET @v_msglongdesc = 'Job Created ' + @v_curdatetime
	SET @v_msgshortdesc = 'Job Created'

	SET @v_jobdesc = 'Create Printings from Title List ' + @v_curdatetime

	EXEC qutl_update_job @v_batchkey output, @v_jobkey output, @v_jobtypecode, NULL, @v_jobdesc, 'Create Printings from Title List', @v_userid, 0, 0, 0, @v_msgtype_pending,
		@v_msglongdesc, @v_msgshortdesc, NULL, 7, @o_error_code output, @o_error_desc output
	
	EXECUTE get_next_key @v_userid, @v_processinstancekey OUTPUT

	INSERT INTO tmwebprocessinstance
	(processinstancekey, processcode, lastuserid, lastmaintdate)
	VALUES
	(@v_processinstancekey, @v_processcode, @v_userid, GETDATE())

	DECLARE @bookTable TABLE
	(
		bookkey INT
	)
		
	INSERT INTO @bookTable
	SELECT bookkey
	FROM qcs_get_booklist(@i_title_listkey, null, null, 0)

	DECLARE title_cur CURSOR FAST_FORWARD FOR
	SELECT DISTINCT bookkey
	FROM @bookTable

	OPEN title_cur

	FETCH NEXT FROM title_cur INTO @v_bookkey

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		INSERT INTO tmwebprocessinstanceitem
		(processinstancekey, sortorder, key1, key2, key3, key4, key5, lastuserid, lastmaintdate)
		VALUES
		(@v_processinstancekey, 1, @v_jobkey, @v_batchkey, @v_bookkey, @i_userkey, @i_background_process, @v_userid, GETDATE())

		FETCH NEXT FROM title_cur INTO @v_bookkey
	END

	CLOSE title_cur 
    DEALLOCATE title_cur

	IF COALESCE(@i_background_process, 0) = 0
	BEGIN
		PRINT 'Executing tmwebprocess_copy_printings_from_titlelist...'
		EXEC tmwebprocess_copy_printings_from_titlelist @i_background_process, @o_error_code output, @o_error_desc output
	END

	SELECT @v_jobkey

END
GO

GRANT EXEC ON qutl_create_printings_webprocess_from_titlelist TO PUBLIC
GO