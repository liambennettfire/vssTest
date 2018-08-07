IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_update_projects_in_list_base')
  DROP  Procedure  qutl_update_projects_in_list_base
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_update_projects_in_list_base
  (@xmlParameters   ntext,
  @SearchType       integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************
**  Name: qutl_update_projects_in_list_base
**  Desc: This stored procedure loops through all projects within the passed list
**        and issues updates for each project based on passed criteria array.
**
**  Auth: Kate J. Wiewiora
**  Date: 23 March 2009
***********************************************************************************
**    Change History
***********************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**  05/31/17    Colman    44295 - Created from original qutl_update_projects_in_list
**                        to support passing a searchtype.
***********************************************************************************/

DECLARE 
  @AccessCode INT,
  @AllowUpdateInd TINYINT,
  @ColumnName VARCHAR(120),
  @CriteriaKey  INT,  
  @CriteriaSequence VARCHAR(6),
  @CurrencyCode INT,  --gentable 122 (Currency)
  @DataTypeCode SMALLINT, --gentable 441 (Search Criteria Datatype)
  @DateTypeCode INT,  --gentable 323 (Task/Date Type)
  @DecimalValue DECIMAL(10,2),
  @DetailCriteriaInd  TINYINT,
  @DetailCriteriaKey  INT,
  @DocNum			INT,
  @ErrorVar   INT,
  @FailedInd  BIT,
  @FieldDescDetail  VARCHAR(255),
  @FirstItem  BIT,
  @HistoryCount INT,
  @HistoryOrder SMALLINT,
  @IsOpen			BIT,
  @ItemEstActBest CHAR(1),
  @ItemSubValue VARCHAR(120),
  @ItemSubValueDesc VARCHAR(120),
  @ItemSub2Value  VARCHAR(120),
  @ItemSub2ValueDesc  VARCHAR(120),
  @ItemValue  VARCHAR(120),
  @ItemValueDesc  VARCHAR(120),
  @Key1 INT,
  @Key2 INT,
  @Key1Column VARCHAR(30),
  @Key2Column VARCHAR(30),
  @LastCriteriaKey  INT,
  @LastSequenceNumber VARCHAR(3),
  @ListKey  INT,
  @ParentCriteriaKey  INT,
  @PriceTypeCode  INT,  --gentable 306 (Price Type)
  @QuoteStart VARCHAR(3),
  @QuoteEnd   VARCHAR(3),
  @RowcountVar  INT,	
  @SearchItem SMALLINT,  --gentable 550 (Search Item Type)
  @SecondColumnName   VARCHAR(120),
  @SecondTableName    VARCHAR(30),
  @SequenceNumber     VARCHAR(3),
  @SubgenColumnName   VARCHAR(120),
  @Subgen2ColumnName  VARCHAR(120),
  @SQLAddWhere  VARCHAR(1000),
  @SQLHistoryExec   NVARCHAR(2000),
  @SQLHistoryExec1  NVARCHAR(2000),
  @SQLHistoryExec2  NVARCHAR(2000),
  @SQLHistoryExec3  NVARCHAR(2000),
  @SQLHistoryExec4  NVARCHAR(2000),
  @SQLHistoryExec5  NVARCHAR(2000),
  @SQLHistorySubExec  NVARCHAR(2000),
  @SQLHistorySubExec1  NVARCHAR(2000),
  @SQLHistorySubExec2  NVARCHAR(2000),
  @SQLHistorySubExec3  NVARCHAR(2000),
  @SQLHistorySubExec4  NVARCHAR(2000),
  @SQLHistorySubExec5  NVARCHAR(2000),
  @SQLSetValues   VARCHAR(1000),
  @SQLUpdate    NVARCHAR(2000),
  @SQLUpdate1   NVARCHAR(2000),
  @SQLUpdate2   NVARCHAR(2000),
  @SQLUpdate3   NVARCHAR(2000),
  @SQLUpdate4   NVARCHAR(2000),
  @SQLUpdate5   NVARCHAR(2000),
  @SQLWhere   VARCHAR(2000),
  @SPError  INT,
  @SPErrorMessage VARCHAR(2000),  
  @TableName  VARCHAR(30),	
  @TempIndex  INT,
  @TempString VARCHAR(100),
  @TempSQL  NVARCHAR(1000),
  @Title    VARCHAR(255),
  @UpdateCount  INT,  
  @UserID   VARCHAR(30),
  @UserKey  INT,
  @XMLCriteria  VARCHAR(8000),	
  @XMLSearchString  VARCHAR(120),
  @CurrentProjectStatus int,
  @AcqCompletedDatacode int,
  @msg varchar(2000),
  @datadesc varchar(255),
  @Count INT,
  @SearchItemcode INT,
  @UsageClasscode INT, 
  @TempName NVARCHAR(2000),  
  @NewProjectStatus INT,
  @FileTypeCode INT,
  @task_activedate DATETIME,
  @task_datetypecode INT,
  @task_duration	INT,
  @task_taqtaskkey	INT,
  @task_startdate	DATETIME,
  @task_itemdateval	VARCHAR(120),
  @CriteriaKey1  INT,  
  @CriteriaKey2  INT,  
  @CriteriaKey3  INT,  
  @CriteriaKey4  INT,  
  @CriteriaKey5  INT,   
  @ColumnName1  VARCHAR(120),
  @ColumnName2  VARCHAR(120),
  @ColumnName3  VARCHAR(120),
  @ColumnName4  VARCHAR(120),
  @ColumnName5  VARCHAR(120),
  @SubgenColumnName1 VARCHAR(120),
  @SubgenColumnName2 VARCHAR(120),
  @SubgenColumnName3 VARCHAR(120),
  @SubgenColumnName4 VARCHAR(120),
  @SubgenColumnName5 VARCHAR(120),
  @SQLRelatedUpdate    NVARCHAR(2000),
  @SQLRelatedUpdate1   NVARCHAR(2000),
  @SQLRelatedUpdate2   NVARCHAR(2000),
  @SQLRelatedUpdate3   NVARCHAR(2000),
  @SQLRelatedUpdate4   NVARCHAR(2000),
  @SQLRelatedUpdate5   NVARCHAR(2000),    
  @filterorglevelkey INT,
  @orgentrykey INT,
  @OrgAccessCode INT      
	
	DECLARE @TaskTable TABLE
  (
		datetypecode	int,
		activedate		datetime
  )
  
  SET @task_activedate = NULL
	SET @task_datetypecode = NULL

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @FirstItem = 1
  SET @FailedInd = 0
  SET @o_error_code = 0
  SET @o_error_desc = NULL  
 
  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @xmlParameters

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML parameters document.'
    GOTO ExitHandler
  END
  
  SET @IsOpen = 1
  
  
  -- *********** Get Search request info from XML ************
  -- Get ListKey and UserKey elements from the passed XML document
  SELECT @ListKey = ListKey, @UserKey = UserKey  
  FROM OPENXML(@DocNum,  '/Transaction/DBAction/XMLParameter/Search')
  WITH (ListKey INT 'ListKey', UserKey INT 'UserKey')
        
  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting ListKey and UserKey from XML parameters.'
    GOTO ExitHandler
  END
  
  
  -- ******** Get the UserID for the given userkey ****** --
  SELECT @UserID = userid
  FROM qsiusers
  WHERE userkey = @UserKey

  -- Make sure qsiusers record exists for this userkey
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting UserID from qsiusers table (userkey=' + CONVERT(VARCHAR, @UserKey) +').'
    GOTO ExitHandler
  END
  
  -- ******** Get SearchItem from qse_searchlist for this list *****
  SELECT @SearchItem = searchitemcode
  FROM qse_searchlist
  WHERE listkey = @ListKey
  
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Missing qse_searchlist record (listkey=' + CONVERT(VARCHAR, @ListKey) + ').'
    GOTO ExitHandler
  END
  
  -- DEBUG
  PRINT '@ListKey=' + CONVERT(VARCHAR, @ListKey)
  PRINT '@UserKey=' + CONVERT(VARCHAR, @UserKey)  
  PRINT '@SearchType=' + CONVERT(VARCHAR, @SearchType)


  -- Delete any existing udpate feedback rows for this user/searchitemcode
  DELETE FROM qse_updatefeedback
  WHERE userkey = @UserKey AND searchitemcode = @SearchItem
  

  -- ****** Loop through all items in the list to build and issue UPDATE statements *****
  DECLARE listitems_cursor CURSOR FOR
    SELECT key1, key2, projecttitle, projectstatus, searchitemcode, usageclasscode
    FROM qse_searchresults, coreprojectinfo
    WHERE qse_searchresults.key1 = coreprojectinfo.projectkey AND
          qse_searchresults.listkey = @ListKey
    ORDER BY projecttitle
  
  OPEN listitems_cursor

  FETCH NEXT FROM listitems_cursor INTO @Key1, @Key2, @Title, @CurrentProjectStatus, @SearchItemcode, @UsageClasscode

  WHILE @@FETCH_STATUS = 0
  BEGIN
    
    -- Do not allow project to be updated if current value is 'Acquisition Completed' (qsicode = 1)        
    SELECT @AcqCompletedDatacode = datacode, @datadesc = datadesc
      FROM gentables
     WHERE tableid = 522
       AND qsicode = 1
       
    IF @SearchType = 21 AND @CurrentProjectStatus = @AcqCompletedDatacode BEGIN
      SET @FailedInd = 1
                    
      SET @msg = 'Updates are not allowed to ' + @Title + ' because it is locked due to its status of ' + @datadesc +'.'
      INSERT INTO qse_updatefeedback (userkey,searchitemcode,key1,key2,itemdesc,runtime,[message])
      VALUES (@UserKey,@SearchItem,@Key1,0,@Title,getdate(),@msg)
        
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0
      BEGIN
        --ROLLBACK TRANSACTION
        SET @o_error_code = -1
        SET @o_error_desc = 'Update failed for project ''' + @Title + ''' (projectkey=' + CONVERT(VARCHAR, @Key1) + ').'
        GOTO ExitHandler
      END
                             
      -- Skip further processing for this project
      GOTO GetNextListItem
    END
    
    -- Build the SET values clause for the UPDATE statement once - for the first project only
    IF @FirstItem = 1
    BEGIN

      SET @UpdateCount = 0
      SET @SequenceNumber = 1
      SET @SQLAddWhere = ''
      
      -- ***************** Parse UPDATE CRITERIA from XML ******************
      -- Loop to get all Search/Criteria elements from the passed XML document
      DECLARE criteria_cursor CURSOR LOCAL FOR 
        SELECT CriteriaSequence, CriteriaKey, DetailCriteriaKey
        FROM OPENXML(@DocNum,  '/Transaction/DBAction/XMLParameter/Search/Criteria')
        WITH (CriteriaSequence VARCHAR(6) 'CriteriaSequence',
            CriteriaKey INT 'CriteriaKey',
            DetailCriteriaKey INT 'DetailCriteriaKey')

      OPEN criteria_cursor

      FETCH NEXT FROM criteria_cursor
      INTO @CriteriaSequence, @CriteriaKey, @DetailCriteriaKey

      IF @@FETCH_STATUS <> 0	-- no criteria entered - return
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'No update criteria were entered.'
          GOTO ExitHandler
        END

      -- ***** CRITERIA LOOP *****
      WHILE @@FETCH_STATUS = 0
      BEGIN
        
        -- DEBUG
        PRINT '-'
        PRINT ' @CriteriaSequence=' +  @CriteriaSequence
        PRINT ' @CriteriaKey=' + CONVERT(VARCHAR, @CriteriaKey)
        IF @DetailCriteriaKey IS NOT NULL
          PRINT ' @DetailCriteriaKey=' + CONVERT(VARCHAR, @DetailCriteriaKey)
              
       -- Store the main/parent criteriakey for later comparison with next fetch
        SET @ParentCriteriaKey = @CriteriaKey
                
        -- Use DetailCriteriaKey when passed (used for composite search criteria)
        IF @DetailCriteriaKey IS NOT NULL
          SET @CriteriaKey = @DetailCriteriaKey        
                
        -- ***** Get DataType for this criteria and check criteria type *****
        SELECT @DataTypeCode = c.datatypecode,
            @DetailCriteriaInd = c.detailcriteriaind,
            @AllowUpdateInd = d.allowupdateind
        FROM qse_searchcriteria c
            LEFT OUTER JOIN qse_searchcriteriadetail d ON c.searchcriteriakey = d.detailcriteriakey and d.parentcriteriakey = @ParentCriteriaKey    
        WHERE c.searchcriteriakey = @CriteriaKey
         
        --DEBUG 
        --PRINT ' @DataTypeCode=' + CONVERT(VARCHAR, @DataTypeCode)
        --PRINT ' @DetailCriteriaInd=' + CONVERT(VARCHAR, @DetailCriteriaInd)
        --PRINT ' @@AllowUpdateInd=' + CONVERT(VARCHAR, @AllowUpdateInd)

        -- ***** Get additional criteria information based on SearchType *****
        SELECT @TableName = tablename,
          @ColumnName = columnname,
          @SubgenColumnName = subgencolumnname,
          @Subgen2ColumnName = subgen2columnname,
          @SecondTableName = secondtablename,
          @SecondColumnName = secondcolumnname
        FROM qse_searchtypecriteria
        WHERE searchtypecode = @SearchType AND 
              searchcriteriakey = @CriteriaKey

        -- Make sure qse_searchtypecriteria record exists
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 OR @RowcountVar = 0
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Missing qse_searchtypecriteria record (searchtypecode=' +
            CONVERT(VARCHAR, @SearchType) + ', searchcriteriakey=' + CONVERT(VARCHAR, @CriteriaKey) + ').'
          GOTO ExitHandler
        END
               
        IF @TableName IS NULL
          SET @TableName = ''
        IF @ColumnName IS NULL
          SET @ColumnName = ''
        IF @SubgenColumnName IS NULL
          SET @SubgenColumnName = ''
        IF @Subgen2ColumnName IS NULL
          SET @Subgen2ColumnName = ''
        IF @SecondTableName IS NULL
          SET @SecondTableName = ''
        IF @SecondColumnName IS NULL
          SET @SecondColumnName = ''
          
        -- Extract 'UPPER' from table name, if present
        IF UPPER(LEFT(@TableName, 6)) = 'UPPER('
          SET @TableName = SUBSTRING(@TableName, 7, 30)
        IF UPPER(LEFT(@SecondTableName, 6)) = 'UPPER('
          SET @SecondTableName = SUBSTRING(@SecondTableName, 7, 30)
          
        -- DEBUG
        PRINT ' @ColumnName=' + @ColumnName
        IF @SubgenColumnName <> ''
          PRINT ' @SubgenColumnName=' + @SubgenColumnName
        IF @Subgen2ColumnName <> ''
          PRINT ' @Subgen2ColumnName=' + @Subgen2ColumnName
        IF @SecondColumnName <> ''
          PRINT ' @SecondColumnName=' + @SecondColumnName
        
        -- Set the XML Criteria search string based on this Criteria's sequence number
        SET @XMLSearchString = '/Transaction/DBAction/XMLParameter/Search/Criteria[CriteriaSequence=''' + @CriteriaSequence + ''']/Item'    

        -- ******** Get Search/Criteria/Item values from the passed XML document ******   
        SELECT @ItemValue = Value, @ItemValueDesc = ValueDesc,
              @ItemSubValue = SubValue, @ItemSubValueDesc = SubValueDesc,
              @ItemSub2Value = Sub2Value, @ItemSub2ValueDesc = Sub2ValueDesc,
              @ItemEstActBest = EstActBest
        FROM OPENXML(@DocNum, @XMLSearchString)
        WITH (Value VARCHAR(120) 'Value',
              ValueDesc VARCHAR(120) 'ValueDesc',
              SubValue VARCHAR(120) 'SubValue',
              SubValueDesc VARCHAR(120) 'SubValueDesc',
              Sub2Value VARCHAR(120) 'Sub2Value',
              Sub2ValueDesc VARCHAR(120) 'Sub2ValueDesc',
              EstActBest CHAR(1) 'EstActBest')

        IF @@ERROR <> 0 BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Error extracting Item value criteria from XML parameters.'
          GOTO ExitHandler
        END
        
        --DEBUG
        PRINT ' @ItemValue=' + @ItemValue
        IF @ItemValueDesc IS NOT NULL
          PRINT ' @ItemValueDesc=' + @ItemValueDesc
        IF @ItemSubValue IS NOT NULL
          PRINT ' @ItemSubValue=' + @ItemSubValue
        IF @ItemSubValueDesc IS NOT NULL
          PRINT ' @ItemSubValueDesc=' + @ItemSubValueDesc
        IF @ItemSub2Value IS NOT NULL
          PRINT ' @ItemSub2Value=' + @ItemSub2Value
        IF @ItemSub2ValueDesc IS NOT NULL
          PRINT ' @ItemSub2ValueDesc=' + @ItemSub2ValueDesc
        IF @ItemEstActBest IS NOT NULL
          PRINT ' @ItemEstActBest=' + @ItemEstActBest
        
        -- Add needed quotation marks to string values
        SET @QuoteStart = ''
        SET @QuoteEnd = ''                
        IF @DataTypeCode = 1 OR @DataTypeCode = 9		--Text OR Text Flag
        BEGIN
          -- Set both quote strings to single quote
          SET @QuoteStart = ''''
          SET @QuoteEnd = ''''
          -- Replace single quote with double single quote in all string values
          SET @ItemValue = REPLACE(@ItemValue, '''', '''''')
        END        
        
        -- If ESTIMATED is selected, update SecondColumnName instead
        -- NOTE: this will only work if tablename = secondtablename
        IF @ItemEstActBest = 'E' AND LTRIM(@SecondColumnName) <> ''
          SET @ColumnName = @SecondColumnName
          
        IF @ItemEstActBest = 'A' AND @CriteriaKey = 87  --Task Date
        BEGIN
          SET @SubgenColumnName = 'actualind'
          SET @ItemSubValue = 1
        END          
        
        -- ********* Build the SQL Update values statement OR SQL Where clause, depending on criteria type *******
        -- For detail criteria used as row locators for the update (allowupdateind=0), 
        -- build the string to add to SQL Where clause, and continue to the next criteria row       
        IF @DetailCriteriaInd = 1 AND @AllowUpdateInd = 0
          BEGIN
            -- Build the additional WHERE clause string
            SET @SQLAddWhere = @SQLAddWhere + ' AND ' + @ColumnName + '=' + @QuoteStart + @ItemValue + @QuoteEnd
            IF @ItemSubValue IS NOT NULL
              SET @SQLAddWhere = @SQLAddWhere + ' AND ' + @SubgenColumnName + '=' + @ItemSubValue
            IF @ItemSub2Value IS NOT NULL
              SET @SQLAddWhere = @SQLAddWhere + ' AND ' + @Subgen2ColumnName + '=' + @ItemSub2Value            
              
            -- Skip further processing - fetch next criteria row
            GOTO FetchNextCriteria
          END
          
        ELSE  -- Standard criteria and updatable Detail criteria (allowupdateind=1)
          BEGIN
            -- Increment the total number of update statements to execute for each item in list
            SET @UpdateCount = @UpdateCount + 1
          
            -- Build the UPDATE table SET new column values statement
            SET @SQLSetValues = 'UPDATE ' + @TableName + ' SET '
            SET @SQLSetValues = @SQLSetValues + @ColumnName + '=' + @QuoteStart + @ItemValue + @QuoteEnd
            IF @ItemSubValue IS NOT NULL
              SET @SQLSetValues = @SQLSetValues + ', ' + @SubgenColumnName + '=' + @ItemSubValue
            IF @ItemSub2Value IS NOT NULL
              SET @SQLSetValues = @SQLSetValues + ', ' + @Subgen2ColumnName + '=' + @ItemSub2Value
            
            -- Add timestamp to the update statement
            SET @SQLSetValues = @SQLSetValues + ', lastuserid=''' + @UserID + ''', lastmaintdate=getdate()'   
          END --standard criteria and updatable detail criteria
                
        -- ******* Get key columns for this table from qse_searchtableinfo *******
        SELECT @Key1Column = tablekey1column, @Key2Column = tablekey2column
        FROM qse_searchtableinfo
        WHERE searchitemcode = @SearchItem AND UPPER(tablename) = UPPER(@TableName)

        -- Check if qse_searchtableinfo record exists for this searchitem and tablename
        SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
        IF @ErrorVar <> 0 OR @RowcountVar = 0
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Missing qse_searchtableinfo record (searchitemcode=' + 
            CONVERT(VARCHAR, @SearchItem) + ', tablename=''' + @TableName + ''').'
          GOTO ExitHandler
        END
        
        
        -- ******* Build the SQL Where clause for the UPDATE statement ********
        SET @SQLWhere = ' WHERE ' + @Key1Column + '=@p_Key1Value'
        IF @Key2Column IS NOT NULL
          SET @SQLWhere = @SQLWhere + ' AND ' + @Key2Column + '=@p_Key2Value'
                
        -- ******* Create full UPDATE SQL with Key1 and Key2 value parameters ******
        -- When updating the bookprice table, always update the ACTIVE price only - add
        -- activeind condition to the WHERE clause string
        IF @TableName = 'bookprice'
          SET @SQLAddWhere = @SQLAddWhere + ' AND activeind=1'
        -- Add additional conditions to the WHERE clause string
        SET @SQLWhere = @SQLWhere + @SQLAddWhere
        -- Build the UPDATE statement
        SET @SQLUpdate = @SQLSetValues + @SQLWhere
                
        -- ****** Save built SQL strings for dynamic execution *****
        -- NOTE: Up to 5 update parameters will be passed, so we'll have up to 5 updates
        SET @SQLRelatedUpdate = NULL
        
        IF @UpdateCount = 1
          BEGIN
            SET @CriteriaKey1 = @CriteriaKey
            SET @ColumnName1 = @ColumnName
            SET @SubgenColumnName1 = @SubgenColumnName          
            SET @SQLUpdate1 = @SQLUpdate
            SET @SQLHistoryExec1 = @SQLHistoryExec
            SET @SQLHistorySubExec1 = @SQLHistorySubExec
            IF @SQLRelatedUpdate IS NOT NULL
              SET @SQLRelatedUpdate1 = @SQLRelatedUpdate           
          END
        ELSE IF @UpdateCount = 2
          BEGIN
            SET @CriteriaKey2 = @CriteriaKey
            SET @ColumnName2 = @ColumnName
            SET @SubgenColumnName2 = @SubgenColumnName                 
            SET @SQLUpdate2 = @SQLUpdate
            SET @SQLHistoryExec2 = @SQLHistoryExec
            SET @SQLHistorySubExec2 = @SQLHistorySubExec
            IF @SQLRelatedUpdate IS NOT NULL
              SET @SQLRelatedUpdate2 = @SQLRelatedUpdate          
          END
        ELSE IF @UpdateCount = 3
          BEGIN
            SET @CriteriaKey3 = @CriteriaKey
            SET @ColumnName3 = @ColumnName
            SET @SubgenColumnName3 = @SubgenColumnName                 
            SET @SQLUpdate3 = @SQLUpdate
            SET @SQLHistoryExec3 = @SQLHistoryExec
            SET @SQLHistorySubExec3 = @SQLHistorySubExec
            IF @SQLRelatedUpdate IS NOT NULL
              SET @SQLRelatedUpdate3 = @SQLRelatedUpdate                     
          END
        ELSE IF @UpdateCount = 4
          BEGIN
            SET @CriteriaKey4 = @CriteriaKey
            SET @ColumnName4 = @ColumnName
            SET @SubgenColumnName4 = @SubgenColumnName              
            SET @SQLUpdate4 = @SQLUpdate
            SET @SQLHistoryExec4 = @SQLHistoryExec
            SET @SQLHistorySubExec4 = @SQLHistorySubExec
            IF @SQLRelatedUpdate IS NOT NULL
              SET @SQLRelatedUpdate4 = @SQLRelatedUpdate                     
          END
        ELSE
          BEGIN
            SET @CriteriaKey5 = @CriteriaKey
            SET @ColumnName5 = @ColumnName
            SET @SubgenColumnName5 = @SubgenColumnName             
            SET @SQLUpdate5 = @SQLUpdate
            SET @SQLHistoryExec5 = @SQLHistoryExec
            SET @SQLHistorySubExec5 = @SQLHistorySubExec
            IF @SQLRelatedUpdate IS NOT NULL
              SET @SQLRelatedUpdate5 = @SQLRelatedUpdate               
          END
          
        
        FetchNextCriteria:
        
        --IF @CriteriaKey = 86 --TASK/DATE
        BEGIN
					--IF @DetailCriteriaKey = 87 --taqprojecttask.activedate
					IF @CriteriaKey = 87 --taqprojecttask.activedate
					BEGIN
						IF @ItemValue IS NOT NULL AND LEN(@ItemValue) > 0
						BEGIN
							SET @task_itemdateval = @ItemValue
							SET @task_itemdateval = SUBSTRING(@task_itemdateval, CHARINDEX('''', @task_itemdateval) + 1, LEN(@task_itemdateval) - CHARINDEX('''', @task_itemdateval) + 1)
							SET @task_itemdateval = SUBSTRING(@task_itemdateval, 0, CHARINDEX('''', @task_itemdateval))
							
							SET @task_activedate = CONVERT(DATETIME, REPLACE(@task_itemdateval, '''', ''), 101)
						END
					END
					--ELSE IF @DetailCriteriaKey = 88 --taqprojecttask.datetypecode
					ELSE IF @CriteriaKey = 88 --taqprojecttask.datetypecode
					BEGIN
						IF @ItemValue IS NOT NULL AND LEN(@ItemValue) > 0
						BEGIN
							SET @task_datetypecode = CAST(@ItemValue AS INT)
						END
					END
        END
        
        -- Store the main criteriakey and sequence for comparison with next fetch
        SET @LastCriteriaKey = @ParentCriteriaKey
        SET @LastSequenceNumber = @SequenceNumber        
                
        FETCH NEXT FROM criteria_cursor
        INTO @CriteriaSequence, @CriteriaKey, @DetailCriteriaKey
        
        -- Extract the SequenceNumber from CriteriaSequence string
        -- (SequenceNumber::SubSequenceNumber)
        SET @TempIndex = CHARINDEX('::', @CriteriaSequence)
        IF @TempIndex > 0
          SET @SequenceNumber = SUBSTRING(@CriteriaSequence, 1, @TempIndex - 1)        
        
        -- Reset SQL Add Where clause and SQL History insert for each new criteria
        IF NOT (@CriteriaKey = @LastCriteriaKey AND @SequenceNumber = @LastSequenceNumber)
        BEGIN
          SET @SQLAddWhere = ''
          SET @SQLHistoryExec = NULL
          SET @SQLHistorySubExec = NULL
          
          IF @task_activedate IS NOT NULL AND @task_datetypecode IS NOT NULL
          BEGIN
						INSERT INTO @TaskTable
						(activedate, datetypecode)
						VALUES
						(@task_activedate, @task_datetypecode)
						
						SET @task_activedate = NULL
						SET @task_datetypecode = NULL
          END
        END
          
      END

      CLOSE criteria_cursor
      DEALLOCATE criteria_cursor        
       
      SET @FirstItem = 0      
      PRINT ' '
        
    END --IF @FirstItem=1
        

    -- ******* Add lock for this project ******
    -- Returned ACCESS CODE:
    --  0(Locked By Another User)
    --  1(Not Locked or Locked By This User already)
    -- -1(Error)
    -- NOTE: Hardcoding for Titles for now - will need to change based on SearchItem
    -- if calling SearchResultsUpdate functionality for Contacts and/or Projects    
    BEGIN TRANSACTION
    
    EXEC qutl_add_object_lock @UserID, 'taqprojectlock', 'taqprojectkey', null,
        @Key1, 0, 'project', 'TAQ', @AccessCode output, @o_error_code output, @o_error_desc output

    SELECT @ErrorVar = @@ERROR
    IF @ErrorVar <> 0 
    BEGIN
      ROLLBACK TRANSACTION
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not lock project (taqprojectkey=' + CONVERT(VARCHAR, @Key1) + ').'
      GOTO ExitHandler
    END 
                
    COMMIT TRANSACTION
    
    -- UK: Project org level security check is commented out for now because it was never implemeneted, I just added it while doing Case 34286
 --   SET @orgentrykey = NULL
	--SET @OrgAccessCode = 2
	
	--SELECT @filterorglevelkey = filterorglevelkey FROM filterorglevel WHERE filterkey = 7  -- User Org Access Level    
	
	--IF @filterorglevelkey IS NOT NULL BEGIN 
	--   SELECT @orgentrykey = t.orgentrykey
	--   FROM orglevel o 
	--   INNER JOIN taqprojectorgentry t ON o.orglevelkey = t.orglevelkey AND t.taqprojectkey = @Key1 
	--   AND t.orglevelkey = @filterorglevelkey
	--END         
        
    -- ****** BEGIN TRANSACTION for this project ******
    BEGIN TRANSACTION

    --DEBUG
    PRINT CONVERT(VARCHAR, @Key1) + ',' + CONVERT(VARCHAR, @Key2) + ':'
    
    IF @AccessCode = 1 
    --AND @OrgAccessCode = 2
     BEGIN
      
      -- ****** UPDATE 1 *******
      IF @SQLUpdate1 IS NOT NULL
      BEGIN
        -- DEBUG
        PRINT ' ' + @SQLUpdate1
            
        EXEC qutl_execute_project_update 1, @SQLUpdate1, @SQLHistoryExec1, @SQLHistorySubExec1, @SQLRelatedUpdate1,
          @CriteriaKey1, @UserKey, @SearchItem, @Key1, @ColumnName1, @SubgenColumnName1, @SPError OUT, @SPErrorMessage OUT
			  
        IF @SPError = -1
        BEGIN
          SET @FailedInd = 1
          GOTO Update2
        END
        ELSE IF @SpError = -2
        BEGIN
          ROLLBACK TRANSACTION
          GOTO ExitHandler
        END       
      END --IF @SQLUpdate1 IS NOT NULL
      

      -- ****** UPDATE 2 *******
      Update2:
            
      IF @SQLUpdate2 IS NOT NULL
      BEGIN
        -- DEBUG
        PRINT ' ' + @SQLUpdate2
        
		EXEC qutl_execute_project_update 2, @SQLUpdate2, @SQLHistoryExec2, @SQLHistorySubExec2, @SQLRelatedUpdate2,
		  @CriteriaKey2, @UserKey, @SearchItem, @Key1,@ColumnName2, @SubgenColumnName2, @SPError OUT, @SPErrorMessage OUT
				  
		IF @SPError = -1
		BEGIN
		 SET @FailedInd = 1
		 GOTO Update3
		END
		ELSE IF @SpError = -2
		BEGIN
		  ROLLBACK TRANSACTION
		  GOTO ExitHandler
		END        
      END --IF @SQLUpdate2 IS NOT NULL
      
      
      -- ****** UPDATE 3 *******
      Update3:
            
      IF @SQLUpdate3 IS NOT NULL
      BEGIN
        -- DEBUG
        PRINT ' ' + @SQLUpdate3
        
        EXEC qutl_execute_project_update 3, @SQLUpdate3, @SQLHistoryExec3, @SQLHistorySubExec3, @SQLRelatedUpdate3,
         @CriteriaKey3, @UserKey, @SearchItem, @Key1, @ColumnName3, @SubgenColumnName3, @SPError OUT, @SPErrorMessage OUT
			  
        IF @SPError = -1
        BEGIN
          SET @FailedInd = 1
          GOTO Update4
        END
        ELSE IF @SpError = -2
        BEGIN
          ROLLBACK TRANSACTION
          GOTO ExitHandler
        END      
      END --IF @SQLUpdate3 IS NOT NULL
      
      
      -- ****** UPDATE 4 *******
      Update4:
            
      IF @SQLUpdate4 IS NOT NULL
      BEGIN
        -- DEBUG
        PRINT ' ' + @SQLUpdate4
        
        EXEC qutl_execute_project_update 4, @SQLUpdate4, @SQLHistoryExec4, @SQLHistorySubExec4, @SQLRelatedUpdate4,
          @CriteriaKey4, @UserKey, @SearchItem, @Key1, @ColumnName4,@SubgenColumnName4, @SPError OUT, @SPErrorMessage OUT
			  
        IF @SPError = -1
        BEGIN
          SET @FailedInd = 1
          GOTO Update5
        END
        ELSE IF @SpError = -2
        BEGIN
          ROLLBACK TRANSACTION
          GOTO ExitHandler
        END      
      END --IF @SQLUpdate4 IS NOT NULL
      
      
      -- ****** UPDATE 5 *******
      Update5:
            
      IF @SQLUpdate5 IS NOT NULL
      BEGIN
        -- DEBUG
        PRINT ' ' + @SQLUpdate5

        EXEC qutl_execute_project_update 5, @SQLUpdate5, @SQLHistoryExec5, @SQLHistorySubExec5, @SQLRelatedUpdate5,
          @CriteriaKey5, @UserKey, @SearchItem, @Key1, @ColumnName5, @SubgenColumnName5, @SPError OUT, @SPErrorMessage OUT
			  
        IF @SPError = -1
        BEGIN
          SET @FailedInd = 1
          GOTO Updates_Finished
        END
        ELSE IF @SpError = -2
        BEGIN
          ROLLBACK TRANSACTION
          GOTO ExitHandler
        END
      END --IF @SQLUpdate5 IS NOT NULL
      
      Updates_Finished:      
      
      --UPDATE DURATION FOR ANY DATE TYPE TASK UPDATES
      SET @task_activedate = NULL
			SET @task_datetypecode = NULL
			
			DECLARE task_cursor CURSOR FOR
			SELECT activedate, datetypecode
			FROM @TaskTable
			
			OPEN task_cursor
			
			FETCH NEXT FROM task_cursor INTO @task_activedate, @task_datetypecode
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @task_taqtaskkey = NULL
				SET @task_startdate = NULL
				
				DECLARE duration_cursor CURSOR FOR
				SELECT t.taqtaskkey, t.startdate
				FROM taqprojecttask t
				JOIN datetype d
				ON (t.datetypecode = d.datetypecode)
				WHERE t.taqprojectkey = @Key1
					AND t.datetypecode = @task_datetypecode
					AND COALESCE(d.milestoneind, 0) = 0
					AND t.startdate IS NOT NULL
					
				OPEN duration_cursor

				FETCH NEXT FROM duration_cursor INTO @task_taqtaskkey, @task_startdate

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @task_activedate IS NOT NULL AND @task_startdate IS NOT NULL
					BEGIN
						IF @task_activedate > @task_startdate
						BEGIN
							SELECT @task_duration =
							 (DATEDIFF(dd, @task_startdate, @task_activedate) + 1)
							-(DATEDIFF(wk, @task_startdate, @task_activedate) * 2)
							-(CASE WHEN DATENAME(dw, @task_startdate) = 'Sunday' THEN 1 ELSE 0 END)
							-(CASE WHEN DATENAME(dw, @task_activedate) = 'Saturday' THEN 1 ELSE 0 END)
							
							UPDATE taqprojecttask
							SET duration = @task_duration, lastmaintdate = GETDATE()
							WHERE taqtaskkey = @task_taqtaskkey
						END
						ELSE BEGIN
							UPDATE taqprojecttask
							SET duration = NULL, lastmaintdate = GETDATE()
							WHERE taqtaskkey = @task_taqtaskkey
						END
					END
					
					FETCH NEXT FROM duration_cursor INTO @task_taqtaskkey, @task_startdate
				END
				
				CLOSE duration_cursor
				DEALLOCATE duration_cursor
				
				FETCH NEXT FROM task_cursor INTO @task_activedate, @task_datetypecode
			END
			
			CLOSE task_cursor
			DEALLOCATE task_cursor
      
      -- ********* Remove lock for this project ********  
      EXEC qutl_remove_object_lock @UserID, 'taqprojectlock', 'taqprojectkey', null,
          @Key1, 0, 'project', 'TAQ', @o_error_code output, @o_error_desc output 
          
      SELECT @ErrorVar = @@ERROR
      IF @ErrorVar <> 0 BEGIN
        ROLLBACK TRANSACTION
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to remove lock (taqprojectkey=' + CONVERT(VARCHAR, @Key1) + ').'
        GOTO ExitHandler
      END      
          
     END
    ELSE  -- @AccessCode=0 (locked by other user) OR @AccessCode=-1 (error)
     BEGIN
      -- DEBUG
      PRINT '  @AccessCode=' + CONVERT(VARCHAR, @AccessCode)
     
      -- Could not lock and update title - write to qse_updatefeedback table
      SET @FailedInd = 1
      SET @TempIndex = CHARINDEX('.', @o_error_desc, 0)
      SET @o_error_desc = SUBSTRING(@o_error_desc, 0, @TempIndex +1)
      
      INSERT INTO qse_updatefeedback     
        (userkey,
        searchitemcode,
        key1,
        key2,
        itemdesc,
        message,
        runtime)
      VALUES
        (@UserKey,
        @SearchItem,
        @Key1, 
        @Key2,
        @Title,
        @o_error_desc,
        getdate())
        
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0
      BEGIN
        ROLLBACK TRANSACTION
        SET @o_error_code = -1
        SET @o_error_desc = 'Update failed for project ''' + @Title + ''' (taqprojectkey=' + CONVERT(VARCHAR, @Key1) + ').'
        GOTO ExitHandler
      END
        
     END  --@AccessCode=0
        
    -- ****** COMMIT TRANSACTION for this project ******
    COMMIT TRANSACTION

    GetNextListItem:
    FETCH NEXT FROM listitems_cursor INTO @Key1, @Key2, @Title, @CurrentProjectStatus, @SearchItemcode, @UsageClasscode
  END

  CLOSE listitems_cursor
  DEALLOCATE listitems_cursor  
  
  GOTO ExitHandler
  

 ExitHandler:
  IF @IsOpen = 1
  BEGIN
    EXEC sp_xml_removedocument @DocNum
    SET @DocNum = NULL
  END
    
  IF @o_error_desc IS NOT NULL AND LTRIM(RTRIM(@o_error_desc)) <> ''
    PRINT 'ERROR: ' + @o_error_desc
    
  -- Flag this update to indicate to the calling function that some projects 
  -- within the passed list could not be updated (qse_updatefeedback records exist)
  IF @FailedInd = 1
    SET @o_error_code = -2
    
GO

GRANT EXEC ON qutl_update_projects_in_list_base TO PUBLIC
GO

