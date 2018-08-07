IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'qcs_process_scheduled_approvals') AND type in (N'P', N'PC'))
DROP PROCEDURE qcs_process_scheduled_approvals
GO

CREATE PROCEDURE qcs_process_scheduled_approvals
AS
BEGIN
/*********************************************************************************
**   Modified: Kusum Basra
**       Date: June 12 2014
**       Case: 28060 Automated cloud approval process needs to write title history  
**
**********************************************************************************/
  DECLARE @v_count INT
  DECLARE @v_count2 INT
  DECLARE @v_job_started_code INT
  DECLARE @v_job_error_code INT
  DECLARE @v_job_warning_code INT
  DECLARE @v_job_information_code INT
  DECLARE @v_job_aborted_code INT
  DECLARE @v_job_completed_code INT
  DECLARE @v_job_pending_code INT

  DECLARE @v_cloud_sched_approval_code INT
  DECLARE @v_cloud_approval_send_code INT

  DECLARE @v_approved_already_no_send_code INT
  DECLARE @v_approved_already_request_send_code INT
  DECLARE @v_never_approve_title_code INT
  DECLARE @v_no_distribution_template INT

  DECLARE @v_qsibatchkey INT
  DECLARE @v_qsijobkey INT
  DECLARE @v_jobtypecode INT
  DECLARE @v_jobdesc VARCHAR(2000)
  DECLARE @v_jobdesc_short VARCHAR(255)
  DECLARE @v_userid_cloud_approval_jobs VARCHAR(30)
  DECLARE @v_userid VARCHAR(30)
  DECLARE @v_orig_userid VARCHAR(30)
  DECLARE @v_referencekey1  INT
  DECLARE @v_referencekey2  INT
  DECLARE @v_referencekey3  INT
  DECLARE @v_messagecode INT
  DECLARE @v_messagetypecode INT
  DECLARE @v_messagetypeqsicode INT
  DECLARE @v_messagelongdesc VARCHAR(4000)
  DECLARE @v_messageshortdesc VARCHAR(255)
  DECLARE @o_error_code INT
  DECLARE @error_var INT
  DECLARE @rowcount_var INT
  DECLARE @o_error_desc	VARCHAR(300)
  DECLARE @v_cloudapprovaljobkey  INT
  DECLARE @v_cloudapprovalsendjobkey  INT
  DECLARE @v_sendjobcreated TINYINT

  DECLARE @v_bookkey  INT
  DECLARE @v_requestedapprovaldate DATETIME
  DECLARE @v_csdisttemplatekey  INT
  DECLARE @v_csapprovalcode INT
  DECLARE @v_not_distributed_code INT
  DECLARE @v_approvedind INT
  DECLARE @v_num_of_titles_approved INT
  DECLARE @v_sendqty_processed INT
  DECLARE @v_std_elo_disttemplatekey INT
  DECLARE @v_to_automatically_process INT
  DECLARE @v_clientdefaultvalue INT
  DECLARE @v_dateformat_value VARCHAR(40)
  DECLARE @v_dateformat_conversionvalue INT
  DECLARE @v_curdatetime VARCHAR(255)
  DECLARE @v_datacode INT
  DECLARE @v_startpos INT     

  SELECT @v_count = 0
  SELECT @v_count2 = 0
  SELECT @v_num_of_titles_approved = 0
  SELECT @v_sendqty_processed = 0
  SELECT @v_std_elo_disttemplatekey = 0
  SELECT @v_csdisttemplatekey = 0
  SELECT @v_csapprovalcode = 0
  
  -- select all cloudscheduleforapproval rows with an requestapprovaldate < or = currentdate
	SELECT @v_count = COUNT(*)
    FROM cloudscheduleforapproval
   WHERE requestedapprovaldate <= getdate()


  IF @v_count = 0 
    RETURN

  SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80		
  SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
  SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode						 
  SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1       
  SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')
		
  -- Message Types
  SELECT @v_job_started_code=datacode FROM gentables WHERE tableid=539 AND qsicode=1
  SELECT @v_job_error_code=datacode FROM gentables WHERE tableid=539 AND qsicode=2
  SELECT @v_job_warning_code=datacode FROM gentables WHERE tableid=539 AND qsicode=3
  SELECT @v_job_information_code=datacode FROM gentables WHERE tableid=539 AND qsicode=4
  SELECT @v_job_aborted_code=datacode FROM gentables WHERE tableid=539 AND qsicode=5
  SELECT @v_job_completed_code=datacode FROM gentables WHERE tableid=539 AND qsicode=6
  SELECT @v_job_pending_code=datacode FROM gentables WHERE tableid=539 AND qsicode=7

  -- Job Types
  SELECT @v_cloud_sched_approval_code=datacode FROM gentables WHERE tableid=543 AND qsicode=6
  SELECT @v_cloud_approval_send_code=datacode FROM gentables WHERE tableid=543 AND qsicode=7

  -- Messages
  SELECT @v_approved_already_no_send_code=datacode FROM gentables WHERE tableid=651 AND qsicode=5
  SELECT @v_approved_already_request_send_code=datacode FROM gentables WHERE tableid=651 AND qsicode=6
  SELECT @v_never_approve_title_code=datacode FROM gentables WHERE tableid=651 AND qsicode=7
  SELECT @v_no_distribution_template=datacode FROM gentables WHERE tableid= 651 and qsicode= 14

  --Cloud Send Process Status 
  SELECT @v_to_automatically_process=datacode FROM gentables WHERE tableid = 652 and qsicode=1 

  --retrieve userid from clientdefaults
  SELECT @v_userid_cloud_approval_jobs = stringvalue FROM clientdefaults WHERE clientdefaultid = 70

  -- retrieve standard elo distribution template key (supplied by Catherine)
  SELECT @v_std_elo_disttemplatekey = templatekey 
    FROM csdistributiontemplate 
   WHERE eloquencefieldtag = 'CLD_DTMP_STDELO'

  SET @v_qsibatchkey = NULL
  SET @v_qsijobkey = NULL
  SET @v_jobtypecode = @v_cloud_sched_approval_code
  SET @v_jobdesc = 'Cloud Scheduled Approval ' + @v_curdatetime
  SET @v_jobdesc_short = 'Cloud Approval ' + @v_curdatetime
  SET @v_userid = @v_userid_cloud_approval_jobs
  SET @v_referencekey1 = 0
  SET @v_referencekey2 = 0
  SET @v_referencekey3 = 0
  SET @v_messagetypecode = @v_job_started_code
  SET @v_messagetypeqsicode = 1
  SET @v_messagelongdesc = 'Job Started ' + @v_curdatetime
  SET @v_messageshortdesc = 'Job Started'
  SET @v_messagecode = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- start the Cloud Schedule Approval Job
  EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
   @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
   @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
   @o_error_code output, @o_error_desc output

  SET @v_cloudapprovaljobkey = @v_qsijobkey

  UPDATE qsijob
     SET qtyprocessed = @v_count
   WHERE qsijobkey = @v_cloudapprovaljobkey
 
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update qsijob table.'
    RETURN
  END 

  SELECT @v_count2 = COUNT(*)
    FROM cloudscheduleforapproval
   WHERE (csdisttemplatekey IS NOT NULL OR
          csdisttemplatekey = 0)


  IF @v_count2 > 0 BEGIN
    SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1    
    SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')  
    SET @v_sendjobcreated = 1
    -- create the job for "Cloud Approval Send"
    SET @v_qsijobkey = NULL
    SET @v_jobtypecode = @v_cloud_approval_send_code
    SET @v_jobdesc = 'Cloud Approval Send ' + @v_curdatetime
    SET @v_jobdesc_short = 'Cloud Approval Send ' + @v_curdatetime
    SET @v_userid = @v_userid_cloud_approval_jobs
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

    SET @v_cloudapprovalsendjobkey = @v_qsijobkey
    
    INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey, partnercontactkey,processstatuscode,jobstartind,jobendind, lastuserid, lastmaintdate)
      VALUES(@v_cloudapprovalsendjobkey,NULL,NULL,0,NULL,@v_to_automatically_process,1,0,@v_userid,getdate())
    
  END
  ELSE BEGIN
    SET @v_sendjobcreated = 0
  END

  CREATE TABLE #tmp_cloudscheduleforapproval (bookkey INT not null, requestedapprovaldate DATETIME, csdisttemplatekey INT, lastuserid VARCHAR(30))
 
  INSERT INTO #tmp_cloudscheduleforapproval
    SELECT bookkey, requestedapprovaldate, csdisttemplatekey, lastuserid
      FROM cloudscheduleforapproval
     WHERE requestedapprovaldate <= getdate()


  DECLARE cloudscheduleforapproval_cur CURSOR FOR
    SELECT bookkey, requestedapprovaldate, csdisttemplatekey, lastuserid
      FROM #tmp_cloudscheduleforapproval
 
  OPEN cloudscheduleforapproval_cur

  FETCH NEXT FROM cloudscheduleforapproval_cur INTO @v_bookkey,@v_requestedapprovaldate,@v_csdisttemplatekey,@v_orig_userid

  WHILE (@@FETCH_STATUS = 0) 
  BEGIN

    /* standard elo dist template used */
    IF @v_csdisttemplatekey = @v_std_elo_disttemplatekey BEGIN
      EXECUTE qtitle_update_bookedistatus @v_bookkey, 1, @v_orig_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

      IF @o_error_code < 0 BEGIN
        -- Error
        SET @v_qsijobkey = @v_cloudapprovaljobkey
        SET @v_jobtypecode = NULL
        SET @v_jobdesc = NULL
        SET @v_jobdesc_short = NULL
        SET @v_userid = NULL
        SET @v_referencekey1 = @v_bookkey
        SET @v_referencekey2 = 0
        SET @v_referencekey3 = 0
        SET @v_messagetypecode = NULL
        SET @v_messagetypeqsicode = NULL
        SET @v_messagelongdesc = @o_error_desc
        SET @v_messageshortdesc = NULL
        SET @v_messagecode = NULL
        SET @o_error_code = 0
        SET @o_error_desc = ''

        EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
         @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
         @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
         @o_error_code output, @o_error_desc output

        INSERT INTO cloudscheduleforapproval_history 
          (bookkey, processeddate,requestedapprovaldate,approvalind,csdisttemplatekey, lastuserid,lastmaintdate)
        VALUES
          (@v_bookkey, getdate(),@v_requestedapprovaldate,@v_approvedind,@v_csdisttemplatekey,@v_userid_cloud_approval_jobs,getdate())

        GOTO next_row
      END
    END  /* standard elo dist template used*/

    SELECT @v_csapprovalcode = csapprovalcode FROM bookdetail WHERE bookkey = @v_bookkey

      
    IF @v_csapprovalcode = 1 BEGIN  --Approved for distribution
			SELECT @v_not_distributed_code = datacode
			FROM gentables
			WHERE tableid = 639
				AND qsicode = 1
			
			UPDATE bookdetail
			SET csmetadatastatuscode = @v_not_distributed_code
			WHERE bookkey = @v_bookkey
			
      IF @v_csdisttemplatekey IS NOT NULL AND @v_csdisttemplatekey > 0 BEGIN
        SET @v_approvedind = 0

        INSERT INTO cloudsendstaging (jobkey,bookkey,elementkey,csdisttemplatekey,partnercontactkey,processstatuscode,lastuserid,lastmaintdate)
         VALUES(@v_cloudapprovalsendjobkey,@v_bookkey,NULL,@v_csdisttemplatekey,NULL,@v_to_automatically_process,@v_userid_cloud_approval_jobs,getdate())

        SELECT @v_sendqty_processed = @v_sendqty_processed + 1
    
        SET @v_qsijobkey = @v_cloudapprovaljobkey
        SET @v_jobtypecode = NULL
        SET @v_jobdesc = NULL
        SET @v_jobdesc_short = NULL
        SET @v_userid = NULL
        SET @v_referencekey1 = @v_bookkey
        SET @v_referencekey2 = 0
        SET @v_referencekey3 = 0
        SET @v_messagetypecode = NULL
        SET @v_messagetypeqsicode = NULL
        SET @v_messagelongdesc = 'Title was already approved. Since a distribution template was present in the approval request, the send to the template is being processed' 
        SET @v_messageshortdesc = NULL
        SET @v_messagecode = @v_approved_already_request_send_code
        SET @o_error_code = 0
        SET @o_error_desc = ''

        EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
         @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
         @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
         @o_error_code output, @o_error_desc output

      END /* @v_csdisttemplatekey is not null and > 0 */
      ELSE BEGIN
        SET @v_qsijobkey = @v_cloudapprovaljobkey
        SET @v_jobtypecode = NULL
        SET @v_jobdesc = NULL
        SET @v_jobdesc_short = NULL
        SET @v_userid = NULL
        SET @v_referencekey1 = @v_bookkey
        SET @v_referencekey2 = 0
        SET @v_referencekey3 = 0
        SET @v_messagetypecode = NULL
        SET @v_messagetypeqsicode = NULL
        SET @v_messagelongdesc = 'Title was already approved. No send was requested.' 
        SET @v_messageshortdesc = NULL
        SET @v_messagecode = @v_approved_already_no_send_code
        SET @o_error_code = 0
        SET @o_error_desc = ''

        EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
         @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
         @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
         @o_error_code output, @o_error_desc output


      END  /* @v_csdisttemplatekey is null or 0 */
    END /* @v_csapprovalcode = 1 */
    ELSE IF @v_csapprovalcode = 3 BEGIN   /*Never Approve */
      SET @v_approvedind = 0
      SET @v_qsijobkey = @v_cloudapprovaljobkey
      SET @v_jobtypecode = NULL
      SET @v_jobdesc = NULL
      SET @v_jobdesc_short = NULL 
      SET @v_userid = NULL
      SET @v_referencekey1 = @v_bookkey
      SET @v_referencekey2 = 0
      SET @v_referencekey3 = 0
      SET @v_messagetypecode = NULL
      SET @v_messagetypeqsicode = NULL
      SET @v_messagelongdesc = 'Title is set to Never Approve. The automated process will not approve this title; it must be done through Title Managemante' 
      SET @v_messageshortdesc = NULL
      SET @v_messagecode = @v_never_approve_title_code
      SET @o_error_code = 0
      SET @o_error_desc = ''

      EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
       @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
       @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
       @o_error_code output, @o_error_desc output
    END /* @v_csapprovalcode = 3 */
    ELSE BEGIN 
       IF @v_csdisttemplatekey > 0 BEGIN  --Send is requested for all approved assets
            SET @v_csapprovalcode = 1
       
		   UPDATE bookdetail 
			  SET csapprovalcode = @v_csapprovalcode
			WHERE bookkey = @v_bookkey
			
		   INSERT INTO cloudsendstaging (jobkey,bookkey,elementkey,csdisttemplatekey,partnercontactkey,processstatuscode,lastuserid,lastmaintdate)
			  VALUES(@v_cloudapprovalsendjobkey,@v_bookkey,NULL,@v_csdisttemplatekey,NULL,@v_to_automatically_process,@v_userid_cloud_approval_jobs,getdate())

           
		   SET @v_approvedind = 1
		   SET @v_num_of_titles_approved = @v_num_of_titles_approved + 1
		   SET @v_sendqty_processed = @v_sendqty_processed + 1
		   
	   END
	   ELSE BEGIN
		  SET @v_csapprovalcode = 0
		
		  SET @v_qsijobkey = @v_cloudapprovaljobkey
		  SET @v_jobtypecode = NULL
		  SET @v_jobdesc = NULL
		  SET @v_jobdesc_short = NULL 
		  SET @v_userid = NULL
		  SET @v_referencekey1 = @v_bookkey
		  SET @v_referencekey2 = 0
		  SET @v_referencekey3 = 0
		  SET @v_messagetypecode = NULL
		  SET @v_messagetypeqsicode = NULL
		  SET @v_messagelongdesc = 'Title was not approved; no distribution template provided' 
		  SET @v_messageshortdesc = NULL
		  SET @v_messagecode = @v_no_distribution_template
		  SET @o_error_code = 0
		  SET @o_error_desc = ''

		  EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
		   @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
		   @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
		   @o_error_code output, @o_error_desc output
		
	   
	   END
    END /* @v_csapprovalcode <> 1 or 3 */


    INSERT INTO cloudscheduleforapproval_history 
      (bookkey, processeddate,requestedapprovaldate,approvalind,csdisttemplatekey, lastuserid,lastmaintdate)
    VALUES
      (@v_bookkey, getdate(),@v_requestedapprovaldate,@v_approvedind,@v_csdisttemplatekey,@v_userid_cloud_approval_jobs,getdate())

    /*delete row from cloudscheduleforapproval */
    DELETE FROM cloudscheduleforapproval
     WHERE bookkey = @v_bookkey 
       AND requestedapprovaldate = @v_requestedapprovaldate
       AND csdisttemplatekey = @v_csdisttemplatekey
       AND lastuserid = @v_orig_userid

    /* Fetch next cloudscheduleforapproval row */
    next_row:
    FETCH NEXT FROM cloudscheduleforapproval_cur INTO @v_bookkey,@v_requestedapprovaldate,@v_csdisttemplatekey,@v_orig_userid

  END	/* @@FETCH_STATUS=0 - cloudscheduleforapproval_cur */
    
  CLOSE cloudscheduleforapproval_cur 
  DEALLOCATE cloudscheduleforapproval_cur
  DROP TABLE #tmp_cloudscheduleforapproval
 
  IF @v_sendjobcreated = 1 BEGIN
    -- write a Job End row for the Cloud Approval Send Job to pass along to other processes
    -- so they know when to complete this job
    INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey,partnercontactkey,processstatuscode, jobstartind,jobendind, lastuserid, lastmaintdate)
      VALUES(@v_cloudapprovalsendjobkey,NULL,NULL,0,NULL,@v_to_automatically_process,0,1,@v_userid_cloud_approval_jobs,getdate())

    UPDATE qsijob
       SET qtyprocessed = @v_sendqty_processed
     WHERE qsijobkey = @v_cloudapprovalsendjobkey
       
  END 
 
  UPDATE qsijob
     SET qtycompleted = @v_num_of_titles_approved
   WHERE qsijobkey = @v_cloudapprovaljobkey
     

  -- Complete the Process Cloud ApprovalsJob
  SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1    
  SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')  
  SET @v_qsijobkey = @v_cloudapprovaljobkey
  SET @v_jobtypecode = NULL
  SET @v_jobdesc = NULL
  SET @v_jobdesc_short = NULL
  SET @v_userid = @v_userid_cloud_approval_jobs
  SET @v_referencekey1 = 0
  SET @v_referencekey2 = 0
  SET @v_referencekey3 = 0
  SET @v_messagetypecode = @v_job_completed_code
  SET @v_messagetypeqsicode = 6
  SET @v_messagelongdesc = 'Job Completed ' + @v_curdatetime + '. Total Number of Titles processsed = ' 
     + cast(@v_sendqty_processed as varchar) + '. Total Number of Titles approved = ' + cast(@v_num_of_titles_approved as varchar)
  SET @v_messageshortdesc = 'Job Completed'
  SET @v_messagecode = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''

  EXEC qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_jobtypecode,0,@v_jobdesc,@v_jobdesc_short,
     @v_userid,@v_referencekey1,@v_referencekey2,@v_referencekey3,@v_messagetypecode,
     @v_messagelongdesc,@v_messageshortdesc,@v_messagecode,@v_messagetypeqsicode,
     @o_error_code output, @o_error_desc output
  
	
END
GO

GRANT EXEC ON qcs_process_scheduled_approvals TO PUBLIC
GO
