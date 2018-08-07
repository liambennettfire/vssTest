IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_search_request')
BEGIN
  PRINT 'Dropping Procedure qse_search_request'
  DROP PROCEDURE  qse_search_request
END
GO

PRINT 'Creating Procedure qse_search_request'
GO

/******************************************************************************
**  Name: qse_search_request
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/25/2016   UK          Case 36563
**  11/30/2016   Colman      Case 41930 Allow multiple Bookkey and UPCs on Title Search 
**  02/08/2017   Josh
**  05/22/2017   UK          Case 42666
**  02/12/2018   Colman      Case 49522 Title COUNTRY RIGHTS search returns no rows
**  03/20/2018   Colman      Case 50255 Search criteria not returning results of OR Condition elements
**  03/23/2018   Colman      Case 50477 Pub Date search timing out
**  03/24/2018   Colman      Case 50404 Title Search with two participants results in a time out error
**  04/15/2018   Colman      Case 50838
**  05/02/2018   Colman      Case 50992
**  05/09/2018   Colman      Case 51371 - Handle empty orgentry criteria
**  06/18/2018   Colman      Case 51965 & 51926
**  07/16/2018   Colman      TM-566 - Product Detail Epub Type search returning no results
*******************************************************************************/

CREATE PROCEDURE qse_search_request
(
  @i_searchcriteria_xml NTEXT,
  @o_listkey            INT OUT,
  @o_number_of_rows     INT OUT,
  @o_ColumnOrderList    VARCHAR(255) OUT,
  @o_StyleList          VARCHAR(2000) OUT,
  @o_error_code         INT OUT,
  @o_error_desc         VARCHAR(2000) OUT 
)
AS

  --exec qutl_trace 'qse_search_request',
    --'@i_searchcriteria_xml', NULL, @i_searchcriteria_xml

