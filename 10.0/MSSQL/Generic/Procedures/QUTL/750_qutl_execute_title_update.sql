IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_execute_title_update')
BEGIN
  PRINT 'Dropping Procedure qutl_execute_title_update'
  DROP  Procedure  qutl_execute_title_update
END
GO

PRINT 'Creating Procedure qutl_execute_title_update'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: qutl_execute_title_update
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  09/16/2016   UK          Case 40489
*******************************************************************************/

CREATE PROCEDURE qutl_execute_title_update
 (@UpdateNumber       INT,
  @SQLUpdate          NVARCHAR(2000),
  @SQLHistoryExec     NVARCHAR(2000),
  @SQLHistorySubExec  NVARCHAR(2000),
  @SQLRelatedUpdate   NVARCHAR(2000),
  @CriteriaKey        INT,
  @UserKey            INT,
  @SearchItem         INT,
  @BookKey            INT,
  @PrintingKey        INT,
  @ColumnName         VARCHAR(120),
  @SubgenColumnName   VARCHAR(120),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*****************************************************************************************************************
**  Name: qutl_execute_title_update
**  Desc: This stored procedure is called from qutl_udpate_titles_in_list.
**        It processes and executes the related update statements for any of the 5 allowed update criteria.
**        Returns 0 if all sucessful, -1 if validation failed for this update and processing should continue 
**        in the calling procedure to the next update, -2 if DB Error occurred and all processing should stop.
**
**  Auth: Kate J. Wiewiora
**  Date: 1 August 2011
******************************************************************************************************************/

DECLARE
  @CurrencyCode INT,  --gentable 122 (Currency)
  @CurrentCSApprovalCode INT,  
  @DateType INT,
  @datelabel VARCHAR(100),
  @datetype_accesscode SMALLINT,
  @ErrorVar   INT,
  @HistoryOrder SMALLINT,
  @PriceTypeCode  INT,  --gentable 306 (Price Type)
  @PriceValidationGroupCode	INT,
  @ProductNumber VARCHAR(50),
  @RowcountVar  INT,	
  @SPError  INT,
  @SPErrorMessage VARCHAR(2000),  
  @StandardInd CHAR(1),
  @TableName  VARCHAR(30),
  @RelatedTableName VARCHAR(30),	
  @TempIndex  INT,
  @TempString VARCHAR(100),
  @TestCount INT,
  @Title    VARCHAR(255),
  @UserID   VARCHAR(30),
  @DataDesc VARCHAR(40),
  @LanguageCode INT,
  @LanguageCode2 INT,
  @Eloquenceincloud_clientvalue INT,
  @SendToEloquenceInd INT,
  @OrigEdiStatusCode INT,
  @EdiStatusCode INT,
  @EloCloudStatusCode INT,  
  @InsertRowIntoCloudScheduleForApproval INT,
  @DeleteRowFromCloudScheduleForApproval INT,   
  @WindowName VARCHAR(100),
  @SecurityMessage VARCHAR(2000),
  @FailedInd  BIT,
  @AccessCode INT,
  @v_objectlist_xml varchar(4000),
  @LinkLevelCode  INT,
  @workkey_rowcount INT,
  @WorkFieldInd  INT,
  @WorkFieldIndSub  INT,
  @WindowID INT,
  @AvailObjectID VARCHAR(50),   
  @AvailObjectName VARCHAR(50),
  @AvailObjectIDAndName VARCHAR(100),
  @Object VARCHAR(100),
  @AvailObjectDesc VARCHAR(50),
  @DocNum1 INT   
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ' '
  SET @InsertRowIntoCloudScheduleForApproval = 0
  SET @WorkFieldInd = 0
  SET @WorkFieldIndSub = 0

  -- ******** Get the UserID for the given userkey ****** --
  SELECT @UserID = userid
  FROM qsiusers
  WHERE userkey = @UserKey

  -- Make sure qsiusers record exists for this userkey
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0
  BEGIN
    SET @o_error_desc = 'Error getting UserID from qsiusers table (userkey=' + CONVERT(VARCHAR, @UserKey) + ').'
    GOTO DBError
  END

  -- Get the title and productnumber for this bookkey/printingkey
  SELECT @Title = title, @ProductNumber = productnumber, @LinkLevelCode = linklevelcode
  FROM coretitleinfo
  WHERE bookkey = @BookKey AND printingkey = @PrintingKey
  
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0
  BEGIN
    SET @o_error_desc = 'Error getting title information (bookkey=' + CONVERT(VARCHAR, @BookKey) + ', printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'
    GOTO DBError
  END
  
  IF @ProductNumber IS NOT NULL AND LTRIM(RTRIM(@ProductNumber)) <> ''
  BEGIN
    SET @Title = @Title + ' (' + @ProductNumber + ')'
  END

  -- Extract tablename being updated from SQLUpdate
  SET @TempIndex = CHARINDEX('UPDATE ', @SQLUpdate)
  IF @TempIndex > 0
  BEGIN
    SET @TableName = SUBSTRING(@SQLUpdate, @TempIndex + 7, 100)
    SET @TempIndex = CHARINDEX(' SET ', @TableName)
    IF @TempIndex > 0 
      SET @TableName = SUBSTRING(@TableName, 1, @TempIndex)
  END
      
  PRINT @TableName

  IF @LinkLevelCode = 10 BEGIN
     SELECT @workkey_rowcount = COUNT(*)
       FROM book
      WHERE workkey = @BookKey 
        AND linklevelcode = 20
    
     IF (@workkey_rowcount > 0) AND (@SQLHistoryExec IS NOT NULL) BEGIN
      SELECT @WorkFieldInd = workfieldind
        FROM titlehistorycolumns
       WHERE tablename = @TableName
         AND columnname = @ColumnName
     END

     IF (@workkey_rowcount > 0) AND (@SQLHistorySubExec IS NOT NULL) BEGIN
      SELECT @WorkFieldIndSub = workfieldind
        FROM titlehistorycolumns
       WHERE tablename = @TableName
         AND columnname = @SubgenColumnName
     END
  END  -- @LinkLevelCode = 10
  ELSE BEGIN
    SET @WorkFieldInd = 0
    SET @WorkFieldIndSub = 0
  END
  
-- Check to see if security is applicable for any of these functions
 IF @CriteriaKey = 8 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: BISAC Status function'
    SET @WindowName = 'ChangeBISACStatus'
  END
  ELSE IF @CriteriaKey = 17 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: PRICE function'
    SET @WindowName = 'ChangePrice'
  END 
  ELSE IF @CriteriaKey = 89 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: Eloquence Customer function'
    SET @WindowName = 'ChangeEloquenceCustomer'
  END                       
  ELSE IF @CriteriaKey = 185 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: Never Send To Eloquence function'
    SET @WindowName = 'ChangeNeverSendToEloquence'
  END 
  ELSE IF @CriteriaKey = 186 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: Send To Eloquence function'
    SET @WindowName = 'ChangeSendToEloquence'
  END
  ELSE IF @CriteriaKey = 191 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: REL TO ELO – FILE TYPE function'
    SET @WindowName = 'RelToEloFileType'
  END
  ELSE IF @CriteriaKey = 192 BEGIN
    SET @SecurityMessage = @UserId + ' does not have access to change: REL TO ELO – COMMENT TYPE function'
    SET @WindowName = 'RelToEloCommentType'
  END     
  
  IF @CriteriaKey = 8 OR  @CriteriaKey = 17 OR  @CriteriaKey = 89 OR  @CriteriaKey = 185 OR @CriteriaKey = 186 OR @CriteriaKey = 191 OR  @CriteriaKey = 192 BEGIN
    exec dbo.qutl_check_page_object_security @UserKey,@WindowName,@BookKey,@PrintingKey,0,@AccessCode output,
                                             @v_objectlist_xml output,@o_error_code output,@o_error_desc output	  

	    
	  IF @AccessCode = 0 OR @o_error_code < 0 BEGIN
		SET @FailedInd = 1
	                  		
        INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
        VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SecurityMessage)		
	      		
	   SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN
          SET @o_error_desc = 'Error occurred during inset into qse_updatefeedback table.'
          GOTO DBError
        END        
		-- Skip further processing for this update - goto next update in the calling stored procedure
		GOTO ValidationFailed         
	  END
  END 
  
  -- ***** Get DataType for this criteria and check criteria type *****
  SET @WindowName = 'productsummary'  
  SELECT @WindowID = windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = @WindowName
        
  exec dbo.qutl_check_page_object_security @UserKey,@WindowName,@BookKey,@PrintingKey,0,@AccessCode output,
						    @v_objectlist_xml output,@o_error_code output,@o_error_desc output	    
	        
  IF @v_objectlist_xml IS NOT NULL OR @v_objectlist_xml <> '' BEGIN
	-- Prepare passed XML document for processing
	EXEC sp_xml_preparedocument @DocNum1 OUTPUT, @v_objectlist_xml
	-- ***************** Parse UPDATE CRITERIA from XML ******************
	-- Loop to get all Search/Criteria elements from the passed XML document
	DECLARE securityobjectsavailable_cursor CURSOR LOCAL FOR 
	  SELECT  a.availobjectid, a.availobjectname, COALESCE(a.availobjectdesc, '')
	  FROM securityobjectsavailable a LEFT OUTER JOIN qse_searchcriteria c
	  ON a.criteriakey = c.searchcriteriakey
	  WHERE windowid = @WindowID AND	
	        availobjectid IS NOT NULL AND
			availobjectname IS NOT NULL AND
			a.criteriakey = @CriteriaKey

	OPEN securityobjectsavailable_cursor

	FETCH NEXT FROM securityobjectsavailable_cursor
	INTO @AvailObjectID, @AvailObjectName, @AvailObjectDesc

	-- ***** CRITERIA LOOP *****
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	   SET @AvailObjectIDAndName = LTRIM(RTRIM(LOWER(@AvailObjectID + '.' + @AvailObjectName)))   
	   
	   IF @CriteriaKey = 17 BEGIN
			IF (@ColumnName = 'finalprice' AND @AvailObjectName <> 'txtFinalPriceEdit') OR (@ColumnName = 'budgetprice' AND @AvailObjectName <> 'txtBudgetPriceEdit')  BEGIN
			  FETCH NEXT FROM securityobjectsavailable_cursor
			  INTO @AvailObjectID, @AvailObjectName, @AvailObjectDesc	
			  
			  CONTINUE			
			END
	   END
	   
	   IF EXISTS(SELECT  *
		  FROM OPENXML(@DocNum1,  '/Security')
		  WHERE text IS NOT NULL AND CONVERT(VARCHAR(100), text) = @AvailObjectIDAndName) BEGIN
		  
			SET @FailedInd = 1
		                      
			SET @SecurityMessage = @UserId + ' is not allowed to update : ' + @AvailObjectDesc							
		                                  
			INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
			VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SecurityMessage)	            
		        	      
		   SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
			IF @ErrorVar <> 0 BEGIN
			  SET @o_error_desc = 'Error occurred during inset into qse_updatefeedback table.'
			  GOTO DBError
			END  		  
			
			-- Skip further processing for this update - goto next update in the calling stored procedure
			GOTO ValidationFailed     		  
		END
	  	      
	  FETCH NEXT FROM securityobjectsavailable_cursor
	  INTO @AvailObjectID, @AvailObjectName, @AvailObjectDesc
	END
	  
	CLOSE securityobjectsavailable_cursor
	DEALLOCATE securityobjectsavailable_cursor        
  END  
        
  IF @TableName = 'bookprice'
  BEGIN
    -- Extract PriceTypeCode and CurrencyCode from the WHERE clause of the update statement
    SET @TempIndex = CHARINDEX('pricetypecode=', @SQLUpdate)
    IF @TempIndex > 0
    BEGIN
      SET @TempString = SUBSTRING(@SQLUpdate, @TempIndex + 14, 100)
      SET @TempIndex = CHARINDEX(' ', @TempString)
      IF @TempIndex > 0
        SET @PriceTypeCode = SUBSTRING(@TempString, 1, @TempIndex)
    END
    -- Extract CurrencyCode
    SET @TempIndex = CHARINDEX('currencytypecode=', @SQLUpdate)
    IF @TempIndex > 0
    BEGIN
      SET @TempString = SUBSTRING(@SQLUpdate, @TempIndex + 17, 100)
      SET @TempIndex = CHARINDEX(' ', @TempString)
      IF @TempIndex > 0 
        SET @CurrencyCode = SUBSTRING(@TempString, 1, @TempIndex)
    END

    PRINT ' @PriceTypeCode=' + CONVERT(VARCHAR, @PriceTypeCode)
    PRINT ' @CurrencyCode=' + CONVERT(VARCHAR, @CurrencyCode)
    
    -- When setting budgetprice or finalprice to 0, must check if zero price is allowed for this title    
    SET @TempIndex = CHARINDEX('budgetprice=0,', @SQLUpdate)
    IF @TempIndex = 0
      SET @TempIndex = CHARINDEX('finalprice=0,', @SQLUpdate)

	IF @TempIndex = 0 BEGIN
      SET @TempIndex = CHARINDEX('budgetprice=0 ', @SQLUpdate)
      IF @TempIndex = 0
        SET @TempIndex = CHARINDEX('finalprice=0 ', @SQLUpdate)
	END
          
    IF @TempIndex > 0   --either trying to set budgetprice or finalprice to zero
    BEGIN
      SELECT @PriceValidationGroupCode = pricevalidationgroupcode  
      FROM bookdetail
      WHERE bookkey = @BookKey

      IF @PriceValidationGroupCode IS NULL
      BEGIN
        EXEC qtitle_set_price_validation_group @BookKey, @SPError OUT, @SPErrorMessage OUT
  
        IF @SPError = -1
        BEGIN
