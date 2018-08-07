IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_update_titles_in_list')
BEGIN
  PRINT 'Dropping Procedure qutl_update_titles_in_list'
  DROP  Procedure  qutl_update_titles_in_list
END
GO

PRINT 'Creating Procedure qutl_update_titles_in_list'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_update_titles_in_list
  (@xmlParameters   ntext,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_update_titles_in_list
**  Desc: This stored procedure loops through all titles within the passed list
**        and issues updates for each title based on passed criteria array.
**
**  Auth: Kate J. Wiewiora
**  Date: 10 May 2006
*******************************************************************************/

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
  @EditionAddtlDesc VARCHAR(100),
  @EditionNumDesc VARCHAR(40),
  @ErrorVar   INT,
  @FailedInd  BIT,
  @FieldDescDetail  VARCHAR(255),
  @FullEditionDesc  VARCHAR(150),
  @MiscItemType varchar(255),
  @FirstItem  BIT,
  @HistoryCount INT,
  @IsOpen			BIT,
  @ItemEstActBest CHAR(1),
  @ItemSubValue VARCHAR(1000),
  @ItemSubValueDesc VARCHAR(1000),
  @ItemSub2Value  VARCHAR(1000),
  @ItemSub2ValueDesc  VARCHAR(1000),
  @ItemValue  VARCHAR(1000),
  @ItemValueDesc  VARCHAR(1000),
  @ItemValueOrig  VARCHAR(1000),
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
  @SearchType SMALLINT,  --gentable 442 (Search Type)
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
  @SQLRelatedUpdate    NVARCHAR(2000),
  @SQLRelatedUpdate1   NVARCHAR(2000),
  @SQLRelatedUpdate2   NVARCHAR(2000),
  @SQLRelatedUpdate3   NVARCHAR(2000),
  @SQLRelatedUpdate4   NVARCHAR(2000),
  @SQLRelatedUpdate5   NVARCHAR(2000),  
  @SQLSetValues   VARCHAR(1000),
  @SQLUpdate    NVARCHAR(2000),
  @SQLUpdate1   NVARCHAR(2000),
  @SQLUpdate2   NVARCHAR(2000),
  @SQLUpdate3   NVARCHAR(2000),
  @SQLUpdate4   NVARCHAR(2000),
  @SQLUpdate5   NVARCHAR(2000),
  @SQLWhere   VARCHAR(2000),
  @CriteriaKey1  INT,  
  @CriteriaKey2  INT,  
  @CriteriaKey3  INT,  
  @CriteriaKey4  INT,  
  @CriteriaKey5  INT,  
  @SPError  INT,
  @SPErrorMessage VARCHAR(2000),  
  @TableName  VARCHAR(30),	
  @TempIndex  INT,
  @TempString VARCHAR(100),
  @Title    VARCHAR(255),
  @UpdateCount  INT,  
  @UserID   VARCHAR(30),
  @UserKey  INT,
  @XMLSearchString  VARCHAR(120),
  @SendToEloquenceInd INT,
  @WindowName VARCHAR(100),
  @SecurityMessage VARCHAR(2000),
  @CommentTypeCode INT,
  @CommentTypeSubCode INT,
  @FileTypeCode INT,
  @task_activedate DATETIME,
	@task_datetypecode INT,
	@task_printingnum INT,
	@task_duration	INT,
	@task_taqtaskkey	INT,
	@task_startdate	DATETIME,
	@task_printkey	INT,
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
  @filterorglevelkey INT,
  @orgentrykey INT,
  @OrgAccessCode INT    
	
	DECLARE @TaskTable TABLE
  (
		firstprintonly	int,
		datetypecode	int,
		activedate		datetime
  )
  
  SET @task_activedate = NULL
	SET @task_datetypecode = NULL
	SET @task_printingnum = NULL
	
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
  
  -- ***** SearchType must be 15 (Search Results Update - gentable 442) *******
  SET @SearchType = 15
  
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


  -- Delete any existing update feedback rows for this user/searchitemcode
  DELETE FROM qse_updatefeedback
  WHERE userkey = @UserKey AND searchitemcode = @SearchItem
  
  -- Delete any existing update Addtl Processing rows for this user/searchitemcode
  DELETE FROM qse_update_addtlprocessing
  WHERE userkey = @UserKey AND searchitemcode = @SearchItem

  -- ****** Loop through all items in the list to build and issue UPDATE statements *****
  DECLARE listitems_cursor CURSOR fast_forward FOR
    SELECT key1, key2, title
    FROM qse_searchresults, coretitleinfo
    WHERE qse_searchresults.key1 = coretitleinfo.bookkey AND
          qse_searchresults.key2 = coretitleinfo.printingkey AND
          qse_searchresults.listkey = @ListKey
    ORDER BY title
  
  OPEN listitems_cursor

  FETCH NEXT FROM listitems_cursor INTO @Key1, @Key2, @Title

  WHILE @@FETCH_STATUS = 0
  BEGIN

    PRINT '@Key1=' + CONVERT(VARCHAR, @Key1)
    PRINT '@Key2=' + CONVERT(VARCHAR, @Key2)
        
    -- Build the SET values clause for the UPDATE statement once - for the first title only
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
       
        IF @CriteriaKey = 8 OR (@CriteriaKey = 14 AND @DetailCriteriaKey = 17) OR @CriteriaKey = 89 OR @CriteriaKey = 185 OR @CriteriaKey = 186 OR (@CriteriaKey = 187 AND @DetailCriteriaKey=191) OR (@CriteriaKey = 188 AND @DetailCriteriaKey=192) BEGIN
          -- Check Security
          IF @CriteriaKey = 185 BEGIN
            -- Never Send Title To Eloquence
            SET @SecurityMessage = @UserId + ' does not have access to: Never Send Title to Eloquence'
            SET @WindowName = 'ChangeNeverSendToEloquence'
          END
          ELSE IF @CriteriaKey = 186 BEGIN
            -- Send Title To Eloquence OR Do Not Send to Eloquence OR Remove From Eloquence
            SET @SecurityMessage = @UserId + ' does not have access to: Send Title to Eloquence'
            SET @WindowName = 'ChangeSendToEloquence'
          END
          ELSE IF @CriteriaKey = 187 AND @DetailCriteriaKey=191 BEGIN
            -- Change Eloquence Indicator for 
            SET @SecurityMessage = @UserId + ' does not have access to: Change Eloquence Indicator for File Type'
            SET @WindowName = 'RelToEloFileType'
          END
          ELSE IF @CriteriaKey = 188 AND @DetailCriteriaKey=192 BEGIN
            -- Send Title To Eloquence OR Do Not Send to Eloquence OR Remove From Eloquence
            SET @SecurityMessage = @UserId + ' does not have access to: Change Eloquence Indicator for Comment Type'
            SET @WindowName = 'RelToEloCommentType'
          END
		      ELSE IF @CriteriaKey = 8 BEGIN
			      SET @SecurityMessage = @UserId + ' does not have access to change: BISAC Status function'
			      SET @WindowName = 'ChangeBISACStatus'
		      END
		      ELSE IF @CriteriaKey = 14 AND @DetailCriteriaKey = 17 BEGIN
			      SET @SecurityMessage = @UserId + ' does not have access to change: PRICE function'
			      SET @WindowName = 'ChangePrice'
		      END 
		      ELSE IF @CriteriaKey = 89 BEGIN
			      SET @SecurityMessage = @UserId + ' does not have access to change: Eloquence Customer function'
			      SET @WindowName = 'ChangeEloquenceCustomer'
		      END                                 
                    
          exec dbo.qutl_check_page_security @UserKey, @WindowName, 0, @AccessCode out, @SPError out, @SPErrorMessage out
          
          IF @SPError < 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = @SPErrorMessage
            GOTO ExitHandler
          END
            
          IF @AccessCode = 0 BEGIN
            SET @FailedInd = 1
                          
            INSERT INTO qse_updatefeedback (userkey,searchitemcode,key1,key2,itemdesc,runtime,[message])
            VALUES (@UserKey,@SearchItem,0,0,'All Titles',getdate(),@SecurityMessage)
              
            SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
            IF @ErrorVar <> 0
            BEGIN
              ROLLBACK TRANSACTION
              SET @o_error_code = -1
              SET @o_error_desc = 'Update failed for title ''' + @Title + ''' (bookkey=' + CONVERT(VARCHAR, @Key1) + 
                ', printingkey=' + CONVERT(VARCHAR, @Key2) + ').'
              GOTO ExitHandler
            END
                        
            print @SecurityMessage
             
            -- Skip further processing for this criteria
            GOTO FetchNextCriteria
          END
        END
                
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
        PRINT ' @DataTypeCode=' + CONVERT(VARCHAR, @DataTypeCode)
        PRINT ' @DetailCriteriaInd=' + CONVERT(VARCHAR, @DetailCriteriaInd)
        PRINT ' @@AllowUpdateInd=' + CONVERT(VARCHAR, @AllowUpdateInd)

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
                  
        -- Save ItemValue in case the value is modified
        SET @ItemValueOrig = @ItemValue
        
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
                
        IF @CriteriaKey = 128 AND @ItemValueDesc IS NOT NULL --Edition
        BEGIN        
          -- We must update full edition description when editioncode is updated
          SELECT @EditionNumDesc = g.alternatedesc1, @EditionAddtlDesc = b.additionaleditinfo
          FROM bookdetail b LEFT OUTER JOIN gentables g ON b.editionnumber = g.datacode AND g.tableid = 557
          WHERE b.bookkey = @Key1
          
          SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
          IF @ErrorVar <> 0 OR @RowcountVar = 0
          BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Error getting Edition information for edition description update.'
            GOTO ExitHandler
          END                
         
          SET @FullEditionDesc = @ItemValueDesc
          IF @EditionNumDesc IS NOT NULL OR @EditionAddtlDesc IS NOT NULL
          BEGIN
            IF @EditionNumDesc IS NOT NULL
              SET @FullEditionDesc = @EditionNumDesc + ', ' + @ItemValueDesc
                            
            IF @EditionAddtlDesc IS NOT NULL
              SET @FullEditionDesc = @FullEditionDesc + ', ' + @EditionAddtlDesc
              
			SET @FullEditionDesc =  REPLACE(@FullEditionDesc, '''', '''''')                       
          END
          
          SET @SubgenColumnName = 'editiondescription'
          SET @ItemSubValue = '''' + @FullEditionDesc + ''''
        END
        
        -- Misc dropdowns have value in @ItemSubValue
        IF @TableName = 'bookmisc' AND @DataTypeCode = 4
        BEGIN
          SET @ItemValue = @ItemSubValue
          SET @ItemSubValue = null
          SET @ItemValueDesc = @ItemSubValueDesc
          SET @ItemSubValueDesc = null          
        END

        -- Setting Eloquence status
        IF @TableName = 'bookedistatus' AND @DataTypeCode = 6 BEGIN
          IF @CriteriaKey = 185 BEGIN
            -- Never Send to Eloquence
            IF @ItemValue = '1' BEGIN
              -- yes was selected - set edistatuscode to 8 (Never Send To Eloquence)
              SET @ItemValue = '8'
            END
            ELSE BEGIN
              -- clear edistatuscode
              SET @ItemValue = '0'
            END
            -- copy current edistatuscode into previousedistatuscode column
            SET @SubgenColumnName = 'previousedistatuscode'
            SET @ItemSubValue = 'edistatuscode'
          END
          ELSE BEGIN
            -- Didn't match a criteriakey - fetch next criteria row
            GOTO FetchNextCriteria
          END
        END

        IF @TableName = 'bookedistatus' AND @DataTypeCode = 10 BEGIN
          IF @CriteriaKey = 186 BEGIN
            -- Send to Eloquence
            IF @ItemValue = '1' BEGIN
              -- yes was selected - set edistatuscode as follows:
              -- if currently 8 (Never Send) - leave it
              -- if currently 1 (Not Sent) - leave it
              -- if currently 0 (Not filled in) - set it to 1 (Not Sent)             
              -- if not 0,1,8 - set it to 3 (resend)
              SET @ItemValue = 'CASE COALESCE(edistatuscode,0) 
                                 WHEN 0 THEN 1            
                                ELSE 3 END'    
              SET @SQLAddWhere = @SQLAddWhere + ' AND (COALESCE(edistatuscode,0) not in (1,8))'
            END
            ELSE IF @ItemValue = '2' BEGIN
              -- no was selected - set edistatuscode to 7 (do not send) as long as it isn't currently never send
              SET @ItemValue = '7'
              SET @SQLAddWhere = @SQLAddWhere + ' AND (COALESCE(edistatuscode,0) <> 8)'
            END
            ELSE IF @ItemValue = '3' BEGIN
              -- no and remove from eloquence was selected - set edistatuscode to 6 (delete)
              SET @ItemValue = '6'
            END
            ELSE BEGIN
              GOTO FetchNextCriteria
            END
            
            -- copy current edistatuscode into previousedistatuscode column
            SET @SubgenColumnName = 'previousedistatuscode'
            SET @ItemSubValue = 'edistatuscode'
          END
          ELSE BEGIN
            -- Didn't match a criteriakey - fetch next criteria row
            GOTO FetchNextCriteria
          END
        END
        
        -- Modify printingnum criteria - printingnum column lives on the printing table
        IF @CriteriaKey = 197
        BEGIN
          SET @ColumnName = 'printingkey'
          SET @ItemValue = '(SELECT printingkey FROM printing WHERE bookkey=@p_Key1Value AND printingnum=' + @QuoteStart + @ItemValue + @QuoteEnd + ')'
        END
        
        -- ********* Build the SQL Update values statement OR SQL Where clause, depending on criteria type *******
        -- For detail criteria used as row locators for the update (allowupdateind=0), 
        -- build the string to add to SQL Where clause, and continue to the next criteria row       
        IF @DetailCriteriaInd = 1 AND @AllowUpdateInd = 0
          BEGIN
            -- Build the additional WHERE clause string
            SET @SQLAddWhere = @SQLAddWhere + ' AND ' + @ColumnName + '=' + @QuoteStart + @ItemValue + @QuoteEnd
            IF @ItemSubValue IS NOT NULL AND COALESCE(@SubgenColumnName,'') <> ''
              SET @SQLAddWhere = @SQLAddWhere + ' AND ' + @SubgenColumnName + '=' + @ItemSubValue
            IF @ItemSub2Value IS NOT NULL AND COALESCE(@Subgen2ColumnName,'') <> ''
              SET @SQLAddWhere = @SQLAddWhere + ' AND ' + @Subgen2ColumnName + '=' + @ItemSub2Value            
              
            --print '@SQLAddWhere: ' + @SQLAddWhere
            
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
            IF @ItemSubValue IS NOT NULL AND COALESCE(@SubgenColumnName,'') <> ''
              SET @SQLSetValues = @SQLSetValues + ', ' + @SubgenColumnName + '=' + @ItemSubValue
            ELSE IF @SubgenColumnName <> ''
              SET @SQLSetValues = @SQLSetValues + ', ' + @SubgenColumnName + '=NULL'
            IF @ItemSub2Value IS NOT NULL AND COALESCE(@Subgen2ColumnName,'') <> '' 
              SET @SQLSetValues = @SQLSetValues + ', ' + @Subgen2ColumnName + '=' + @ItemSub2Value
            ELSE IF @Subgen2ColumnName <> ''
              SET @SQLSetValues = @SQLSetValues + ', ' + @Subgen2ColumnName + '=NULL'
            
            -- Add timestamp to the update statement
            SET @SQLSetValues = @SQLSetValues + ', lastuserid=''' + @UserID + ''', lastmaintdate=getdate()'
                        
            -- For titles, check if this table tracks history
            IF @SearchItem = 1  --Title
            BEGIN            
              -- Check if this table tracks history
              SELECT @HistoryCount = COUNT(*)
              FROM titlehistorycolumns 
              WHERE LOWER(tablename) = LOWER(@TableName)                
                
              IF @HistoryCount > 0  --yes, this table tracks history 
              BEGIN               
              
                -- For bookdates table update, must pass DateTypeCode for datehistory
                SET @DateTypeCode = 0
                IF @TableName = 'bookdates'
                BEGIN                    
                  -- Extract DateTypeCode from @SQLAddWhere clause
                  SET @TempIndex = CHARINDEX('datetypecode=', @SQLAddWhere)
                  IF @TempIndex > 0
                    SET @DateTypeCode = SUBSTRING(@SQLAddWhere, @TempIndex + 13, 100)
                    
                  PRINT ' @DateTypeCode=' + CONVERT(VARCHAR, @DateTypeCode)
                END
                
                -- For bookprice table update (Price Value), must pass PriceType shortdesc as
                -- titlehistory fielddesc, and append Currency shortdesc to Price Value changed
                SET @FieldDescDetail = 'NULL'
                IF @TableName = 'bookprice'
                BEGIN
                  -- Extract PriceTypeCode from @SQLAddWhere
                  SET @TempIndex = CHARINDEX('pricetypecode=', @SQLAddWhere)
                  IF @TempIndex > 0
                  BEGIN
                    SET @TempString = SUBSTRING(@SQLAddWhere, @TempIndex + 14, 100)
                    SET @TempIndex = CHARINDEX(' ', @TempString)
                    IF @TempIndex > 0
                      SET @PriceTypeCode = SUBSTRING(@TempString, 1, @TempIndex)
                      
                    IF @PriceTypeCode > 0
                    BEGIN
                      -- Get short description for the Price Type - save as FieldDescDetail
                      SELECT @FieldDescDetail = datadescshort
                      FROM gentables
                      WHERE tableid = 306 AND datacode = @PriceTypeCode
                    END                    
                  END

                  IF @FieldDescDetail IS NOT NULL
                   BEGIN
                     SET @FieldDescDetail = '''' + REPLACE(@FieldDescDetail, '''', '''''') + ''''
                   END 
                  
                  -- Extract CurrencyCode from @SQLAddWhere
                  SET @TempIndex = CHARINDEX('currencytypecode=', @SQLAddWhere)                 
                  IF @TempIndex > 0
                  BEGIN
                    SET @TempString = SUBSTRING(@SQLAddWhere, @TempIndex + 17, 100)
                    SET @TempIndex = CHARINDEX(' ', @TempString)
                    IF @TempIndex > 0
                      SET @CurrencyCode = SUBSTRING(@TempString, 1, @TempIndex)
                    ELSE
                      SET @CurrencyCode = SUBSTRING(@TempString, 1, 100)
                                          
                    IF @CurrencyCode > 0
                    BEGIN
                      -- Get short description for Currency - append to Price Value
                      SELECT @TempString = datadescshort
                      FROM gentables
                      WHERE tableid = 122 AND datacode = @CurrencyCode
                      
                      IF @TempString IS NOT NULL AND LTRIM(RTRIM(@TempString)) <> ''
                      BEGIN
                        -- First, format the price value to include 2 decimals
                        SET @DecimalValue = CONVERT(DECIMAL(10,2), @ItemValueDesc)
                        SET @ItemValueDesc = CONVERT(VARCHAR, @DecimalValue)
                        -- Append Currency short description to the formatted Price
                        SET @ItemValueDesc = @ItemValueDesc + ' ' + @TempString
                      END
                    END
                  END
                END --bookprice
                
                IF @TableName = 'bookcomments'
                BEGIN
                  SET @CommentTypeCode = 0
                  SET @CommentTypeSubCode = 0
                
                  -- Extract CommentTypeCode and CommentTypeSubCode from @SQLAddWhere
                  SET @TempIndex = CHARINDEX('commenttypecode=', @SQLAddWhere)
                  IF @TempIndex > 0
                  BEGIN
                    SET @TempString = SUBSTRING(@SQLAddWhere, @TempIndex + 16, 100)
                    SET @TempIndex = CHARINDEX(' ', @TempString)
                    IF @TempIndex > 0
                      SET @CommentTypeCode = SUBSTRING(@TempString, 1, @TempIndex)

                    print @SQLAddWhere
                    
                    SET @TempIndex = CHARINDEX('commenttypesubcode=', @SQLAddWhere)
                    IF @TempIndex > 0
                    BEGIN
                      SET @TempString = SUBSTRING(@SQLAddWhere, @TempIndex + 19, 100)
                      SET @TempIndex = CHARINDEX(' ', @TempString)
                      IF @TempIndex > 0
                        SET @CommentTypeSubCode = SUBSTRING(@TempString, 1, @TempIndex)
                      ELSE
                        SET @CommentTypeSubCode = SUBSTRING(@TempString, 1, 100)
                    END
                    
                    --PRINT ' @CommentTypeCode=' + CONVERT(VARCHAR, @CommentTypeCode)
                    --PRINT ' @CommentTypeSubCode=' + CONVERT(VARCHAR, @CommentTypeSubCode)
                      
                    IF @CommentTypeCode > 0 AND @CommentTypeSubCode > 0
                    BEGIN
                      -- Get short description for the Comment Type - save as FieldDescDetail
                      SELECT @FieldDescDetail = COALESCE(datadescshort,datadesc)
                      FROM subgentables
                      WHERE tableid = 284 
                        AND datacode = @CommentTypeCode
                        AND datasubcode = @CommentTypeSubCode
                        
                      IF @FieldDescDetail IS NOT NULL
                       BEGIN
                         IF @CommentTypeCode = 1 BEGIN
                           SET @FieldDescDetail = '(M) ' + @FieldDescDetail
                         END
                         ELSE IF @CommentTypeCode = 3 BEGIN
                           SET @FieldDescDetail = '(E) ' + @FieldDescDetail
                         END
                         ELSE IF @CommentTypeCode = 4 BEGIN
                           SET @FieldDescDetail = '(T) ' + @FieldDescDetail
                         END
                         ELSE IF @CommentTypeCode = 5 BEGIN
                           SET @FieldDescDetail = '(P) ' + @FieldDescDetail
                         END
                       
                         SET @FieldDescDetail = '''' + REPLACE(@FieldDescDetail, '''', '''''') + ''''
                       END                        
                    END                    
                  END
                END

                IF @TableName = 'filelocation'
                BEGIN
                  SET @FileTypeCode = 0
                
                  -- Extract FileTypeCode from @SQLAddWhere
                  SET @TempIndex = CHARINDEX('filetypecode=', @SQLAddWhere)
                  IF @TempIndex > 0
                  BEGIN
                    SET @TempString = SUBSTRING(@SQLAddWhere, @TempIndex + 13, 100)
                    SET @TempIndex = CHARINDEX(' ', @TempString)
                    IF @TempIndex > 0
                      SET @FileTypeCode = SUBSTRING(@TempString, 1, @TempIndex)
                    ELSE
                      SET @FileTypeCode = SUBSTRING(@TempString, 1, 100)

                    --print @SQLAddWhere
                                        
                    PRINT ' @FileTypeCode=' + CONVERT(VARCHAR, @FileTypeCode)
                      
                    IF @FileTypeCode > 0
                    BEGIN
                      -- Get short description for the File Type - save as FieldDescDetail
                      SELECT @FieldDescDetail = COALESCE(datadescshort,datadesc)
                      FROM gentables
                      WHERE tableid = 354
                        AND datacode = @FileTypeCode
                        
                      IF @FieldDescDetail IS NOT NULL
                       BEGIN
                         SET @FieldDescDetail = '''' + REPLACE(@FieldDescDetail, '''', '''''') + ''''
                       END                        
                    END                    
                  END
                END
                                
                IF @CriteriaKey = 150
                BEGIN
                  SET @ItemValueDesc = 'Customer Verification - ' + @ItemValueDesc
                END
                
                -- need to send miscname to title history procedure 
                IF @TableName = 'bookmisc'
                BEGIN

                  SELECT @FieldDescDetail = miscname, @MiscItemType = misckey
                  FROM bookmiscitems
                  WHERE searchcriteriakey = @CriteriaKey

                  IF @FieldDescDetail IS NOT NULL
                   BEGIN
                     SET @FieldDescDetail = '''' + REPLACE(@FieldDescDetail, '''', '''''') + ''''
                   END 
                END
                           
                --print ' @FieldDescDetail: ' + @FieldDescDetail
                
                -- Replace single quote with double single quote in all string value descriptions
                SET @ItemValueDesc = '''' + REPLACE(@ItemValueDesc, '''', '''''') + ''''
                SET @ItemSubValueDesc = '''' + REPLACE(@ItemSubValueDesc, '''', '''''') + ''''
                SET @ItemSub2ValueDesc = '''' + REPLACE(@ItemSub2ValueDesc, '''', '''''') + ''''   
                
                -- For bookdates udpate, use ItemValueDesc string (ex: 3/26/09) rather than ItemValue string (ex. CONVERT(datetime, '3/26/2009', 101))
                IF @DateTypeCode > 0
                BEGIN
                  SET @ItemValue = @ItemValueDesc
                END
                
                -- For gentables or other drop-downs, write value description to title history
                IF @DataTypeCode = 4 OR @DataTypeCode = 10
                BEGIN
                  SET @ItemValue = @ItemValueDesc
                END                
                
                -- *** Build history SQL Procedure EXECUTE statment for ColumnName: ***
                --tablename,columnname,
                --bookkey,printingkey,datetypecode,
                --currentstringvalue,
                --transtype,userid,historyorder,
                --fielddescdetail,error_code,error_desc
                SET @SQLHistoryExec = N'EXEC qtitle_update_titlehistory ' + 
                  @TableName + ',' + @ColumnName + 
                  ',@p_Key1Value,@p_Key2Value,' + CONVERT(VARCHAR, @DateTypeCode) + ',' + 
                  @QuoteStart + @ItemValue + @QuoteEnd + 
                  ',''update'',''' + @UserID + ''',@p_HistoryOrder,' + 
                  @FieldDescDetail + ',@SPError OUTPUT,@SPErrorMessage OUTPUT'
                                  
                -- *** Build history SQL Procedure EXECUTE statment for SubColumnName ***
                IF @SubgenColumnName <> ''
                  SET @SQLHistorySubExec = N'EXEC qtitle_update_titlehistory ' + 
                    @TableName + ',' + @SubgenColumnName + 
                    ',@p_Key1Value,@p_Key2Value,NULL,' +
                    @QuoteStart + @ItemSubValueDesc + @QuoteEnd + 
                    ',''update'',''' + @UserID + ''',@p_HistoryOrder,' + 
                    @FieldDescDetail + ',@SPError OUTPUT,@SPErrorMessage OUTPUT'                                
              END -- @HistoryCount > 0 (title tracks history)
            END --@SearchItem = 1 (Titles)            
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
        
        -- When updating the bookprice table, always update the ACTIVE price only - add
        -- activeind condition to the WHERE clause string
        IF @TableName = 'bookprice'
          SET @SQLAddWhere = @SQLAddWhere + ' AND activeind=1'

        IF @TableName = 'bookmisc'
		      SET @SQLAddWhere = @SQLAddWhere + ' AND misckey=' + @MiscItemType
		      
		    IF @TableName = 'bookverification'
		      SET @SQLAddWhere = @SQLAddWhere + ' AND verificationtypecode=1'

        -- For BISAC Status criteria, must also delete Expected Ship Date
        SET @SQLRelatedUpdate = NULL
        IF @CriteriaKey = 8 BEGIN
          SET @SQLRelatedUpdate = 'DELETE FROM bookdates WHERE bookkey=@p_Key1Value' +
            ' AND printingkey=@p_Key2Value' + 
            ' AND datetypecode IN (SELECT datetypecode FROM datetype WHERE qsicode=9)'
        END
        
        -- If setting edistatuscode, need to also update bookedipartner table
        IF @TableName = 'bookedistatus' BEGIN
          IF @CriteriaKey = 185 BEGIN
            -- Never Send to Eloquence
            SET @SendToEloquenceInd = 0

            SET @SQLRelatedUpdate = 'UPDATE bookedipartner' + 
              ' SET sendtoeloquenceind = ' + CONVERT(VARCHAR, @SendToEloquenceInd) +
              ' WHERE bookkey=@p_Key1Value AND printingkey=@p_Key2Value' 
          END
          ELSE IF @CriteriaKey = 186 BEGIN
            IF @ItemValueOrig = '1' OR @ItemValueOrig = '3' BEGIN
              -- Send to Eloquence or Remove From Eloquence
              SET @SendToEloquenceInd = 1
            END
            ELSE BEGIN
              -- Do Not Send to Eloquence
              SET @SendToEloquenceInd = 0
            END
            
            SET @SQLRelatedUpdate = 'UPDATE bookedipartner' + 
              ' SET sendtoeloquenceind = ' + CONVERT(VARCHAR, @SendToEloquenceInd) +
              ' WHERE bookkey=@p_Key1Value AND printingkey=@p_Key2Value' 
          END
          ELSE BEGIN
            -- Didn't match a criteriakey - fetch next criteria row
            GOTO FetchNextCriteria
          END
        END
        
        -- ******* Create full UPDATE SQL with Key1 and Key2 value parameters ******
        -- Add additional conditions to the WHERE clause string
        SET @SQLWhere = @SQLWhere + @SQLAddWhere
        -- Build the UPDATE statement
        SET @SQLUpdate = @SQLSetValues + @SQLWhere
                       
        -- ****** Save built SQL strings for dynamic execution *****
        -- NOTE: Up to 5 update parameters will be passed, so we'll have up to 5 updates
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
						IF @ItemValueDesc IS NOT NULL AND LEN(@ItemValueDesc) > 0
						BEGIN
							SET @task_activedate = CONVERT(DATETIME, REPLACE(@ItemValueDesc, '''', ''), 101)
						END
					END
					--ELSE IF @DetailCriteriaKey = 88 --taqprojecttask.datetypecode
					ELSE IF @CriteriaKey = 88 --taqprojecttask.datetypecode
					BEGIN
						IF @ItemValueOrig IS NOT NULL AND LEN(@ItemValueOrig) > 0
						BEGIN
							SET @task_datetypecode = CAST(@ItemValueOrig AS INT)
						END
					END
					--ELSE IF @DetailCriteriaKey = 197 --printingnum
					ELSE IF @CriteriaKey = 197 --printingnum
					BEGIN
						SET @task_printingnum = CAST(@ItemValueOrig AS INT)
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
          
          IF @task_printingnum IS NULL
          BEGIN
						SET @task_printingnum = 0
          END
          
          IF @task_activedate IS NOT NULL AND @task_datetypecode IS NOT NULL AND @task_printingnum IS NOT NULL
          BEGIN
						INSERT INTO @TaskTable
						(activedate, datetypecode, firstprintonly)
						VALUES
						(@task_activedate, @task_datetypecode, @task_printingnum)
						
						SET @task_activedate = NULL
						SET @task_datetypecode = NULL
						SET @task_printingnum = NULL
          END
        END
          
      END

      CLOSE criteria_cursor
      DEALLOCATE criteria_cursor        
       
      SET @FirstItem = 0      
      PRINT ' '
        
    END --IF @FirstItem=1
        
        
    ---------------------------------------------------
    
    -- ******* Add lock for this title ******
    -- Returned ACCESS CODE:
    --  0(Locked By Another User)
    --  1(Not Locked or Locked By This User already)
    -- -1(Error)
    BEGIN TRANSACTION
    
    EXEC qutl_add_object_lock @UserID, 'booklock', 'bookkey', 'printingkey',
        @Key1, 0, 'title', 'TMMW', @AccessCode output, @o_error_code output, @o_error_desc output

    SELECT @ErrorVar = @@ERROR
    IF @ErrorVar <> 0 
    BEGIN
      ROLLBACK TRANSACTION
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not lock title (bookkey=' + CONVERT(VARCHAR, @Key1) + ', printingkey=' + CONVERT(VARCHAR, @Key2) + ').'
      GOTO ExitHandler
    END 
                
    COMMIT TRANSACTION
    
    SET @orgentrykey = NULL
	SET @OrgAccessCode = 2
	
	SELECT @filterorglevelkey = filterorglevelkey FROM filterorglevel WHERE filterkey = 7  -- User Org Access Level    
	
	IF @filterorglevelkey IS NOT NULL BEGIN 
	   SELECT @orgentrykey = b.orgentrykey
	   FROM orglevel o 
	   INNER JOIN bookorgentry b ON o.orglevelkey = b.orglevelkey AND b.bookkey = @Key1 
	   AND b.orglevelkey = @filterorglevelkey
	END 
    
    IF @AccessCode = 1 AND @orgentrykey IS NOT NULL
    BEGIN                  			    
	  EXEC qutl_check_user_orgsecurity @UserKey, @orgentrykey, @OrgAccessCode output, @o_error_code output, @o_error_desc output

	  SELECT @ErrorVar = @@ERROR
	  IF @ErrorVar <> 0 
	  BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Could not execute procedure: qutl_check_user_orgsecurity.'
		GOTO ExitHandler
	  END 
		
	  IF @OrgAccessCode <> 2 BEGIN		
		-- ********* Remove lock for this title ********  
		EXEC qutl_remove_object_lock @UserID, 'booklock', 'bookkey', 'printingkey',
			@Key1, 0, 'title', 'TMMW', @o_error_code output, @o_error_desc output 
	          
		SELECT @ErrorVar = @@ERROR
		IF @ErrorVar <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Unable to remove lock (bookkey=' + CONVERT(VARCHAR, @Key1) + ', printingkey=' + CONVERT(VARCHAR, @Key2) + ').'
		  GOTO ExitHandler
		END 

		SET @o_error_desc = @UserId + ' does not have access to change this title: Org Level security set to Read Only / No Access.'		  		
	  END		  
    END
    
    
    -- ****** BEGIN TRANSACTION for this title ******
    BEGIN TRANSACTION

    --DEBUG
    PRINT CONVERT(VARCHAR, @Key1) + ',' + CONVERT(VARCHAR, @Key2) + ':'
    
    IF @AccessCode = 1 AND @OrgAccessCode = 2
    BEGIN              
      -- ****** UPDATE 1 *******
      IF @SQLUpdate1 IS NOT NULL
      BEGIN      
        EXEC qutl_execute_title_update 1, @SQLUpdate1, @SQLHistoryExec1, @SQLHistorySubExec1, @SQLRelatedUpdate1,
          @CriteriaKey1, @UserKey, @SearchItem, @Key1, @Key2, @ColumnName1, @SubgenColumnName1, @SPError OUT, @SPErrorMessage OUT
			  
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
      END
      
      -- ****** UPDATE 2 *******
      Update2:
      
      IF @SQLUpdate2 IS NOT NULL
      BEGIN
        EXEC qutl_execute_title_update 2, @SQLUpdate2, @SQLHistoryExec2, @SQLHistorySubExec2, @SQLRelatedUpdate2,
          @CriteriaKey2, @UserKey, @SearchItem, @Key1, @Key2,@ColumnName2, @SubgenColumnName2, @SPError OUT, @SPErrorMessage OUT
			  
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
      END
      
      -- ****** UPDATE 3 *******
      Update3:
      
      IF @SQLUpdate3 IS NOT NULL
      BEGIN
         EXEC qutl_execute_title_update 3, @SQLUpdate3, @SQLHistoryExec3, @SQLHistorySubExec3, @SQLRelatedUpdate3,
          @CriteriaKey3, @UserKey, @SearchItem, @Key1, @Key2, @ColumnName3, @SubgenColumnName3, @SPError OUT, @SPErrorMessage OUT
			  
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
      END
      
      -- ****** UPDATE 4 *******
      Update4:
      
      IF @SQLUpdate4 IS NOT NULL
      BEGIN
        EXEC qutl_execute_title_update 4, @SQLUpdate4, @SQLHistoryExec4, @SQLHistorySubExec4, @SQLRelatedUpdate4,
          @CriteriaKey4, @UserKey, @SearchItem, @Key1, @Key2, @ColumnName4,@SubgenColumnName4, @SPError OUT, @SPErrorMessage OUT
			  
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
      END
      
      -- ****** UPDATE 5 *******
      Update5:
      
      IF @SQLUpdate5 IS NOT NULL
      BEGIN
        EXEC qutl_execute_title_update 5, @SQLUpdate5, @SQLHistoryExec5, @SQLHistorySubExec5, @SQLRelatedUpdate5,
          @CriteriaKey5, @UserKey, @SearchItem, @Key1, @Key2, @ColumnName5, @SubgenColumnName5, @SPError OUT, @SPErrorMessage OUT
			  
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
      END
      
      Updates_Finished:
      
      --UPDATE DURATION FOR ANY DATE TYPE TASK UPDATES
      SET @task_activedate = NULL
			SET @task_datetypecode = NULL
			SET @task_printingnum = NULL
			
			DECLARE task_cursor CURSOR FOR
			SELECT activedate, datetypecode, firstprintonly
			FROM @TaskTable
			
			OPEN task_cursor
			
			FETCH NEXT FROM task_cursor INTO @task_activedate, @task_datetypecode, @task_printingnum
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @task_taqtaskkey = NULL
				SET @task_startdate = NULL
				SET @task_printkey = NULL
				
				DECLARE duration_cursor CURSOR FOR
				SELECT t.taqtaskkey, t.startdate, t.printingkey
				FROM taqprojecttask t
				JOIN datetype d
				ON (t.datetypecode = d.datetypecode)
				WHERE t.bookkey = @Key1
					AND t.datetypecode = @task_datetypecode
					AND (@task_printingnum = 0 OR t.printingkey = 1)
					AND COALESCE(d.milestoneind, 0) = 0
					AND t.startdate IS NOT NULL
					
				OPEN duration_cursor

				FETCH NEXT FROM duration_cursor INTO @task_taqtaskkey, @task_startdate, @task_printkey

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
					
					FETCH NEXT FROM duration_cursor INTO @task_taqtaskkey, @task_startdate, @task_printkey
				END
				
				CLOSE duration_cursor
				DEALLOCATE duration_cursor
				
				FETCH NEXT FROM task_cursor INTO @task_activedate, @task_datetypecode, @task_printingnum
			END
			
			CLOSE task_cursor
			DEALLOCATE task_cursor
      
      -- ********* Remove lock for this title ********  
      EXEC qutl_remove_object_lock @UserID, 'booklock', 'bookkey', 'printingkey',
          @Key1, 0, 'title', 'TMMW', @o_error_code output, @o_error_desc output 
          
      SELECT @ErrorVar = @@ERROR
      IF @ErrorVar <> 0 BEGIN
        ROLLBACK TRANSACTION
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to remove lock (bookkey=' + CONVERT(VARCHAR, @Key1) + ', printingkey=' + CONVERT(VARCHAR, @Key2) + ').'
        GOTO ExitHandler
      END      
          
    END
    ELSE
    BEGIN  -- @AccessCode=0 (locked by other user) OR @AccessCode=-1 (error), @OrgAccessCode = 0 or 1 (Read Only / No Access Org Level Security set)

      PRINT '  @AccessCode=' + CONVERT(VARCHAR, @AccessCode)
      PRINT '  @OrgAccessCode=' + CONVERT(VARCHAR, @OrgAccessCode)         
     
      -- Could not lock and update title - write to qse_updatefeedback table
      SET @FailedInd = 1
      SET @TempIndex = CHARINDEX('.', @o_error_desc, 0)
      SET @o_error_desc = SUBSTRING(@o_error_desc, 0, @TempIndex +1)
      
      INSERT INTO qse_updatefeedback     
        (userkey, searchitemcode, key1, key2, itemdesc, message, runtime)
      VALUES
        (@UserKey, @SearchItem, @Key1, @Key2, @Title, @o_error_desc, getdate())
        
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0
      BEGIN
        ROLLBACK TRANSACTION
        SET @o_error_code = -1
        SET @o_error_desc = 'Update failed for title ''' + @Title + ''' (bookkey=' + CONVERT(VARCHAR, @Key1) + 
          ', printingkey=' + CONVERT(VARCHAR, @Key2) + ').'
        GOTO ExitHandler
      END
        
    END  --@AccessCode=0
        
    -- ****** COMMIT TRANSACTION for this title ******
    COMMIT TRANSACTION
    
    GetNextListItem:
    
    FETCH NEXT FROM listitems_cursor INTO @Key1, @Key2, @Title
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
    
  -- Flag this update to indicate to the calling function that some titles 
  -- within the passed list could not be updated (qse_updatefeedback records exist)
  IF @FailedInd = 1
    SET @o_error_code = -2
      
GO

GRANT EXEC ON qutl_update_titles_in_list TO PUBLIC
GO