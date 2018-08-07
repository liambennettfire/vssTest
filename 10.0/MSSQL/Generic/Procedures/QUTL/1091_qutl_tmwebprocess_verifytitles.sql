IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[qutl_tmwebprocess_verifytitles]')
      AND type IN (N'P', N'PC')
    )
  DROP PROCEDURE [dbo].[qutl_tmwebprocess_verifytitles]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qutl_tmwebprocess_verifytitles] 
(
  @i_tmwebprocesscode INT,
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)

AS
/*************************************************************************************************************************
**  Name: qutl_tmwebprocess_verifytitles
**  Desc: This stored procedure is run preiodically via a job and checks for tmwebprocess requests to validate titles from 
**		  a list of titles and executes them. All of the bookkeys from the list should already be made available as
**		  tmwebprocessinstanceitem records.
**
**    Auth: Colman
**    Date: 3/1/2018
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**************************************************************************************************************************/
DECLARE @v_bookkey INT,
  @v_printingkey INT,
  @v_verificationtypecode INT,
  @v_processinstancekey INT,
  @v_jobkey INT,
  @v_batchkey INT,
  @v_userid VARCHAR(30),
  @v_jobtypecode INT,
  @v_processcode INT,
  @v_msgtype_started INT,
  @v_msgtype_error INT,
  @v_msgtype_information INT,
  @v_msgtype_completed INT,
  @v_clientdefaultvalue INT,
  @v_curdatetime VARCHAR(255),
  @v_msglongdesc VARCHAR(4000),
  @v_msgshortdesc VARCHAR(255),
  @v_verification_status VARCHAR(255),
  @v_error_code INT,
  @v_error_msg VARCHAR(MAX),
  @v_nextkey INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_msgtype_started = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 1

  SELECT @v_msgtype_error = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 2

  SELECT @v_msgtype_information = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 4

  SELECT @v_msgtype_completed = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 6

  SELECT @v_processcode = @i_tmwebprocesscode

  SELECT @v_jobtypecode = code2
  FROM gentablesrelationshipdetail
  WHERE gentablesrelationshipkey = 30
    AND code1 = @v_processcode

  DECLARE @currentjobstable TABLE (jobkey INT, batchkey INT)
  DECLARE @currentprocesstable TABLE (processinstancekey INT)

  DECLARE webproc_cur CURSOR FOR
    SELECT twp.processinstancekey,
      twpi.key1 AS jobkey,
      twpi.key2 AS batchkey,
      twpi.key3 AS bookkey,
      twpi.key4 AS printingkey,
      twpi.key5 AS verificationtypecode,
      twpi.lastuserid AS userid
    FROM tmwebprocessinstance twp
      JOIN tmwebprocessinstanceitem twpi ON twp.processinstancekey = twpi.processinstancekey
    WHERE twp.processcode = @v_processcode
    ORDER BY twp.processinstancekey, twpi.sortorder

  OPEN webproc_cur

  FETCH NEXT
  FROM webproc_cur
  INTO @v_processinstancekey, @v_jobkey, @v_batchkey, @v_bookkey, @v_printingkey, @v_verificationtypecode, @v_userid

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
		IF NOT EXISTS (SELECT 1 FROM @currentjobstable WHERE jobkey = @v_jobkey)
    BEGIN
      --generate job message to indicate the job has started
      INSERT INTO @currentjobstable (jobkey, batchkey)
      VALUES (@v_jobkey, @v_batchkey)

      SELECT @v_curdatetime = dbo.qutl_get_formatted_jobdate(GETDATE())

      SET @v_msglongdesc = 'Job Execution Started ' + @v_curdatetime
      SET @v_msgshortdesc = 'Job Execution Started'

      EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, 0, 0, 0,
        @v_msgtype_started, @v_msglongdesc, @v_msgshortdesc, NULL, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT
    END

    --keep track of all the of the processinstancekeys that are getting processed
		IF NOT EXISTS (SELECT 1 FROM @currentprocesstable WHERE processinstancekey = @v_processinstancekey)
      INSERT INTO @currentprocesstable (processinstancekey)
      VALUES (@v_processinstancekey)

    SET @o_error_code = 0
    SET @o_error_desc = ''

    IF (@v_verificationtypecode > 0) 
    BEGIN
      EXECUTE qtitle_verify_title @v_bookkey, @v_printingkey, @v_verificationtypecode, @v_userid, @v_error_code output, @v_error_msg output
      
      -- EXECUTE qutl_trace 'qtitle_verify_title',
        -- '@v_bookkey', @v_bookkey, NULL,
        -- '@v_printingkey', @v_printingkey, NULL,
        -- '@v_verificationtypecode', @v_verificationtypecode, NULL,
        -- '@v_error_code', @v_error_code, NULL,
        -- '@v_error_msg', NULL, @v_error_msg

      IF @v_error_code < 0 
      BEGIN
        SELECT @v_curdatetime = dbo.qutl_get_formatted_jobdate(GETDATE())

        SET @v_msglongdesc = 'Error validating title ' + @v_curdatetime
        SET @v_msgshortdesc = 'Error validating title'

        EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0,
          @v_msgtype_error, @v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code OUTPUT, @o_error_desc OUTPUT
      END 
      ELSE IF @v_error_code > 0 
      BEGIN
        SELECT @v_curdatetime = dbo.qutl_get_formatted_jobdate(GETDATE())

        SELECT @v_verification_status = datadesc FROM gentables WHERE tableid = 513 AND datacode = @v_error_code
        SET @v_msgshortdesc = @v_verification_status
        SET @v_msglongdesc = @v_verification_status

        EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0,
          @v_msgtype_information, @v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code OUTPUT, @o_error_desc OUTPUT
      END 
    END
      
    UPDATE qsijob
    SET qtycompleted = ISNULL(qtycompleted, 0) + 1
    WHERE qsijobkey = @v_jobkey

    FETCH NEXT
    FROM webproc_cur
    INTO @v_processinstancekey, @v_jobkey, @v_batchkey, @v_bookkey, @v_printingkey, @v_verificationtypecode, @v_userid
  END

  CLOSE webproc_cur
  DEALLOCATE webproc_cur

  DECLARE job_cur CURSOR FOR
    SELECT jobkey, batchkey
    FROM @currentjobstable

  OPEN job_cur

  FETCH NEXT FROM job_cur
  INTO @v_jobkey, @v_batchkey

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    SELECT @v_curdatetime = dbo.qutl_get_formatted_jobdate(GETDATE())

    SET @v_msglongdesc = 'Job Completed ' + @v_curdatetime
    SET @v_msgshortdesc = 'Job Completed'

    EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, 0, 0, 0,
      @v_msgtype_completed, @v_msglongdesc, @v_msgshortdesc, NULL, 6, @o_error_code OUTPUT, @o_error_desc OUTPUT

    FETCH NEXT
    FROM job_cur
    INTO @v_jobkey, @v_batchkey
  END

  CLOSE job_cur
  DEALLOCATE job_cur

  --cleanup the tmwebprocessinstance now that all have been processed
  DELETE
  FROM tmwebprocessinstanceitem
  WHERE processinstancekey IN (
    SELECT processinstancekey
    FROM @currentprocesstable
  )

  DELETE
  FROM tmwebprocessinstance
  WHERE processinstancekey IN (
    SELECT processinstancekey
    FROM @currentprocesstable
  )
END
GO

GRANT EXEC ON qutl_tmwebprocess_verifytitles TO PUBLIC
GO