--          SET @FailedInd = 1
          
          INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
          VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
          
          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0
          BEGIN            
            GOTO DBError
          END 
        
          -- Skip further processing for this update - goto next update in the calling stored procedure
          GOTO ValidationFailed 
        END 			  
        
        SELECT @PriceValidationGroupCode = pricevalidationgroupcode  
        FROM bookdetail
        WHERE bookkey = @BookKey              
      END

      PRINT ' @PriceValidationGroupCode=' + CONVERT(VARCHAR, @PriceValidationGroupCode)

      -- Validate title prices for this title - run the title price validation procedure
      EXEC qtitle_price_validation 0, 0, @PriceValidationGroupCode, @PriceTypeCode, @CurrencyCode, @SPError OUT, @SPErrorMessage OUT
    
      IF @SPError = -1
      BEGIN
--        SET @FailedInd = 1
        
        INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
        VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
        
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN
          GOTO DBError
        END 
      
        -- Skip further processing for this update - goto next update in the calling stored procedure
        GOTO ValidationFailed 
      END 
    END
  END
                
  IF @TableName = 'bookdates' OR @TableName = 'taqprojecttask'
  BEGIN     
    -- Extract DateTypeCode from the WHERE clause of the update statement
    SET @TempIndex = CHARINDEX('datetypecode=', @SQLUpdate)
    IF @TempIndex > 0 BEGIN
      SET @TempString = SUBSTRING(@SQLUpdate, @TempIndex + 13, 100)

      SET @TempIndex = CHARINDEX(' ', @TempString)
      IF @TempIndex = 0 BEGIN
        SET @TempIndex = len(@TempString)
      END

      IF @TempIndex > 0 BEGIN
        SET @DateType = SUBSTRING(@TempString, 1, @TempIndex)
                     
        PRINT ' @DateType=' + CONVERT(VARCHAR, @DateType)      
        
        IF @DateType > 0 BEGIN
          SELECT @datetype_accesscode = dbo.qutl_check_gentable_value_security_by_status(@UserKey, 'tasktracking', 323, @DateType, @BookKey, @PrintingKey, 0)

          IF COALESCE(@datetype_accesscode,2) IN (0,1) BEGIN  -- not allowed to update
