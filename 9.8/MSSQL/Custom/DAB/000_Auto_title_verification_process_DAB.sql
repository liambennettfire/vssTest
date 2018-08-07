if exists (select * from dbo.sysobjects where id = object_id(N'dbo.DAB_auto_title_verification_process') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.DAB_auto_title_verification_process
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE DAB_auto_title_verification_process
 (@i_backgroundprocesskey        integer,
  @o_error_code     integer output,
  @o_standardmsgcode integer output,
  @o_standardmsgsubcode integer output,
  @o_error_desc     varchar(2000) output)
AS
/*************************************************************************************************************
**  Name: DAB_Delivery_search_to_backgroundprocess
**  Desc: 
** 
**  Auth: Kusum Basra
**  Date: 1 June 2016
*************************************************************************************************************/

DECLARE
  @v_batchkey INT,
  @v_bookkey  INT,
  @v_printingkey INT,
  @v_backgroundprocesskey INT,
  @v_columnorderlist  VARCHAR(255),
  @v_curdatetime  VARCHAR(255),
  @v_error  INT,
  @v_errordesc  VARCHAR(2000),
  @v_jobdesc  VARCHAR(2000),
  @v_jobdescshort VARCHAR(255),
  @v_jobkey INT,
  @v_jobtype_autoverify INT,
  @v_listkey  INT,
  @v_msgdesc  VARCHAR(255),
  @v_msgtype_started  INT,
  @v_msgtype_error  INT,
  @v_numrows  INT,
  @v_partnercontactkey  INT,
  @v_rowcount INT,
  @v_searchcriteria_xml VARCHAR(MAX),
  @v_status_ready INT,
  @v_stylelist  VARCHAR(2000),
  @v_userid VARCHAR(30),
  @v_clientdefaultvalue INT,
  @v_dateformat_value VARCHAR(40),
  @v_dateformat_conversionvalue INT,
  @v_datacode INT,
  @v_startpos INT,
  @v_csverificationtypecode INT ,
  @v_stored_procedure VARCHAR(255),
  @v_customerkey INT,
  @v_msg_nocustomer	INT,
  @v_sql NVARCHAR(2000),
  @v_msgshortdesc VARCHAR(255),
  @v_titleverifystatuscode INT,
  @v_csverify_failed INT ,
  @v_msg_failedver INT,
  @v_msgtype_info INT,
  @v_msgtype_completed INT 
  
BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = ''
    SET @o_standardmsgcode = 0
    SET @o_standardmsgsubcode = 0
    
    
	SELECT @v_msgtype_started = datacode
	  FROM gentables
	  WHERE tableid = 539 AND qsicode = 1
	  
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error getting Message Type=Started from gentables 539.'
		RETURN 
	END
	  
	SELECT @v_msgtype_error = datacode
	  FROM gentables
	  WHERE tableid = 539 AND qsicode = 2
	  
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error getting Message Type=Error from gentables 539.'
		RETURN 
	END  
	  
	SELECT @v_jobtype_autoverify = datacode
	  FROM gentables
	  WHERE tableid = 543 AND qsicode = 18 --Auto Title Verification Job
	  
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error getting Job Type from gentables 543.'
		RETURN 
	END
	    
	SELECT @v_status_ready = datacode
	  FROM gentables
	  WHERE tableid = 652 AND qsicode = 1 --Ready to Automatically Process
	  
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error getting Auto Title Verification Process Status from gentables 652.'
		RETURN 
	END
	
	SELECT @v_csverify_failed = datacode FROM gentables WHERE tableid = 513 AND qsicode = 2 
	
	SELECT @v_msg_failedver = datacode FROM gentables WHERE tableid = 651 AND qsicode = 8  -- Title Failed Verification
	
	SELECT @v_msg_nocustomer = datacode FROM gentables WHERE tableid = 651 AND qsicode = 12 --No elo customer
	
	SELECT @v_msgtype_info = datacode FROM gentables WHERE tableid = 539 AND qsicode = 4 -- Information
	
	SELECT @v_msgtype_completed = datacode FROM gentables WHERE tableid = 539 AND qsicode = 6 -- Completed
	
	SELECT @v_csverificationtypecode = datacode, @v_stored_procedure = alternatedesc1 FROM gentables WHERE tableid = 556 AND qsicode = 3 -- CS Verification
	
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error getting CS Verification from gentables 556.'
		RETURN 
	END 
		  
	SELECT @v_numrows = COUNT(*) FROM  backgroundprocess WHERE jobtypecode = @v_jobtype_autoverify
	
	IF @v_numrows = 0 BEGIN --No  titles found - nothing to process
		RETURN
	END

	SELECT TOP 1 @v_userid = lastuserid FROM backgroundprocess WHERE jobtypecode = @v_jobtype_autoverify
	
	SELECT @v_bookkey = key1, @v_printingkey = integervalue1 FROM backgroundprocess WHERE jobtypecode =  @v_jobtype_autoverify	
	   AND backgroundprocesskey = @i_backgroundprocesskey
	
	-- Start the job to populate backgroundprocess job
	SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80		
    SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
    SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode								  	 
    SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1  
    SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')

    SET @v_jobdesc = 'Auto Title Verification Job ' + @v_curdatetime
    SET @v_jobdescshort = 'Title Verify. - Auto ' + @v_curdatetime
    SET @v_msgdesc = 'Job Started ' + @v_curdatetime
    SET @v_jobkey = NULL
    SET @v_batchkey = NULL
    
    EXEC qutl_update_job @v_batchkey OUTPUT, @v_jobkey OUTPUT, @v_jobtype_autoverify, 0, @v_jobdesc, @v_jobdescshort, @v_userid, @v_bookkey, 0, 0,
      @v_msgtype_started, @v_msgdesc, 'Job Started', NULL, 1, @v_error OUTPUT, @v_errordesc OUTPUT

    IF @v_error = -1 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error returned by qutl_update_job procedure - could not start Auto Title Verification Job.'
		RETURN 
    END
      		
    SET @v_customerkey = NULL
	SELECT @v_customerkey = elocustomerkey FROM book WHERE bookkey = @v_bookkey	
    
	IF ISNULL(@v_customerkey, 0) = 0  BEGIN
		SET @v_msgdesc = 'Title does not have a valid eloquence customer'
		SET @v_msgshortdesc = NULL
			
		EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0, NULL,
		  @v_msgdesc, @v_msgshortdesc, @v_msg_nocustomer, NULL, @o_error_code output, @o_error_desc output
    END
    ELSE BEGIN
    	IF COALESCE(@v_stored_procedure, '') <> '' BEGIN
			SET @v_sql = N'exec ' + @v_stored_procedure + ' @BookKey, @PrintingKey, @VerificationType, @UserId, @SPError output, @SPErrorMessage output'
	              
			EXECUTE sp_executesql @v_sql,N'@BookKey int,@PrintingKey int, @VerificationType int, @UserId varchar(30), @SPError int output, @SPErrorMessage varchar(2000) output', 
			  @BookKey = @v_bookkey,@PrintingKey = @v_printingkey, @VerificationType = @v_csverificationtypecode,@UserId = 'qsidba', @SPError = @o_error_code output, @SPErrorMessage = @o_error_desc output
    	END
    		
    	IF @@ERROR <> 0 BEGIN
    		SET @v_msgdesc = 'Error executing verification stored procedure: ' + @v_stored_procedure
				    + ', inner error: ' + COALESCE(@o_error_desc, 'none')
			SET @v_msgshortdesc = 'Error executing verification stored procedure: ' + @v_stored_procedure
    			
			EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0, @v_msgtype_error,
				    @v_msgdesc, @v_msgshortdesc, NULL, 2, @o_error_code output, @o_error_desc output
					    
		    SELECT @v_titleverifystatuscode = titleverifystatuscode
		      FROM bookverification
		     WHERE bookkey = @v_bookkey
			   AND verificationtypecode = @v_csverificationtypecode
				   
			IF @v_titleverifystatuscode = @v_csverify_failed  BEGIN  
				SET @v_msgdesc = 'Title Failed Verification; please see verification messages for details'
				SET @v_msgshortdesc = NULL
  				
				EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0, @v_msgtype_error,
				  @v_msgdesc, @v_msgshortdesc, @v_msg_failedver, 8, @o_error_code output, @o_error_desc output
			   END
    	END
    	ELSE BEGIN
    		SET @v_msgdesc = 'Title Verification successful for bookkey: ' + CONVERT(VARCHAR,@v_bookkey)
			SET @v_msgshortdesc = NULL
  				
			EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0, @v_msgtype_error,
			  @v_msgdesc, @v_msgshortdesc, @v_msgtype_completed, 6, @o_error_code output, @o_error_desc output
    	
    	END
    END -- Valid eloquence customer
	    
    
    SET @v_msgdesc = 'Auto Title Verification Process Finished'
	SET @v_msgshortdesc = 'Auto Title Verification Process Finished'
			
	EXEC qutl_update_job NULL, @v_jobkey, NULL, NULL, NULL, NULL, @v_userid, @v_bookkey, 0, 0, @v_msgtype_info,
		    @v_msgdesc, @v_msgshortdesc, NULL, 4, @o_error_code output, @o_error_desc output


END 
GO

GRANT EXEC ON DAB_Delivery_search_to_backgroundprocess TO PUBLIC
GO