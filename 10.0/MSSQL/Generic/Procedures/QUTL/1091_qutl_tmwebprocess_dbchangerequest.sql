IF EXISTS (
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[qutl_tmwebprocess_dbchangerequest]')
      AND type IN (N'P', N'PC')
    )
  DROP PROCEDURE [dbo].[qutl_tmwebprocess_dbchangerequest]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[qutl_tmwebprocess_dbchangerequest] 
(
  @i_tmwebprocesscode INT,
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)

AS
/*************************************************************************************************************************
**  Name: qutl_tmwebprocess_dbchangerequest
**  Desc: This stored procedure is run preiodically via a job and checks for tmwebprocess db change requests
**
**    Auth: Colman
**    Date: 3/15/2018
**************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  06/12/18    Colman    Case 42604
**************************************************************************************************************************/
 -- exec qutl_trace 'qutl_tmwebprocess_dbchangerequest',
   -- '@i_tmwebprocesscode', @i_tmwebprocesscode, NULL

DECLARE
  @v_itemdesc VARCHAR(MAX), 
  @v_message VARCHAR(MAX),
  @v_processinstancekey INT,
  @v_request_xml VARCHAR(MAX),
  @v_jobkey INT,
  @v_batchkey INT,
  @v_userid VARCHAR(30),
  @v_userkey INT,
  @v_searchitemcode INT, 
  @v_key1 INT, 
  @v_key2 INT,
  @v_jobtypecode INT,
  @v_processcode INT,
  @v_itemtype INT,
  @v_msgtype_started INT,
  @v_msgtype_error INT,
  @v_msgtype_completed INT,
  @v_curdatetime VARCHAR(255),
  @v_msglongdesc VARCHAR(4000),
  @v_msgshortdesc VARCHAR(255),
  @o_newkeys VARCHAR(4000), 
  @o_warnings VARCHAR(4000),
  @v_update_in_list_proc INT,
  @v_nextkey INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_update_in_list_proc = 0

  SELECT @v_msgtype_started = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 1

  SELECT @v_msgtype_error = datacode
  FROM gentables
  WHERE tableid = 539
    AND qsicode = 2

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
    SELECT TOP 1 twp.processinstancekey, -- For now, just process one request per background job
      twpi.key1 AS jobkey,
      twpi.key2 AS batchkey,
      twpi.text1 AS request_xml,
      twpi.lastuserid AS userid
    FROM tmwebprocessinstance twp
      JOIN tmwebprocessinstanceitem twpi ON twp.processinstancekey = twpi.processinstancekey
    WHERE twp.processcode = @v_processcode
    ORDER BY twp.processinstancekey, twpi.sortorder

  OPEN webproc_cur

  FETCH NEXT
  FROM webproc_cur
  INTO @v_processinstancekey, @v_jobkey, @v_batchkey, @v_request_xml, @v_userid

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

    -- exec qutl_trace 'qutl_tmwebprocess_dbchangerequest',
      -- '@v_processinstancekey', @v_processinstancekey, NULL,
      -- '@v_request_xml', NULL, @v_request_xml

    IF ISNULL(@v_request_xml, '') <> ''
    BEGIN
      IF CHARINDEX('update_titles_in_list', @v_request_xml) > 0 OR CHARINDEX('update_title_territories_in_list', @v_request_xml) > 0
      BEGIN
        SET @v_update_in_list_proc = 1
        SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 AND qsicode = 1
      END
      ELSE IF CHARINDEX('update_projects_in_list', @v_request_xml) > 0
      BEGIN
        SET @v_update_in_list_proc = 1
        SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 AND qsicode = 3
      END
      ELSE IF CHARINDEX('update_journals_in_list', @v_request_xml) > 0
      BEGIN
        SET @v_update_in_list_proc = 1
        SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 AND qsicode = 6
      END
      
      EXECUTE qutl_dbchange_request @v_request_xml, @o_newkeys out, @o_warnings out, @o_error_code output, @o_error_desc output
    
      IF @v_update_in_list_proc = 1 AND @o_error_code = -2
      BEGIN
        SELECT @v_userkey = userkey FROM qsiusers WHERE userid = @v_userid

        -- Get feedback rows for this user and itemtype
        DECLARE feedback_cur CURSOR FOR
          SELECT key1, itemdesc, message
          FROM qse_updatefeedback
          WHERE userkey = @v_userkey 
            AND searchitemcode = @v_itemtype
          ORDER BY itemdesc

        OPEN feedback_cur
        
        FETCH feedback_cur INTO
          @v_key1, @v_itemdesc, @v_message

        WHILE @@FETCH_STATUS = 0
        BEGIN
          SET @v_msgshortdesc = 'Error updating ' + @v_itemdesc
          SET @v_msglongdesc = 'Error updating ' + @v_itemdesc + ': ' + @v_message

          EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, @v_key1, NULL, NULL, @v_userid, 0, 0, 0, @v_msgtype_error,
            @v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output
            
          FETCH feedback_cur INTO
            @v_key1, @v_itemdesc, @v_message
        END

        CLOSE feedback_cur
        DEALLOCATE feedback_cur
      END
      ELSE IF @o_error_code <> 0
      BEGIN
        SET @v_msglongdesc = 'Job encountered an error while executing qutl_dbchange_request' 
        SET @v_msgshortdesc = 'Job encountered an error while executing qutl_dbchange_request'
        
        IF ISNULL(@o_error_desc, '') <> ''
          SET @v_msglongdesc = @v_msglongdesc + ': ' + @o_error_desc

        EXEC qutl_update_job @v_batchkey, @v_jobkey, @v_jobtypecode, NULL, NULL, NULL, @v_userid, 0, 0, 0, @v_msgtype_error,
          @v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output

        BREAK
      END
      ELSE
      BEGIN
        UPDATE qsijob
        SET qtycompleted = ISNULL(qtycompleted, 0) + 1
        WHERE qsijobkey = @v_jobkey
      END
    END

    FETCH NEXT
    FROM webproc_cur
    INTO @v_processinstancekey, @v_jobkey, @v_batchkey, @v_request_xml, @v_userid
  END

  CLOSE webproc_cur
  DEALLOCATE webproc_cur

  DECLARE job_cur CURSOR FOR
    SELECT jobkey, batchkey
    FROM @currentjobstable

  OPEN job_cur

  FETCH NEXT FROM job_cur
  INTO @v_jobkey, @v_batchkey

  WHILE @@FETCH_STATUS = 0
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

GRANT EXEC ON qutl_tmwebprocess_dbchangerequest TO PUBLIC
GO