--            SET @FailedInd = 1
                   
            SELECT @datelabel = COALESCE(datelabel, description) 
            FROM datetype 
            WHERE datetypecode = @DateType
                   
            INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
            VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), 'Not allowed to update task type: ' + '''' + @datelabel + '''')
              
            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0
            BEGIN
              GOTO DBError
            END
                          
            -- Skip further processing for this update - goto next update in the calling stored procedure
            GOTO ValidationFailed 
          END
        END  
      END     
    END
  END
                    
  IF @TableName = 'bookdetail'
  BEGIN          
    -- see if we are updating csapprovalcode
    SET @TempIndex = CHARINDEX('csapprovalcode=', @SQLUpdate)
    IF @TempIndex > 0
    BEGIN
      -- Only allow CSApprovalCode to be updated if current value is not 'Never Approve'
      SELECT @CurrentCSApprovalCode = csapprovalcode
      FROM bookdetail
      WHERE bookkey = @BookKey

      IF @CurrentCSApprovalCode = 3 BEGIN
        -- Not allowed to update Eloquence ApprovalCode - write to qse_updatefeedback table
--        SET @FailedInd = 1
                      
        INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
        VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(),
          'Cannot change Eloquence Approval Code when it is set to ' + '''' + dbo.get_gentables_desc(620, @CurrentCSApprovalCode, 'long') + '''')
          
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN
          GOTO DBError
        END
                      
        -- Skip further processing for this update - goto next update in the calling stored procedure
        GOTO ValidationFailed 
      END
      ELSE BEGIN
        INSERT INTO qse_update_addtlprocessing (userkey, searchitemcode, searchcriteriakey, key1, key2, lastuserid, lastmaintdate)
        VALUES (@UserKey, @SearchItem, @CriteriaKey, @BookKey, @PrintingKey, @UserID, getdate())
          
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN
          SET @o_error_desc = 'Error occurred during inset into qse_update_addtlprocessing table.'
          GOTO DBError
        END
      END
    END
    -- see if we are updating languagecode
    SET @TempIndex = CHARINDEX('languagecode=', @SQLUpdate)
    IF @TempIndex > 0
    BEGIN
      SET @TempString = SUBSTRING(@SQLUpdate, @TempIndex + 13, 100)

      SELECT @TempIndex = CASE WHEN CHARINDEX(',', @TempString) > 0 THEN CHARINDEX(',', @TempString)-1
						       ELSE LEN(@TempString)
						  END 

      IF @TempIndex > 0 BEGIN
		SET @LanguageCode = CONVERT(INT, LTRIM(RTRIM(SUBSTRING(@TempString, 1, @TempIndex))))

		  SELECT @LanguageCode2 = COALESCE(languagecode2, 0)
		  FROM bookdetail
		  WHERE bookkey = @BookKey

		  IF @LanguageCode2 = @LanguageCode BEGIN
			-- Not allowed to update languagecode2 - write to qse_updatefeedback table
		    SELECT @DataDesc = datadesc 
		    FROM gentables 
		    WHERE tableid = 318 AND datacode = @LanguageCode

			INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, [message])
			VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @DataDesc + ' language already exists.')
	                      	          
			SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
			IF @ErrorVar <> 0
			BEGIN
			  GOTO DBError
			END
	                      
			-- Skip further processing for this update - goto next update in the calling stored procedure
			GOTO ValidationFailed 
		  END
		END
    END
  END 
               
  -- Make sure row exists before doing update
  -- need to do row exists check on a table by table basis - because there may be additional keys required
  IF @TableName = 'bookmisc' BEGIN
    SELECT @TestCount = COUNT(*) 
    FROM bookmisc bm, bookmiscitems bmi
    WHERE bm.misckey = bmi.misckey AND searchcriteriakey = @CriteriaKey AND bookkey = @BookKey

    IF @@ERROR <> 0
    BEGIN
      SET @o_error_desc = 'Error checking bookmisc table (searchcriteriakey=' + CONVERT(VARCHAR, @CriteriaKey) + ', bookkey=' + CONVERT(VARCHAR, @BookKey) + ').'
      GOTO DBError
    END

    print '@TestCount: ' + cast(COALESCE(@TestCount,0) as varchar)
    
    IF @TestCount = 0 BEGIN
      -- no row found - INSERT Row
      INSERT INTO bookmisc (bookkey, misckey, lastuserid, lastmaintdate, sendtoeloquenceind)
      SELECT @BookKey, misckey, @UserID, getdate(), defaultsendtoeloqvalue
      FROM bookmiscitems
      WHERE searchcriteriakey = @CriteriaKey
    END
    
    IF @@ERROR <> 0
    BEGIN
      SET @o_error_desc = 'Error adding new bookmisc row (Criteriakey: ' + CONVERT(VARCHAR, @CriteriaKey) + ').'
      GOTO DBError
    END
  END  

  -- Make sure bookedistatus/bookedipartner rows exist before doing update           
  IF @TableName = 'bookedistatus' BEGIN
  
    SELECT @StandardInd = UPPER(standardind)
    FROM coretitleinfo
    WHERE bookkey = @BookKey AND printingkey = @PrintingKey
    
    IF @StandardInd = 'Y' BEGIN
      -- Not allowed to send templates to Eloquence - write to qse_updatefeedback table
