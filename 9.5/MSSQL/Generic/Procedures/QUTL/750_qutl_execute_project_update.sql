IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_execute_project_update')
BEGIN
  PRINT 'Dropping Procedure qutl_execute_project_update'
  DROP  Procedure  qutl_execute_project_update
END
GO

PRINT 'Creating Procedure qutl_execute_project_update'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_execute_project_update
 (@UpdateNumber       INT,
  @SQLUpdate          NVARCHAR(2000),
  @SQLHistoryExec     NVARCHAR(2000),
  @SQLHistorySubExec  NVARCHAR(2000),
  @SQLRelatedUpdate   NVARCHAR(2000),
  @CriteriaKey        INT,
  @UserKey            INT,
  @SearchItem         INT,
  @ProjectKey         INT,
  @ColumnName         VARCHAR(120),
  @SubgenColumnName   VARCHAR(120),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*****************************************************************************************************************
**  Name: qutl_execute_project_update
**  Desc: This stored procedure is called from qutl_udpate_titles_in_list.
**        It processes and executes the related update statements for any of the 5 allowed update criteria.
**        Returns 0 if all sucessful, -1 if validation failed for this update and processing should continue 
**        in the calling procedure to the next update, -2 if DB Error occurred and all processing should stop.
**
**  Auth: Uday A. Khisty
**  Date: 8 October 2015
******************************************************************************************************************/

DECLARE
  @CurrentProjectStatus int,
  @TempName NVARCHAR(2000), 
  @NewProjectStatus INT,    
  @SearchItemcode INT,
  @UsageClasscode INT,   
  @Count INT,    
  @RowcountVar  INT,
  @ErrorVar   INT,  	
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
  @WindowName VARCHAR(100),
  @SecurityMessage VARCHAR(2000),
  @FailedInd  BIT,
  @AccessCode INT,
  @v_objectlist_xml varchar(4000),
  @WindowID INT,
  @AvailObjectID VARCHAR(50),   
  @AvailObjectName VARCHAR(50),
  @AvailObjectIDAndName VARCHAR(100),
  @Object VARCHAR(100),
  @AvailObjectDesc VARCHAR(50),
  @DocNum1 INT,
  @DateType INT,  
  @datetype_accesscode SMALLINT,   
  @datelabel VARCHAR(100)
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ' '

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
  SELECT @Title = projecttitle, @CurrentProjectStatus = projectstatus, @SearchItemcode = searchitemcode, @UsageClasscode = usageclasscode  
  FROM coreprojectinfo
  WHERE projectkey = @ProjectKey
  
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0
  BEGIN
    SET @o_error_desc = 'Error getting project information (projectkey=' + CONVERT(VARCHAR, @ProjectKey) + ').'
    GOTO DBError
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
  
  -- ***** Get DataType for this criteria and check criteria type *****
  SET @WindowName = 'projectsummary'  
  SELECT @WindowID = windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = @WindowName
        
  exec dbo.qutl_check_page_object_security @UserKey,@WindowName,0,0,@ProjectKey,@AccessCode output,
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
	   
	   IF EXISTS(SELECT  *
		  FROM OPENXML(@DocNum1,  '/Security')
		  WHERE text IS NOT NULL AND CONVERT(VARCHAR(100), text) = @AvailObjectIDAndName) BEGIN
		  
			SET @FailedInd = 1
		                      
			SET @SecurityMessage = @UserId + ' is not allowed to update : ' + @AvailObjectDesc							
		                                  
			INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
			VALUES (@UserKey, @SearchItem, @ProjectKey, 0, @Title, getdate(), @SecurityMessage)	            
		        	      
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
  
  IF @TableName = 'taqproject'
  BEGIN
    -- Extract PriceTypeCode and CurrencyCode from the WHERE clause of the update statement
    SET @TempIndex = CHARINDEX('taqprojectstatuscode=', @SQLUpdate)
    IF @TempIndex > 0
    BEGIN
		SET @TempName = SUBSTRING(@SQLUpdate, @TempIndex + 21, 100)
		SET @TempIndex = CHARINDEX(', ', @TempName)
		SET @NewProjectStatus = CONVERT(int, LTRIM(RTRIM(SUBSTRING(@TempName, 0, @TempIndex))))    

		SELECT @Count = COUNT(*)
		FROM gentablesitemtype
		WHERE tableid = 522 AND datacode = @NewProjectStatus
		  AND itemtypecode = @SearchItemcode
		  AND COALESCE(itemtypesubcode,0) IN (0,@UsageClasscode)

		IF @Count = 0 
		BEGIN
		  SET @FailedInd = 1
          
		  INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
		  VALUES (@UserKey, @SearchItem, @ProjectKey, 0, @Title, getdate(), 'New Status is not allowed for ' + @Title + '.')

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
  
-- UK: Commented it out for now because we dont currently have tables for projectkey security for statuses
--  IF @TableName = 'bookdates' OR @TableName = 'taqprojecttask'
--  BEGIN     
--    -- Extract DateTypeCode from the WHERE clause of the update statement
--    SET @TempIndex = CHARINDEX('datetypecode=', @SQLUpdate)
--    IF @TempIndex > 0 BEGIN
--      SET @TempString = SUBSTRING(@SQLUpdate, @TempIndex + 13, 100)

--      SET @TempIndex = CHARINDEX(' ', @TempString)
--      IF @TempIndex = 0 BEGIN
--        SET @TempIndex = len(@TempString)
--      END

--      IF @TempIndex > 0 BEGIN
--        SET @DateType = SUBSTRING(@TempString, 1, @TempIndex)
                     
--        PRINT ' @DateType=' + CONVERT(VARCHAR, @DateType)      
        
--        IF @DateType > 0 BEGIN
--          SELECT @datetype_accesscode = dbo.qutl_check_gentable_value_security(@UserKey, 'tasktracking', 323, @DateType, 0, 0, 0)

--          IF COALESCE(@datetype_accesscode,2) IN (0,1) BEGIN  -- not allowed to update
----            SET @FailedInd = 1
                   
--            SELECT @datelabel = COALESCE(datelabel, description) 
--            FROM datetype 
--            WHERE datetypecode = @DateType
                   
--            INSERT INTO qse_updatefeedback (userkey, searchitemcode, key1, key2, itemdesc, runtime, message)
--            VALUES (@UserKey, @SearchItem, @ProjectKey, 0, @Title, getdate(), 'Not allowed to update task type: ' + '''' + @datelabel + '''')
              
--            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
--            IF @ErrorVar <> 0
--            BEGIN
--              GOTO DBError
--            END
                          
--            -- Skip further processing for this update - goto next update in the calling stored procedure
--            GOTO ValidationFailed 
--          END
--        END  
--      END     
--    END
--  END  
  
  -- DEBUG
  PRINT ' ' + @SQLUpdate

  EXECUTE sp_executesql @SQLUpdate, N'@p_Key1Value INT,@p_Key2Value INT', @ProjectKey, 0
          
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0
  BEGIN
    SET @o_error_desc = 'Error executing SQL UPDATE ' + CONVERT(VARCHAR, @UpdateNumber) + ': ' + @SQLUpdate + ' (taqprojectkey=' + CONVERT(VARCHAR, @ProjectKey) + ').'
    GOTO DBError
  END  
  
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

GRANT EXEC ON qutl_execute_project_update TO PUBLIC
go