BEGIN
  DECLARE 
  @AccessInd    INT,
  @AllowMultipleRowsInd			TINYINT,
  @AllowMultipleValuesInd   TINYINT,
  @BestColumnName   VARCHAR(120),
  @CheckOrgentryKey INT,
  @CheckOrglevelKey INT,
  @ColumnName				VARCHAR(150),
  @CommaPosIndex    INT,
  @ComparisonOperator		SMALLINT,		--gentable 299
  @ComparisonStringOp		VARCHAR(40),
  @ContactSQLUnion   NVARCHAR(4000),
  @CSEODStatus  VARCHAR(30),
  @CreationDateCode INT,
  @CriteriaCount    INT,  
  @CriteriaKey      INT,
  @CriteriaKeysUsed  VARCHAR(1000),
  @CriteriaSequence VARCHAR(6),
  @CriteriaString   VARCHAR(MAX),
  @DetailCriteriaString VARCHAR(MAX),
  @DataTypeCode			SMALLINT,   --gentable 441
  @DetailCriteriaInd  TINYINT,
  @DetailCriteriaKey  INT,
  @DocNum				INT,
  @EndQuote				VARCHAR(20),
  @ErrorVar				INT,
  @ExistsClause			VARCHAR(1000),
  @ExistsSearchSQLFrom  VARCHAR(1000),
  @ExistsSearchSQLWhere VARCHAR(2000),
  @FilterKey  INT,
  @FilterOrglevelKey  INT,
  @FirstItemLogicalOperator VARCHAR(3),		--AND/OR
  @FirstTableInstance TINYINT,
  @FromTableName			VARCHAR(50),
  @GenTableID   INT,
  @IsCoreTable  BIT,
  @IsOpen				BIT,
  @InsertSQL				NVARCHAR(MAX),
  @ItemAllAges	CHAR(1),
  @ItemCount    INT,
  @ItemEndRangeValue		VARCHAR(120),
  @ItemEstActBest     CHAR(1),
  @ItemSubgenValue			VARCHAR(120),
  @ItemSubgen2Value			VARCHAR(120),
  @ItemValue				VARCHAR(MAX),
  @ItemValueString			VARCHAR(MAX),
  @JoinTable        VARCHAR(50),
  @JoinToResultsFrom		VARCHAR(1000),
  @JoinToResultsFromString  VARCHAR(MAX),
  @JoinToResultsWhere		VARCHAR(2000),
  @KeyColumnCounter			INT,
  @KeyColumnString			VARCHAR(200),
  @LastCommaPosIndex    INT,
  @ListKey				INT,
  @ListType				INT,
  @LogicalOperator    VARCHAR(3),		--AND/OR
  @MaxSearchRows  INT,
  @MiscKey        INT,
  @MultValueSeparator VARCHAR(10),
  @MultValueSeparatorASCII  INT,
  @NewSequenceNum     INT,
  @NewSubSequenceNum INT,
  @NewItemValue   VARCHAR(MAX),
  @OrgSecurityFilter  VARCHAR(MAX),	
  @OrgentryFilter			VARCHAR(MAX),
  @OrgEntryJoinWhere VARCHAR(MAX),
  @OrgEntryCriteriaWhere VARCHAR(MAX),
  @OrgentryKey          INT,
  @OrgentryParentKey    INT,
  @OrgentrySQLUnion     VARCHAR(MAX),  
  @OrgentryTableName		VARCHAR(50),
  @OrglevelKey          INT,
  @ParentCriteriaInd    TINYINT,
  @ParentCriteriaKey    INT,
  @PopupInd  TINYINT,
  @Position   INT,
  @PrevCriteriaKey      INT,
  @PrevDetailCriteriaInd TINYINT,
  @PrevParentCriteriaKey INT,
  @PrevSequenceNum      INT,
  @ProcessTableJoins    BIT,
  @Quote				VARCHAR(20),
  @RelatedTitleSQLUnion   NVARCHAR(4000),
  @ResultsColumnName		VARCHAR(50),
  @ResultsTableName			VARCHAR(50),
  @ResultsLimit			INT,
  @ResultsViewKey   INT,
  @ReturnResultsInd			BIT,
  @ReturnResultsWithNoOrgentries INT,
  @RowcountVar			INT,
  @SearchSQL				NVARCHAR(MAX),
  @SearchSQLCriteria		VARCHAR(MAX),
  @SearchSQLFrom			VARCHAR(1000),
  @SearchSQLSelect			VARCHAR(4000),
  @SearchSQLWhere			VARCHAR(4000),
  @SearchItem       SMALLINT,   --gentable 550
  @SearchType				INT,			--gentable 442
  @SecondColumnName			VARCHAR(150),
  @SecondTableName			VARCHAR(50),
  @SelectedUsageClass   INT,
  @SequenceNum        INT,
  @SubSequenceNum INT,
  @StripDashesInd			TINYINT,
  @SubgenColumnName			VARCHAR(120),
  @Subgen2ColumnName		VARCHAR(120),
  @TableAlias				VARCHAR(50),
  @TableName				VARCHAR(50),
  @TableNameKey				VARCHAR(50),
  @TempCounter			INT,
  @TableAliasNum       INT,
  @TempOrgentryKey  INT,
  @TempPos    INT,
  @TempSearch VARCHAR(MAX),
  @ThisItemString			VARCHAR(MAX),
  @TitleParticipantSearch INT,
  @UpdateUsageClass BIT,
  @UsageClassTableName		VARCHAR(50),
  @UseCriteriaExistsClause	BIT,
  @UseExistsClause			BIT,
  @UseNotExistsClause		BIT,
  @UseRelatedTitleUnion BIT,
  @UserID				VARCHAR(30),
  @UserKey				INT,
  @UseTableAlias       INT,
  @WebSchedulingClientOption INT,
  @XMLSearchString			VARCHAR(120),
  @TitlePrefix VARCHAR(5),
  @Title VARCHAR(255),
  @AdditionalFilter VARCHAR(4000),
  @FullTextSearchInd INT,
  @VerificationTypeCode VARCHAR(10),
  @MessageCategoryCode VARCHAR(10),
  @IncludeZeroValuesInd INT,
  @FinalCriteria TINYINT = 0

  DECLARE 
    @OP_EQ TINYINT = 1,
    @OP_INCLUDE TINYINT = 2,
    @OP_START TINYINT = 3,
    @OP_GT TINYINT = 4,
    @OP_LT TINYINT = 5,
    @OP_NEQ TINYINT = 6,
    @OP_BETWEEN TINYINT = 7,
    @OP_IN TINYINT = 8

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @KeyColumnCounter = 0
  SET @KeyColumnString = ''
  SET @UseRelatedTitleUnion = 0
  SET @SearchSQLCriteria = ''
  SET @CriteriaKeysUsed = ','
  SET @JoinToResultsFromString = ''
  SET @o_listkey = 0
  SET @o_ColumnOrderList = ''
  SET @o_StyleList = ''
  SET @VerificationTypeCode = ''
  SET @MessageCategoryCode = ''
  SET @IncludeZeroValuesInd = 0
  SET @DetailCriteriaString = ''
  
  CREATE TABLE #SearchSQLCriteria (
    CriteriaSequence VARCHAR(6),
    SequenceNum INT,
    SubSequenceNum INT,
    CriteriaKey INT,
    DetailCriteriaKey INT,
    DataTypeCode SMALLINT,
    GenTableID INT,
    MiscKey INT,
    AllowMultipleRowsInd TINYINT,
    AllowMultipleValuesInd TINYINT,
    MultValueSeparator VARCHAR(10),
    DetailCriteriaInd TINYINT,
    ParentCriteriaInd TINYINT,
    StripDashesInd TINYINT,
    ParentCriteriaKey INT,
    FullTextSearchInd TINYINT,
    IncludeZeroValuesInd TINYINT
    )

  CREATE TABLE #SearchSQLCriteriaItem (
    CriteriaSequence VARCHAR(6),
    SequenceNum INT,
    SubSequenceNum INT,
    CriteriaKey INT,
    DetailCriteriaKey INT,
    ItemID INT identity,
    Value VARCHAR(max),
    SubValue VARCHAR(120),
    Sub2Value VARCHAR(120),
    EndRangeValue VARCHAR(120),
    EstActBest CHAR(1),
    AllAges CHAR(1),
    ComparisonOperator SMALLINT,
    LogicalOperator VARCHAR(3)
  )

  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @i_searchcriteria_xml

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the onix product record'
    GOTO ExitHandler
  END
  SET @IsOpen = 1
  
  -- Get the client's datetypecode for Creation Date (qsicode=10)
  SELECT @TempCounter = COUNT(*)
  FROM datetype WHERE qsicode = 10
  
  SET @CreationDateCode = 0
  IF @TempCounter > 0
    SELECT @CreationDateCode = datetypecode
    FROM datetype WHERE qsicode = 10
    
  -- Check the client default for the maximum number of search rows allowed to be returned by search request
  SELECT @TempCounter = COUNT(*)
  FROM clientdefaults WHERE clientdefaultid = 57
  
  SET @MaxSearchRows = 20000
  IF @TempCounter > 0  
    SELECT @MaxSearchRows = clientdefaultvalue
    FROM clientdefaults
    WHERE clientdefaultid = 57  --Max Search Rows

  -- Check if client is using web task scheduling
  SET @WebSchedulingClientOption = 0

  SELECT @WebSchedulingClientOption = ISNULL(optionvalue, 0)
  FROM clientoptions
  WHERE optionid = 72
  
  -- *********** Get SEARCH request info ************ --
  -- Get all <Search> elements from the passed XML document
  SELECT @SearchType = SearchType,
    @ListType = ListType,
    @UserKey = UserKey,    
    @ReturnResultsInd = ReturnResults,
    @ResultsLimit = ResultsLimit,
    @OrgentryFilter = OrgentryFilter,
    @ReturnResultsWithNoOrgentries = ReturnResultsWithNoOrgentries,
    @TitleParticipantSearch = TitleParticipantSearch,
    @ResultsViewKey = ResultsViewKey,
    @PopupInd = PopupInd
  FROM OPENXML(@DocNum,  '/Search')
  WITH (SearchType INT 'SearchType', 
        ListType INT 'ListType',
        UserKey INT 'UserKey',
        ReturnResults BIT 'ReturnResults',
        ResultsLimit INT 'ResultsLimit',
        OrgentryFilter VARCHAR(100) 'OrgentryFilter',
        ReturnResultsWithNoOrgentries INT 'ReturnResultsWithNoOrgentries',
        TitleParticipantSearch INT 'TitleParticipantSearch',
        ResultsViewKey INT 'ResultsViewKey',
        PopupInd BIT 'PopupInd')

  -- Default necessary values if for any reason NULL values are passed inside the XML document
  -- (even though that should never happen)
  IF @UserKey IS NULL
    SET @UserKey = 0			--default user to 'QSIADMIN' if NULL userkey is passed
  IF @ReturnResultsInd IS NULL
    SET @ReturnResultsInd = 0
  IF @OrgentryFilter IS NULL
    SET @OrgentryFilter = ' '   --initialize to single space
  IF @ListType IS NULL OR @ListType = 0
    SET @ListType = 1  

  IF @ResultsViewKey IS NULL
    SET @ResultsViewKey = 0
  IF @PopupInd IS NULL
    SET @PopupInd = 0

  SET @SearchSQLWhere = 'WHERE '
  
  -- Hardcoding results table here, based on search type
  IF @SearchType = 1 OR @SearchType = 6 OR @SearchType = 9 OR @SearchType = 26 OR @SearchType = 27		-- Titles
    BEGIN
      SET @SearchItem = 1
      SET @FromTableName = 'coretitleinfo'
    END
  ELSE IF @SearchType = 7 OR @SearchType = 10     -- Projects
    BEGIN
      SET @SearchItem = 3
      SET @FromTableName = 'coreprojectinfo'
    END
  ELSE IF @SearchType = 8						-- Contacts
    BEGIN
      SET @SearchItem = 2
      SET @FromTableName = 'corecontactinfo'
    END
  ELSE IF @SearchType = 16        -- Search Results Lists
    BEGIN
      SET @SearchItem = 4
      SET @FromTableName = 'qse_searchlist'
    END
  ELSE IF @SearchType = 17        -- User Admin
    BEGIN
      SET @SearchItem = 5
      SET @FromTableName = 'coreprojectinfo'
      SET @SearchSQLWhere = @SearchSQLWhere + ' coreprojectinfo.usageclasscode IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 29) AND '              
    END
  ELSE IF @SearchType = 18        -- journals
    BEGIN
      SET @SearchItem = 6
      SET @FromTableName = 'coreprojectinfo'
    END
  ELSE IF (@SearchType = 19 or @SearchType = 20)    -- task view and task group
    BEGIN
      SET @SearchItem = 8
      SET @FromTableName = 'taskview'
    END
  ELSE IF @SearchType = 22        -- works
    BEGIN
      SET @SearchItem = 9
      SET @FromTableName = 'coreprojectinfo, taqproject'
      SET @SearchSQLWhere = @SearchSQLWhere + ' coreprojectinfo.projectkey=taqproject.taqprojectkey AND '
      SET @UsageClassTableName = 'coreprojectinfo'
    END
  ELSE IF @SearchType = 23		-- P&L versions
    BEGIN
      SET @SearchItem = 12
      SET @FromTableName = 'coreprojectinfo, taqversion'
      SET @SearchSQLWhere = @SearchSQLWhere + ' coreprojectinfo.projectkey=taqversion.taqprojectkey AND coreprojectinfo.usageclasscode IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 29) AND '
    END
  ELSE IF @SearchType = 25     -- Contracts
    BEGIN
      SET @SearchItem = 10
      SET @FromTableName = 'coreprojectinfo'
    END
  ELSE IF @SearchType = 24     -- Scales
    BEGIN
      SET @SearchItem = 11
      SET @FromTableName = 'coreprojectinfo'
    END
  ELSE IF @SearchType = 28     -- Printings
    BEGIN
      SET @SearchItem = 14
      SET @FromTableName = 'coreprojectinfo, taqprojectprinting_view'
      SET @SearchSQLWhere = @SearchSQLWhere + ' coreprojectinfo.projectkey=taqprojectprinting_view.taqprojectkey AND '
    END  
  ELSE IF @SearchType = 29     -- Purchase Orders
    BEGIN
      SET @SearchItem = 15
      SET @FromTableName = 'coreprojectinfo'
    END   
  ELSE IF @SearchType = 30     -- Specification Template
    BEGIN
      SET @SearchItem = 5          -- User Admin
      SET @FromTableName = 'coreprojectinfo'
      SET @SearchSQLWhere = @SearchSQLWhere + ' coreprojectinfo.usageclasscode IN (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44) AND '      
    END        
  ELSE
    BEGIN
      SET @FromTableName = ''
    END

  IF @UsageClassTableName IS NULL
    SET @UsageClassTableName = @FromTableName
    
  -- ********* Get LISTKEY *********** --
  -- Check if qse_searchlist record exists for this user, search type and the given list type
  SELECT @TempCounter = COUNT(*)
  FROM qse_searchlist
  WHERE userkey = @UserKey AND
        searchtypecode = @SearchType AND
        listtypecode = @ListType
        
  IF @TempCounter = 0	-- record doesn't exist - INSERT
    BEGIN
      -- ******** Get the UserID for the given userkey ****** --
      -- UserID is referenced in get_next_key
      SELECT @UserID = userid
      FROM qsiusers
      WHERE userkey = @UserKey

      -- Make sure qsiusers record exists for this userkey
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 OR @RowcountVar = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not get UserID from qsiusers table for UserKey ' + CONVERT(VARCHAR, @UserKey)
        GOTO ExitHandler
      END
    
      -- Generate new listkey
      EXECUTE get_next_key @UserId, @ListKey OUTPUT
      
      /***** START THE TRANSACTION *****/
      BEGIN TRANSACTION      

      -- Insert missing qse_searchlist row
      SET @InsertSQL = N'INSERT INTO qse_searchlist ' + 
        '(listkey, userkey, searchtypecode, listtypecode, listdesc, defaultind, searchitemcode, usageclasscode, createdbyuserid) ' +
        'SELECT @p_ListKey, @p_UserKey, searchtypecode, listtypecode, listdesc, defaultind, searchitemcode, usageclasscode, ' +
        'CASE ' +
        ' WHEN @p_UserKey < 0 THEN ''QSIDBA''' +
        ' ELSE (SELECT userid FROM qsiusers WHERE qsiusers.userkey = @p_UserKey) ' +
        'END userid ' +
        'FROM qse_searchlist ' +
        'WHERE userkey = -1 AND searchtypecode = ' + CAST(@SearchType AS NVARCHAR) + 
        ' AND listtypecode = ' + CAST(@ListType AS NVARCHAR)

      EXECUTE sp_executesql @InsertSQL,
		    N'@p_ListKey INT, @p_UserKey INT', 
		    @ListKey, @UserKey
		    
      /******** COMMIT *******/
      COMMIT TRANSACTION
      
    END
  ELSE
    BEGIN
      -- Given the list type, userkey and search type, 
      -- get the corresponding listkey needed for the INSERT statement
      SELECT @ListKey = listkey
      FROM qse_searchlist
      WHERE userkey = @UserKey AND
            searchtypecode = @SearchType AND
            listtypecode = @ListType
    END
    
  --DEBUG
  PRINT '@SearchType: ' + CONVERT(VARCHAR, @SearchType)
  PRINT '@ListKey: ' + CONVERT(VARCHAR, @ListKey)
  PRINT '@FromTableName: ' + @FromTableName
  PRINT '@ResultsViewKey: ' + cast(@ResultsViewKey as varchar)

  -- Initialize the SELECT list, FROM clause and WHERE clause
  -- NOTE: The SELECT list will consist of ListKey and the list of KEY COLUMNS determined at runtime.
  -- The complete SELECT list will be used to build the INSERT statement into the qse_searchresults table.
  -- DISTINCT is needed for cases when searching for author lastname, and there are multiple authors 
  -- on the title with same lastname.
  SET @SearchSQLSelect = 'SELECT DISTINCT '
  SET @SearchSQLFrom = 'FROM ' + @FromTableName
 
  IF @JoinToResultsWhere is not null AND @JoinToResultsWhere <> '' BEGIN
    SET @SearchSQLWhere = @SearchSQLWhere + @JoinToResultsWhere
  END
  
  -- When ResultsLimit is passed inside the XML file, search results should be limited to the number passed
  IF @ResultsLimit IS NOT NULL AND @ResultsLimit > 0
    SET @SearchSQLSelect = @SearchSQLSelect + 'TOP ' + CONVERT(VARCHAR, @ResultsLimit) + ' '
  
  SET @ExistsSearchSQLFrom = ''
  SET @ExistsSearchSQLWhere = ''
  SET @CriteriaCount = 0
  SET @PrevCriteriaKey = 0
  SET @PrevSequenceNum = 0
    
  -- ***************** Parse CRITERIA into Temp Tables ****************** --

  -- Loop to get all <Search/Criteria> elements from the passed XML document
  DECLARE criteria_cursor_xml CURSOR LOCAL
  FOR
  SELECT CriteriaSequence,
    CriteriaKey,
    DetailCriteriaKey
  FROM OPENXML(@DocNum, '/Search/Criteria') WITH (
      CriteriaSequence VARCHAR(6) 'CriteriaSequence',
      CriteriaKey INT 'CriteriaKey',
      DetailCriteriaKey INT 'DetailCriteriaKey'
      )

  OPEN criteria_cursor_xml

  FETCH NEXT
  FROM criteria_cursor_xml
  INTO @CriteriaSequence, @CriteriaKey, @DetailCriteriaKey

  IF @@FETCH_STATUS <> 0 -- no criteria entered - return
  BEGIN
    SET @o_error_code = - 1
    SET @o_error_desc = 'No criteria entered'

    GOTO ExitHandler
  END

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF CHARINDEX('::', @CriteriaSequence) > 0
    BEGIN
      SET @SequenceNum = CONVERT(INT, SUBSTRING(@CriteriaSequence, 0, CHARINDEX('::', @CriteriaSequence)))
      SET @SubSequenceNum = CONVERT(INT, SUBSTRING(@CriteriaSequence, CHARINDEX('::', @CriteriaSequence) + 2, 3))
    END
    ELSE
    BEGIN
      SET @SequenceNum = CONVERT(INT, @CriteriaSequence)
      SET @SubSequenceNum = @SequenceNum
    END

    IF @DetailCriteriaKey IS NOT NULL
    BEGIN
      INSERT INTO #SearchSQLCriteria (
        CriteriaSequence,
        SequenceNum,
        SubSequenceNum,
        CriteriaKey,
        DetailCriteriaKey,
        DataTypeCode,
        GenTableID,
        MiscKey,
        AllowMultipleRowsInd,
        AllowMultipleValuesInd,
        MultValueSeparator,
        DetailCriteriaInd,
        ParentCriteriaInd,
        StripDashesInd,
        ParentCriteriaKey,
        FullTextSearchInd,
        IncludeZeroValuesInd
        )
        SELECT @CriteriaSequence,
        @SequenceNum,
        @SubSequenceNum,
        @CriteriaKey,
        d.detailcriteriakey,
        c.datatypecode,
        c.gentableid,
        c.misckey,
        c.allowmultiplerowsind,
        c.allowmultiplevaluesind,
        COALESCE(c.multvalueseparator, ''),
        c.detailcriteriaind,
        c.parentcriteriaind,
        c.stripdashesind,
        d.parentcriteriakey,
        c.fulltextsearchind
        ,NULL
      FROM qse_searchcriteria c
      LEFT JOIN qse_searchcriteriadetail d ON c.searchcriteriakey = d.detailcriteriakey
      WHERE d.detailcriteriakey = @DetailCriteriaKey
        AND d.parentcriteriakey = @CriteriaKey
    END
    ELSE
    BEGIN
      INSERT INTO #SearchSQLCriteria (
        CriteriaSequence,
        SequenceNum,
        SubSequenceNum,
        CriteriaKey,
        DetailCriteriaKey,
        DataTypeCode,
        GenTableID,
        MiscKey,
        AllowMultipleRowsInd,
        AllowMultipleValuesInd,
        MultValueSeparator,
        DetailCriteriaInd,
        ParentCriteriaInd,
        StripDashesInd,
        ParentCriteriaKey,
        FullTextSearchInd,
        IncludeZeroValuesInd
        )
        SELECT @CriteriaSequence,
        @SequenceNum,
        @SubSequenceNum,
        @CriteriaKey,
        @DetailCriteriaKey,
        c.datatypecode,
        c.gentableid,
        c.misckey,
        c.allowmultiplerowsind,
        c.allowmultiplevaluesind,
        COALESCE(c.multvalueseparator, ''),
        c.detailcriteriaind,
        c.parentcriteriaind,
        c.stripdashesind,
        NULL,
        c.fulltextsearchind
        ,NULL
      FROM qse_searchcriteria c
      WHERE c.searchcriteriakey = @CriteriaKey
    END

    -- Make sure qse_searchcriteria record exists
    -- NOTE: When given searchcriteriakey is passed inside the XML, it must exist in qse_searchcriteria
    SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
    IF @ErrorVar <> 0 OR @RowcountVar = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Missing qse_searchcriteria record (searchcriteriakey=' + CONVERT(VARCHAR, @CriteriaKey) + ')'
      GOTO ExitHandler
    END

    ---------- Loop to get all Item in the Criteria Sequence -------------------------------

    SET @XMLSearchString = '/Search/Criteria[CriteriaSequence=''' + @CriteriaSequence + ''']/Item'    

    DECLARE item_cursor_xml CURSOR FOR 
      SELECT Value, SubValue, Sub2Value, EndRangeValue, EstActBest, AllAges,
            ComparisonOperator, LogicalOperator
      FROM OPENXML(@DocNum,  @XMLSearchString)
      WITH (Value VARCHAR(MAX) 'Value',
            SubValue VARCHAR(120) 'SubValue',
            Sub2Value VARCHAR(120) 'Sub2Value',
            EndRangeValue VARCHAR(120) 'EndRangeValue',
            EstActBest CHAR(1) 'EstActBest',
            AllAges CHAR(1) 'AllAges',
            ComparisonOperator SMALLINT 'ComparisonOperator',
            LogicalOperator VARCHAR(3) 'LogicalOperator')

    OPEN item_cursor_xml

    FETCH NEXT FROM item_cursor_xml INTO 
      @ItemValue,
      @ItemSubgenValue,
      @ItemSubgen2Value,
      @ItemEndRangeValue,
      @ItemEstActBest,
      @ItemAllAges,
      @ComparisonOperator,
      @LogicalOperator

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO #SearchSQLCriteriaItem (
          CriteriaSequence,
          SequenceNum,
          SubSequenceNum,
          CriteriaKey,
          DetailCriteriaKey,
          Value,
          SubValue,
          Sub2Value,
          EndRangeValue,
          EstActBest,
          AllAges,
          ComparisonOperator,
          LogicalOperator
          )
        VALUES (
          @CriteriaSequence,
          @SequenceNum,
          @SubSequenceNum,
          @CriteriaKey,
          @DetailCriteriaKey,
          @ItemValue,
          @ItemSubgenValue,
          @ItemSubgen2Value,
          @ItemEndRangeValue,
          @ItemEstActBest,
          @ItemAllAges,
          @ComparisonOperator,
          @LogicalOperator
          )

      FETCH NEXT FROM item_cursor_xml INTO 
        @ItemValue,
        @ItemSubgenValue,
        @ItemSubgen2Value,
        @ItemEndRangeValue,
        @ItemEstActBest,
        @ItemAllAges,
        @ComparisonOperator,
        @LogicalOperator
    END
    CLOSE item_cursor_xml
    DEALLOCATE item_cursor_xml

    FETCH NEXT
    FROM criteria_cursor_xml
    INTO @CriteriaSequence, @CriteriaKey, @DetailCriteriaKey
  END

  CLOSE criteria_cursor_xml
  DEALLOCATE criteria_cursor_xml

  ---------------------------------------------------------------------------------
  --- PROCESS CRITERIA FROM TEMP TABLES -------------------------------------------
  ---------------------------------------------------------------------------------

  DECLARE criteria_cursor CURSOR LOCAL FOR 
    SELECT 
        CriteriaSequence,
        SequenceNum,
        SubSequenceNum,
        CriteriaKey,
        DetailCriteriaKey,
        DataTypeCode,
        GenTableID,
        MiscKey,
        AllowMultipleRowsInd,
        AllowMultipleValuesInd,
        MultValueSeparator,
        DetailCriteriaInd,
        ParentCriteriaInd,
        StripDashesInd,
        ParentCriteriaKey,
        FullTextSearchInd,
        IncludeZeroValuesInd
    FROM #SearchSQLCriteria

  OPEN criteria_cursor

  FETCH NEXT FROM criteria_cursor INTO
    @CriteriaSequence,
    @SequenceNum,
    @SubSequenceNum,
    @CriteriaKey,
    @DetailCriteriaKey,
    @DataTypeCode,
    @GenTableID,
    @MiscKey,
    @AllowMultipleRowsInd,
    @AllowMultipleValuesInd,
    @MultValueSeparator,
    @DetailCriteriaInd,
    @ParentCriteriaInd,
    @StripDashesInd,
    @ParentCriteriaKey,
    @FullTextSearchInd,
    @IncludeZeroValuesInd

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Initialize all variables for each new CRITERIA
    SET @UseTableAlias = 0
    SET @TableAliasNum = 0
    SET @IsCoreTable = 0
    SET @Quote = ''
    SET @EndQuote = ''
    SET @CriteriaString = ''
    SET @ItemValueString = ''
    SET @ExistsClause = ''
    SET @UseCriteriaExistsClause = 0
    SET @FullTextSearchInd = 0

    IF @SequenceNum <> @PrevSequenceNum
      SET @CriteriaCount = @CriteriaCount + 1
    
    -- DEBUG
    PRINT ''
    PRINT '  @PrevSequenceNum: ' + CONVERT(VARCHAR, @PrevSequenceNum)
    PRINT '  @SequenceNum: ' + CONVERT(VARCHAR, @SequenceNum)
    PRINT '  @CriteriaSequence: ' + @CriteriaSequence
    PRINT '  @CriteriaKey: ' + CONVERT(VARCHAR, @CriteriaKey)
    IF @DetailCriteriaKey IS NOT NULL
      PRINT '  @DetailCriteriaKey: ' + CONVERT(VARCHAR, @DetailCriteriaKey)    
    
    -- Use DetailCriteriaKey when passed (used for composite search criteria)
    IF @DetailCriteriaKey IS NOT NULL
      SET @CriteriaKey = @DetailCriteriaKey    
    
    IF @DetailCriteriaInd = 1
    BEGIN
      SELECT @AllowMultipleRowsInd = allowmultiplerowsind
      FROM qse_searchcriteria
      WHERE searchcriteriakey = @ParentCriteriaKey
      
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0 OR @RowcountVar = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Missing qse_searchcriteria record (searchcriteriakey=' + CONVERT(VARCHAR, @ParentCriteriaKey) + ')'
        GOTO ExitHandler
      END
    END   

    -- Get additional criteria information based on SearchType
    SELECT @TableName = ISNULL(tablename, ''),
      @ColumnName = ISNULL(columnname, ''),
      @SubgenColumnName = ISNULL(subgencolumnname, ''),
      @Subgen2ColumnName = ISNULL(subgen2columnname, ''),
      @SecondTableName = ISNULL(secondtablename, ''),
      @SecondColumnName = ISNULL(secondcolumnname, ''),
      @BestColumnName = ISNULL(bestcolumnname, '')
    FROM qse_searchtypecriteria
    WHERE searchtypecode = @SearchType AND
          searchcriteriakey = @CriteriaKey

    -- Make sure qse_searchtypecriteria record exists
    SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
    IF @ErrorVar <> 0 OR @RowcountVar = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Missing qse_searchtypecriteria record (searchtypecode=' +
        CONVERT(VARCHAR, @SearchType) + ', searchcriteriakey=' + CONVERT(VARCHAR, @CriteriaKey) + ')'
      GOTO ExitHandler
    END
    
    -- Before we possibly replace a variable in the table name, save the original version for use as a key into qse_searchtableinfo
    -- Remove Upper and coalesce from table name, if present
    SET @TableNameKey = REPLACE(REPLACE(@TableName, 'UPPER(', ''), 'COALESCE(', '')

    -- '#' is a variable to be replaced with the sequence number
    --IF CHARINDEX('#', @TableName) > 0
    --   SET @TableName = REPLACE(@TableName, '#', CONVERT(VARCHAR, @SequenceNum))

    -- 11/5/08 - KW - Case 5644 - We have to manipulate the TASK/DATE title searches here:
    -- if 'Web scheduling' clientoption is ON, search on taqprojecttask (otherwise, searches are set up for bookdates)
    IF @SearchItem = 1 AND @TableName = 'bookdates'  --TASK/DATE title search
    BEGIN        
      IF @WebSchedulingClientOption = 1 or (@ParentCriteriaKey = 271 and @CriteriaKey = 87) -- using web scheduling - search on taqprojecttask instead
      BEGIN
        SET @TableName = 'taqprojecttask'
        SET @SecondTableName = ''
        SET @SecondColumnName = ''
        SET @BestColumnName = ''
      END
    END
    
    IF LTRIM(@ColumnName) <> ''
      SET @ColumnName = @TableName + '.' + @ColumnName
    IF LTRIM(@SubgenColumnName) <> ''
      SET @SubgenColumnName = @TableName + '.' + @SubgenColumnName
    IF LTRIM(@Subgen2ColumnName) <> ''
      SET @Subgen2ColumnName = @TableName + '.' + @Subgen2ColumnName
    IF LTRIM(@SecondColumnName) <> ''
      SET @SecondColumnName = @SecondTableName + '.' + @SecondColumnName
    IF LTRIM(@BestColumnName) <> ''
      SET @BestColumnName = @TableName + '.' + @BestColumnName
      
    -- Extract Upper from table name, if present
    IF UPPER(LEFT(@TableName, 6)) = 'UPPER('
      SET @TableName = SUBSTRING(@TableName, 7, 30)
    IF UPPER(LEFT(@SecondTableName, 6)) = 'UPPER('
      SET @SecondTableName = SUBSTRING(@SecondTableName, 7, 30)
      
    -- Extract COALESCE from table name, if present
    IF UPPER(LEFT(@TableName, 9)) = 'COALESCE('
      SET @TableName = SUBSTRING(@TableName, 10, 30)
      
    -- Special processing is required for date values that are saved with time precision.
    -- Must extract the time portion and search on date only.
    IF UPPER(LEFT(@ColumnName, 5)) = 'DATE('
    BEGIN
      SET @ColumnName = SUBSTRING(@ColumnName, 6, 100)
      SET @ColumnName = 'CONVERT(datetime,CONVERT(varchar,' + @ColumnName + ', 101),101)'
    END
    
    IF @ColumnName = 'bookdetail.gradelow'
    BEGIN
      SET @ColumnName = 'CONVERT(FLOAT, CASE bookdetail.gradelow WHEN '''' THEN NULL WHEN ''P'' THEN -2 WHEN ''K'' THEN 0 ELSE bookdetail.gradelow END)'
      IF @SecondColumnName = 'bookdetail.gradehigh'
        SET @SecondColumnName = 'CONVERT(FLOAT, CASE bookdetail.gradehigh WHEN '''' THEN NULL WHEN ''P'' THEN -2 WHEN ''K'' THEN 0 ELSE bookdetail.gradehigh END)'
    END
      
    -- Check if current table is core table
    IF UPPER(LEFT(@TableName, 4)) = 'CORE' OR @SearchType = 16
      SET @IsCoreTable = 1

      
    -- **** Determine if table joins should be processed for this row *****
    SET @ProcessTableJoins = 0
    IF @DetailCriteriaInd = 1 
      SET @ProcessTableJoins = 1      
    ELSE IF @ParentCriteriaInd = 0 AND @IsCoreTable = 0
	    SET @ProcessTableJoins = 1
     
    -- Treat the detail criteria for the custom REVIEW LOG search criteria as regular criteria 
    -- so that EXISTS clause would be used for each subsequent taqelementmisc detail
    IF (@DetailCriteriaInd = 1 AND @ParentCriteriaKey = 251)
      SET @DetailCriteriaInd = 0     

    -- Get necessary joins for the table as determined by this search Criteria
    IF @ProcessTableJoins = 1
    BEGIN
      SET @FirstTableInstance = 0
      DECLARE @TableNum INT

      -- Create a temp table with the join table(s) to process
      DECLARE @JoinTables TABLE (tablenum INT, jointoresultstablefrom VARCHAR(MAX), jointoresultstablewhere VARCHAR(MAX))
      DELETE FROM @JoinTables

      -- Main join table
      INSERT INTO @JoinTables (tablenum, jointoresultstablefrom, jointoresultstablewhere)
        SELECT 1, jointoresultstablefrom, ISNULL(jointoresultstablewhere, '')
        FROM qse_searchtableinfo
        WHERE searchitemcode = @SearchItem 
          AND tablename = @TableNameKey

      -- Second join table if any
      IF LTRIM(RTRIM(@SecondTableName)) <> @TableName
        INSERT INTO @JoinTables (tablenum, jointoresultstablefrom, jointoresultstablewhere)
          SELECT 2, jointoresultstablefrom, ISNULL(jointoresultstablewhere, '')
          FROM qse_searchtableinfo
          WHERE searchitemcode = @SearchItem 
            AND tablename = @SecondTableName

      DECLARE tableinfo_cursor CURSOR FOR 
      SELECT tablenum, jointoresultstablefrom, ISNULL(jointoresultstablewhere, '')
      FROM @JoinTables
      ORDER BY tablenum

      OPEN tableinfo_cursor

      FETCH NEXT FROM tableinfo_cursor 
      INTO @TableNum, @JoinToResultsFrom, @JoinToResultsWhere

      -- Build the FROM clause and WHERE clause for the search SQL for each join table
      IF @@FETCH_STATUS = 0
      BEGIN
         --exec qutl_trace 'qse_search_request',
         --  '@TableNum', @TableNum, NULL,
         --  '@JoinToResultsFrom', NULL, @JoinToResultsFrom,
         --  '@JoinToResultsWhere', NULL, @JoinToResultsWhere

        IF @SearchItem = 1 
          AND @JoinToResultsFrom = 'bookdates' 
          AND (@WebSchedulingClientOption = 1 OR (@ParentCriteriaKey = 271 AND @CriteriaKey = 87)) --TASK/DATE title search
        BEGIN        
          SET @JoinToResultsFrom = REPLACE(@JoinToResultsFrom, 'bookdates', 'taqprojecttask')
          SET @JoinToResultsWhere = REPLACE(@JoinToResultsWhere, 'bookdates', 'taqprojecttask')
        END
        ELSE IF @WebSchedulingClientOption = 0 and @CriteriaKey <> 272 and @CriteriaKey <> 273 
            and @CriteriaKey <> 274 and not (@ParentCriteriaKey = 271 and @CriteriaKey = 87)
        BEGIN
          SET @JoinToResultsFrom = REPLACE(@JoinToResultsFrom, 'taqprojecttask', 'bookdates')
          SET @JoinToResultsWhere = REPLACE(@JoinToResultsWhere, 'taqprojecttask', 'bookdates')
        END

        IF CHARINDEX('#', @JoinToResultsFrom) > 0
          SET @UseTableAlias = 1
        
        IF @UseTableAlias = 1
        BEGIN
          -- The FROM clause needs one unique table alias per item in a criteria sequence
          SELECT @ItemCount = COUNT(*) FROM #SearchSQLCriteriaItem WHERE CriteriaSequence = @CriteriaSequence
          IF @ItemCount = 0
            SET @ItemCount = 1

          SET @TableAliasNum = @SequenceNum * 100
          SET @TempCounter = 0
          WHILE @TempCounter < @ItemCount
          BEGIN
            SET @TempCounter = @TempCounter + 1
            SET @SearchSQLFrom = @SearchSQLFrom + ', ' + REPLACE(@JoinToResultsFrom, '#', CONVERT(VARCHAR, @TableAliasNum + @TempCounter))

            IF LTRIM(@JoinToResultsWhere) <> ''
              SET @SearchSQLWhere = @SearchSQLWhere + REPLACE(@JoinToResultsWhere, '#', CONVERT(VARCHAR, @TableAliasNum + @TempCounter)) + ' AND '
          END
        END
        ELSE
        BEGIN
          -- Check if @JoinToResultsFrom tables were already processed - don't add it multiple times to FROM clause
          IF CHARINDEX(@JoinToResultsFrom + ',', @JoinToResultsFromString + ',') = 0 AND 
              CHARINDEX(@JoinToResultsFrom + ' ', @JoinToResultsFromString + ' ') = 0
          BEGIN
            SET @FirstTableInstance = 1
            SET @LastCommaPosIndex = 1

            SET @CommaPosIndex = CHARINDEX(',', @JoinToResultsFrom, 1)
            IF @CommaPosIndex > 0
            BEGIN
              -- Loop to process each table in the @JoinToResultsFrom string separately
              WHILE (@CommaPosIndex > 0) BEGIN
                SET @JoinTable = SUBSTRING(@JoinToResultsFrom, @LastCommaPosIndex, @CommaPosIndex - @LastCommaPosIndex)
                SET @JoinTable = LTRIM(RTRIM(@JoinTable))

                -- Add this table only if it doesn't already exist in the SQL FROM clause
                IF CHARINDEX(', ' + @JoinTable + ',', ', ' + @SearchSQLFrom + ',') = 0 AND
                   CHARINDEX(', ' + @JoinTable + ' ', ', ' + @SearchSQLFrom + ' ') = 0
                    SET @SearchSQLFrom = @SearchSQLFrom + ', ' + @JoinTable

                SET @LastCommaPosIndex = @CommaPosIndex + 1
                SET @CommaPosIndex = CHARINDEX(',', @JoinToResultsFrom, @LastCommaPosIndex)
              END --WHILE @CommaPosIndex
                  
              -- Process the last table listed in the @JoinToResultsFrom (after last comma)
              SET @JoinTable = SUBSTRING(@JoinToResultsFrom, @LastCommaPosIndex, 200)
              SET @JoinTable = LTRIM(RTRIM(@JoinTable))

              -- Add it if it is not already there
              IF CHARINDEX(', ' + @JoinTable + ',', ', ' + @SearchSQLFrom + ',') = 0 AND 
                 CHARINDEX(', ' + @JoinTable + ' ', ', ' + @SearchSQLFrom + ' ') = 0
                  SET @SearchSQLFrom = @SearchSQLFrom + ', ' + @JoinTable
            END
            ELSE IF CHARINDEX(@JoinToResultsFrom + ',', @SearchSQLFrom + ',') = 0 AND 
  				          CHARINDEX(@JoinToResultsFrom + ' ', @SearchSQLFrom + ' ') = 0  
            BEGIN
              -- Add this table to the FROM clause
              SET @SearchSQLFrom = @SearchSQLFrom + ', ' + @JoinToResultsFrom                
            END

            -- Add necessary joins to the WHERE clause for this TABLE
            IF LTRIM(@JoinToResultsWhere) <> ''
              IF CHARINDEX(@JoinToResultsWhere, @SearchSQLWhere) = 0  --KW Note: should loop through each join
                SET @SearchSQLWhere = @SearchSQLWhere + @JoinToResultsWhere + ' AND '
          END
        END
            
        IF @UseTableAlias = 0 
        BEGIN
          -- For detail criteria, check if @JoinToResultsFrom tables already exist in the @ExistsSearchSQLFrom
          -- FROM clause - don't add it multiple times
          IF @DetailCriteriaInd = 1 AND CHARINDEX(@JoinToResultsFrom, @ExistsSearchSQLFrom) = 0
          BEGIN
            SET @LastCommaPosIndex = 1
              
            SET @CommaPosIndex = CHARINDEX(',', @JoinToResultsFrom, 1)
            IF @CommaPosIndex > 0
            BEGIN
              -- Loop to process each table in the @JoinToResultsFrom string separately
              WHILE (@CommaPosIndex > 0) BEGIN
                SET @JoinTable = SUBSTRING(@JoinToResultsFrom, @LastCommaPosIndex, @CommaPosIndex - @LastCommaPosIndex)
                SET @JoinTable = LTRIM(RTRIM(@JoinTable))
                    
                -- Add this table only if it doesn't already exist in the SQL FROM clause
                IF CHARINDEX(', ' + @JoinTable + ',', ', ' + @ExistsSearchSQLFrom + ',') = 0
                  IF CHARINDEX(', ' + @JoinTable + ' ', ', ' + @ExistsSearchSQLFrom + ' ') = 0
                    IF @ExistsSearchSQLFrom = ''
                      SET @ExistsSearchSQLFrom = @ExistsSearchSQLFrom + @JoinTable
                    ELSE
                      SET @ExistsSearchSQLFrom = @ExistsSearchSQLFrom + ', ' + @JoinTable
                    
                SET @LastCommaPosIndex = @CommaPosIndex + 1
                SET @CommaPosIndex = CHARINDEX(',', @JoinToResultsFrom, @LastCommaPosIndex)
              END --WHILE @CommaPosIndex
                  
              -- Process the last table listed in the @JoinToResultsFrom (after last comma)
              SET @JoinTable = SUBSTRING(@JoinToResultsFrom, @LastCommaPosIndex, 200)
              SET @JoinTable = LTRIM(RTRIM(@JoinTable))
                  
              IF CHARINDEX(', ' + @JoinTable + ',', ', ' + @ExistsSearchSQLFrom + ',') = 0
                IF CHARINDEX(', ' + @JoinTable + ' ', ', ' + @ExistsSearchSQLFrom + ' ') = 0
                  IF @ExistsSearchSQLFrom = ''
                    SET @ExistsSearchSQLFrom = @ExistsSearchSQLFrom + @JoinTable
                  ELSE
                    SET @ExistsSearchSQLFrom = @ExistsSearchSQLFrom + ', ' + @JoinTable
            END
            ELSE
            BEGIN
              -- Add this table to the FROM clause
              IF @ExistsSearchSQLFrom = ''
                SET @ExistsSearchSQLFrom = @ExistsSearchSQLFrom + @JoinToResultsFrom
              ELSE
                SET @ExistsSearchSQLFrom = @ExistsSearchSQLFrom + ', ' + @JoinToResultsFrom                
            END

            -- Add necessary joins to the WHERE clause for this TABLE
            IF LTRIM(@JoinToResultsWhere) <> ''
              IF CHARINDEX(@JoinToResultsWhere, @ExistsSearchSQLWhere) = 0  --KW Note: should loop through each join
                SET @ExistsSearchSQLWhere = @ExistsSearchSQLWhere + @JoinToResultsWhere + ' AND '
          END
          ELSE
          BEGIN
            -- If @JoinToResultsFrom clause was already added to the @SearchSQLFrom clause,
            -- EXISTS clause will be formed
            IF @ParentCriteriaKey <> 235 BEGIN   -- 235 = COUNTRY RIGHTS
              SET @UseCriteriaExistsClause = 1
            END
          END
            
          IF @JoinToResultsFromString <> ''
            SET @JoinToResultsFromString = @JoinToResultsFromString + ', '

          SET @JoinToResultsFromString = @JoinToResultsFromString + @JoinToResultsFrom        
        END

        FETCH NEXT FROM tableinfo_cursor 
        INTO @TableNum, @JoinToResultsFrom, @JoinToResultsWhere
      END -- WHILE

      CLOSE tableinfo_cursor
      DEALLOCATE tableinfo_cursor

    END --IF @ProcessTableJoins
    
    SET @ItemCount = 0
    
    DECLARE item_cursor CURSOR FOR 
      SELECT Value, SubValue, Sub2Value, EndRangeValue, EstActBest, AllAges,
            ComparisonOperator, LogicalOperator
      FROM #SearchSQLCriteriaItem
      WHERE CriteriaSequence = @CriteriaSequence
      ORDER BY ItemID

    OPEN item_cursor

    FETCH NEXT FROM item_cursor INTO 
      @ItemValue,
      @ItemSubgenValue,
      @ItemSubgen2Value,
      @ItemEndRangeValue,
      @ItemEstActBest,
      @ItemAllAges,
      @ComparisonOperator,
      @LogicalOperator

    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @ItemCount = @ItemCount + 1
      SET @TableAliasNum = @TableAliasNum + 1

      SET @UpdateUsageClass = 0
      IF @CriteriaKey = 120 AND @ComparisonOperator = @OP_EQ AND @ItemValueString = ''  --Usage Class, Equals, first value
        SET @UpdateUsageClass = 1
      
      -- Initialize all variables for each new ITEM
      SET @UseExistsClause = 0
      SET @UseNotExistsClause = 0
      SET @ItemValue = LTRIM(@ItemValue)
      
      IF @CriteriaKey = 207
      BEGIN
        -- Ignore this criteria - it is here only for the purposes of correcting SQL when Export Status = 2 (Error)
        IF @ItemValue = 2 --Error: replace FROM and WHERE clause
        BEGIN
          SET @SearchSQLFrom = REPLACE(@SearchSQLFrom, ', fileprocesscatalog', ', edifeederrors')
          SET @SearchSQLWhere = REPLACE(@SearchSQLWhere, 'fileprocesscatalog.bookkey', 'edifeederrors.key3')
          SET @SearchSQLWhere = REPLACE(@SearchSQLWhere, 'fileprocesscatalog.printingkey', 'edifeederrors.key4')
          SET @SearchSQLWhere = REPLACE(@SearchSQLWhere, 'fileprocesscatalog.filekey', 'edifeederrors.filekey')
          SET @SearchSQLWhere = REPLACE(@SearchSQLWhere, 'fileprocesscatalog.filetypeind', 'edifeederrors.errortype')
        END
        GOTO NEXT_CRITERIA
      END

      -- print 'FETCH NEXT FROM item_cursor'
      -- print '    @CriteriaKey: ' + cast(@CriteriaKey  as varchar)     
      -- print '    @ParentCriteriaKey: ' + COALESCE(cast(@ParentCriteriaKey  as varchar), 'null')        
      -- print '    @DetailCriteriaInd: ' + COALESCE(cast(@DetailCriteriaInd  as varchar), 'null')        
      -- print '    @SequenceNum: ' + COALESCE(cast(@SequenceNum  as varchar), 'null')        
      -- print '    @PrevSequenceNum: ' + COALESCE(cast(@PrevSequenceNum  as varchar), 'null')        
      -- print '    @PrevCriteriaKey: ' + COALESCE(cast(@PrevCriteriaKey  as varchar), 'null')        
      -- print '    @ItemCount: ' + COALESCE(cast(@ItemCount  as varchar), 'null')        
      -- print '    @ItemValue: ' + COALESCE(cast(@ItemValue  as varchar), 'null')        
       
      IF CHARINDEX('@ItemValue', @SearchSQLFrom) > 0
      BEGIN
        -- From is a Functional Table that takes ItemValue as a parameter
        SET @SearchSQLFrom = REPLACE(@SearchSQLFrom, '@ItemValue', @ItemValue)
      END      

      IF @ColumnName = ''
      BEGIN
        -- There is no additional WHERE clause so go to next criteria without further processing
        -- This should only happen when the WHERE criteria is accomplished with a parameter to a Functional Table as above
        CLOSE item_cursor
        DEALLOCATE item_cursor

        FETCH NEXT FROM criteria_cursor INTO
          @CriteriaSequence,
          @SequenceNum,
          @SubSequenceNum,
          @CriteriaKey,
          @DetailCriteriaKey,
          @DataTypeCode,
          @GenTableID,
          @MiscKey,
          @AllowMultipleRowsInd,
          @AllowMultipleValuesInd,
          @MultValueSeparator,
          @DetailCriteriaInd,
          @ParentCriteriaInd,
          @StripDashesInd,
          @ParentCriteriaKey,
          @FullTextSearchInd,
          @IncludeZeroValuesInd

        IF @@FETCH_STATUS <> 0
          SET @DetailCriteriaKey = NULL

        GOTO FETCHED_NEXT_CRITERIA
      END        
            
      IF @LogicalOperator IS NULL
        SET @LogicalOperator = 'AND'
        
      IF @DetailCriteriaInd = 1
      BEGIN
        IF @SequenceNum = @PrevSequenceNum
          SET @ThisItemString = @ThisItemString + ' AND '
        ELSE 
        BEGIN
          -- This is a new detail criteria sequence. However, it could be using the same criteria as the previous one.
          -- In this case we need to group it with the previous set of detail criteria.
          IF @ParentCriteriaKey = @PrevCriteriaKey
            SET @DetailCriteriaString = @DetailCriteriaString + ') ' + @LogicalOperator + ' ('
          ELSE
            SET @DetailCriteriaString = '('

          SET @ThisItemString = ''
        END
      END
      ELSE
      BEGIN
        IF EXISTS (SELECT 1 FROM #SearchSQLCriteriaItem WHERE SequenceNum = @SequenceNum AND LogicalOperator = 'OR')
          SET @ThisItemString = '('
        ELSE
          SET @ThisItemString = ''
      END

      -- BEGIN Exists clause logic ------------------------------------------------------------------
      
      IF 1=1  -- so I can hide the block in SQL Server Manager
      BEGIN
        -- Override UseExistsClause flag if EXISTS clause should be used for entire criteria section
        IF @UseCriteriaExistsClause = 1 AND @LogicalOperator = 'AND'
          SET @UseExistsClause = 1

        -- EXISTS clause must be used when searching against the same table/column with an 'AND' operator
        -- (when multiple criteria of the same kind are allowed)
        IF @AllowMultipleRowsInd = 1 AND @LogicalOperator = 'AND'
          SET @UseExistsClause = 1

        -- Always use EXISTS clause for DISTRIBUTION STATUS composite criteria
        IF @ParentCriteriaKey = 193
          SET @UseExistsClause = 1

        -- When using the 'Not Equals' operator against table whose records may NOT exist for the given title,
        -- NOT EXISTS clause must be used (with an 'Equals' operator instead) to include also those titles
        -- that have NO records associated with the table being searched.
        IF @Tablename = 'csdistribution_view' OR (@ComparisonOperator = @OP_NEQ AND
          (@TableName = 'catalogsection' OR @TableName = 'season' OR @TableName = 'bookcustom' OR @TableName = 'bookaudience'))
        BEGIN
            -- Because ComparisonOperator is obtained at Item level, the tables
            -- have already been added to the FROM clause and an INNER JOIN to the WHERE clause.
            -- This is ok if the NOT EXISTS is true and other records exist in the joined table.
            -- But if there are no rows other rows than the ones that don't exist, the inner join 
            -- excludes the book/project/etc even though it meets the not exists criteria.
            -- So we remove the join.
          SET @SearchSQLFrom = REPLACE(@SearchSQLFrom, ', ' + @JoinToResultsFrom, '')
          SET @SearchSQLWhere = REPLACE(@SearchSQLWhere, @JoinToResultsWhere + ' AND ', '')
          IF @ComparisonOperator = @OP_NEQ
          BEGIN
            SET @UseNotExistsClause = 1
            IF @Tablename <> 'csdistribution_view'
              SET @ComparisonOperator = @OP_EQ
          END
        END

        -- When EXISTS clause will be used and the comparison operator is 'Not Equals',
        -- we must really use the NOT EXISTS clause w/'Equals' operator
        IF @UseExistsClause = 1 AND @ComparisonOperator = @OP_NEQ
        BEGIN
          IF @DetailCriteriaInd = 1 AND @SequenceNum = @PrevSequenceNum
          BEGIN
            IF CHARINDEX (@TableName, @ThisItemString) > 0 AND CHARINDEX(@ColumnName, @ThisItemString) = 0
            BEGIN
              SET @UseNotExistsClause = 0
              SET @ComparisonOperator = @OP_NEQ
            END
          END
          ELSE
          BEGIN   
            -- Because ComparisonOperator is obtained at Item level, the tables
            -- have already been added to the FROM clause and an INNER JOIN to the WHERE clause.
            -- This is ok if the NOT EXISTS is true and other records exist in the joined table.
            -- But if there are no rows other rows than the ones that don't exist, the inner join 
            -- excludes the book/project/etc even though it meets the not exists criteria.
            -- So we remove the join.
            SET @SearchSQLFrom = REPLACE(@SearchSQLFrom, ', ' + @JoinToResultsFrom, '')
            SET @SearchSQLWhere = REPLACE(@SearchSQLWhere, @JoinToResultsWhere + ' AND ', '')
            SET @UseNotExistsClause = 1
            SET @ComparisonOperator = @OP_EQ
          END
        END
      END

      -- END Exists clause logic ------------------------------------------------------------------

      --DEBUG
      PRINT '    @UseExistsClause=' + CONVERT(VARCHAR, @UseExistsClause)     
      PRINT '    @UseNotExistsClause: ' + CONVERT(VARCHAR, @UseNotExistsClause)
      PRINT '    @ComparisonOperator: ' + CONVERT(VARCHAR, @ComparisonOperator)

      -- Convert string criteria to UPPERCASE
      IF @DataTypeCode = 1
        SET @ItemValue = UPPER(@ItemValue)

      -- Strip dashes out of entered criteria when required by searchcriteria
      IF @StripDashesInd = 1
        SET @ItemValue = REPLACE(@ItemValue, '-', '')
               
      -- BEGIN Multiple values handling ------------------------------------------------------------------

      IF @AllowMultipleValuesInd = 1 AND @MultValueSeparator <> '' AND @ComparisonOperator = @OP_EQ  --Equals
      BEGIN
      
        IF CHARINDEX('CHAR(', @MultValueSeparator) > 0
          SET @MultValueSeparatorASCII = CONVERT(INT, REPLACE(REPLACE(@MultValueSeparator, 'CHAR(', ''), ')', ''))
        ELSE
          SET @MultValueSeparatorASCII = -1
          
        -- Replace single quote with double single quote in all string values
        SET @ItemValue = REPLACE(@ItemValue, '''', '''''')          

        IF @DataTypeCode = 1 -- string
        BEGIN
          -- Replace the multiple value separator with a comma and close each value with a single quote
          -- (ex: from '978-0-7627-1064-5;;978-0-8090-4219-7' to '978-0-7627-1064-5','978-0-8090-4219-7')
          IF @MultValueSeparatorASCII < 0
            SET @NewItemValue = '(''' + REPLACE(@ItemValue, @MultValueSeparator, ''',''') + ''')'
          ELSE
          BEGIN
            SET @NewItemValue = ''
            SET @Position = 1
            WHILE @Position <= DATALENGTH(@ItemValue)
            BEGIN
              IF ASCII(SUBSTRING(@ItemValue, @Position, 1)) = @MultValueSeparatorASCII
                SET @NewItemValue = @NewItemValue + ''','''
              ELSE
                SET @NewItemValue = @NewItemValue + SUBSTRING(@ItemValue, @Position, 1)
              SET @Position = @Position + 1
            END
            SET @NewItemValue = '(''' + @NewItemValue + ''')'
          END
        END
        ELSE IF @DataTypeCode = 2 -- numeric
        BEGIN
          IF @MultValueSeparatorASCII < 0
            SET @NewItemValue = '(' + REPLACE(@ItemValue, @MultValueSeparator, ',') + ')'
          ELSE
          BEGIN
            SET @NewItemValue = ''
            SET @Position = 1
            WHILE @Position <= DATALENGTH(@ItemValue)
            BEGIN
              IF ASCII(SUBSTRING(@ItemValue, @Position, 1)) = @MultValueSeparatorASCII
                SET @NewItemValue = @NewItemValue + ','
              ELSE
                SET @NewItemValue = @NewItemValue + SUBSTRING(@ItemValue, @Position, 1)
              SET @Position = @Position + 1
            END
            SET @NewItemValue = '(' + @NewItemValue + ')'
          END
        END
        --PRINT @MultValueSeparatorASCII
        --PRINT @NewItemValue
        
        SET @ItemValue = @NewItemValue
        SET @ComparisonOperator = @OP_IN --Use IN clause
      END
      -- END Multiple values handling ----------------------------------------------------------------------

      -- BEGIN Numeric/Text flag handling ------------------------------------------------------------------
      IF @DataTypeCode = 6 OR @DataTypeCode = 9	--Numeric Flag (1/0) OR Text Flag (Y/N)
      BEGIN          
        -- NOTE: For datatypes 6 and 9 - Numeric Flag (1/0) and Text Flag (Y/N), searching on OFF value
        -- with the 'Not Equals' operator is the SAME AS searching for ON value with 'Equals' operator
        -- (EX: NOT EQUALS 0 is the same as EQUALS 1; NOT EQUALS 'N' is the same as EQUALS 'Y')
        IF @ComparisonOperator = @OP_NEQ  --Not Equals
          BEGIN
            -- Switch operator from 'Not Equals' to 'Equals' and flip flag value
            SET @ComparisonOperator = @OP_EQ
            IF @ItemValue = '0'
              SET @ItemValue = '1'
            ELSE IF @ItemValue = '1'
              SET @ItemValue = '0'
            ELSE IF @ItemValue = 'N'
              SET @ItemValue = 'Y'
            ELSE IF @ItemValue = 'Y'
              SET @ItemValue = 'N'
          END
        ELSE  --Equals
          BEGIN
            IF @UseExistsClause = 1 AND (@ItemValue = '0' OR @ItemValue = 'N') AND 
              @TableName <> 'cs_element_view'
            BEGIN
              -- When using EXISTS clause for OFF flags, switch to NOT EXISTS clause
              -- and flip flag value
              SET @UseNotExistsClause = 1
              IF @ItemValue = '0'
                SET @ItemValue = '1'
              ELSE IF @ItemValue = 'N'
                SET @ItemValue = 'Y'                
            END
          END
      END
      -- END Numeric/Text flag handling ------------------------------------------------------------------
          
      -- For Miscellanous Item Gentable criteria, actual value is at subgentable level
      IF @DataTypeCode = 4 AND (@TableName = 'bookmisc' OR @TableName = 'taqprojectmisc' OR @TableName = 'globalcontactmisc' OR @TableName = 'taqelementmisc')
      BEGIN
        SET @ItemValue = @ItemSubgenValue
        SET @ItemSubgenValue = NULL
      END
      
      SELECT @ComparisonStringOp =
      CASE @ComparisonOperator
        WHEN 1 THEN ' = '		--Equals
        WHEN 2 THEN ' LIKE '		--Includes
        WHEN 3 THEN ' LIKE '		--Starts With
        WHEN 4 THEN ' > '		--Greater Than
        WHEN 5 THEN ' < '		--Less Than
        WHEN 6 THEN ' <> '		--Not Equal To
        WHEN 7 THEN ' BETWEEN '	--RANGE (special processing required)
        WHEN 8 THEN ' IN '  --Multiple values Equals search
      END
      
      --DEBUG
      PRINT '    @LogicalOperator: ' + @LogicalOperator
      PRINT '    @ComparisonOperator: ' + CONVERT(VARCHAR, @ComparisonOperator) + ' (' + @ComparisonStringOp + ')'
      PRINT '    @ItemValue: ' + @ItemValue
      IF @ItemSubgenValue IS NOT NULL
        PRINT '    @ItemSubgenValue: ' + @ItemSubgenValue
      IF @ItemSubgen2Value IS NOT NULL
        PRINT '    @ItemSubgen2Value: ' + @ItemSubgen2Value
      IF @ItemEndRangeValue IS NOT NULL
        PRINT '    @ItemEndRangeValue: ' + @ItemEndRangeValue 
      IF @ItemEstActBest IS NOT NULL
        PRINT '    @ItemEstActBest: ' + @ItemEstActBest
      IF @ItemAllAges IS NOT NULL
        PRINT '    @ItemAllAges: ' + @ItemAllAges

      -- Add needed quotation marks to string values
      IF ((@DataTypeCode = 1 OR @DataTypeCode = 9) AND @ComparisonOperator <> 8)		--Text OR Text Flag (but not multiple value IN clause search)
	     OR (@DataTypeCode = 10 AND 1 = (SELECT 1 WHERE @ItemValue LIKE 
       REPLACE('00000000-0000-0000-0000-000000000000', '0', '[0-9a-fA-F]')))                            -- globalcontactplaces has GUID keys into cloudregion
      BEGIN
        -- Initialize both quote strings to single quote
        SET @Quote = ''''
        IF @FullTextSearchInd = 1 AND @ComparisonOperator <> 2 BEGIN
            SET @Quote = ',' + '''' + '"'
        END
        SET @EndQuote = ''''
        IF @FullTextSearchInd = 1 AND @ComparisonOperator <> 2 BEGIN
          SET @EndQuote = '"' + ''''
        END
        IF @ComparisonOperator = @OP_INCLUDE BEGIN
          --IF @FullTextSearchInd = 1 BEGIN
          --  SET @Quote = ',' + '''' + '"*'
          --END
          --ELSE BEGIN
            SET @Quote = '''%'
          --END
        END
        IF @ComparisonOperator = @OP_INCLUDE OR @ComparisonOperator = @OP_START BEGIN
          IF @FullTextSearchInd = 1 AND @ComparisonOperator <> 2 BEGIN
            SET @EndQuote = '*"' + ''''
          END
          ELSE BEGIN
            SET @EndQuote = '%'''
          END
        END

        --PRINT '    @Quote: ' + @Quote
        --PRINT '    @EndQuote: ' + @EndQuote
        
        -- Replace single quote with double single quote in all string values
        SET @ItemValue = REPLACE(@ItemValue, '''', '''''')
        
        -- remove double quotes for full text search
        IF @FullTextSearchInd = 1 AND @ComparisonOperator <> 2 BEGIN
          SET @ItemValue = REPLACE(@ItemValue, '"', '')
        END      
      END

      -- BEGIN Table/criteria specific processing ----------------------------------------------------------

      IF 1=1 -- So I can hide the block in SQL Server Manager
      BEGIN
        -- For some criteria, we won't know how to build the entire WHERE clause (table join)
        -- until processing time, so we must modify it here, if needed:
        IF @TableName = 'season' AND @ItemValue <> '99999' --not UNSCHEDULED Season
          IF @ItemEstActBest = 'E'  --Estimated Season
            SET @ThisItemString = @ThisItemString + ' coretitleinfo.estseasonkey = season.seasonkey AND '
          ELSE IF @ItemEstActBest = 'A' --Actual Season
            SET @ThisItemString = @ThisItemString + ' coretitleinfo.seasonkey = season.seasonkey AND '
          ELSE  --Best Season
            SET @ThisItemString = @ThisItemString + ' coretitleinfo.bestseasonkey = season.seasonkey AND '
        ELSE IF @TableName = 'booksubjectcategory'  --any of the custom title categories
          SET @ThisItemString = @ThisItemString + ' booksubjectcategory.categorytableid=' + CONVERT(VARCHAR, @GenTableID) + ' AND '
        ELSE IF @TableName = 'globalcontactcategory'  --any of the custom contact categories
          SET @ThisItemString = @ThisItemString + ' globalcontactcategory.tableid=' + CONVERT(VARCHAR, @GenTableID) + ' AND '        
        ELSE IF @TableName = 'taqprojectsubjectcategory'  --any of the custom project categories
          SET @ThisItemString = @ThisItemString + ' taqprojectsubjectcategory.categorytableid=' + CONVERT(VARCHAR, @GenTableID) + ' AND '
        ELSE IF @TableName = 'bookcomments' and @FullTextSearchInd = 0
          SET @ThisItemString = @ThisItemString + ' subgentables.qsicode=' + CONVERT(VARCHAR, @CriteriaKey) + ' AND '
        ELSE IF @TableName = 'bookmisc'
          SET @ThisItemString = @ThisItemString + ' (bookmisc.misckey=' + CONVERT(VARCHAR, @MiscKey) + ' AND '
        ELSE IF @TableName = 'taqprojectmisc'
          SET @ThisItemString = @ThisItemString + ' (taqprojectmisc.misckey=' + CONVERT(VARCHAR, @MiscKey) + ' AND '
        ELSE IF @TableName = 'globalcontactmisc'
          SET @ThisItemString = @ThisItemString + ' (globalcontactmisc.misckey=' + CONVERT(VARCHAR, @MiscKey) + ' AND '
        ELSE IF @TableName = 'taqelementmisc'
          SET @ThisItemString = @ThisItemString + ' (taqelementmisc.misckey=' + CONVERT(VARCHAR, @MiscKey) + ' AND '
        ELSE IF @TableName = 'bookproductdetail'  --any of the bookproductdetail
          SET @ThisItemString = @ThisItemString + ' bookproductdetail.tableid=' + CONVERT(VARCHAR, @GenTableID) + ' AND '                
        ELSE IF @TableName = 'bookproductdetail#'  --any of the bookproductdetail
          SET @ThisItemString = @ThisItemString + ' bookproductdetail#.tableid=' + CONVERT(VARCHAR, @GenTableID) + ' AND '                

        --IF @CriteriaKey = 137 --Template Creation Date
        --  SET @ThisItemString = @ThisItemString + ' taqprojecttask.datetypecode=' + CONVERT(VARCHAR, @CreationDateCode) + ' AND '
              
        -- ***** Build ITEM-VALUE string for this passed <Item> ******
        -- For ESTIMATED searches, use SecondColumnName when constructing WHERE clause
        IF @ItemEstActBest = 'E' AND LTRIM(@SecondColumnName) <> ''
          SET @ColumnName = @SecondColumnName
        -- For BEST searches, use BestColumnName when constructing WHERE clause
        IF @ItemEstActBest = 'B' AND LTRIM(@BestColumnName) <> ''
          SET @ColumnName = @BestColumnName
      
        -- Construct basic value comparison for WHERE clause
        IF @TableName = 'season' AND @ItemValue = '99999' --UNSCHEDULED Season
          BEGIN
            SET @ThisItemString = @ThisItemString + '(coretitleinfo.seasonkey IS NULL'
            SET @ColumnName = 'coretitleinfo.seasonkey'
            SET @ItemEstActBest = ''
          END
        ELSE IF (@TableName = 'bookmisc' OR @TableName = 'taqprojectmisc' OR @TableName = 'globalcontactmisc' OR @TableName = 'taqelementmisc')
        BEGIN
          IF @ItemValue = '999999991' --<ANY VALUE> criteria
            SET @ThisItemString = @ThisItemString + @TableName + '.longvalue IS NOT NULL'
          ELSE IF @ItemValue = '999999992' --<NO VALUE> criteria
            SET @ThisItemString = @ThisItemString + @TableName + '.longvalue IS NULL'
          ELSE IF @ItemValue IS NOT NULL
            SET @ThisItemString = @ThisItemString + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
          ELSE
            SET @ThisItemString = @ThisItemString + @ColumnName + ' IS NOT NULL'
        END
        ELSE IF @CriteriaKey = 197  --First Printing Only flag - only build into where clause if 1-Yes selected
          BEGIN
            IF @ItemValue > 0
            BEGIN
              SET @ColumnName = REPLACE(@ColumnName, 'temp_printing', 'printing')            
              SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
            END
          END
        ELSE IF @CriteriaKey = 294  --Last Printing Only flag - only build into where clause if 1-Yes selected
          BEGIN
            IF @ItemValue > 0
            BEGIN
              SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + '(SELECT maxprintingnum FROM maxprintingnum_view where maxprintingnum_view.bookkey = taqprojectprinting_view.bookkey)'
            END
          END
        ELSE IF @CriteriaKey = 120 OR @CriteriaKey = 215  --Usage Class or Project Usage Class
          SET @ThisItemString = @ThisItemString + '(' + @SubgenColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
        ELSE IF @CriteriaKey = 211  --Project List
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp_qse_searchresults', 'qse_searchresults')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
          END
        ELSE IF @CriteriaKey = 246  --Title List
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp2_qse_searchresults', 'qse_searchresults')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
          END        
        ELSE IF @CriteriaKey = 240  --Metadata/Asset?
          BEGIN
            SELECT @CSEODStatus = CONVERT(VARCHAR, datacode)
            FROM gentables
            WHERE tableid = 639 AND qsicode = 5  --CS/EOD Title Level Status: Not up to date at all selected Partners
          
            IF @ItemValue = 1 --Metadata only
              SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @CSEODStatus + @EndQuote
            ELSE IF @ItemValue = 2  --Asset only
              SET @ThisItemString = @ThisItemString + '(' + @SecondColumnName + @ComparisonStringOp + @Quote + @CSEODStatus + @EndQuote
            ELSE
              SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @CSEODStatus + @EndQuote +
                ' OR ' + @SecondColumnName + @ComparisonStringOp + @Quote + @CSEODStatus + @EndQuote 
              
            SET @SecondColumnName = ''
          END
        ELSE IF @CriteriaKey = 250  --Element Contact
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp_elementcontact', 'globalcontact')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote 
          END
        ELSE IF @CriteriaKey = 256  --Media/Publication (GWOLF custom - element contact 1)
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp_elementcontact1', 'g1')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
          END
        ELSE IF @CriteriaKey = 257  --Reviewer (GWOLF custom - element contact 2)
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp_elementcontact2', 'g2')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
          END
        ELSE IF @CriteriaKey = 276  --Cloud Outbox Status
          BEGIN
		     IF @ItemValue = 1
			    SET @ColumnName = 'dbo.qcs_get_istitleinoutbox(' + @ColumnName + ') > 0'
		     ELSE
			    SET @ColumnName = 'dbo.qcs_get_istitleinoutbox(' + @ColumnName + ') = 0'
			  		   
		      IF ( @ComparisonOperator = @OP_NEQ )
			     SET @ThisItemString = @ThisItemString + 'NOT (' + @ColumnName
		      ELSE
			     SET @ThisItemString = @ThisItemString + ' (' + @ColumnName
          END
        ELSE IF @CriteriaKey = 89 AND @ItemValue = -2	--Eloquence Customer (ALL)
          BEGIN
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + ' IS NOT NULL '
          END
        ELSE IF @CriteriaKey = 277 or @CriteriaKey = 333  --Author/Participant Last Name, Author/Participant First Name
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp_globalcontact', 'globalcontact')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote 
          END 
        ELSE IF @CriteriaKey = 285 OR @CriteriaKey = 286 OR @CriteriaKey = 287 OR @CriteriaKey = 288 OR @CriteriaKey = 289  --PO Related Title/Prtg
          BEGIN
            SET @ColumnName = REPLACE(@ColumnName, 'temp_purchaseorderstitlesview', 'purchaseorderstitlesview')
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote 
          END          
        ELSE IF @CriteriaKey = 60  -- Titles 
		    BEGIN
			    IF @ItemValue IS NOT NULL BEGIN
				    IF UPPER(LEFT(@ItemValue, 4)) = 'THE ' BEGIN
					    SET @TitlePrefix = 'THE'
					    SET @Title = SUBSTRING(@ItemValue,5,LEN(@ItemValue))
				    END	
				    ELSE IF UPPER(LEFT(@ItemValue, 3)) = 'AN ' BEGIN
					    SET @TitlePrefix = 'AN'
					    SET @Title = SUBSTRING(@ItemValue,4,LEN(@ItemValue))
				    END	
				    ELSE IF UPPER(LEFT(@ItemValue, 2)) = 'A ' BEGIN
					    SET @TitlePrefix = 'A'
					    SET @Title = SUBSTRING(@ItemValue,3,LEN(@ItemValue))
				    END	
				    ELSE BEGIN
					    SET @TitlePrefix = NULL
				    END
    --				PRINT '    @TitlePrefix=' + CONVERT(VARCHAR, @TitlePrefix)
    --				PRINT '    @Title=' + CONVERT(VARCHAR, @Title)
				    IF @TitlePrefix  IS NOT NULL BEGIN
				        --PRINT '    @ThisItemString=' + CONVERT(VARCHAR, @ThisItemString)
					    SET @ThisItemString = @ThisItemString + ' ((UPPER(coretitleinfo.titleprefix) ' + @ComparisonStringOp +
					    + @Quote + @TitlePrefix + @EndQuote + 
					    '  AND ' + @ColumnName +  @ComparisonStringOp + @Quote + @Title + @EndQuote + 
					    ') OR (' + @ColumnName +  @ComparisonStringOp + @Quote + @ItemValue + @EndQuote + ') '
					    --PRINT '    @ThisItemString=' + CONVERT(VARCHAR, @ThisItemString)
				    END
				    ELSE BEGIN
					    SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
				    END
			     END
			    ELSE BEGIN
				    SET @ThisItemString = @ThisItemString + '(' + @ColumnName + ' IS NOT NULL '
			    END
    --			PRINT '    @ThisItemString=' + CONVERT(VARCHAR, @ThisItemString)
		    END                         
        ELSE
          IF @ItemValue IS NOT NULL
            IF @FullTextSearchInd = 1 AND @ComparisonOperator <> 2 BEGIN
              SET @ThisItemString = @ThisItemString + '(CONTAINS(' + @ColumnName + @Quote + @ItemValue + @EndQuote + ')'
            END
            ELSE BEGIN          
              SET @ThisItemString = @ThisItemString + '(' + @ColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
            END
          ELSE
            SET @ThisItemString = @ThisItemString + '(' + @ColumnName + ' IS NOT NULL '

        -- When 'Not Equals' comparison operator is used, must include IS NULL condition
        -- NOTE: 'Not Equals' operator will be filtered OUT when Allow Multiple entries (of SAME type) is 1
        IF ( @ComparisonOperator = @OP_NEQ )	--Not Equals
          IF ( @ItemSubgenValue is null )
            SET @ThisItemString = @ThisItemString + ' OR ' + @ColumnName + ' IS NULL'
          ELSE
            SET @ThisItemString = @ThisItemString

        -- When searching for Equals OFF flags ('N', 0 values), must include IS NULL condition
        IF @ComparisonOperator = @OP_EQ			--Equals
          IF @DataTypeCode = 6 AND @ItemValue = '0'		--Numeric Flag (1/0), OFF value
            SET @ThisItemString = @ThisItemString + ' OR ' + @ColumnName + ' IS NULL '
          ELSE IF @DataTypeCode = 9 AND @ItemValue = 'N'	--Text Flag (Y/N), OFF value
            SET @ThisItemString = @ThisItemString + ' OR ' + @ColumnName + ' IS NULL '
      
        -- Additional criteria filter
        IF @CriteriaKey = 241 --Pub Date
          SET @ThisItemString = @TableName + '.datetypecode=(SELECT datetypecode FROM datetype WHERE qsicode=7) AND ' + @ThisItemString
        
        -- When 'Range' comparison operator is used, must complete the BETWEEN condition
        IF @ComparisonOperator = @OP_BETWEEN			--Range
          SET @ThisItemString = @ThisItemString + ' AND ' + @Quote + @ItemEndRangeValue + @EndQuote
              
        IF @CriteriaKey = 295 --Age Range
        BEGIN
          IF @ItemValue = 0	--UP to age high
            SET @ThisItemString = @ThisItemString + ' OR bookdetail.agelowupind=1)'
          ELSE
            SET @ThisItemString = @ThisItemString + ')'
          SET @ThisItemString = @ThisItemString + ' AND (' + @SecondColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote + ' AND ' + @Quote + @ItemEndRangeValue + @EndQuote
          IF @ItemEndRangeValue = 9999	--Age low and UP
            SET @ThisItemString = @ThisItemString + ' OR bookdetail.agehighupind=1'       
        END
      
        IF @CriteriaKey = 296 --Grade Range
        BEGIN
          IF @ItemValue = -3	--UP to Grade high
            SET @ThisItemString = @ThisItemString + ' OR bookdetail.gradelowupind=1)'
          ELSE
            SET @ThisItemString = @ThisItemString + ')'
          SET @ThisItemString = @ThisItemString + ' AND (' + @SecondColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote + ' AND ' + @Quote + @ItemEndRangeValue + @EndQuote
          IF @ItemEndRangeValue = 9999	--Grade low and UP
            SET @ThisItemString = @ThisItemString + ' OR bookdetail.gradehighupind=1'       
        END      
              
        -- Book Verification Messages
        IF @CriteriaKey = 199 --verificationtypecode
          SET @VerificationTypeCode = @ItemValue
        IF @CriteriaKey = 306 --messagecategorycode
          SET @MessageCategoryCode = @ItemValue

        -- This join is necessary if we are searching on both verification type and message category
        IF @CriteriaKey = 306 AND @VerificationTypeCode <> '' --messagecategorycode
            SET @ThisItemString = @ThisItemString + ' AND bookverification.verificationtypecode = bookverificationmessage.verificationtypecode'       
        IF @CriteriaKey = 199 AND @MessageCategoryCode <> '' --verificationtypecode
            SET @ThisItemString = @ThisItemString + ' AND bookverification.verificationtypecode = bookverificationmessage.verificationtypecode'       
        
        IF LTRIM(@SecondColumnName) <> ''
        BEGIN  
          -- Some Text criteria may have second column populated - add OR to where clause
          -- (ColumnName OR SecondColumnName)
          IF @DataTypeCode = 1 OR @DataTypeCode = 4   --Text or Gentable
            SET @ThisItemString = @ThisItemString + ' OR ' +
                @SecondColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote              
        
          -- For BEST searches, add 'best' logic to criteria string (if BestColumnName not available)
          IF @ItemEstActBest = 'B' AND LTRIM(@BestColumnName) = ''               
          BEGIN
            -- Add the condition to search on second column when first column is NULL or 0
            -- NOTE: For now, assuming NUMERIC/FLOAT column BEST SEARCHES 
              SET @ThisItemString = @ThisItemString + ' OR ' +
                '((' + @ColumnName + ' IS NULL OR ' + @ColumnName + '=0) AND ' + 
                @SecondColumnName + @ComparisonStringOp + @Quote + @ItemValue + @EndQuote
 
            -- When 'Range' comparison operator is used, must complete the BETWEEN condition
            IF @ComparisonOperator = @OP_BETWEEN	--Range
              SET @ThisItemString = @ThisItemString + ' AND ' + @Quote + @ItemEndRangeValue + @EndQuote
          
            -- Close the parenthesis
            SET @ThisItemString = @ThisItemString + ')'
          END
        END --IF LTRIM(@SecondColumnName) <> ''

        IF @CriteriaKey = 159 AND @ParentCriteriaKey = 157 --RELATED TITLE - Title (detail criteria)
          SET @UseRelatedTitleUnion = 1  
      
        -- For Task searches (taqprojecttask table), we must take actualind into account
        -- since taqprojecttask always stores the date in activedate column, and actualind
        -- defines the date as Actual (1) or Estimated (0)
        IF @TableName = 'taqprojecttask' AND @ItemEstActBest = 'A'
          SET @ThisItemString = @ThisItemString + ' AND taqprojecttask.actualind=1'
      END
      
      -- END Table/criteria specific processing ----------------------------------------------------------

      -- Add subgentable and sub2gentable item-value string
      -- NOTE: Since the 'Not Equals' operator is always filtered out when Allow Multiple entries indicator
      -- is set to 1, subgentable and sub2gentable string will never be built at the same time when the
      -- IS NULL condition is added above 
      
      -- 2/19/10 - KW - There were issues with fixes for the listed cases below. Another related case is 11669.
      -- 11/18/09 Lisa  the 'Not Equals' operator is falling through here with a subgenvalue.
      -- See cases 11195 & 11364 & 11551
      IF @ComparisonOperator = @OP_NEQ
       BEGIN
        IF @ItemSubgenValue IS NOT NULL OR @ItemSubgen2Value IS NOT NULL
         BEGIN
          SET @ThisItemString = @ThisItemString + ' OR (' + @ColumnName + '=' + @Quote + @ItemValue + @EndQuote
          IF @ItemSubgen2Value IS NULL
            SET @ThisItemString = @ThisItemString + ' AND (' + @SubgenColumnName + '<>' + @ItemSubgenValue + ' OR ' + @SubgenColumnName + ' IS NULL)'
          ELSE
            SET @ThisItemString = @ThisItemString + ' AND ' + @SubgenColumnName + '=' + @ItemSubgenValue + 
              ' AND (' + @Subgen2ColumnName + '<>' + @ItemSubgen2Value + ' OR ' + @Subgen2ColumnName + ' IS NULL)'
          SET @ThisItemString = @ThisItemString + ')' 
         END
       END
      ELSE
       BEGIN
        IF @ItemSubgenValue IS NOT NULL
          SET @ThisItemString = @ThisItemString + ' AND ' + @SubgenColumnName + '=' + @ItemSubgenValue
        IF @ItemSubgen2Value IS NOT NULL
          SET @ThisItemString = @ThisItemString + ' AND ' + @Subgen2ColumnName + '=' + @ItemSubgen2Value
       END
	   
	    --02/07/2017 - JRG - 
	    --Need to have a check where if the destinations value = 0 the search will pull a record back.
	    --Used in New territory rights searches
	    IF ISNULL(@IncludeZeroValuesInd,0) = 1
		  BEGIN 
			  SET @ThisItemString = @ThisItemString + ' OR ' + @ColumnName + ' = ''0'''
		  END

      -- Close the parenthesis for built ITEM-VALUE string
--      SET @ThisItemString = @ThisItemString + ')'
      SET @ThisItemString = dbo.qutl_close_parens(@ThisItemString)

      --DEBUG
      PRINT '@ThisItemString: ' + @ThisItemString

      -- If this table has already been added to the select list, and now we must search against the same
      -- table again, use EXISTS clause to narrow down the search (ex: Pub Date and Release date ranges)
      IF @DetailCriteriaInd = 0
      BEGIN
        IF @ItemCount > 1
          SET @ItemValueString = @ItemValueString + ' ' + @LogicalOperator + ' '

        -- Do not use the Exists clause for the first instance of criteria or first item of the same criteria
        IF @FirstTableInstance = 1
        BEGIN          
          SET @TempSearch = ',' + CONVERT(VARCHAR, @CriteriaKey) + ','
          SET @TempPos = CHARINDEX(@TempSearch, @CriteriaKeysUsed) 
          IF @TempPos = 0 OR @ItemCount = 1
            SET @UseExistsClause = 0
        END

        IF @UseExistsClause = 1 OR @UseNotExistsClause = 1
          BEGIN
            -- For custom REVIEW LOG criteria, the element misc rows for different misckeys must refer to same taqelementkey - 
            -- remove taqprojectelement from the EXISTS clause, so taqprojectelement in the where clause refers to same element
            IF @TableName = 'taqelementmisc'
            BEGIN
              SET @JoinToResultsFrom = 'taqelementmisc'
              SET @JoinToResultsWhere = 'taqprojectelement.taqelementkey = taqelementmisc.taqelementkey'
            END
                      
            -- Build the EXISTS clause
            IF @UseNotExistsClause = 1
              SET @ExistsClause = '(NOT EXISTS (SELECT * FROM ' + @JoinToResultsFrom + ' WHERE ' + @JoinToResultsWhere
            ELSE
              SET @ExistsClause = '(EXISTS (SELECT * FROM ' + @JoinToResultsFrom + ' WHERE ' + @JoinToResultsWhere

            IF @JoinToResultsWhere <> ''
              SET @ExistsClause = @ExistsClause + ' AND ('
              
            SET @ExistsClause = @ExistsClause + @ThisItemString + ')'

            -- The built EXISTS clause is the ITEM-VALUE string
            SET @ItemValueString = @ItemValueString + @ExistsClause

          END
          ELSE
            SET @ItemValueString = @ItemValueString + @ThisItemString

        PRINT '@ItemValueString: ' + @ItemValueString
          
        SET @CriteriaKeysUsed = @CriteriaKeysUsed + CONVERT(VARCHAR, @CriteriaKey) + ','
          
      END

      IF @UseTableAlias = 1
        SET @ItemValueString = REPLACE(@ItemValueString, '#', CONVERT(VARCHAR, @TableAliasNum))

      FETCH NEXT FROM item_cursor INTO 
        @ItemValue,
        @ItemSubgenValue,
        @ItemSubgen2Value,
        @ItemEndRangeValue,
        @ItemEstActBest,
        @ItemAllAges,
        @ComparisonOperator,
        @LogicalOperator

      IF @UpdateUsageClass = 1
      BEGIN
        IF @@FETCH_STATUS = 0 --more values fetched
          UPDATE qse_searchlist
          SET usageclasscode = 0
          WHERE userkey = @UserKey AND
              searchtypecode = @SearchType AND
              listtypecode = @ListType
        ELSE  --there are no more values
        BEGIN
          IF @ItemValue IS NULL SET @ItemValue = 0
          SET @SelectedUsageClass = @ItemValue

          UPDATE qse_searchlist
          SET usageclasscode = @SelectedUsageClass
          WHERE userkey = @UserKey AND
              searchtypecode = @SearchType AND
              listtypecode = @ListType
        END
      END
    END --item_cursor

    NEXT_CRITERIA:
    
    CLOSE item_cursor
    DEALLOCATE item_cursor

    --- Finished processing item values within criteria instance --------------

    -- Keep track of previous criteria key and sequence number
    IF @DetailCriteriaInd = 1
      SET @PrevCriteriaKey = @ParentCriteriaKey
    ELSE
      SET @PrevCriteriaKey = @CriteriaKey

    SET @PrevSequenceNum = @SequenceNum    
    SET @PrevParentCriteriaKey = @ParentCriteriaKey
    SET @PrevDetailCriteriaInd = @DetailCriteriaInd
    
    FETCH NEXT FROM criteria_cursor INTO
      @CriteriaSequence,
      @NewSequenceNum,
      @NewSubSequenceNum,
      @CriteriaKey,
      @DetailCriteriaKey,
      @DataTypeCode,
      @GenTableID,
      @MiscKey,
      @AllowMultipleRowsInd,
      @AllowMultipleValuesInd,
      @MultValueSeparator,
      @DetailCriteriaInd,
      @ParentCriteriaInd,
      @StripDashesInd,
      @ParentCriteriaKey,
      @FullTextSearchInd,
      @IncludeZeroValuesInd

    IF @@FETCH_STATUS <> 0
      SET @FinalCriteria = 1

    IF @FinalCriteria = 1
      SET @DetailCriteriaKey = NULL
    
    -- Now that we have the next criteria info, process the items from the previous -------------------------

    -- If this is a new criteria sequence...
    IF @PrevDetailCriteriaInd = 0 OR @FinalCriteria = 1 OR @SequenceNum <> @NewSequenceNum
    BEGIN
      IF @PrevDetailCriteriaInd = 1
      BEGIN
        PRINT '@DetailCriteriaString: ' + @DetailCriteriaString

        -- DISTRIBUTION STATUS (193) should always use EXISTS clause
        IF @PrevParentCriteriaKey <> 193
        BEGIN
          -- Do not use the Exists clause for the first instance of detail criteria with an AND logical operator
          SET @TempSearch = ',' + CONVERT(VARCHAR, @CriteriaKey) + ','
          SET @TempPos = CHARINDEX(@TempSearch, @CriteriaKeysUsed) 
          IF @TempPos = 0
            SET @UseExistsClause = 0
        END
        ELSE IF @PrevParentCriteriaKey = 235 BEGIN   -- COUNTRY RIGHTS
          -- may be overkill here but just in case
          SET @UseExistsClause = 0
          SET @UseNotExistsClause = 0
        END
        
        IF @UseExistsClause = 1 OR @UseNotExistsClause = 1
        BEGIN
          -- Build the EXISTS clause (@ExistsSearchSQLWhere ends with 'AND')
          IF @UseNotExistsClause = 1
            SET @ExistsClause = '(NOT EXISTS (SELECT 1 FROM ' + @JoinToResultsFrom + ' WHERE ' + @JoinToResultsWhere
          ELSE
            SET @ExistsClause = '(EXISTS (SELECT 1 FROM ' + @JoinToResultsFrom + ' WHERE ' + @JoinToResultsWhere

          SET @ExistsClause = @ExistsClause + ' AND ' + @ThisItemString + '))'

          -- The built EXISTS clause is the ITEM-VALUE string
          SET @ItemValueString = @ItemValueString + @ExistsClause
        END
        ELSE
          SET @ItemValueString = @ItemValueString + @ThisItemString        
        
        -- For detail criteria, check the next fetched row's parentcriteriakey
        IF @DetailCriteriaKey IS NULL
          SET @PrevParentCriteriaKey = 0
        ELSE        
          SELECT @PrevParentCriteriaKey = @CriteriaKey

        -- Close the parenthesis for all detail criteria of same parent
        IF @PrevParentCriteriaKey <> @PrevCriteriaKey 
        BEGIN
          SET @DetailCriteriaString = @DetailCriteriaString + @ItemValueString
          SET @DetailCriteriaString = dbo.qutl_close_parens(@DetailCriteriaString)
          SET @CriteriaString = @CriteriaString + @DetailCriteriaString
          SET @DetailCriteriaString = ''
        END
        ELSE
        BEGIN
          SET @DetailCriteriaString = @DetailCriteriaString + @ItemValueString
          SET @ItemValueString = ''
        END
        
        PRINT '1979 @DetailCriteriaString: ' + @DetailCriteriaString
        PRINT '1980 @CriteriaString: ' + @CriteriaString

        -- Record the fact that we have seen this criteria key
        SET @CriteriaKeysUsed = @CriteriaKeysUsed + CONVERT(VARCHAR, @PrevParentCriteriaKey) + ','
      END
      ELSE -- Non-detail criteria
      BEGIN
        SET @CriteriaString = @CriteriaString + @ItemValueString
      END
    END

    IF @ItemAllAges = 1
    BEGIN
      IF @CriteriaString IS NULL
        SET @CriteriaString = 'bookdetail.allagesind=1'
      ELSE
		    SET @CriteriaString = @CriteriaString + ' OR bookdetail.allagesind=1'
  	END

    IF @CriteriaString <> ''
      SET @CriteriaString = '(' + @CriteriaString + ')'

    SET @CriteriaString = dbo.qutl_close_parens(@CriteriaString)
        
    --DEBUG
    PRINT '1999 @CriteriaCount: ' + convert(varchar, @CriteriaCount)
    PRINT '2000 @ItemValueString: ' + @ItemValueString
    PRINT '2001 @CriteriaString: ' + @CriteriaString
        
    IF @SequenceNum <> @PrevSequenceNum
    BEGIN
      SET @CriteriaString = dbo.qutl_close_parens(@CriteriaString)
    END
    PRINT '2007 @CriteriaString: ' + @CriteriaString
    PRINT '2008 @SearchSQLCriteria: ' + @SearchSQLCriteria

    IF @CriteriaCount > 1 AND @CriteriaString <> '' AND ltrim(rtrim(@SearchSQLCriteria)) <> '' 
    BEGIN
      SET @SearchSQLCriteria = @SearchSQLCriteria + ' AND ' + @CriteriaString
    END
    ELSE
      SET @SearchSQLCriteria = @SearchSQLCriteria + @CriteriaString
        
    PRINT '*** @SearchSQLCriteria: ' + @SearchSQLCriteria
      
    IF (@PrevParentCriteriaKey = 251)
      SET @CriteriaCount = @CriteriaCount + 1           

    SET @SequenceNum = @NewSequenceNum
    SET @SubSequenceNum = @NewSubSequenceNum

    FETCHED_NEXT_CRITERIA:
  END

  CLOSE criteria_cursor
  DEALLOCATE criteria_cursor

  -- ********* Additional criteria filter ********* --
  -- For Titles, only show first printing and no templates 
  -- 9/22/08 - AK - Templates can be searched for (Case #5532)
  IF @SearchItem = 1 BEGIN	-- Titles
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND (coretitleinfo.printingkey=1 OR coretitleinfo.issuenumber>1)'
  END
  
  -- For Contact Searches, show all public contacts, user's own private Contacts, 
  -- and private contacts of other users on their private team
  IF @SearchItem = 2 BEGIN  --Contacts     
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND (corecontactinfo.privateind IS NULL OR corecontactinfo.privateind=0' +
      ' OR (corecontactinfo.privateind=1 AND (owneruserkey=' + CONVERT(VARCHAR, @UserKey) +
      ' OR corecontactinfo.owneruserkey IN (SELECT accesstouserkey FROM qsiprivateuserlist' +
      ' WHERE primaryuserkey=' + CONVERT(VARCHAR, @UserKey) + '))))'
    
    -- Case 10906 - For Title Participant search, also restrict contacts with "Private Author" role
    IF @TitleParticipantSearch = 1 BEGIN
      SET @SearchSQLCriteria = @SearchSQLCriteria + ' AND corecontactinfo.contactkey NOT IN 
       (SELECT gr.globalcontactkey
        FROM globalcontactrole gr
        WHERE gr.globalcontactkey = corecontactinfo.contactkey AND
              gr.rolecode IN (SELECT datacode	FROM gentables WHERE tableid=285 AND qsicode=8))'

    END
  END  
  
  -- All project-based searches must filter on searchitemcode
  -- Projects(3)/P&L Templates(5)/Journals(6)/Works(9)/Contracts(10)/Scales(11)/Printings(14)
  IF @SearchItem = 3 OR @SearchItem = 5 OR @SearchItem = 6  OR @SearchItem = 9 OR @SearchItem = 10 OR @SearchItem = 11 OR @SearchItem = 14 OR @SearchItem = 15 BEGIN  
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND coreprojectinfo.searchitemcode=' + CONVERT(VARCHAR, @SearchItem)
  END
  
  -- Titles and project-based searches (except Journals) must filter based on usage class security setup for the user
  IF @SearchItem = 1 OR @SearchItem = 3 OR @SearchItem = 5 OR @SearchItem = 9 OR @SearchItem = 10 OR @SearchItem = 11 BEGIN
    -- Check if 'ALL' usageclasses row exists for this Item Type and UserKey
    SELECT @TempCounter = COUNT(*)
    FROM qsiusersusageclass 
    WHERE userkey = @UserKey AND itemtypecode = @SearchItem AND usageclasscode=0

    -- Only if 'ALL' row does not exist for this Item Type and user filter on user's allowed usage classes
    IF @TempCounter = 0 BEGIN
      SET @SearchSQLCriteria = @SearchSQLCriteria +
        ' AND ' + @UsageClassTableName + '.usageclasscode IN
          (SELECT usageclasscode FROM qsiusersusageclass
           WHERE userkey=' + CONVERT(VARCHAR, @UserKey) + ' AND itemtypecode=' + CONVERT(VARCHAR, @SearchItem) + ')'
    END
  END
  
  -- For Project Searches, show all public projects, user's own private projects, 
  -- and private projects of other users on their private team
  IF @SearchType = 7 BEGIN  --Projects
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND (coreprojectinfo.privateind IS NULL OR coreprojectinfo.privateind=0' +
      ' OR (coreprojectinfo.privateind=1 AND (projectownerkey=' + CONVERT(VARCHAR, @UserKey) +
      ' OR coreprojectinfo.projectownerkey IN (SELECT accesstouserkey FROM qsiprivateuserlist' +
      ' WHERE primaryuserkey=' + CONVERT(VARCHAR, @UserKey) + '))))'
  END
  
  -- For List Searches, only return user-defined results lists (listtypecode=3,saveascriteriaind=0)
  -- Return only public lists, user's own private lists, and private lists of other users on their private team
  IF @SearchType = 16 BEGIN
    SET @SearchSQLCriteria = @SearchSQLCriteria +
      ' AND qse_searchlist.listtypecode=3 AND qse_searchlist.saveascriteriaind=0' +
      ' AND (qse_searchlist.privateind IS NULL OR qse_searchlist.privateind=0' +
      ' OR (qse_searchlist.privateind=1 AND (qse_searchlist.userkey=' + CONVERT(VARCHAR, @UserKey) +
      ' OR qse_searchlist.userkey IN (SELECT accesstouserkey FROM qsiprivateuserlist' +
      ' WHERE primaryuserkey=' + CONVERT(VARCHAR, @UserKey) + '))))'
  END  
  
  -- For Owner Project Search (on Home Page), show all user's own projects, as well as 
  -- all projects for the users on their private team. Don't show "cancelled" projects.
  IF @SearchType = 10 BEGIN
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND (((coreprojectinfo.privateind IS NULL OR coreprojectinfo.privateind=0) AND coreprojectinfo.projectkey IN 
          (SELECT TOP 100 PERCENT c.projectkey 
          FROM coreprojectinfo c, 
           qse_searchlist l, 
           qse_searchresults r
          WHERE c.projectkey = r.key1 and 
           r.listkey = l.listkey and
           l.searchtypecode = 7 and 
           l.listtypecode = 7 and
           l.userkey = ' + CONVERT(VARCHAR, @UserKey) + 
           ' ORDER BY r.lastuse desc' +
            '))' +
      ' OR (coreprojectinfo.privateind=1 AND (projectownerkey=' + CONVERT(VARCHAR, @UserKey) +
      ' OR coreprojectinfo.projectownerkey IN (SELECT accesstouserkey FROM qsiprivateuserlist' +
      ' WHERE primaryuserkey=' + CONVERT(VARCHAR, @UserKey) + '))))'
  END
  
  -- For Journal Searches, show all public journals, user's own private journals, 
  -- and private journals of other users on their private team
  IF @SearchType = 18 BEGIN  --Journals
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND (coreprojectinfo.privateind IS NULL OR coreprojectinfo.privateind=0' +
      ' OR (coreprojectinfo.privateind=1 AND (projectownerkey=' + CONVERT(VARCHAR, @UserKey) +
      ' OR coreprojectinfo.projectownerkey IN (SELECT accesstouserkey FROM qsiprivateuserlist' +
      ' WHERE primaryuserkey=' + CONVERT(VARCHAR, @UserKey) + '))))'
  END

  -- For Task View Search do not show Task Groups
  IF @SearchType = 19 BEGIN  -- Task View
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND ISNULL(taskview.taskgroupind,0)=0'
  END

  -- For Task Group Search only show Task Groups
  IF @SearchType = 20 BEGIN  -- Task Group
    SET @SearchSQLCriteria = @SearchSQLCriteria + 
      ' AND ISNULL(taskview.taskgroupind,0)=1'
  END

  -- For CS/ELO Outbox, get only Send To Elo titles with statuses: 1-Not Sent, 3-Resend, 6-Delete (mimics Powerbuilder Elo Outbox)
  -- and bookdetail.csapprovalcode = 1
  IF @SearchType = 26 BEGIN
    --SET @SearchSQLFrom = @SearchSQLFrom + ', bookedipartner, bookedistatus'
    --SET @SearchSQLWhere = @SearchSQLWhere + ' bookedipartner.edipartnerkey = bookedistatus.edipartnerkey AND ' +         
    --  'bookedipartner.bookkey = bookedistatus.bookkey AND bookedipartner.printingkey = bookedistatus.printingkey AND ' +   
    --  'bookedistatus.bookkey = coretitleinfo.bookkey AND bookedistatus.printingkey = coretitleinfo.printingkey AND '

    -- Add this table only if it doesn't already exist in the SQL FROM clause
    IF CHARINDEX(', bookdetail,', ', ' + @SearchSQLFrom + ',') = 0 BEGIN
       IF CHARINDEX(', bookdetail ', ', ' + @SearchSQLFrom + ' ') = 0 BEGIN
          SET @SearchSQLFrom = @SearchSQLFrom + ', bookdetail' 
          SET @SearchSQLWhere = @SearchSQLWhere + 'coretitleinfo.bookkey = bookdetail.bookkey AND '
       END
    END
    --SET @SearchSQLCriteria = @SearchSQLCriteria + 'AND bookedipartner.sendtoeloquenceind = 1 AND bookedistatus.edistatuscode in (1,3,6)' +
    --    ' AND bookdetail.csapprovalcode = 1'
    SET @SearchSQLCriteria = @SearchSQLCriteria + ' AND ([dbo].qcs_get_csapproved(bookdetail.bookkey) = 1)'
  END
  
  -- For eloquence Outbox search, get only Send To Elo titles with statuses: 1-Not Sent, 3-Resend, 6-Delete (mimics Powerbuilder Elo Outbox)
  IF @SearchType = 27 BEGIN
    SET @SearchSQLFrom = @SearchSQLFrom + ', bookedipartner, bookedistatus'
    SET @SearchSQLWhere = @SearchSQLWhere + ' bookedipartner.edipartnerkey = bookedistatus.edipartnerkey AND ' +         
      'bookedipartner.bookkey = bookedistatus.bookkey AND bookedipartner.printingkey = bookedistatus.printingkey AND ' +   
      'bookedistatus.bookkey = coretitleinfo.bookkey AND bookedistatus.printingkey = coretitleinfo.printingkey AND '
    SET @SearchSQLCriteria = @SearchSQLCriteria + 'AND bookedipartner.sendtoeloquenceind = 1 AND bookedistatus.edistatuscode in (1,3,6)'
  END

  -- ************* Parse KEY COLUMNS **************** --
  IF @SelectedUsageClass IS NULL
    SET @SelectedUsageClass = 0

  SELECT @TempCounter = COUNT(*)
  FROM qse_searchresultscolumns
  WHERE searchtypecode = @SearchType AND 
      usageclasscode = @SelectedUsageClass AND
      keycolumnind = 1
      
  IF @TempCounter = 0
    SET @SelectedUsageClass = 0
  
  --DEBUG
  --PRINT '@SelectedUsageClass: ' + CONVERT(VARCHAR, @SelectedUsageClass)
  
  -- Get key column results for the given search type (FOR SELECT LIST)
  DECLARE searchresultskeys_cursor CURSOR FOR
    SELECT tablename, columnname
    FROM qse_searchresultscolumns
    WHERE searchtypecode = @SearchType AND 
        usageclasscode = @SelectedUsageClass AND
        keycolumnind = 1
    ORDER BY columnnumber ASC

  OPEN searchresultskeys_cursor

  FETCH NEXT FROM searchresultskeys_cursor INTO
    @ResultsTableName, @ResultsColumnName

  -- Loop to build the KeyColumnString which will be used to determine list of KEY COLUMN VALUES at runtime.
  -- The KeyColumnString will be used to build the INSERT statement into the qse_searchresults table.
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @KeyColumnCounter = @KeyColumnCounter + 1
    SET @KeyColumnString = @KeyColumnString + 'COALESCE(' + @ResultsTableName + '.' + @ResultsColumnName + ',0)'

    FETCH NEXT FROM searchresultskeys_cursor INTO
      @ResultsTableName, @ResultsColumnName

    IF @@FETCH_STATUS = 0
      SET @KeyColumnString = @KeyColumnString + ', '
    ELSE
      SET @KeyColumnString = @KeyColumnString + ' '
  END

  -- There are 4 PRIMARY KEY columns on qse_searchresults table at the moment - listkey, and 3 key columns.
  -- Values must always be inserted to all four columns - insert 0 into key2 and key3 columns if KEY consists of only one value.
  IF @KeyColumnCounter < 2
    SET @KeyColumnString = @KeyColumnString + ', 0, 0'
  ELSE IF @KeyColumnCounter < 3
    SET @KeyColumnString = @KeyColumnString + ', 0'

  CLOSE searchresultskeys_cursor
  DEALLOCATE searchresultskeys_cursor
  
  -- *********** Initialize SQL ************* --
  SET @SearchSQLSelect = @SearchSQLSelect + CONVERT(VARCHAR, @ListKey) + ', ' + @KeyColumnString
  SET @SearchSQLCriteria = '(' + @SearchSQLCriteria + ') ' --NOTE: these parentheses make a big performance difference

  -- ************ ORGENTRY SECURITY FILTER ************ -- 
  IF @SearchType <> 16 
  BEGIN  --not for list searches
    EXEC qse_get_orgentry_filter @SearchType,
      @OrgentryFilter,
      @UserKey,
      @ReturnResultsWithNoOrgentries,
      @OrgentryTableName OUTPUT,
      @OrgEntryJoinWhere OUTPUT,
      @OrgEntryCriteriaWhere OUTPUT,
      @o_error_code OUTPUT,
      @o_error_desc OUTPUT

    -- For Contact searches, UNION clause must be used because of orgentry classification: 
    -- some contacts will have orglevel hierarchy assigned, and these records must be filtered accordingly, 
    -- and other contacts will NOT have orglevel selected at all, and these records must show for all.
    SET @OrgentrySQLUnion = ''
    IF @SearchItem = 2 AND (@OrgentryFilter = ' ' OR @ReturnResultsWithNoOrgentries = 1)
    BEGIN
      SET @OrgentrySQLUnion = CHAR(13) + ' UNION ' + CHAR(13) + 
        @SearchSQLSelect + ' ' + @SearchSQLFrom + ' ' + 
        @SearchSQLWhere + ' ' + @SearchSQLCriteria +
        ' AND NOT EXISTS (SELECT * FROM ' + @OrgentryTableName +
        ' WHERE ' + @OrgEntryJoinWhere + ')'
    END
      
    -- Now, after SQL union string is built, add orgentry table to the main SQL
    PRINT ''
    PRINT '@OrgEntryJoinWhere: ' + @OrgEntryJoinWhere
    PRINT '@OrgentryTableName: ' + @OrgentryTableName
    PRINT '@OrgEntryCriteriaWhere: ' + @OrgEntryCriteriaWhere

    IF LTRIM(RTRIM(@OrgEntryCriteriaWhere)) <> ''
    BEGIN
      IF LTRIM(RTRIM(@OrgEntryJoinWhere)) <> ''
        SET @SearchSQLWhere = @SearchSQLWhere + @OrgEntryJoinWhere + ' AND '

      -- Add this table only if it doesn't already exist in the SQL FROM clause
      IF CHARINDEX(@OrgentryTableName + ',', @SearchSQLFrom) = 0 AND CHARINDEX(@OrgentryTableName + ' ', @SearchSQLFrom) = 0
        SET @SearchSQLFrom = @SearchSQLFrom + ', ' + @OrgentryTableName

      SET @SearchSQLCriteria = @SearchSQLCriteria + ' AND ' + @OrgEntryCriteriaWhere
    END
  END --IF @SearchType <> 16

  --PRINT '@SearchSQLCriteria: ' + @SearchSQLCriteria

  /***** START THE TRANSACTION *****/
  BEGIN TRANSACTION
 
  -- Delete any existing items for this list
  DELETE FROM qse_searchresults WHERE listkey = @ListKey

  -- Just for good measure
  SET @SearchSQLCriteria = dbo.qutl_close_parens(@SearchSQLCriteria)
 
  -- Build the search SQL
  SET @SearchSQL = N'' + @SearchSQLSelect + ' ' + @SearchSQLFrom + ' ' + 
    @SearchSQLWhere + ' ' + @SearchSQLCriteria
   
  -- Additional processing for contact searches
  IF @SearchItem = 2  -- Contacts
  BEGIN
    -- Add the orgentry filter UNION statement
    SET @SearchSQL = @SearchSQL + @OrgentrySQLUnion
      
    -- If the contact search sql includes globalcontactrelationship_view, another UNION statement
    -- must be added for this search to take into account the reverse relationship
    IF CHARINDEX('globalcontactrelationship_view', @SearchSQL) > 0
    BEGIN
      SET @ContactSQLUnion = REPLACE(@SearchSQL, 'globalcontactrelationship_view.globalcontactkey1', '<placeholder>')
      SET @ContactSQLUnion = REPLACE(@ContactSQLUnion, 'globalcontactrelationship_view.globalcontactkey2', 'globalcontactrelationship_view.globalcontactkey1')
      SET @ContactSQLUnion = REPLACE(@ContactSQLUnion, '<placeholder>', 'globalcontactrelationship_view.globalcontactkey2')
        
      SET @ContactSQLUnion = REPLACE(@ContactSQLUnion, 'globalcontactrelationship_view.contactrelationshipcode1', '<placeholder>')
      SET @ContactSQLUnion = REPLACE(@ContactSQLUnion, 'globalcontactrelationship_view.contactrelationshipcode2', 'globalcontactrelationship_view.contactrelationshipcode1')
      SET @ContactSQLUnion = REPLACE(@ContactSQLUnion, '<placeholder>', 'globalcontactrelationship_view.contactrelationshipcode2')
        
      SET @SearchSQL = @SearchSQL + CHAR(13) + ' UNION ' + CHAR(13) + @ContactSQLUnion
    END
  END
    
  IF @UseRelatedTitleUnion = 1
  BEGIN
    SET @RelatedTitleSQLUnion = REPLACE(@SearchSQL, 'coretitleinfo, taqprojecttitle', 'taqprojecttitle')
    SET @RelatedTitleSQLUnion = REPLACE(@RelatedTitleSQLUnion, 'taqprojecttitle.bookkey = coretitleinfo.bookkey AND', '')
    SET @RelatedTitleSQLUnion = REPLACE(@RelatedTitleSQLUnion, 'coretitleinfo.title', 'taqprojecttitle.relateditem2name')
      
    SET @SearchSQL = @SearchSQL + CHAR(13) + ' UNION ' + CHAR(13) + @RelatedTitleSQLUnion
  END
  
  --exec qutl_trace 'qse_search_request',
  --  '@SearchSQL', NULL, @SearchSQL

  -- Build the dynamic INSERT statement
  SET @InsertSQL = N'INSERT INTO qse_searchresults (listkey, key1, key2, key3) ' + CHAR(13) + @SearchSQL
    
  -- EXECUTE the dynamic INSERT statement to insert key values for the results into qse_searchresults table
  EXECUTE sp_executesql @InsertSQL
  
  -- Return number of rows inserted
  SELECT @o_number_of_rows = @@ROWCOUNT, @o_error_code = @@ERROR
  SET @o_listkey = @ListKey
  
  -- If the number of rows returned by the search is greater than the client's maximum allowed rows,
  -- clear the results for this listkey - we want to prevent timeouts when loading large result sets
  IF @o_number_of_rows > @MaxSearchRows
  BEGIN
    DELETE FROM qse_searchresults
    WHERE listkey = @ListKey
  END

  /******** COMMIT ********/
  COMMIT TRANSACTION
  
  -- If ReturnResults indicator is ON, execute procedure that will return search results
  IF @ReturnResultsInd = 1
    BEGIN
      EXECUTE qse_return_list @ListKey, @UserKey, null, @ResultsViewKey, @PopupInd, 
        @o_ColumnOrderList OUTPUT, @o_StyleList OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

      -- Check if search results were returned for the given listkey
      SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
      IF @ErrorVar <> 0
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Error returning list results for listkey ' + CONVERT(VARCHAR, @ListKey)
          GOTO ExitHandler
        END

      IF @RowcountVar = 0
        BEGIN
          SET @o_error_code = 0
          SET @o_error_desc = 'No rows returned for listkey ' + CONVERT(VARCHAR, @ListKey)
          GOTO ExitHandler
        END
    END

  GOTO ExitHandler
  
------------
ExitHandler:
------------

--DEBUG
--PRINT @InsertSQL
    DROP TABLE #SearchSQLCriteria
    DROP TABLE #SearchSQLCriteriaItem

  -- Close criteria cursors if still valid
  IF CURSOR_STATUS('local', 'criteria_cursor_xml') >= 0
  BEGIN
    CLOSE criteria_cursor_xml
    DEALLOCATE criteria_cursor_xml
  END

  IF CURSOR_STATUS('local', 'criteria_cursor') >= 0
  BEGIN
    CLOSE criteria_cursor
    DEALLOCATE criteria_cursor
  END

  IF @IsOpen = 1
    EXEC sp_xml_removedocument @DocNum

  IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> ''
    PRINT 'ERROR: ' + @o_error_desc
  
END
GO

GRANT EXEC ON qse_search_request TO PUBLIC
GO