--      SET @FailedInd = 1
                    
      INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
      VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(),
        'Cannot set Eloquence Status. Templates cannot be sent to Eloquence.')
        
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0
      BEGIN
        GOTO DBError
      END
                    
      -- Skip further processing for this update - goto next update in the calling stored procedure
      GOTO ValidationFailed 
    END
    
    IF @CriteriaKey = 185 OR @CriteriaKey = 186 BEGIN
      -- Never Send to Eloquence OR Send To Eloquence OR Remove From Eloquence            
      -- Need Row on bookedistatus and bookedipartner     
      SELECT @TestCount = COUNT(*) 
      FROM bookedistatus
      WHERE bookkey = @BookKey AND printingkey = @PrintingKey

      IF @@ERROR <> 0
      BEGIN
        SET @o_error_desc = 'Error checking bookedistatus table (bookkey=' + CONVERT(VARCHAR, @BookKey) + ', printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'
        GOTO DBError
      END

      print '@TestCount(bookedistatus): ' + cast(COALESCE(@testcount,0) as varchar)
      
      IF @testcount = 0 BEGIN              
        -- no row found - INSERT Row
        INSERT INTO bookedistatus (edipartnerkey, bookkey, printingkey, edistatuscode, lastuserid, lastmaintdate, previousedistatuscode)
        VALUES (1, @BookKey, @PrintingKey, 0, @UserID, getdate(), 0)
        
        IF @@ERROR <> 0
        BEGIN
          SET @o_error_desc = 'Error adding new row to bookedistatus table (bookkey=' + CONVERT(VARCHAR, @BookKey) + ', printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'
          GOTO DBError
        END
        ELSE BEGIN
          SELECT @OrigEdiStatusCode = 0
        END
      END
      ELSE BEGIN
         SELECT @OrigEdiStatusCode = COALESCE(edistatuscode, 0)
		       FROM bookedistatus
		      WHERE bookkey = @BookKey
      END
      
      -- bookedipartner     
      SELECT @testcount = COUNT(*) 
      FROM bookedipartner
      WHERE bookkey = @BookKey AND printingkey = @PrintingKey

      IF @@ERROR <> 0
      BEGIN
        SET @o_error_desc = 'Error checking bookedipartner table (bookkey=' + CONVERT(VARCHAR, @BookKey) + ', printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'
        GOTO DBError
      END

      print '@testcount(bookedipartner): ' + cast(COALESCE(@testcount,0) as varchar)
      
      IF @testcount = 0 BEGIN
        -- no row found - INSERT Row
        INSERT INTO bookedipartner (edipartnerkey, bookkey, printingkey, lastuserid, lastmaintdate, sendtoeloquenceind)
        VALUES (1, @BookKey, @PrintingKey, @UserID, getdate(), 0)
      
        IF @@ERROR <> 0
        BEGIN
          SET @o_error_desc = 'Error adding new row to bookedipartner table (bookkey=' + CONVERT(VARCHAR, @BookKey) + ', printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'
          GOTO DBError
        END
      END
    END

    IF @CriteriaKey = 185 OR @CriteriaKey = 186 BEGIN
      -- Check if client uses Eloquence in Cloud
      SELECT @Eloquenceincloud_clientvalue = optionvalue
        FROM clientoptions
       WHERE optionid = 111
       
      SET @InsertRowIntoCloudScheduleForApproval  = 0
      SET @DeleteRowFromCloudScheduleForApproval  = 0      
       
      IF @CriteriaKey = 186 BEGIN /*Send to Eloquence */
        -- Extract edistatuscode from the WHERE clause of the update statement
        SET @TempIndex = CHARINDEX('sendtoeloquenceind = ', @SQLRelatedUpdate)
        IF @TempIndex > 0
        BEGIN
          SET @TempString = SUBSTRING(@SQLRelatedUpdate, @TempIndex + 21, 100)
          SET @TempIndex = CHARINDEX(' ', @TempString)
          IF @TempIndex > 0 BEGIN
             SET @EloCloudStatusCode = SUBSTRING(@TempString, 1, 1)
             
             IF @Eloquenceincloud_clientvalue = 1 AND @OrigEdiStatusCode <> 8 BEGIN
				 IF @EloCloudStatusCode = 1 BEGIN  -- Yes
				   SET @InsertRowIntoCloudScheduleForApproval  = 1
				 END
             END
             ELSE IF @OrigEdiStatusCode = 8 AND @EloCloudStatusCode = 1 BEGIN
				SET @FailedInd = 1
			                  		
				INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
				VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), 'Not Sent to Eloquence because the Title is set as Never Send To Eloquence')		
			      		
			   SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
				IF @ErrorVar <> 0
				BEGIN
				  SET @o_error_desc = 'Error occurred during inset into qse_updatefeedback table.'
				  GOTO DBError
				END        
				-- Skip further processing for this update - goto next update in the calling stored procedure
				GOTO ValidationFailed
             END 
          END
        END 
      END        
      
      IF @Eloquenceincloud_clientvalue = 1 AND @CriteriaKey = 185 BEGIN /*Never Send to Eloquence */      
        -- Extract edistatuscode from the WHERE clause of the update statement
        SET @TempIndex = CHARINDEX('edistatuscode=CASE', @SQLUpdate)
        IF @TempIndex > 0
        BEGIN
          IF @OrigEdiStatusCode <> 8 AND @OrigEdiStatusCode <> 1 BEGIN  -- 8 Never Send 1 Not Sent
             SET @DeleteRowFromCloudScheduleForApproval  = 0
          END
        END
        ELSE BEGIN
          SET @TempIndex = CHARINDEX('edistatuscode=', @SQLUpdate)
          IF @TempIndex > 0
          BEGIN
              SET @TempString = SUBSTRING(@SQLUpdate, @TempIndex + 14, 100)
              SET @TempIndex = CHARINDEX(', ', @TempString)
              IF @TempIndex > 0 BEGIN
                 SET @EdiStatusCode = SUBSTRING(@TempString, 1, 1)
                 IF @EdiStatusCode =  8 BEGIN  --Delete
                   SET @DeleteRowFromCloudScheduleForApproval  = 1
                 END
              END
          END
        END      
      END       

      IF @Eloquenceincloud_clientvalue = 1 AND @CriteriaKey = 186 BEGIN /*Send to Eloquence */
      
        PRINT ' @InsertRowIntoCloudScheduleForApproval=' + CONVERT(VARCHAR, @InsertRowIntoCloudScheduleForApproval)
        
        IF @InsertRowIntoCloudScheduleForApproval = 1 BEGIN
           EXEC qcs_create_cloudscheduleforapproval_row @BookKey, @SPError OUT, @SPErrorMessage OUT

           IF @SPError = -1
           BEGIN
               
             INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
              VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
                
             SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
             IF @ErrorVar <> 0
             BEGIN            
               GOTO DBError
             END 
              
             -- Skip further processing for this update - goto next update in the calling stored procedure
             GOTO ValidationFailed 
           END 
        END	
        IF @InsertRowIntoCloudScheduleForApproval = 0 BEGIN
           EXEC qcs_delete_cloudscheduleforapproval_row @BookKey, @SPError OUT, @SPErrorMessage OUT

           IF @SPError = -1
           BEGIN
               
              INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
              VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
                
              SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
              IF @ErrorVar <> 0
              BEGIN            
                GOTO DBError
              END 
              
              -- Skip further processing for this update - goto next update in the calling stored procedure
              GOTO ValidationFailed 
            END 
        END	
      END  -- Criteriakye = 186

     IF @Eloquenceincloud_clientvalue = 1 AND @CriteriaKey = 185 AND @DeleteRowFromCloudScheduleForApproval = 1 BEGIN /*Never Send to Eloquence */
       EXEC qcs_delete_cloudscheduleforapproval_row @BookKey, @SPError OUT, @SPErrorMessage OUT

       IF @SPError = -1
       BEGIN
         
        INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
         VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
          
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN            
          GOTO DBError
        END 
        
        -- Skip further processing for this update - goto next update in the calling stored procedure
        GOTO ValidationFailed 
      END 	
     END  -- criteriakey = 185
    END
  END
                 
  -- DEBUG
  PRINT ' ' + @SQLUpdate

  EXECUTE sp_executesql @SQLUpdate, N'@p_Key1Value INT,@p_Key2Value INT', @BookKey, @PrintingKey
          
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0
  BEGIN
    SET @o_error_desc = 'Error executing SQL UPDATE ' + CONVERT(VARCHAR, @UpdateNumber) + ': ' + @SQLUpdate + ' (bookkey=' + CONVERT(VARCHAR, @BookKey) + ',printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'          
    GOTO DBError
  END
        
  -- If at least one record was updated in SQLUpdate1 above, 
  -- execute titlehistory/datehistory stored procedure(s) if necessary
  IF @RowcountVar > 0
  BEGIN
    -- Initialize HistoryOrder to NULL for each titlehistory exec
    SET @HistoryOrder = NULL
    
    IF @SQLHistoryExec IS NOT NULL --history for ColumnName
    BEGIN

      PRINT ' ' + @SQLHistoryExec
                
      -- For bookprices, must pass HistoryOrder for titlehistory            
      IF @TableName = 'bookprice'
      BEGIN
        -- Get historyorder for the ACTIVE price being updated
        SELECT @HistoryOrder = history_order
        FROM bookprice
        WHERE bookkey = @BookKey AND
            pricetypecode = @PriceTypeCode AND
            currencytypecode = @CurrencyCode AND activeind = 1
            
        IF @@ERROR <> 0  BEGIN
          SET @o_error_desc = 'Error getting history_order from bookprice table for Update ' + CONVERT(VARCHAR, @UpdateNumber) + ' (bookkey=' + CONVERT(VARCHAR, @BookKey) + ',printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'
          GOTO DBError
        END
        
        IF @HistoryOrder IS NOT NULL
          PRINT ' @HistoryOrder=' + CONVERT(VARCHAR, @HistoryOrder)
      END

      EXECUTE sp_executesql @SQLHistoryExec, 
        N'@p_Key1Value INT, @p_Key2Value INT, @p_HistoryOrder INT, @SPError INT OUTPUT, @SPErrorMessage VARCHAR(2000) OUTPUT', 
        @BookKey, @PrintingKey, @HistoryOrder, @SPError OUTPUT, @SPErrorMessage OUTPUT

      IF @@ERROR <> 0  BEGIN
        SET @o_error_desc = 'Error executing dynamic SQL for stored procedure qtitle_update_titlehistory (Update ' + CONVERT(VARCHAR, @UpdateNumber) + ').'
        GOTO DBError
      END   
      
      IF (@SPError <> 0) BEGIN
        SET @o_error_desc = 'Error generated while running stored procedure qtitle_update_titlehistory (Update ' + CONVERT(VARCHAR, @UpdateNumber) + '): ' + @SPErrorMessage
        GOTO DBError
      END
    END --IF @SQLHistoryExec IS NOT NULL
    
    IF @SQLHistorySubExec IS NOT NULL  --history for SubColumnName
    BEGIN

      PRINT ' ' + @SQLHistorySubExec
      
      EXECUTE sp_executesql @SQLHistorySubExec, 
        N'@p_Key1Value INT, @p_Key2Value INT, @p_HistoryOrder INT, @SPError INT OUTPUT, @SPErrorMessage VARCHAR(2000) OUTPUT', 
        @BookKey, @PrintingKey, @HistoryOrder, @SPError OUTPUT, @SPErrorMessage OUTPUT

      IF @@ERROR <> 0  BEGIN
        SET @o_error_desc = 'Error executing dynamic SQL for stored procedure qtitle_update_titlehistory (Update Sub ' + CONVERT(VARCHAR, @UpdateNumber) + ').'
        GOTO DBError
      END   
      
      IF (@SPError <> 0) BEGIN
        SET @o_error_desc = 'Error generated while running stored procedure qtitle_update_titlehistory (Update Sub ' + CONVERT(VARCHAR, @UpdateNumber) + '): ' + @SPErrorMessage
        GOTO DBError
      END
    END --IF @SQLHistorySubExec IS NOT NULL
    
    IF @SQLRelatedUpdate IS NOT NULL
    BEGIN
    
      PRINT ' ' + @SQLRelatedUpdate

      EXECUTE sp_executesql @SQLRelatedUpdate, 
        N'@p_Key1Value INT,@p_Key2Value INT', @BookKey, @PrintingKey
        
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0
      BEGIN
        SET @o_error_desc = 'Error executing Related SQL UPDATE ' + CONVERT(VARCHAR, @UpdateNumber) + ': ' + @SQLRelatedUpdate + ' (bookkey=' + CONVERT(VARCHAR, @BookKey) + ',printingkey=' + CONVERT(VARCHAR, @PrintingKey) + ').'          
        GOTO DBError
      END
    END --IF @SQLRelatedUpdate IS NOT NULL

     IF @WorkFieldInd = 1 BEGIN
      -- propagate values to subordinate titles
      EXEC qtitle_copy_work_info @BookKey, @TableName, @ColumnName, @SPError OUT, @SPErrorMessage OUT
    
      IF @SPError = -1
      BEGIN
        INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
          VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
        
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN
          GOTO DBError
        END 
      
        -- Skip further processing for this update - goto next update in the calling stored procedure
        GOTO ValidationFailed 
      END 

    END --@WorkFieldInd = 1

    IF @WorkFieldIndSub = 1 BEGIN
       -- propagate values to subordinate titles
      EXEC qtitle_copy_work_info @BookKey, @TableName, @SubgenColumnName, @SPError OUT, @SPErrorMessage OUT
    
      IF @SPError = -1
      BEGIN
       
        INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
        VALUES (@UserKey, @SearchItem, @BookKey, @PrintingKey, @Title, getdate(), @SPErrorMessage)
        
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0
        BEGIN
          GOTO DBError
        END 
      
        -- Skip further processing for this update - goto next update in the calling stored procedure
        GOTO ValidationFailed 
      END 
    END --@WorkFieldIndSub = 1
  END --IF @RowcountVar > 0

RETURN

ValidationFailed:
SET @o_error_code = -1
RETURN

DBError:
SET @o_error_code = -2
IF @o_error_desc = ' '
  SET @o_error_desc = 'Error occurred during insert into qse_updatefeedback table.'
RETURN
        
END
go

GRANT EXEC ON qutl_execute_title_update TO PUBLIC
go
