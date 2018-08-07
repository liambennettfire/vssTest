if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_send_prepublish') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_send_prepublish
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcs_send_prepublish]
(@i_processstatuscode	int,
 @i_jobkey	int,
 @i_publishtablestatuscode	int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	DECLARE @v_error  INT,
					@v_msgtype_started	INT,
					@v_msgtype_error	INT,
					@v_msgtype_warning	INT,
					@v_msgtype_info		INT,
					@v_msgtype_aborted	INT,
					@v_msg_failedver	INT,
					@v_msg_verwarning	INT,
					@v_msg_noassets	INT,
					@v_msg_unapproved	INT,
					@v_msg_nocustomer	INT,
					@v_msg_withcsformat	INT,
					@v_procstat_ready	INT,
					@v_procstat_ondemand	INT,
					@v_procstat_notready	INT,
					@v_preprocessSp	NVARCHAR(255),
					@v_csverificationSp NVARCHAR(255),
					@v_csverificationtypecode	INT,
					@v_csverify_failed INT,
					@v_csverify_warnings INT,
					@v_csverify_passed INT,
					@v_titleverifystatuscode INT,
					@v_approvedstatuscode INT,
					@v_msglongdesc VARCHAR(4000),
					@v_msgshortdesc VARCHAR(255),
					@v_count int,
					@v_index int,
					@v_min_jobkey int,
					@v_sql NVARCHAR(2000),
					@v_distributiontypecode int,
					@v_displayname VARCHAR(255),
					@v_id uniqueidentifier,
					@v_jobkey int,
					@v_bookkey int,
					@v_customerkey int,
					@v_elementkey int,
					@v_csdisttemplatekey int,
					@v_partnercontactkey int,
					@v_processstatuscode int,
					@v_jobstartind tinyint,
					@v_jobendind tinyint,
					@v_validind tinyint,
					@v_betterfileind tinyint,
					@v_lastuserid varchar(30),
					@v_lastmaintdate datetime,
					@v_quote char(2),
					@v_debug tinyint,
					@v_metadata_asset int,
					@v_metadata_elementkey int,
					--@v_asset_approved int,
					@v_messagecode int,
					@v_messagedesc varchar(4000),
					@v_min_bookkey int,
					@v_cnt int,
					@v_idx int,
					@v_cloudsendstaging_count int,
					@v_title_cnt int,
					@v_clientdefaultvalue INT,
					@v_dateformat_value VARCHAR(40),
					@v_dateformat_conversionvalue INT,
					@v_curdatetime VARCHAR(255),
					@v_datacode INT,
					@v_startpos INT 											
	
	SET @v_debug = 0
					
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SET @v_quote = ''''
	 
	--Prefetch gentable values
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
		
	SELECT @v_msg_failedver = datacode
	FROM gentables
	WHERE tableid = 651
		AND qsicode = 8
		
	SELECT @v_msg_verwarning = datacode
	FROM gentables
	WHERE tableid = 651
		AND qsicode = 9
		
	SELECT @v_msg_noassets = datacode
	FROM gentables
	WHERE tableid = 651
		AND qsicode = 10
		
	SELECT @v_msg_unapproved = datacode
	FROM gentables
	WHERE tableid = 651
		AND qsicode = 11
		
	SELECT @v_msg_nocustomer = datacode
	FROM gentables
	WHERE tableid = 651
		AND qsicode = 12
		
	SELECT @v_msg_withcsformat = datacode
	FROM gentables
	WHERE tableid = 651
		AND qsicode = 13
	
	SELECT @v_procstat_ready = datacode
	FROM gentables
	WHERE tableid = 652
		AND qsicode = 1
		
	SELECT @v_procstat_ondemand = datacode
	FROM gentables
	WHERE tableid = 652
		AND qsicode = 2
		
	SELECT @v_procstat_notready = datacode
	FROM gentables
	WHERE tableid = 652
		AND qsicode = 3
	
	SELECT @v_csverify_failed = datacode
	FROM gentables 
	WHERE tableid = 513
		AND qsicode = 2
		
	SELECT @v_csverify_passed = datacode
	FROM gentables
	WHERE tableid = 513
		AND qsicode = 3
		
	SELECT @v_csverify_warnings = datacode
  FROM gentables 
  WHERE tableid = 513
		AND qsicode = 4
	
	SELECT @v_preprocessSp = stringvalue
	FROM clientdefaults
	WHERE clientdefaultid = 71
	
	SELECT @v_csverificationSp = alternatedesc1, @v_csverificationtypecode = datacode
	FROM gentables
	WHERE tableid = 556
		AND qsicode = 3
		
	SELECT @v_approvedstatuscode = datacode
	FROM gentables
	WHERE tableid = 593
		AND qsicode = 3
		
	SELECT @v_metadata_asset = datacode
	FROM gentables
	WHERE tableid = 287
		AND qsicode = 3

	--end of gentables prefetches
		
	--Get rows from CloudSendStaging based on parameters
	DECLARE @work TABLE
	(
		id uniqueidentifier NOT NULL PRIMARY KEY,
		parentid uniqueidentifier NOT NULL,
		jobkey int NOT NULL,
		bookkey int NULL,
		customerkey int NULL,
		elementkey int NULL,
		csdisttemplatekey int NULL,
		partnercontactkey int NULL,
		processstatuscode int NULL,
		jobstartind tinyint NULL,
		jobendind tinyint NULL,
		validind tinyint NULL,
		betterfileind tinyint NULL,
		lastuserid varchar(30) NULL,
		lastmaintdate datetime NULL,
		messagecode int NULL,
		messagedesc varchar(4000) NULL
	)

  DECLARE @alljobs TABLE
  (
	  jobkey int
  )

	IF ISNULL(@i_jobkey,0) = 0
	BEGIN
		SELECT @v_cloudsendstaging_count = count(*)
		FROM cloudsendstaging css
		LEFT OUTER JOIN book b
		ON css.bookkey = b.bookkey
		WHERE processstatuscode = @i_processstatuscode
	END
	ELSE BEGIN
		SELECT @v_cloudsendstaging_count = count(*)
		FROM cloudsendstaging css
		LEFT OUTER JOIN book b
		ON css.bookkey = b.bookkey
		WHERE processstatuscode = @i_processstatuscode
			AND jobkey = @i_jobkey
	END
	
	WHILE (@v_cloudsendstaging_count > 0)
  BEGIN
    -- make sure @work is empty
	  delete from @work
	  	  
	  -- process rows in chunks
	  IF ISNULL(@i_jobkey,0) = 0
	  BEGIN
		  INSERT INTO @work
		  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
		  SELECT TOP 50000 id, id, jobkey, b.bookkey, b.elocustomerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, 1, 0, css.lastuserid, css.lastmaintdate
		  FROM cloudsendstaging css
		  LEFT OUTER JOIN book b
		  ON css.bookkey = b.bookkey
		  WHERE processstatuscode = @i_processstatuscode
		  ORDER BY jobstartind DESC, jobendind ASC, jobkey ASC, css.bookkey ASC, css.lastmaintdate ASC
	  END
	  ELSE BEGIN
		  INSERT INTO @work
		  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
		  SELECT TOP 50000 id, id, jobkey, b.bookkey, b.elocustomerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, 1, 0, css.lastuserid, css.lastmaintdate
		  FROM cloudsendstaging css
		  LEFT OUTER JOIN book b
		  ON css.bookkey = b.bookkey
		  WHERE processstatuscode = @i_processstatuscode
			  AND jobkey = @i_jobkey
		  ORDER BY jobstartind DESC, jobendind ASC, jobkey ASC, css.bookkey ASC, css.lastmaintdate ASC
	  END
  	
  	-- keep track of all the jobs that are being processed
	  DELETE FROM @alljobs
	  
	  INSERT INTO @alljobs (jobkey)
	  SELECT DISTINCT jobkey
	  FROM @work
	  WHERE ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
  	  	
	  --------------------
	  --JOBSTARTIND JOBS--
	  --------------------
	  DECLARE jobstart_cursor CURSOR FOR
	  SELECT id, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, 
	         validind, betterfileind, lastuserid, lastmaintdate
	  FROM @work
	  WHERE validind = 1
		  AND jobstartind = 1
  	
	  OPEN jobstart_cursor
  	
	  FETCH jobstart_cursor
	  INTO @v_id, @v_jobkey, @v_bookkey, @v_customerkey, @v_elementkey, @v_csdisttemplatekey, @v_partnercontactkey, @v_processstatuscode,
				  @v_jobstartind, @v_jobendind, @v_validind, @v_betterfileind, @v_lastuserid, @v_lastmaintdate

	  WHILE (@@FETCH_STATUS = 0)
    BEGIN
		  SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80		
		  SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
		  SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode								  	 
		  SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1  
		  SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')
    
		  SET @v_msglongdesc = 'Job Started ' + @v_curdatetime
		  SET @v_msgshortdesc = 'Job Started'
  		
		  EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_started, @v_msglongdesc, @v_msgshortdesc,
			  NULL, 1, @o_error_code output, @o_error_desc output
  		
		  FETCH jobstart_cursor
		  INTO @v_id, @v_jobkey, @v_bookkey, @v_customerkey, @v_elementkey, @v_csdisttemplatekey, @v_partnercontactkey, @v_processstatuscode,
					  @v_jobstartind, @v_jobendind, @v_validind, @v_betterfileind, @v_lastuserid, @v_lastmaintdate
    END
    
    CLOSE jobstart_cursor
	  DEALLOCATE jobstart_cursor
  	
    -- status message      	
    SELECT @v_count = COUNT(*)
    FROM @alljobs
		
    SELECT @v_min_jobkey = MIN(jobkey)
    FROM @alljobs
		
    SET @v_index = 1
		
    WHILE (@v_index <= @v_count)
    BEGIN		    
	    SELECT @v_title_cnt = COUNT(DISTINCT bookkey)
	    FROM @work
	    WHERE jobkey = @v_min_jobkey
	      AND bookkey > 0
		    AND ISNULL(jobstartind, 0) <> 1
		    AND ISNULL(jobendind, 0) <> 1
		    
	    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
	    SET @v_msglongdesc = 'Processing ' + cast(@v_title_cnt as varchar) + ' Distinct Titles'
	    SET @v_msgshortdesc = 'Processing ' + cast(@v_title_cnt as varchar) + ' Distinct Titles'
			
	    EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_info,
		    @v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output
				
	    SET @v_index = @v_index + 1
			
	    SELECT @v_min_jobkey = MIN(jobkey)
	    FROM @alljobs
	    WHERE jobkey > @v_min_jobkey
    END
  	
	  --------------------
	  --TITLE VALIDATION--
	  --------------------
	  DECLARE @jobsforbook TABLE
	  (
		  jobkey int
	  )
  	  	
	  SELECT @v_cnt = COUNT(DISTINCT bookkey)
	  FROM @work
	  WHERE validind = 1
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
  	
	  SELECT @v_min_bookkey = MIN(bookkey)
	  FROM @work
	  WHERE validind = 1
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
  	
	  SET @v_idx = 1
  	
	  WHILE (@v_idx <= @v_cnt)
    BEGIN
      SET @v_bookkey = @v_min_bookkey
      
		  --retrieve associated jobkeys for this book
		  DELETE FROM @jobsforbook
  		
		  INSERT INTO @jobsforbook
		  (jobkey)
		  SELECT DISTINCT jobkey
		  FROM @work
		  WHERE bookkey = @v_bookkey
			  AND validind = 1
			  AND ISNULL(jobstartind, 0) <> 1
			  AND ISNULL(jobendind, 0) <> 1
  			
		  --Customer specific preprocess
		  IF ISNULL(@v_preprocessSp, '') <> ''
		  BEGIN
			  --dynamically call sp passing in @v_bookkey
			  EXEC qcs_run_custom_preverify @v_bookkey, @v_preprocessSp, @o_error_code output, @o_error_desc output
  						
			  IF @o_error_code <> 0
			  BEGIN
				  --ERROR: call qutl_update_job for all jobkeys associated with this bookkey
				  SELECT @v_count = COUNT(*)
				  FROM @jobsforbook
  				
				  SELECT @v_min_jobkey = MIN(jobkey)
				  FROM @jobsforbook
  				
				  SET @v_index = 1
  				
				  WHILE (@v_index <= @v_count)
				  BEGIN
				    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey and bookkey = @v_bookkey
				  			                                               AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1

					  SET @v_msglongdesc = 'Error processing custom stored procedure during title verification ('
						  + CAST(COALESCE(@o_error_code, 0) as varchar) + ') ' + COALESCE(@o_error_desc, '')
					  SET @v_msgshortdesc = 'Error processing custom stored procedure during title verification'
  					
					  EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, @v_msgtype_error,
						  @v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output
  						
					  SET @v_index = @v_index + 1
  					
					  SELECT @v_min_jobkey = MIN(jobkey)
					  FROM @jobsforbook
					  WHERE jobkey > @v_min_jobkey
				  END
  IF @v_debug = 1 BEGIN				
    print 'here1'			
  END	
          -- no more processing should be done for this title - remove from @work and cloudsendstaging				
	        DELETE FROM cloudsendstaging
	        WHERE id IN
		        (SELECT parentid
		           FROM @work 
		          WHERE bookkey =  @v_bookkey)
  		        
	        DELETE FROM @work
	        WHERE bookkey = @v_bookkey
  		        
  			  goto next_title  --move on to next title
			  END
		  END --end preprocess
  		
		  ----------------------------------------
		  --Run title verification for the title--
		  ----------------------------------------
		  SET @v_customerkey = NULL
		  SELECT @v_customerkey = elocustomerkey FROM book WHERE bookkey = @v_bookkey	
  		
		  --Do we have a customer
		  IF ISNULL(@v_customerkey, 0) = 0
		  BEGIN
			  --ERROR: call qutl_update_job for all jobkeys associated with this bookkey
			  SELECT @v_count = COUNT(*)
			  FROM @jobsforbook
  			
			  SELECT @v_min_jobkey = MIN(jobkey)
			  FROM @jobsforbook
  			
			  SET @v_index = 1
  			
			  WHILE (@v_index <= @v_count)
			  BEGIN
  		    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey and bookkey = @v_bookkey
			  			                                               AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				  SET @v_msglongdesc = 'Title does not have a valid eloquence customer'
				  SET @v_msgshortdesc = NULL
  				
				  EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, NULL,
					  @v_msglongdesc, @v_msgshortdesc, @v_msg_nocustomer, NULL, @o_error_code output, @o_error_desc output
  					
				  SET @v_index = @v_index + 1
  				
				  SELECT @v_min_jobkey = MIN(jobkey)
				  FROM @jobsforbook
				  WHERE jobkey > @v_min_jobkey
			  END
  IF @v_debug = 1 BEGIN				
    print 'here2'	
  END						
        -- no more processing should be done for this title - remove from @work and cloudsendstaging				
        DELETE FROM cloudsendstaging
        WHERE id IN
	        (SELECT parentid
	           FROM @work 
	          WHERE bookkey =  @v_bookkey)
  	        
        DELETE FROM @work
        WHERE bookkey = @v_bookkey
  			
			  goto next_title  --move on to next title
		  END --end of Do we have a customer check
  		
		  --Run cs verification dynamically, procedure name is in variable @v_csverificationSp
		  SET @v_titleverifystatuscode = NULL
		  IF COALESCE(@v_csverificationSp, '') <> ''
		  BEGIN
        SET @v_sql = N'exec ' + @v_csverificationSp + 
          ' @BookKey, @PrintingKey, @VerificationType, @UserId, @SPError output, @SPErrorMessage output'
              
        EXECUTE sp_executesql @v_sql, 
          N'@BookKey int, 
            @PrintingKey int, @VerificationType int, 
            @UserId varchar(30), @SPError int output, @SPErrorMessage varchar(2000) output', 
          @BookKey = @v_bookkey, 
          @PrintingKey = 1, @VerificationType = @v_csverificationtypecode, 
          @UserId = 'qsidba', @SPError = @o_error_code output, @SPErrorMessage = @o_error_desc output

        IF @@ERROR <> 0 
			  BEGIN
				  --SET @o_error_code = -1
				  --SET @o_error_desc = 'Error executing verification stored procedure: ' + @v_csverificationSp
				  --	+ ', inner error: ' + COALESCE(@o_error_desc, 'none')
  			  --goto next_title  --move on to next title
    			
			    SELECT @v_count = COUNT(*)
			    FROM @jobsforbook
    			
			    SELECT @v_min_jobkey = MIN(jobkey)
			    FROM @jobsforbook
    			
			    SET @v_index = 1
    			
			    WHILE (@v_index <= @v_count)
			    BEGIN
    		    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey and bookkey = @v_bookkey
	  		  			                                               AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				    SET @v_msglongdesc = 'Error executing verification stored procedure: ' + @v_csverificationSp
					    + ', inner error: ' + COALESCE(@o_error_desc, 'none')
				    SET @v_msgshortdesc = 'Error executing verification stored procedure: ' + @v_csverificationSp
    				
				    EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, @v_msgtype_error,
					    @v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output
    					
				    SET @v_index = @v_index + 1
    				
				    SELECT @v_min_jobkey = MIN(jobkey)
				    FROM @jobsforbook
				    WHERE jobkey > @v_min_jobkey
          END

          -- no more processing should be done for this title - remove from @work and cloudsendstaging				
	        DELETE FROM cloudsendstaging
	        WHERE id IN
		        (SELECT parentid
		           FROM @work 
		          WHERE bookkey =  @v_bookkey)
  		        
	        DELETE FROM @work
	        WHERE bookkey = @v_bookkey

  			  goto next_title  --move on to next title			
			  END
  			
			  SELECT @v_titleverifystatuscode = titleverifystatuscode
			  FROM bookverification
			  WHERE bookkey = @v_bookkey
				  AND verificationtypecode = @v_csverificationtypecode
		  END
  		
		  --Check CS Approval Code...
		  IF ([dbo].qcs_get_csapproved(@v_bookkey) <> 1)
		  BEGIN
			  --ERROR: call qutl_update_job for all jobkeys associated with this bookkey
			  SELECT @v_count = COUNT(*)
			  FROM @jobsforbook
  			
			  SELECT @v_min_jobkey = MIN(jobkey)
			  FROM @jobsforbook
  			
			  SET @v_index = 1
  			
			  WHILE (@v_index <= @v_count)
			  BEGIN
  		    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey and bookkey = @v_bookkey
			  			                                               AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				  SET @v_msglongdesc = 'Title is not approved for the cloud'
				  SET @v_msgshortdesc = NULL
  				
				  EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, NULL,
					  @v_msglongdesc, @v_msgshortdesc, @v_msg_unapproved, NULL, @o_error_code output, @o_error_desc output
  					
				  SET @v_index = @v_index + 1
  				
				  SELECT @v_min_jobkey = MIN(jobkey)
				  FROM @jobsforbook
				  WHERE jobkey > @v_min_jobkey
			  END
  			
  IF @v_debug = 1 BEGIN				
    print 'here3 ' + cast(@v_bookkey as varchar)	
  END			

        -- no more processing should be done for this title - remove from @work and cloudsendstaging				
        DELETE FROM cloudsendstaging
        WHERE id IN
	        (SELECT parentid
	           FROM @work 
	          WHERE bookkey =  @v_bookkey)
  	        
        DELETE FROM @work
        WHERE bookkey = @v_bookkey
  			
			  goto next_title  --move on to next title
		  END
  		
		  --if title fails verification
		  IF @v_titleverifystatuscode = @v_csverify_failed
		  BEGIN
			  --ERROR: call qutl_update_job for all jobkeys associated with this bookkey
			  SELECT @v_count = COUNT(*)
			  FROM @jobsforbook
  			
			  SELECT @v_min_jobkey = MIN(jobkey)
			  FROM @jobsforbook
  			
			  SET @v_index = 1
  			
			  WHILE (@v_index <= @v_count)
			  BEGIN
  		    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey and bookkey = @v_bookkey
			  			                                               AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				  SET @v_msglongdesc = 'Title Failed Verification; please see verification messages for details'
				  SET @v_msgshortdesc = NULL
  				
				  EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, @v_msgtype_error,
					  @v_msglongdesc, @v_msgshortdesc, @v_msg_failedver, 2, @o_error_code output, @o_error_desc output
  					
				  SET @v_index = @v_index + 1
  				
				  SELECT @v_min_jobkey = MIN(jobkey)
				  FROM @jobsforbook
				  WHERE jobkey > @v_min_jobkey
			  END
  IF @v_debug = 1 BEGIN				
    print 'here4'				
  END
        -- no more processing should be done for this title - remove from @work and cloudsendstaging				
        DELETE FROM cloudsendstaging
        WHERE id IN
	        (SELECT parentid
	           FROM @work 
	          WHERE bookkey =  @v_bookkey)
  	        
        DELETE FROM @work
        WHERE bookkey = @v_bookkey
  			
			  goto next_title  --move on to next title
		  END
  		
		  --if title passes verification but with warnings
		  IF @v_titleverifystatuscode = @v_csverify_warnings
		  BEGIN
			  --ERROR: call qutl_update_job for all jobkeys associated with this bookkey
			  SELECT @v_count = COUNT(*)
			  FROM @jobsforbook
  			
			  SELECT @v_min_jobkey = MIN(jobkey)
			  FROM @jobsforbook
  			
			  SET @v_index = 1
  			
			  WHILE (@v_index <= @v_count)
			  BEGIN
  		    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey and bookkey = @v_bookkey
			  			                                               AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				  SET @v_msglongdesc = 'Title passed Verification but had warnings; please see verification messages for details'
				  SET @v_msgshortdesc = NULL
  				
				  EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, @v_msgtype_warning,
					  @v_msglongdesc, @v_msgshortdesc, @v_msg_verwarning, 3, @o_error_code output, @o_error_desc output
  					
				  SET @v_index = @v_index + 1
  				
				  SELECT @v_min_jobkey = MIN(jobkey)
				  FROM @jobsforbook
				  WHERE jobkey > @v_min_jobkey
			  END
  IF @v_debug = 1 BEGIN				
    print 'here5'				
  END
		  END
  		
  next_title:		
  			
		  SET @v_idx = @v_idx + 1
  				
	    SELECT @v_min_bookkey = MIN(bookkey)
	    FROM @work
	    WHERE validind = 1
		    AND ISNULL(jobstartind, 0) <> 1
		    AND ISNULL(jobendind, 0) <> 1
			  AND bookkey > @v_min_bookkey
    END
      	
    -- status message      	
    SELECT @v_count = COUNT(*)
    FROM @alljobs
		
    SELECT @v_min_jobkey = MIN(jobkey)
    FROM @alljobs
		
    SET @v_index = 1
		
    WHILE (@v_index <= @v_count)
    BEGIN
	    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
	    SET @v_msglongdesc = 'Title Verification Process Finished'
	    SET @v_msgshortdesc = 'Title Verification Process Finished'
			
	    EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_info,
		    @v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output
				
	    SET @v_index = @v_index + 1
			
	    SELECT @v_min_jobkey = MIN(jobkey)
	    FROM @alljobs
	    WHERE jobkey > @v_min_jobkey
    END
      	
	  -----------------------------------------------
	  --Determine Valid Assets for Customer/Partner--
	  -----------------------------------------------
    IF @v_debug = 1 BEGIN					
	    select 0,* from @work
	    --where bookkey = 1821572
    END
  	
	  --Flesh out distribution templates into the corresponding partnercontactkeys and put them into the @work table
	  --grab partners specifically named in the template and add to @work table
	  INSERT INTO @work
	  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	  SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, w.elementkey, NULL, dtp.partnercontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	  FROM csdistributiontemplatepartner dtp
	  JOIN globalcontact gc
	  ON dtp.partnercontactkey = gc.globalcontactkey
	  JOIN @work w
	  ON dtp.templatekey = w.csdisttemplatekey
	  JOIN customerpartner cp
	  ON w.customerkey = cp.customerkey
		  AND gc.globalcontactkey = cp.partnercontactkey
	  WHERE dtp.partnercontactkey > 0
		  AND w.csdisttemplatekey > 0
		  AND coalesce(w.partnercontactkey,0) = 0
		  AND w.validind = 1
		  AND ISNULL(w.jobstartind, 0) <> 1
		  AND ISNULL(w.jobendind, 0) <> 1
		  --AND w.jobkey = @v_jobkey
		  --AND w.bookkey = @v_bookkey
		  AND w.elementkey > 0
  	
    IF @v_debug = 1 BEGIN					
	    select 1,* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END
  	
	  --then grab partners by their distributiontype and add to @work table
	  INSERT INTO @work
	  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	  SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, w.elementkey, NULL, cp.partnercontactkey globalcontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	  FROM csdistributiontemplatepartner dtp
	  JOIN @work w 
	  ON dtp.templatekey = w.csdisttemplatekey
	  JOIN customerpartner cp
	  ON w.customerkey = cp.customerkey
		  AND dtp.distributiontypecode = cp.distributiontype
	  WHERE coalesce(dtp.partnercontactkey,0) = 0
		  AND w.validind = 1
		  AND ISNULL(w.jobstartind, 0) <> 1
		  AND ISNULL(w.jobendind, 0) <> 1
		  --AND w.jobkey = @v_jobkey
		  --AND w.bookkey = @v_bookkey
		  AND w.csdisttemplatekey > 0
		  AND coalesce(w.partnercontactkey,0) = 0
		  AND w.elementkey > 0

    IF @v_debug = 1 BEGIN					
	    select 2,* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END
  	
	  -- no asset selected - need to try all approved assets and metadata (even if not approved) for the title
	  -- grab partners/assets specifically named in the template and add to @work table
	  INSERT INTO @work
	  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	  SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, tpe.taqelementkey, NULL, dtp.partnercontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	  FROM csdistributiontemplatepartner dtp
	  JOIN globalcontact gc
	  ON dtp.partnercontactkey = gc.globalcontactkey
	  JOIN @work w
	  ON dtp.templatekey = w.csdisttemplatekey
	  JOIN customerpartner cp
	  ON w.customerkey = cp.customerkey
		  AND gc.globalcontactkey = cp.partnercontactkey
	  JOIN taqprojectelement tpe
	  ON w.bookkey = tpe.bookkey
		  AND ((tpe.elementstatus = @v_approvedstatuscode AND tpe.taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1)) OR
		       (COALESCE(tpe.elementstatus,0) <> @v_approvedstatuscode AND tpe.taqelementtypecode = @v_metadata_asset))
	  WHERE dtp.partnercontactkey > 0
		  AND w.csdisttemplatekey > 0
		  AND coalesce(w.partnercontactkey,0) = 0
		  AND w.validind = 1
		  AND ISNULL(w.jobstartind, 0) <> 1
		  AND ISNULL(w.jobendind, 0) <> 1
		  --AND w.jobkey = @v_jobkey
		  --AND w.bookkey = @v_bookkey
		  AND coalesce(w.elementkey,0) = 0
  	
    IF @v_debug = 1 BEGIN					
	    select 3,* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END
  	
	  -- then grab partners/assets by their distributiontype and add to @work table
	  INSERT INTO @work
	  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	  SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, tpe.taqelementkey, NULL, cp.partnercontactkey globalcontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	  FROM csdistributiontemplatepartner dtp
	  JOIN @work w 
	  ON dtp.templatekey = w.csdisttemplatekey
	  JOIN customerpartner cp
	  ON w.customerkey = cp.customerkey
		  AND dtp.distributiontypecode = cp.distributiontype
	  JOIN taqprojectelement tpe
	  ON w.bookkey = tpe.bookkey
		  AND ((tpe.elementstatus = @v_approvedstatuscode AND tpe.taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1)) OR
		       (COALESCE(tpe.elementstatus,0) <> @v_approvedstatuscode AND tpe.taqelementtypecode = @v_metadata_asset))
	  WHERE coalesce(dtp.partnercontactkey,0) = 0
		  AND w.validind = 1
		  AND ISNULL(w.jobstartind, 0) <> 1
		  AND ISNULL(w.jobendind, 0) <> 1
		  --AND w.jobkey = @v_jobkey
		  --AND w.bookkey = @v_bookkey
		  AND w.csdisttemplatekey > 0
		  AND coalesce(w.partnercontactkey,0) = 0
		  AND coalesce(w.elementkey,0) = 0

    IF @v_debug = 1 BEGIN					
	    select 4,* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END
      
	  -- no asset selected - need to add metadata for all titles that have not sent it before
	  -- grab partners/assets specifically named in the template and add to @work table
	  INSERT INTO @work
	  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	  SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, 0, NULL, dtp.partnercontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	  FROM csdistributiontemplatepartner dtp
	  JOIN globalcontact gc
	  ON dtp.partnercontactkey = gc.globalcontactkey
	  JOIN @work w
	  ON dtp.templatekey = w.csdisttemplatekey
	  JOIN customerpartner cp
	  ON w.customerkey = cp.customerkey
		  AND gc.globalcontactkey = cp.partnercontactkey
	  WHERE dtp.partnercontactkey > 0
		  AND w.csdisttemplatekey > 0
		  AND coalesce(w.partnercontactkey,0) = 0
		  AND w.validind = 1
		  AND ISNULL(w.jobstartind, 0) <> 1
		  AND ISNULL(w.jobendind, 0) <> 1
		  --AND w.jobkey = @v_jobkey
		  --AND w.bookkey = @v_bookkey
		  AND coalesce(w.elementkey,0) = 0
		  AND not exists (select * from taqprojectelement tpe where tpe.bookkey = w.bookkey and tpe.taqelementtypecode = @v_metadata_asset)
  	
    IF @v_debug = 1 BEGIN					
	    select '3A',* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END
      
	  -- then grab partners/assets by their distributiontype and add to @work table - metatdata
	  INSERT INTO @work
	  (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	  SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, 0, NULL, cp.partnercontactkey globalcontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	  FROM csdistributiontemplatepartner dtp
	  JOIN @work w 
	  ON dtp.templatekey = w.csdisttemplatekey
	  JOIN customerpartner cp
	  ON w.customerkey = cp.customerkey
		  AND dtp.distributiontypecode = cp.distributiontype
	  WHERE coalesce(dtp.partnercontactkey,0) = 0
		  AND w.validind = 1
		  AND ISNULL(w.jobstartind, 0) <> 1
		  AND ISNULL(w.jobendind, 0) <> 1
		  --AND w.jobkey = @v_jobkey
		  --AND w.bookkey = @v_bookkey
		  AND w.csdisttemplatekey > 0
		  AND coalesce(w.partnercontactkey,0) = 0
		  AND coalesce(w.elementkey,0) = 0
		  AND not exists (select * from taqprojectelement tpe where tpe.bookkey = w.bookkey and tpe.taqelementtypecode = @v_metadata_asset)

    IF @v_debug = 1 BEGIN					
	    select '4A',* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END
         
    -- status message      	
    IF @v_debug = 1
    BEGIN
			SELECT @v_count = COUNT(*)
			FROM @alljobs
			
			SELECT @v_min_jobkey = MIN(jobkey)
			FROM @alljobs
			
			SET @v_index = 1
			
			WHILE (@v_index <= @v_count)
			BEGIN
				SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				SET @v_msglongdesc = 'Begin Validating Assets/Partners/Formats'
				SET @v_msgshortdesc = 'Begin Validating Assets/Partners/Formats'
				
				EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_info,
					@v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output
					
				SET @v_index = @v_index + 1
				
				SELECT @v_min_jobkey = MIN(jobkey)
				FROM @alljobs
				WHERE jobkey > @v_min_jobkey
			END
    END
         
	  --Create temp table to store records for better files found for hierarchy
	  CREATE TABLE #betterfiles
	  (
		  id	uniqueidentifier NOT NULL PRIMARY KEY,
		  jobkey	int NULL,
		  bookkey	int NULL,
		  elementkey	int NULL,
		  partnercontactkey	int NULL
	  )
  	  
	  DECLARE bookjob_cursor CURSOR FOR
	  SELECT DISTINCT jobkey, bookkey
	  FROM @work
	  WHERE validind = 1
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
  		
	  OPEN bookjob_cursor
  	
	  FETCH bookjob_cursor
	  INTO @v_jobkey, @v_bookkey
  	
	  --weed out invalid rows in work table based on job/bookkey
	  WHILE (@@FETCH_STATUS = 0)
	  BEGIN
      IF @v_debug = 1 BEGIN
        --IF @v_bookkey = 1821572 BEGIN
	        select 5,* from @work
	        --where bookkey = 1821572
	        order by bookkey, partnercontactkey, elementkey
        --END
      END
		  --Invalidate any named partners if they aren't valid for the customer
		  UPDATE @work
		  SET validind = 0
		  WHERE partnercontactkey IS NOT NULL
      AND jobkey = @v_jobkey
		  AND bookkey = @v_bookkey
		  AND id NOT IN
			  (SELECT w.id
			  FROM @work w
			  JOIN customerpartner cp
			  ON w.partnercontactkey = cp.partnercontactkey
				  AND w.customerkey = cp.customerkey
			  WHERE w.validind = 1
				  AND w.jobkey = @v_jobkey
				  AND w.bookkey = @v_bookkey)

      IF @v_debug = 1 BEGIN
        --IF @v_bookkey = 1821572 BEGIN
	        select 6,* from @work
	        --where bookkey = 1821572
	        order by bookkey, partnercontactkey, elementkey
        --END
      END			
      			   
		  ----marry up the formats to the partners		   		    			  
	    UPDATE @work
	    SET validind = 0  --, messagecode = @v_msg_withcsformat, messagedesc = 'Format for the title is not accepted by the partner'
	    WHERE jobkey = @v_jobkey
	    AND bookkey = @v_bookkey
	    AND partnercontactkey > 0
	    AND id NOT IN
		    (SELECT w.id
		    FROM cspartnerformat cpf
		    JOIN bookdetail bd
		    ON cpf.mediacode = bd.mediatypecode
		    AND cpf.mediasubcode = bd.mediatypesubcode
		    JOIN @work w
		    ON w.bookkey = bd.bookkey 
			    AND cpf.partnercontactkey = w.partnercontactkey
			    AND cpf.customerkey = w.customerkey
		    JOIN customerpartner cp
		    ON w.customerkey = cp.customerkey
			    AND cpf.partnercontactkey = cp.partnercontactkey
			    AND cpf.customerkey = cp.customerkey
		    WHERE w.validind = 1
			    AND w.jobkey = @v_jobkey
			    AND w.bookkey = @v_bookkey
			    AND w.partnercontactkey > 0)
      
      IF @v_debug = 1 BEGIN		
        --IF @v_bookkey = 1821572 BEGIN
	        select 7,* from @work
	        --where bookkey = 1821572
	        order by bookkey, partnercontactkey, elementkey
        ---END
      END		
      
		  --invalidate any non-approved assets
		  --unapproved metadata asset is ok as long as the title is approved for CS
		  UPDATE @work
		  SET validind = 0
		  WHERE elementkey > 0 
		  AND jobkey = @v_jobkey
		  AND bookkey = @v_bookkey
		  AND id NOT IN
			  (SELECT w.id
			  FROM taqprojectelement tpe
			  JOIN @work w
			  ON tpe.taqelementkey = w.elementkey
			  WHERE w.validind = 1
				  AND (tpe.elementstatus = @v_approvedstatuscode OR COALESCE(tpe.taqelementtypecode,0) = @v_metadata_asset)				
				  AND w.elementkey > 0
				  AND w.jobkey = @v_jobkey
				  AND w.bookkey = @v_bookkey)
  		
      IF @v_debug = 1 BEGIN
        --IF @v_bookkey = 1821572 BEGIN
	        select 8,* from @work
	        --where bookkey = 1821572
	        order by bookkey, partnercontactkey, elementkey
        --END
      END
  		
		  --then marry up assets for partner/title combos that are still valid
		  UPDATE @work
		  SET validind = 0
		  WHERE elementkey > 0 
		  AND jobkey = @v_jobkey
		  AND bookkey = @v_bookkey
		  AND id NOT IN
			  (SELECT w.id
			  FROM @work w
			  JOIN taqprojectelement tpe
			  ON w.elementkey = tpe.taqelementkey 
			  JOIN customerpartnerassets cpa
			  ON w.customerkey = cpa.customerkey
				  AND w.partnercontactkey = cpa.partnercontactkey
				  AND (tpe.taqelementtypecode = cpa.assettypecode)
			  WHERE w.jobkey = @v_jobkey
				  AND w.bookkey = @v_bookkey
				  AND w.elementkey > 0
				  AND w.validind = 1)
  				
      IF @v_debug = 1 BEGIN				
        --IF @v_bookkey = 1821572 BEGIN
	        select 9,* from @work
	        --where bookkey = 1821572
	        order by bookkey, partnercontactkey, elementkey
        --END
      END

      -- make sure the partners accept metadata
		  UPDATE @work
		  SET validind = 0, messagedesc = 'Metadata asset is not accepted by the partner', messagecode = null
		  WHERE COALESCE(elementkey,0) = 0
		  AND jobkey = @v_jobkey
		  AND bookkey = @v_bookkey
      AND validind = 1
		  AND id NOT IN
			  (SELECT w.id
			  FROM @work w
			  JOIN customerpartnerassets cpa
			  ON w.customerkey = cpa.customerkey
				  AND w.partnercontactkey = cpa.partnercontactkey
				  AND (cpa.assettypecode = @v_metadata_asset)
			  WHERE w.jobkey = @v_jobkey
				  AND w.bookkey = @v_bookkey
				  AND COALESCE(w.elementkey,0) = 0
				  AND w.partnercontactkey > 0
				  AND w.validind = 1)
  				
      IF @v_debug = 1 BEGIN				
        --IF @v_bookkey = 1821572 BEGIN
	        select '9A',* from @work
	        --where bookkey = 1821572
	        order by bookkey, partnercontactkey, elementkey
        --END
      END
  				
		  --next apply asset file hierarchy - priority 1 is highest priority		
		  -- do not send an asset that has an approved higher priority asset 
		  INSERT INTO #betterfiles
		  SELECT DISTINCT w.id, w.jobkey, w.bookkey, w.elementkey, w.partnercontactkey
		  FROM @work w 
		  JOIN taqprojectelement tpe
		  ON w.bookkey = tpe.bookkey
			  AND w.elementkey = tpe.taqelementkey
		  JOIN customerpartnerassets cpa
		  ON w.customerkey = cpa.customerkey
			  AND w.partnercontactkey = cpa.partnercontactkey
			  AND tpe.taqelementtypecode = cpa.assettypecode		--up to here pulling rows requested to be sent
		  JOIN customerpartnerassets cpa2						--from here down, look for better assets on title
		  ON cpa.partnercontactkey = cpa2.partnercontactkey
			  AND cpa.assetcategory = cpa2.assetcategory
			  AND cpa.[priority] > cpa2.[priority]			--find other types that may have a higher priority than what is being sent
			  AND cpa.customerkey = cpa2.customerkey
		  JOIN taqprojectelement tpe2
		  ON tpe2.bookkey = tpe.bookkey
			  AND cpa2.assettypecode = tpe2.taqelementtypecode
			  AND tpe2.elementstatus = @v_approvedstatuscode
		  WHERE w.jobkey = @v_jobkey
			  AND w.bookkey = @v_bookkey
			  AND w.validind = 1
			  AND w.elementkey > 0 
			  AND cpa.[priority] > 1
  		
		  FETCH bookjob_cursor
		  INTO @v_jobkey, @v_bookkey
	  END
  	
	  CLOSE bookjob_cursor
	  DEALLOCATE bookjob_cursor
  		
    -- status message      	
    SELECT @v_count = COUNT(*)
    FROM @alljobs
		
    SELECT @v_min_jobkey = MIN(jobkey)
    FROM @alljobs
		
    SET @v_index = 1
		
    WHILE (@v_index <= @v_count)
    BEGIN
	    SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
	    SET @v_msglongdesc = 'Done Validating Assets/Partners/Formats'
	    SET @v_msgshortdesc = 'Done Validating Assets/Partners/Formats'
			
	    EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_info,
		    @v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output
				
	    SET @v_index = @v_index + 1
			
	    SELECT @v_min_jobkey = MIN(jobkey)
	    FROM @alljobs
	    WHERE jobkey > @v_min_jobkey
    END
  	
    -- status message      	
    IF @v_debug = 1
    BEGIN
			SELECT @v_count = COUNT(*)
			FROM @alljobs
			
			SELECT @v_min_jobkey = MIN(jobkey)
			FROM @alljobs
			
			SET @v_index = 1
			
			WHILE (@v_index <= @v_count)
			BEGIN
				SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				SET @v_msglongdesc = 'Applying File Hierarchy'
				SET @v_msgshortdesc = 'Applying File Hierarchy'
				
				EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_info,
					@v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output
					
				SET @v_index = @v_index + 1
				
				SELECT @v_min_jobkey = MIN(jobkey)
				FROM @alljobs
				WHERE jobkey > @v_min_jobkey
			END
    END
  		
	  UPDATE @work
	  SET validind = 0, betterfileind = 1
	  WHERE id IN
		  (SELECT w.id
		  FROM @work w
		  JOIN #betterfiles bf
		  ON w.id = bf.id
			  AND w.jobkey = bf.jobkey
			  AND w.bookkey = bf.bookkey
			  AND w.elementkey = bf.elementkey
			  AND w.partnercontactkey = bf.partnercontactkey)
  	
    IF @v_debug = 1 BEGIN
      --IF @v_bookkey = 1821572 BEGIN
        select 11,* from @work
        --where bookkey = 1821572
        order by bookkey, partnercontactkey, elementkey
      --END
    END
  	
	  -- set the assets that have a higher priority asset to do not send in the future
	  DECLARE donotsendagain_cursor CURSOR FAST_FORWARD FOR
	  SELECT DISTINCT bf.bookkey, bf.partnercontactkey, bf.elementkey, w.lastuserid
	  FROM @work w, #betterfiles bf
	  WHERE w.id = bf.id 
		  AND w.jobkey = bf.jobkey
		  AND w.bookkey = bf.bookkey
		  AND w.elementkey = bf.elementkey
		  AND w.partnercontactkey = bf.partnercontactkey
  		
	  OPEN donotsendagain_cursor
  	
	  FETCH donotsendagain_cursor
	  INTO @v_bookkey, @v_partnercontactkey, @v_elementkey, @v_lastuserid
  	
	  WHILE (@@FETCH_STATUS = 0)
	  BEGIN
      UPDATE taqprojectelementpartner
      SET resendind = 0, lastuserid = @v_lastuserid, lastmaintdate = GETDATE()
      WHERE bookkey = @v_bookkey
      AND partnercontactkey = @v_partnercontactkey
      AND assetkey = @v_elementkey
      
      -- remove title from outbox
      exec qtitle_set_cspartnerstatuses_on_title @v_bookkey,@v_lastuserid,@o_error_code output,@o_error_desc output
      
      IF @o_error_code < 0 BEGIN
		    SET @v_msglongdesc = 'Error processing qtitle_set_cspartnerstatuses_on_title checking file priority ('
			    + CAST(COALESCE(@o_error_code, 0) as varchar) + ') ' + COALESCE(@o_error_desc, '')
		    SET @v_msgshortdesc = 'Error processing qtitle_set_cspartnerstatuses_on_title checking file priority'
    		
		    EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, @v_msgtype_error,
			    @v_msglongdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output
      END
          
	    FETCH donotsendagain_cursor
  	  INTO @v_bookkey, @v_partnercontactkey, @v_elementkey, @v_lastuserid
	  END
  	
	  CLOSE donotsendagain_cursor
	  DEALLOCATE donotsendagain_cursor

	  -- These checks must be after all partner/asset rows have been added and validated from distribution templates 
	  -- make sure metadata is being sent for all titles to partners that accept it
	  DECLARE metadata_cursor CURSOR FAST_FORWARD FOR
	  SELECT DISTINCT w.jobkey, w.bookkey
	  FROM @work w
	  WHERE validind = 1
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
		  AND w.partnercontactkey > 0
		  AND w.elementkey > 0
  		
	  OPEN metadata_cursor
  	
	  FETCH metadata_cursor
	  INTO @v_jobkey, @v_bookkey
  	
	  WHILE (@@FETCH_STATUS = 0)
	  BEGIN
	    SELECT @v_metadata_elementkey = tpe.taqelementkey
	      FROM taqprojectelement tpe
	     WHERE tpe.bookkey = @v_bookkey 
	       and tpe.taqelementtypecode = @v_metadata_asset
  	   
	    IF @v_metadata_elementkey > 0 BEGIN
	      -- metadata has been sent before for this title - make sure it is being sent to all partners that accept it for this send
	      INSERT INTO @work
	      (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	      SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, @v_metadata_elementkey, NULL, w.partnercontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	      FROM @work w
			  JOIN customerpartnerassets cpa
			  ON w.customerkey = cpa.customerkey
				  AND w.partnercontactkey = cpa.partnercontactkey
				  AND (cpa.assettypecode = @v_metadata_asset)
	      WHERE coalesce(w.partnercontactkey,0) > 0
		      AND w.validind = 1
		      AND ISNULL(w.jobstartind, 0) <> 1
		      AND ISNULL(w.jobendind, 0) <> 1
		      AND w.jobkey = @v_jobkey
		      AND w.bookkey = @v_bookkey
		      AND @v_metadata_elementkey not in (select distinct elementkey from @work where bookkey = @v_bookkey AND w.jobkey = @v_jobkey AND partnercontactkey = w.partnercontactkey)
	    END
	    ELSE BEGIN
	      -- metadata has not been sent before for this title - make sure it is being sent to all partners that accept it for this send
	      INSERT INTO @work
	      (id, parentid, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, validind, betterfileind, lastuserid, lastmaintdate)
	      SELECT NEWID(), w.id, w.jobkey, w.bookkey, w.customerkey, 0, NULL, w.partnercontactkey, w.processstatuscode, NULL, NULL, 1, 0, w.lastuserid, GETDATE()
	      FROM @work w
			  JOIN customerpartnerassets cpa
			  ON w.customerkey = cpa.customerkey
				  AND w.partnercontactkey = cpa.partnercontactkey
				  AND (cpa.assettypecode = @v_metadata_asset)
	      WHERE coalesce(w.partnercontactkey,0) > 0
		      AND w.validind = 1
		      AND ISNULL(w.jobstartind, 0) <> 1
		      AND ISNULL(w.jobendind, 0) <> 1
		      AND w.jobkey = @v_jobkey
		      AND w.bookkey = @v_bookkey
	    END
  	
	    FETCH metadata_cursor
	    INTO @v_jobkey, @v_bookkey
    END
    
    CLOSE metadata_cursor
	  DEALLOCATE metadata_cursor
    
    IF @v_debug = 1 BEGIN					
	    select '12',* from @work
	    --where bookkey = 1821572
      order by bookkey, partnercontactkey, elementkey
    END

    -- status message      	
    IF @v_debug = 1
    BEGIN
			SELECT @v_count = COUNT(*)
			FROM @alljobs
			
			SELECT @v_min_jobkey = MIN(jobkey)
			FROM @alljobs
			
			SET @v_index = 1
			
			WHILE (@v_index <= @v_count)
			BEGIN
				SELECT top 1 @v_lastuserid = lastuserid FROM @work WHERE jobkey = @v_min_jobkey AND ISNULL(jobstartind, 0) <> 1 AND ISNULL(jobendind, 0) <> 1
				SET @v_msglongdesc = 'Inserting to cloudsendpublish'
				SET @v_msgshortdesc = 'Inserting to cloudsendpublish'
				
				EXEC qutl_update_job NULL, @v_min_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, 0, 0, 0, @v_msgtype_info,
					@v_msglongdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output
					
				SET @v_index = @v_index + 1
				
				SELECT @v_min_jobkey = MIN(jobkey)
				FROM @alljobs
				WHERE jobkey > @v_min_jobkey
			END
    END

	  --Insert anything left that is valid on @work table into cloudsendpublish
	  INSERT INTO cloudsendpublish
	  (jobkey, bookkey, customerkey, elementkey, partnercontactkey, sendpriority, processstatuscode, numberofattempts, jobendind, lastuserid, lastmaintdate)
	  SELECT jobkey, bookkey, customerkey, elementkey, partnercontactkey, 1, @i_publishtablestatuscode, NULL, NULL, lastuserid, GETDATE()
	  FROM @work
	  WHERE validind = 1
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
		  AND partnercontactkey > 0
  	
	  --Insert message rows for invalid @work rows
	  SET @v_count = NULL
	  SET @v_jobkey = NULL
	  SET @v_bookkey = NULL
	  SET @v_partnercontactkey = NULL
	  SET @v_betterfileind = NULL
  	
	  --write out specific partner error msgs
	  DECLARE specific_message_cursor CURSOR FAST_FORWARD FOR
	  SELECT DISTINCT jobkey, bookkey, partnercontactkey, messagecode, messagedesc, lastuserid
	  FROM @work
	  WHERE validind = 0
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
		  AND (messagecode > 0 OR COALESCE(messagedesc,'') <> '')
		  AND partnercontactkey > 0
		  AND COALESCE(betterfileind,0) = 0
  		
	  OPEN specific_message_cursor
  	
	  FETCH specific_message_cursor
	  INTO @v_jobkey, @v_bookkey, @v_partnercontactkey, @v_messagecode, @v_messagedesc, @v_lastuserid
  	
	  WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		  SET @v_msglongdesc = @v_messagedesc
		  SET @v_msgshortdesc = SUBSTRING(@v_messagedesc,0,255)
  		
		  EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, @v_partnercontactkey, NULL,
				  @v_msglongdesc, @v_msgshortdesc, @v_messagecode, NULL, @o_error_code output, @o_error_desc output

	    FETCH specific_message_cursor
		  INTO @v_jobkey, @v_bookkey, @v_partnercontactkey, @v_messagecode, @v_messagedesc, @v_lastuserid
	  END
  	
	  CLOSE specific_message_cursor
	  DEALLOCATE specific_message_cursor

    -- check for no assets accepted msg
	  DECLARE message_cursor CURSOR FAST_FORWARD FOR
	  SELECT DISTINCT jobkey, bookkey, betterfileind, lastuserid
	  FROM @work
	  WHERE validind = 0
		  AND COALESCE(betterfileind,0) = 0
		  AND ISNULL(jobstartind, 0) <> 1
		  AND ISNULL(jobendind, 0) <> 1
  		
	  OPEN message_cursor
  	
	  FETCH message_cursor
	  INTO @v_jobkey, @v_bookkey, @v_betterfileind, @v_lastuserid
  	
	  WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		  --If it is discovered that there are no valid assets to send for a title, create job message
		  SELECT @v_count = COUNT(*)
		  FROM @work
		  WHERE validind = 1
			  AND ISNULL(jobstartind, 0) <> 1
			  AND ISNULL(jobendind, 0) <> 1
			  AND jobkey = @v_jobkey
			  AND bookkey = @v_bookkey
  			
		  IF @v_count = 0
		  BEGIN
			  SET @v_msglongdesc = 'Title had no assets accepted for the partners selected'
			  SET @v_msgshortdesc = NULL
  			
			  EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_lastuserid, @v_bookkey, 0, 0, NULL,
					  @v_msglongdesc, @v_msgshortdesc, @v_msg_noassets, NULL, @o_error_code output, @o_error_desc output
		  END
  		
		  FETCH message_cursor
		  INTO @v_jobkey, @v_bookkey, @v_betterfileind, @v_lastuserid
	  END
  	
	  CLOSE message_cursor
	  DEALLOCATE message_cursor
  	
	  ------------------
	  --JOBENDIND JOBS--
	  ------------------
	  DECLARE jobend_cursor CURSOR FOR
	  SELECT id, jobkey, bookkey, customerkey, elementkey, csdisttemplatekey, partnercontactkey, processstatuscode, jobstartind, jobendind, 
	         validind, betterfileind, lastuserid, lastmaintdate
	  FROM @work
	  WHERE validind = 1
		  AND jobendind = 1
  	
	  OPEN jobend_cursor
  	
	  FETCH jobend_cursor
	  INTO @v_id, @v_jobkey, @v_bookkey, @v_customerkey, @v_elementkey, @v_csdisttemplatekey, @v_partnercontactkey, @v_processstatuscode,
				  @v_jobstartind, @v_jobendind, @v_validind, @v_betterfileind, @v_lastuserid, @v_lastmaintdate

	  WHILE (@@FETCH_STATUS = 0)
    BEGIN
		  INSERT INTO cloudsendpublish
		  (jobkey, bookkey, customerkey, elementkey, partnercontactkey, sendpriority, processstatuscode, numberofattempts, jobendind, lastuserid, lastmaintdate)
		  VALUES
		  (@v_jobkey, NULL, NULL, NULL, NULL, NULL, @i_publishtablestatuscode, NULL, @v_jobendind, @v_lastuserid, GETDATE())
  		
		  FETCH jobend_cursor
		  INTO @v_id, @v_jobkey, @v_bookkey, @v_customerkey, @v_elementkey, @v_csdisttemplatekey, @v_partnercontactkey, @v_processstatuscode,
					  @v_jobstartind, @v_jobendind, @v_validind, @v_betterfileind, @v_lastuserid, @v_lastmaintdate
    END
    
    CLOSE jobend_cursor
	  DEALLOCATE jobend_cursor
  	
	  DELETE FROM cloudsendstaging
	  WHERE id IN
		  (SELECT parentid
		  FROM @work)
		  --WHERE validind = 1)
		  --	--AND ISNULL(jobstartind, 0) <> 1
		  --	--AND ISNULL(jobendind, 0) <> 1)
  	
	  DROP TABLE #betterfiles
  	
  	-- see if there are any more rows to process
	  IF ISNULL(@i_jobkey,0) = 0
	  BEGIN
		  SELECT @v_cloudsendstaging_count = count(*)
		  FROM cloudsendstaging css
		  LEFT OUTER JOIN book b
		  ON css.bookkey = b.bookkey
		  WHERE processstatuscode = @i_processstatuscode
	  END
	  ELSE BEGIN
		  SELECT @v_cloudsendstaging_count = count(*)
		  FROM cloudsendstaging css
		  LEFT OUTER JOIN book b
		  ON css.bookkey = b.bookkey
		  WHERE processstatuscode = @i_processstatuscode
			  AND jobkey = @i_jobkey
	  END
    
  END -- main loop	
GO

GRANT EXEC ON qcs_send_prepublish TO PUBLIC
GO