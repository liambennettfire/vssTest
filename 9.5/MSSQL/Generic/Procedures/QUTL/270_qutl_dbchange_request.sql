IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_dbchange_request')
BEGIN
  PRINT 'Dropping Procedure qutl_dbchange_request'
  DROP  Procedure  qutl_dbchange_request
END
GO

PRINT 'Creating Procedure qutl_dbchange_request'
GO

CREATE PROCEDURE qutl_dbchange_request
(
  @i_transaction_xml		NTEXT,
  @o_new_keys       VARCHAR(4000) output,
  @o_warnings       VARCHAR(4000) output,
  @o_error_code			INT           output,
  @o_error_desc			VARCHAR(2000) output 
)
AS

/**********************************************************************************
**  Name: qutl_dbchange_request
**  Desc: This stored procedure is responsible for updating, adding and deleting 
**        from the database. It takes an XML document as a parameter which may
**        contain multiple DB actions that need to take place in a transaction.
**
**  Auth: Kate
**  Date: 28 Apr 2004
**	Revised:    04192010 JH - commented out lines ~865 that handled the html special chars
**              since the fckEditor was configured differently and these are handled up front now.
**********************************************************************************
**    Change History
*************************************************************************************************
**    Date:       Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    03/04/16     UK			  Case 36761  
**    03/22/2016   Kusum          Case 36980 File Location not Writing to Title History from Web 
**    04/06/2016   Kusum          Case 36178 Keys Table at S&S Getting Close to Max Value     
***********************************************************************************************/

BEGIN

--mk20140306> this is code to write the incoming message to a table so it can degugged
--drop table mk_DebugInfo
--create table mk_DebugInfo(Val NTEXT, LastMaintDate datetime, Msg varchar(max))
--insert into mk_DebugInfo select @i_transaction_xml,GETDATE(),'line 37 DB_ChangeReq'

  DECLARE 
	@IsOpen   BIT,
	@IsTitleHistoryTable  BIT,
	@IsContactHistoryTable  BIT,
	@ManageTransactions   BIT,
	@BookKey  INT,
	@PrintingKey  INT,
	@DateTypeCode INT,
	@CheckCount   INT,
	@DocNum			INT,
	@FetchAction		INT,
	@FetchKeys		INT,
	@FetchValues		INT,
	@FetchColumns   INT,
	@HistoryOrder	INT,
	@GlobalContactKey INT,
    @CommentTypeCode INT,
	@StringLength		INT,
	@ActionSequence		VARCHAR(10),
	@ActionType		VARCHAR(20),
	@ActionTable		VARCHAR(50),
	@ProcedureName  VARCHAR(50),
	@Parameters     VARCHAR(4000),
	@DBType  		VARCHAR(50),
	@DBItemColumn		VARCHAR(120),
	@DBItemDesc     VARCHAR(4000),
	@DBItemValue		VARCHAR(4000),
	@FieldDescDetail VARCHAR(120),
	@HistoryColumn	VARCHAR(120),
	@StrHistoryOrder VARCHAR(10),	
	@KeyColumn		VARCHAR(120),
	@KeyValue		VARCHAR(120),
	@TempString		VARCHAR(4000),	
	@UserID			VARCHAR(30),
	@SQLInsertColumnString	VARCHAR(2000),
	@SQLInsertValueString	VARCHAR(4000),
	@SQLDeleteString	VARCHAR(2000),
	@SQLUpdateString	VARCHAR(4000),
	@SQLWhereString		VARCHAR(2000),
	@SQLString		NVARCHAR(max),
	@TestSQLString	NVARCHAR(max),
	@XMLParameter     VARCHAR(2000),
	@XMLSearchString	VARCHAR(255),
	@KeyNamePairs     VARCHAR(MAX),
	@KeyName          VARCHAR(256),
	@v_tablename      varchar(100),
	@v_columnname     varchar(100),
	@PropagateFromBookkey INT,
	@WorkKey    INT,
	@ProjectKey    INT,
	@Key1 INT,
	@KeyValueAsInt    INT,
	@v_currentstringvalue varchar(255),
    @v_count	INT,
    @v_itemtype INT,
    @v_bookkey  INT,
    @v_tempkey  INT,
    @v_citation_bookkey INT,
    @v_citation_history_order INT,
    @v_citation_dbitemcolumn  VARCHAR(120),
    @v_filelocation_bookkey INT,
    @v_filelocation_fielddesc VARCHAR(120),
    @FilelocationgeneratedKey INT
  

  CREATE TABLE #propagatetitle (
	bookkey int not null,
	tablename varchar(100) null,
	columnname varchar(100) null)

  CREATE TABLE #scaleprojectkeys (
	key1 int not null,
	tablename varchar(100) null,
	projectkey int not null)
	
	
  CREATE TABLE #deletetaqprojecttask (
   taqtaskkey int not null,
   lastuserid varchar(30) null)

  SET NOCOUNT ON

  SET @IsOpen = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_warnings = ''
  SET @KeyNamePairs = ''
  
  SET @v_itemtype = 0
  
  -- Prepare passed XML document for processing
  EXEC sp_xml_preparedocument @DocNum OUTPUT, @i_transaction_xml

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error loading the XML transaction document'
    GOTO ExitHandler
  END
  
  SET @IsOpen = 1

  
  /*** Get all <Transaction> elements from the passed XML document ***/
  SELECT @UserID = UserID, @ManageTransactions = ManageTrans
  FROM OPENXML(@DocNum,  '/Transaction')
  WITH (UserID VARCHAR(30) 'UserID',
        ManageTrans BIT 'ManageTrans')

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error extracting UserID from the XML transaction document'
    GOTO ExitHandler
  END

  --DEBUG
  --PRINT '@UserID: ' + CONVERT(VARCHAR, @UserID)
  --PRINT '@ManageTransactions: ' + CONVERT(VARCHAR, @ManageTransactions)
  
  
  /***** START THE TRANSACTION *****/
  IF @ManageTransactions = 1 BEGIN
    --PRINT 'Trans started'
    BEGIN TRANSACTION
  END

  /**** Loop to get all <Transaction/DBAction> elements from the passed XML document ****/
  DECLARE action_cursor CURSOR LOCAL FOR 
    SELECT ActionSequence, ActionType, ActionTable, StrHistoryOrder,
        FieldDescDetail, ProcedureName, Parameters, XMLParameter
    FROM OPENXML(@DocNum,  '/Transaction/DBAction')
    WITH (ActionSequence VARCHAR(10) 'ActionSequence',
         ActionType VARCHAR(20) 'ActionType', 
         ActionTable VARCHAR(50) 'ActionTable',
         StrHistoryOrder VARCHAR(10) 'HistoryOrder',
         FieldDescDetail VARCHAR(120) 'FieldDescDetail',
         ProcedureName VARCHAR(50) 'ProcedureName',
         Parameters VARCHAR(2000) 'Parameters',
         XMLParameter VARCHAR(2000) 'XMLParameter')

  OPEN action_cursor

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error opening the DBAction cursor'
    GOTO ExitHandler
  END

  FETCH NEXT FROM action_cursor INTO 
    @ActionSequence,
    @ActionType,
    @ActionTable,
    @StrHistoryOrder,
    @FieldDescDetail,
    @ProcedureName,
    @Parameters,
    @XMLParameter

  IF @@ERROR <> 0 BEGIN
    SET @o_error_code = @@ERROR
    SET @o_error_desc = 'Error occurred while fetching DBAction cursor rows'
    GOTO ExitHandler
  END

  -- Get the action_cursor fetch status - variable must be used (infinite loop problems)
  SET @FetchAction = @@FETCH_STATUS

  -- Loop to parse each DBAction
  WHILE @FetchAction = 0
  BEGIN

    -- Initialize variables for each DBAction
    SET @SQLInsertColumnString = 'INSERT INTO ' + @ActionTable + ' ('
    SET @SQLInsertValueString = ' VALUES ('
    SET @SQLDeleteString = 'DELETE FROM ' + @ActionTable
    SET @SQLUpdateString = 'UPDATE ' + @ActionTable + ' SET '
    SET @SQLWhereString = ' WHERE '
    SET @SQLString = ''
    SET @TestSQLString = ''
    
    -- Check if this table tracks titlehistory
    SELECT @CheckCount = count(*)
    FROM titlehistorycolumns 
    WHERE LOWER(tablename) = LOWER(@ActionTable)
    
    IF @CheckCount > 0
      SET @IsTitleHistoryTable = 1
    ELSE
      SET @IsTitleHistoryTable = 0
      
    -- Check if this table tracks globalcontacthistory
    SELECT @CheckCount = COUNT(*)
    FROM globalcontacthistorycolumns
    WHERE LOWER(tablename) = LOWER(@ActionTable)
    
    IF @CheckCount > 0
      SET @IsContactHistoryTable = 1
    ELSE
      SET @IsContactHistoryTable = 0      
      
    -- For titlehistory, reset bookkey, printingkey and datetypecode for each action
    SET @BookKey = 0
    SET @PrintingKey = 0
    SET @DateTypeCode = 0
    SET @PropagateFromBookkey = 0
    SET @WorkKey = 0
    SET @FilelocationgeneratedKey = 0
    
    IF @StrHistoryOrder IS NULL
      SET @StrHistoryOrder = ''
    IF @FieldDescDetail IS NULL
      SET @FieldDescDetail = ''
      
    --DEBUG
    --PRINT '  @ActionType: ' + @ActionType
    --PRINT '  @ActionTable: ' + @ActionTable
    --PRINT '  @HistoryOrder: ' + @StrHistoryOrder
    --PRINT '  @FieldDescDetail: ' + @FieldDescDetail
    --PRINT '  @ProcedureName: ' + @ProcedureName
    --PRINT '  @Parameters: ' + @Parameters
    
    IF @StrHistoryOrder IS NULL OR LTRIM(RTRIM(@StrHistoryOrder)) = ''
      SET @HistoryOrder = NULL
    ELSE
      SET @HistoryOrder = CONVERT(INT, @StrHistoryOrder)
      
    
    -- ********************************************************************
    -- START STORED PROCEDURE SECTION
    -- *********************************************************************
    if @ActionType = 'storedprocedure'
    BEGIN
      
      DECLARE @SPError int
      DECLARE @SPErrorMessage varchar(2000)
      DECLARE @NewKeys varchar(2000)
      
      SET @SPError = 0
      SET @SPErrorMessage = '' 
            
      IF @XMLParameter IS NOT NULL
        BEGIN
          -- If <XMLParameter> segment is present in the passed transaction XML,
          -- use the passed XML as the parameter to the procedure to be executed         
          SET @SQLString = N'exec ' + @ProcedureName + 
            ' @XMLParameter, @SPError output, @SPErrorMessage output'
                   
          EXECUTE sp_executesql @SQLString, 
            N'@XMLParameter ntext, @SPError int output, @SPErrorMessage varchar(2000) output', 
            @i_transaction_xml, @SPError output, @SPErrorMessage output
        END
      ELSE
        BEGIN
          -- In all other cases, use our generic stored procedure parameters
          SET @SQLString = N'exec ' + @ProcedureName + 
            ' @Parameters, @Keys, @NewKeys output, @SPError output, @SPErrorMessage output'
        
          EXECUTE sp_executesql @SQLString, 
            N'@Parameters varchar(4000), 
              @Keys varchar(MAX), @NewKeys varchar(2000) output, 
              @SPError int output, @SPErrorMessage varchar(2000) output', 
            @Parameters = @Parameters, 
            @Keys = @KeyNamePairs, @NewKeys = @NewKeys output, 
            @SPError = @SPError output, @SPErrorMessage = @SPErrorMessage output
        END

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error executing dynamic SQL for stored procedure ' + @ProcedureName + '.'
        GOTO ExitHandler
      END   
      
      -- Exit only when error is returned from stored procedure, not a warning (-2)
      IF (@SPError <> 0)
      BEGIN
        SET @o_error_code = @SPError 
        IF @SPError = -2   --WARNING
          BEGIN
            IF @o_warnings <> ''
              SET @o_warnings = @o_warnings + '<newline>'
            SET @o_warnings = @o_warnings + @SPErrorMessage
          END
        ELSE
          BEGIN
            SET @o_error_desc = 'Error generated while running stored procedure ' + @ProcedureName + ' : ' + @SPErrorMessage
            GOTO ExitHandler
          END
      END        
            
      IF @NewKeys IS NOT NULL AND CHARINDEX(@NewKeys, @KeyNamePairs) = 0
      BEGIN
        SET @KeyNamePairs = @KeyNamePairs + @NewKeys
      END

      SET @SQLString = N'' 
    END
    
    -- ****************************************************************
    -- END STORED PROCEDURE SECTION
    -- ****************************************************************
    

    -- Set the XML Action search string based on this Action's sequence number
    SET @XMLSearchString = '/Transaction/DBAction[ActionSequence=''' + @ActionSequence + ''']/Key'

    /*** Loop to get all <Transaction/DBAction/Key> elements from the passed XML document ***/
    DECLARE keys_cursor CURSOR FOR 
      SELECT KeyColumn, KeyValue
      FROM OPENXML(@DocNum,  @XMLSearchString)
      WITH (KeyColumn VARCHAR(120) 'KeyColumn',
	    KeyValue VARCHAR(120) 'KeyValue')

    OPEN keys_cursor

    IF @@ERROR <> 0 BEGIN
      SET @o_error_code = @@ERROR
      SET @o_error_desc = 'Error opening DBAction/Keys cursor for ActionSequence ' + @ActionSequence
      GOTO ExitHandler
    END

    FETCH NEXT FROM keys_cursor INTO 
      @KeyColumn,
      @KeyValue

    IF @@ERROR <> 0 BEGIN
      SET @o_error_code = @@ERROR
      SET @o_error_desc = 'Error occurred while fetching DBAction/Keys cursor rows for ActionSequence ' + @ActionSequence
      GOTO ExitHandler
    END

    -- Get the keys_cursor fetch status - variable must be used (infinite loop problems)
    SET @FetchKeys = @@FETCH_STATUS

    -- Loop to parse each key column information
    WHILE @FetchKeys = 0
    BEGIN

      --DEBUG
      --PRINT '    @KeyColumn: ' + @KeyColumn
      --PRINT '    @KeyValue: ' + @KeyValue	
      
      if (@KeyValue is not null and LEN(@KeyValue) > 0 and SUBSTRING(@KeyValue, 1, 1) = '?')
      BEGIN
        DECLARE @TempKey int
        DECLARE @TempKeyName varchar(256)
        SET @TempKey = 0
        SET @TempKeyName = ''

        IF (LEN(@KeyValue) > 1)
        BEGIN
          SET @TempKeyName = SUBSTRING(@KeyValue, 2, LEN(@KeyValue) -1)
          SET @TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @TempKeyName)
        END

        IF (@TempKey = 0)
        BEGIN
           IF @KeyColumn = 'taqtaskkey' and LOWER(@ActionTable) = 'taqprojecttask' 
			exec next_generic_key 'taqprojecttask', @TempKey output, @o_error_code output, @o_error_desc
          ELSE
			exec next_generic_key @UserID, @TempKey output, @o_error_code output, @o_error_desc
			
          SET @KeyValue = CONVERT(varchar(120), @TempKey)
          IF (LEN(@TempKeyName) > 0)
          BEGIN
            SET @KeyNamePairs = @KeyNamePairs + @TempKeyName + ',' + @KeyValue + ','
          END
        END
        ELSE BEGIN
          SET @KeyValue = CONVERT(varchar(120), @TempKey)
        END
      END

      -- Always build the where clause (regardless of action type)
      SET @SQLWhereString = @SQLWhereString + @KeyColumn + '=' + @KeyValue

      -- For INSERTS, build KEY COLUMN-VALUE string
      IF @ActionType = 'insert' OR @ActionType = 'insertupdate'
      BEGIN
        SET @SQLInsertColumnString = @SQLInsertColumnString + @KeyColumn
        SET @SQLInsertValueString = @SQLInsertValueString + @KeyValue
      END
      
      -- Store bookkey, printingkey and datetypecode values for titlehistory purposes
      IF @KeyColumn = 'bookkey' BEGIN
        SET @BookKey = @KeyValue
        IF Lower(@ActionTable) = 'citation' BEGIN
          SET @v_citation_bookkey = @BookKey
          SET @v_citation_history_order = @HistoryOrder
        END
      END

      IF @KeyColumn = 'printingkey'
        SET @PrintingKey = @KeyValue
        
      IF @KeyColumn = 'datetypecode'
        SET @DateTypeCode = @KeyValue
        
      IF @KeyColumn = 'propagatefrombookkey'
        SET @PropagateFromBookkey = @KeyValue
        
      IF @KeyColumn = 'workkey'
        SET @WorkKey = @KeyValue
        
      IF @KeyColumn = 'filelocationgeneratedkey'
		SET @FilelocationgeneratedKey = @KeyValue

      IF @KeyColumn = 'globalcontactkey' OR @KeyColumn = 'commentkey' 
        SET @GlobalContactKey = @KeyValue

      IF @KeyColumn = 'commenttypecode'
        SET @CommentTypeCode = @KeyValue
        
      -- need to maintain corescaleparameters, but may not always have projectkey passed as key
      IF @KeyColumn = 'taqprojectkey' BEGIN
        IF (@KeyValue is not null and LEN(@KeyValue) > 0) BEGIN
          SET @KeyValueAsInt = cast(@KeyValue as int)
          IF @KeyValueAsInt > 0 BEGIN
            INSERT INTO #scaleprojectkeys (key1,tablename, projectkey)
            VALUES (@KeyValueAsInt,'taqproject',@KeyValueAsInt)

            IF @@ERROR <> 0 BEGIN
              SET @o_error_code = @@ERROR
              SET @o_error_desc = 'Error occurred while inserting to #scaleprojectkeys'
              GOTO ExitHandler
            END
          END
        END
      END

      IF @KeyColumn = 'taqprojectcontactkey' and LOWER(@ActionTable) = 'taqprojectcontact' BEGIN
        IF (@KeyValue is not null and LEN(@KeyValue) > 0) BEGIN
          SET @KeyValueAsInt = cast(@KeyValue as int)
          IF @KeyValueAsInt > 0 BEGIN        
            SELECT DISTINCT @v_tempkey = COALESCE(taqprojectkey,0)
              FROM taqprojectcontact
             WHERE taqprojectcontactkey = @KeyValueAsInt
               AND taqprojectkey > 0
          
            INSERT INTO #scaleprojectkeys (key1,tablename,projectkey)
            VALUES (@KeyValueAsInt,LOWER(@ActionTable),COALESCE(@v_tempkey,0))

            IF @@ERROR <> 0 BEGIN
              SET @o_error_code = @@ERROR
              SET @o_error_desc = 'Error occurred while inserting to #scaleprojectkeys (taqprojectcontact)'
              GOTO ExitHandler
            END
          END
        END
      END

      IF @KeyColumn = 'taqprojectcontactrolekey' and LOWER(@ActionTable) = 'taqprojectcontactrole' BEGIN
        IF (@KeyValue is not null and LEN(@KeyValue) > 0) BEGIN
          SET @KeyValueAsInt = cast(@KeyValue as int)
          IF @KeyValueAsInt > 0 BEGIN
            SELECT DISTINCT @v_tempkey = COALESCE(taqprojectkey,0)
              FROM taqprojectcontactrole
             WHERE taqprojectcontactrolekey = @KeyValueAsInt
               AND taqprojectkey > 0
                    
            INSERT INTO #scaleprojectkeys (key1,tablename,projectkey)
            VALUES (@KeyValueAsInt,LOWER(@ActionTable),COALESCE(@v_tempkey,0))

            IF @@ERROR <> 0 BEGIN
              SET @o_error_code = @@ERROR
              SET @o_error_desc = 'Error occurred while inserting to #scaleprojectkeys (taqprojectcontactrole)'
              GOTO ExitHandler
            END
          END
        END
      END

      IF @KeyColumn = 'taqtaskkey' and LOWER(@ActionTable) = 'taqprojecttask' BEGIN
        IF (@KeyValue is not null and LEN(@KeyValue) > 0) BEGIN
          SET @KeyValueAsInt = cast(@KeyValue as int)
          IF @KeyValueAsInt > 0 BEGIN
            SELECT DISTINCT @v_tempkey = COALESCE(taqprojectkey,0)
              FROM taqprojecttask
             WHERE taqtaskkey = @KeyValueAsInt
               AND taqprojectkey > 0
               
            INSERT INTO #scaleprojectkeys (key1,tablename,projectkey)
            VALUES (@KeyValueAsInt,LOWER(@ActionTable),COALESCE(@v_tempkey,0))

            IF @@ERROR <> 0 BEGIN
              SET @o_error_code = @@ERROR
              SET @o_error_desc = 'Error occurred while inserting to #scaleprojectkeys (taqprojecttask)'
              GOTO ExitHandler
            END

            -- check if there is a bookkey on this taqprojecttask row 
            SELECT @v_bookkey = bookkey
              FROM taqprojecttask
             WHERE taqtaskkey = @KeyValueAsInt

            IF @v_bookkey IS NOT NULL AND @v_bookkey > 0 BEGIN
              SELECT @v_count = 0

              SELECT @v_count = COUNT(*)
                FROM #propagatetitle
               WHERE bookkey = @v_bookkey
                 AND tablename = 'taqprojecttask'
                 AND columnname = 'taqtaskkey'

              IF @v_count = 0 BEGIN
                INSERT INTO #propagatetitle (bookkey,tablename,columnname)
                 VALUES (@v_bookkey,@ActionTable,@KeyColumn)

                IF @@ERROR <> 0 BEGIN
                  SET @o_error_code = @@ERROR
                  SET @o_error_desc = 'Error occurred while inserting to #propagatetitle'
                  GOTO ExitHandler
                END
              END
            END
            IF @ActionType = 'delete' BEGIN
				INSERT INTO #deletetaqprojecttask (taqtaskkey, lastuserid)
					VALUES(@KeyValueAsInt,@UserID)
            END 
          END
        END
      END
      
      
      FETCH NEXT FROM keys_cursor INTO 
      @KeyColumn,
      @KeyValue

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error occurred while fetching DBAction/Keys cursor rows for ActionSequence ' + @ActionSequence
        GOTO ExitHandler
      END

      -- Get the keys_cursor fetch status - variable must be used (infinite loop problems)
      SET @FetchKeys = @@FETCH_STATUS

      -- Append 'AND' into the where clause only if there are more key columns to follow
      IF @FetchKeys = 0		--yes, another key column was fetched - append 'AND'
        SET @SQLWhereString = @SQLWhereString + ' AND '

      -- For INSERTS, always add a comma - at least lastmaintdate/lastuserid columns will follow
      IF @ActionType = 'insert' OR @ActionType = 'insertupdate'  
        BEGIN
          SET @SQLInsertColumnString = @SQLInsertColumnString + ', '
          SET @SQLInsertValueString = @SQLInsertValueString + ', '
        END

    END --END Loop DBAction/Keys cursor

    CLOSE keys_cursor
    DEALLOCATE keys_cursor
    
    
    /***** TITLEHISTORY ******/
    IF @IsTitleHistoryTable = 1
    BEGIN
      -- Prevent the error below if the key to book table update is propagatefrombookkey or workkey - no history is written in those cases
      IF @BookKey = 0
        IF @PropagateFromBookkey > 0
          SET @BookKey = 1
        ELSE IF @WorkKey > 0
          SET @BookKey = 1
          
      -- ERROR when table tracks titlehistory but no bookkey passed
      IF @BookKey = 0 and LOWER(@ActionTable) <> 'filelocation' AND LOWER(@ActionTable) <> 'bookcontactrole' AND LOWER(@ActionTable) <> 'qsicomments'
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Table ' + @ActionTable + ' tracks title history but no bookkey passed'
        GOTO ExitHandler      
      END
      ELSE IF @BookKey = 0 and LOWER(@ActionTable) = 'filelocation' BEGIN
		IF @ActionType <> 'delete' BEGIN
			SET @v_filelocation_fielddesc = ''
			
 			SET @XMLSearchString = '/Transaction/DBAction[ActionSequence=''' + @ActionSequence + ''']/DBItem'    

			/*** Loop to get all <Transaction/DBAction/DBItem> elements from the passed XML document ***/
			  DECLARE bookkey_cursor CURSOR FOR 
				SELECT DBItemColumn, DBItemValue
				FROM OPENXML(@DocNum,  @XMLSearchString)
				WITH (DBItemColumn VARCHAR(120) 'DBItemColumn',
						DBItemValue  VARCHAR(4000) 'DBItemValue')

			  OPEN bookkey_cursor

			  IF @@ERROR <> 0 BEGIN
				SET @o_error_code = @@ERROR
				SET @o_error_desc = 'Error opening DBAction/Values cursor for ActionSequence ' + @ActionSequence
				GOTO ExitHandler
			  END

			  FETCH NEXT FROM bookkey_cursor INTO 
				@DBItemColumn,
				@DBItemValue

			  IF @@ERROR <> 0 BEGIN
				SET @o_error_code = @@ERROR
				SET @o_error_desc = 'Error occurred while fetching DBAction/Values cursor rows for ActionSequence ' + @ActionSequence
				GOTO ExitHandler
			  END
		 
			  -- Get the bookkey_cursor fetch status - variable must be used (infinite loop problems)
			  SET @FetchValues = @@FETCH_STATUS

			  -- Loop to parse each dbchange column information
			  WHILE @FetchValues = 0
			  BEGIN
		       	IF @DBItemValue is null
				  SET @DBItemValue = ''
		    	--DEBUG
				--PRINT '    @DBItemColumn: ' + @DBItemColumn
				--PRINT '    @DBItemValue: '  + @DBItemValue
				IF @DBItemColumn = 'bookkey'
	 				SET @v_filelocation_bookkey = @DBItemValue 
	 				
	 			IF @DBItemColumn = 'filedescription'
	 				SET @v_filelocation_fielddesc = @DBItemValue
	 				
	 			IF @v_filelocation_fielddesc <> '' BEGIN
	 				SET @TempString = SUBSTRING(@v_filelocation_fielddesc, 1, 1)
					IF @TempString = ''''
					  SET @v_filelocation_fielddesc = SUBSTRING(@v_filelocation_fielddesc, 2, 4000)

					  SET @StringLength = LEN(@v_filelocation_fielddesc)
					  SET @TempString = SUBSTRING(@v_filelocation_fielddesc, @StringLength, 1)
					  IF @TempString = ''''
						SET @v_filelocation_fielddesc = SUBSTRING(@v_filelocation_fielddesc, 1, @StringLength -1)
	 			END 
	 			 				
		       	FETCH NEXT FROM bookkey_cursor INTO @DBItemColumn, @DBItemValue

				IF @@ERROR <> 0 BEGIN
				  SET @o_error_code = @@ERROR
				  SET @o_error_desc = 'Error occurred while fetching DBAction/bookkey cursor rows for ActionSequence ' + @ActionSequence
				  GOTO ExitHandler
				END

				-- Get the bookkey_cursor fetch status - variable must be used (infinite loop problems)
				SET @FetchValues = @@FETCH_STATUS
		    
			  END --END Loop DBAction/DBItemValue cursor

			  CLOSE bookkey_cursor
			  DEALLOCATE bookkey_cursor
			  
			  IF @ActionType = 'update' BEGIN
				IF @v_filelocation_fielddesc = ''
					SELECT @v_filelocation_fielddesc = filedescription FROM filelocation
					  WHERE filelocationgeneratedkey = @FilelocationgeneratedKey 
			  END
		END
     END
           
      -- Default printingkey to 1
      IF @PrintingKey = 0
        SET @PrintingKey = 1
    
    END --END IsTitleHistoryTable
    
    IF @IsContactHistoryTable = 1 AND @GlobalContactKey = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Table ' + @ActionTable + ' tracks contact history but no globalcontactkey passed'
      GOTO ExitHandler
    END    
    

    /***** Skip DBItem processing for DELETES ******/
    IF @ActionType <> 'delete'
    BEGIN

      -- Set the XML Action search string based on this Action's sequence number
      -- (EXCLUDE object value types - i.e. long text)
--      SET @XMLSearchString = '/Transaction/DBAction[ActionSequence=''' + @ActionSequence + ''']/DBItem[not(DBType=''longtext'')]'    
      SET @XMLSearchString = '/Transaction/DBAction[ActionSequence=''' + @ActionSequence + ''']/DBItem'    

      /*** Loop to get all <Transaction/DBAction/DBItem> elements from the passed XML document ***/
      DECLARE values_cursor CURSOR FOR 
        SELECT DBItemColumn, DBItemValue, DBItemDesc, DBType
        FROM OPENXML(@DocNum,  @XMLSearchString)
        WITH (DBItemColumn VARCHAR(120) 'DBItemColumn',
	            DBItemValue  VARCHAR(4000) 'DBItemValue',
	            DBItemDesc   VARCHAR(4000) 'DBItemDesc',
              DBType       VARCHAR (50) 'DBType')

      OPEN values_cursor

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error opening DBAction/Values cursor for ActionSequence ' + @ActionSequence
        GOTO ExitHandler
      END

      FETCH NEXT FROM values_cursor INTO 
        @DBItemColumn,
        @DBItemValue,
        @DBItemDesc,
        @DBType

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error occurred while fetching DBAction/Values cursor rows for ActionSequence ' + @ActionSequence
        GOTO ExitHandler
      END
 
      -- Get the values_cursor fetch status - variable must be used (infinite loop problems)
      SET @FetchValues = @@FETCH_STATUS

      -- Loop to parse each dbchange column information
      WHILE @FetchValues = 0
      BEGIN

        IF @DBType is null
          SET @DBType = ''

        IF @DBItemValue is null
          SET @DBItemValue = ''
        
        IF @DBItemDesc is null
          SET @DBItemDesc = ''

        IF @DBType = 'longtext'
	        SET @DBItemValue = ''''''

        
        -- Resolve key requests.
        if (@DBItemValue is not null and LEN(@DBItemValue) > 0 and SUBSTRING(@DBItemValue, 1, 1) = '?')
        BEGIN
--          print 'resolving keys'
--          print @KeyNamePairs
          SET @TempKey = 0
          SET @TempKeyName = ''
          IF (LEN(@DBItemValue) > 1)
          BEGIN
            SET @TempKeyName = SUBSTRING(@DBItemValue, 2, LEN(@DBItemValue) -1)
            SET @TempKey = dbo.key_from_key_list_string(@KeyNamePairs, @TempKeyName)
--            print @TempKey
          END
          IF (@TempKey <> 0)
          BEGIN
            SET @DBItemValue = CAST(@TempKey AS varchar)
          END
        END

        --DEBUG
        --PRINT '    @DBItemColumn: ' + @DBItemColumn
        --PRINT '    @DBItemValue: '  + @DBItemValue
        --IF @DBItemDesc IS NOT NULL AND LTRIM(RTRIM(@DBItemDesc)) <> '' BEGIN
          --PRINT '    @DBItemDesc: '   + @DBItemDesc
        --END
        --IF @DBType IS NOT NULL AND LTRIM(RTRIM(@DBType)) <> '' BEGIN
          --PRINT '    @DBType: '       + @DBType
        --END

        -- Build DBITEM COLUMN-VALUE string for this passed <Action> based on Type
        IF @ActionType = 'update' OR @ActionType = 'insertupdate'
        BEGIN
          IF @DBType <> 'longtext'
            SET @SQLUpdateString = @SQLUpdateString + @DBItemColumn+ '=' + @DBItemValue + ', '
        END
        IF @ActionType = 'insert' OR @ActionType = 'insertupdate'
        BEGIN
          SET @SQLInsertColumnString = @SQLInsertColumnString + @DBItemColumn
          SET @SQLInsertValueString = @SQLInsertValueString + @DBItemValue

          IF @KeyColumn = 'taqtaskkey' and LOWER(@ActionTable) = 'taqprojecttask' and @DBItemColumn = 'bookkey' BEGIN
            IF LEN(@DBItemValue) > 0 AND @DBItemValue <> 'NULL' BEGIN
              SET @v_bookkey = cast(@DBItemValue as int)

              SELECT @v_count = COUNT(*)
              FROM #propagatetitle
              WHERE bookkey = @v_bookkey AND tablename = 'taqprojecttask' AND columnname = 'taqtaskkey'

              IF @v_count = 0 BEGIN
                INSERT INTO #propagatetitle (bookkey,tablename,columnname)
                VALUES (@v_bookkey,@ActionTable,@KeyColumn)

                IF @@ERROR <> 0 BEGIN
                  SET @o_error_code = @@ERROR
                  SET @o_error_desc = 'Error occurred while inserting to #propagatetitle'
                  GOTO ExitHandler
                END
              END
            END
          END
        END

        -- ********* TITLEHISTORY/GLOBALCONTACTHISTORY ********** --
        IF @IsTitleHistoryTable = 1 OR @IsContactHistoryTable = 1
        BEGIN
          IF @DBItemDesc = ''
            SET @DBItemDesc = @DBItemValue

          -- strip out leading and trailing quote
          SET @TempString = SUBSTRING(@DBItemDesc, 1, 1)
          IF @TempString = ''''
            SET @DBItemDesc = SUBSTRING(@DBItemDesc, 2, 4000)

          SET @StringLength = LEN(@DBItemDesc)
          SET @TempString = SUBSTRING(@DBItemDesc, @StringLength, 1)
          IF @TempString = ''''
            SET @DBItemDesc = SUBSTRING(@DBItemDesc, 1, @StringLength -1)

          SET @DBItemDesc = REPLACE(@DBItemDesc, '&amp;', '&')
          SET @DBItemDesc = REPLACE(@DBItemDesc, '''''', '''')
          
          -- DEBUG           
          --PRINT '@ActionTable = ' + @ActionTable
          --PRINT '@DBItemColumn = ' + @DBItemColumn
          --PRINT '@Bookkey = ' + CONVERT(VARCHAR, @Bookkey)
          --PRINT '@PrintingKey = ' + CONVERT(VARCHAR, @PrintingKey)
          --PRINT '@GlobalContactKey = ' + CONVERT(VARCHAR, @GlobalContactKey)
          --PRINT '@DateTypeCode = ' + CONVERT(VARCHAR, @DateTypeCode)
          --PRINT '@DBItemDesc = ' + @DBItemDesc
          --PRINT '@ActionType = ' + @ActionType
          --PRINT '@UserID = ' + @UserID
          --PRINT '@HistoryOrder = ' + CONVERT(VARCHAR, @HistoryOrder)
          --PRINT '@FieldDescDetail = ' + @FieldDescDetail
          
          -- ***** TITLEHISTORY *****
          IF @IsTitleHistoryTable = 1
          BEGIN
            IF LOWER(@ActionTable) = 'qsicomments' AND LOWER(@DBItemColumn) = 'commenttext' AND COALESCE(@v_citation_bookkey,0) > 0
              EXEC qtitle_update_titlehistory @ActionTable, @DBItemColumn, @v_citation_bookkey, 
                @PrintingKey, @DateTypeCode, @DBItemDesc, @ActionType, @UserID, 
                @v_citation_history_order, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
            ELSE IF LOWER(@ActionTable) = 'filelocation' AND COALESCE(@v_filelocation_bookkey,0) > 0
              EXEC qtitle_update_titlehistory @ActionTable, @DBItemColumn, @v_filelocation_bookkey, 
                @PrintingKey, @DateTypeCode, @DBItemDesc, @ActionType, @UserID, 
                @HistoryOrder, @v_filelocation_fielddesc, @o_error_code OUTPUT, @o_error_desc OUTPUT    
            ELSE
              EXEC qtitle_update_titlehistory @ActionTable, @DBItemColumn, @BookKey, 
                @PrintingKey, @DateTypeCode, @DBItemDesc, @ActionType, @UserID, 
                @HistoryOrder, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT

	          IF @o_error_code <> 0 BEGIN
	            GOTO ExitHandler
	          END
	          
			SET @v_count = 0
            IF LOWER(@ActionTable) = 'qsicomments' AND COALESCE(@v_citation_bookkey, 0) > 0 BEGIN
              SELECT @v_count = COUNT(*)
                FROM #propagatetitle
               WHERE bookkey = @v_citation_bookkey
                 AND tablename = @ActionTable
                 AND coalesce(columnname, '') = coalesce(@DBItemColumn, '')

              IF @v_count = 0 BEGIN
                INSERT INTO #propagatetitle (bookkey,tablename,columnname)
                VALUES (@v_citation_bookkey,@ActionTable,@DBItemColumn)
              END      
            END                      
            ELSE BEGIN
              SELECT @v_count = COUNT(*)
                FROM #propagatetitle
               WHERE bookkey = @BookKey
                 AND tablename = @ActionTable
                 AND coalesce(columnname, '') = coalesce(@DBItemColumn, '')

              IF @v_count = 0 BEGIN
				INSERT INTO #propagatetitle (bookkey,tablename,columnname)
			    VALUES (@BookKey,@ActionTable,@DBItemColumn)
              END 
			END
			
            IF @@ERROR <> 0 BEGIN
              SET @o_error_code = @@ERROR
              SET @o_error_desc = 'Error occurred while inserting to #propagatetitle'
              GOTO ExitHandler
            END
          END --IF @IsTitleHistoryTable = 1
          
          -- ***** GLOBALCONTACTHISTORY *****
          IF @IsContactHistoryTable = 1
          BEGIN
            DECLARE @v_place VARCHAR(30), 
                    @v_region VARCHAR(100)

            IF LOWER(@ActionTable) = 'globalcontactplaces' AND LOWER(@KeyColumn) = 'placecode' AND COALESCE(@KeyValue, 0) > 0 BEGIN
              SELECT @v_place = datadesc FROM gentables WHERE tableid = 672 AND datacode = CONVERT(INT, @KeyValue)

              IF LOWER(@DBItemColumn) = 'placecode' BEGIN
                SET @DBItemDesc = COALESCE(@v_place,'')
              END
              ELSE IF @DBItemDesc <> 'NULL' AND (LOWER(@DBItemColumn) = 'countrycode' OR LOWER(@DBItemColumn) = 'regioncode')
              BEGIN
                SELECT @v_region = COALESCE(name,'') FROM cloudregion WHERE id = CONVERT(UNIQUEIDENTIFIER, @DBItemDesc)
                SET @DBItemDesc = COALESCE(@v_place,'') + ': ' + COALESCE(@v_region, '')
              END

              EXEC qcontact_update_globalcontacthistory @ActionTable, @DBItemColumn, @GlobalContactKey,
                  @DBItemDesc, @ActionType, @UserID, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
              IF @o_error_code <> 0 
                GOTO ExitHandler
            END -- if globalcontactplaces
            ELSE IF LOWER(@ActionTable) = 'qsicommentmarkets' AND LOWER(@DBItemColumn) = 'marketcode' BEGIN
              DECLARE @v_desc VARCHAR(100),
                      @v_commenttype VARCHAR(100),
                      @v_marketvalue VARCHAR(100)
              SELECT @v_commenttype = datadesc FROM gentables WHERE tableid=528 AND datacode=@CommentTypeCode
              SELECT @v_marketvalue = datadesc FROM gentables WHERE tableid=673 AND datacode=@DBItemValue
              SET @v_desc = @v_commenttype + ': ' + @v_marketvalue
              EXEC qcontact_update_globalcontacthistory @ActionTable, @DBItemColumn, @GlobalContactKey,
                  @v_desc, @ActionType, @UserID, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
              IF @o_error_code <> 0 
                GOTO ExitHandler
            END -- if qsicommentmarkets
            ELSE BEGIN
              EXEC qcontact_update_globalcontacthistory @ActionTable, @DBItemColumn, @GlobalContactKey,
                 @DBItemDesc, @ActionType, @UserID, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
              
              IF @o_error_code <> 0 BEGIN
                GOTO ExitHandler
              END
            END              
          END --IF @IsContactHistoryTable = 1          
          
        END --title or contact history column        
        
        FETCH NEXT FROM values_cursor INTO 
        @DBItemColumn,
        @DBItemValue,
        @DBItemDesc,
        @DBType

        IF @@ERROR <> 0 BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Error occurred while fetching DBAction/Values cursor rows for ActionSequence ' + @ActionSequence
          GOTO ExitHandler
        END

        -- Get the values_cursor fetch status - variable must be used (infinite loop problems)
        SET @FetchValues = @@FETCH_STATUS

        IF @ActionType = 'update' OR @ActionType = 'insertupdate'
        BEGIN
          IF @DBType <> 'longtext'
          BEGIN
            SET @SQLUpdateString = @SQLUpdateString
          END
        END
        IF @ActionType = 'insert' OR @ActionType = 'insertupdate'
        BEGIN
          -- Always add a comma - at least lastmaintdate/lastuserid columns will follow
          SET @SQLInsertColumnString = @SQLInsertColumnString + ', '
          SET @SQLInsertValueString = @SQLInsertValueString + ', '
        END
 
      END --END Loop DBAction/DBItemValue cursor

      CLOSE values_cursor
      DEALLOCATE values_cursor
    

      /*** Always add the timestamp for INSERTS/UPDATES ***/
      IF @ActionTable = 'qse_searchresults'
        BEGIN
          IF @ActionType = 'update' OR @ActionType = 'insertupdate'
            SET @SQLUpdateString = @SQLUpdateString  + 'lastuse=getdate()'
          IF @ActionType = 'insert' OR @ActionType = 'insertupdate'
            BEGIN
              SET @SQLInsertColumnString = @SQLInsertColumnString + 'lastuse) '
              SET @SQLInsertValueString = @SQLInsertValueString + 'getdate()) '
            END
        END
      ELSE
        BEGIN
          IF @ActionType = 'update' OR @ActionType = 'insertupdate'
            SET @SQLUpdateString = @SQLUpdateString  + 'lastuserid=''' + @UserID + ''', lastmaintdate=getdate()'
          IF @ActionType = 'insert' OR @ActionType = 'insertupdate'
            BEGIN
              SET @SQLInsertColumnString = @SQLInsertColumnString + 'lastuserid, lastmaintdate) '
              SET @SQLInsertValueString = @SQLInsertValueString + '''' + @UserID + ''', getdate()) '
            END
        END

    END -- END IF @ActionType <> 'delete'
    
    
    -- For DELETE actions, loop to write a '(DELETED)' titlehistory/globalcontacthistory record
    -- for each history column for the given table
    IF @ActionType = 'delete'
    BEGIN
    
      IF @IsContactHistoryTable = 1
        DECLARE column_cursor CURSOR FOR 
          SELECT DISTINCT columnname
          FROM globalcontacthistorycolumns
          WHERE tablename = @ActionTable
      ELSE
        DECLARE column_cursor CURSOR FOR 
          SELECT DISTINCT columnname
          FROM titlehistorycolumns
          WHERE tablename = @ActionTable

      OPEN column_cursor

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error opening history columns cursor for Delete action history'
        GOTO ExitHandler
      END

      FETCH NEXT FROM column_cursor INTO @HistoryColumn

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = @@ERROR
        SET @o_error_desc = 'Error occurred while fetching history columns cursor'
        GOTO ExitHandler
      END
 
      -- Get the columns_cursor fetch status - variable must be used (infinite loop problems)
      SET @FetchColumns = @@FETCH_STATUS

      -- Loop to parse each dbchange column information
      WHILE @FetchColumns = 0
      BEGIN
      
        -- ********* TITLEHISTORY ********** --
        IF @IsTitleHistoryTable = 1 and LOWER(@ActionTable) <> 'bookcontactrole'
        BEGIN
          SET @v_currentstringvalue = ''
          IF @ActionTable = 'associatedtitles' AND @HistoryColumn = 'isbn' BEGIN      
            DECLARE @teststring varchar(25)

            SET @TestSQLString = @TestSQLString + N'SELECT @p_teststring = isbn FROM associatedtitles ' + @SQLWhereString
    	
  	        --print @TestSQLString
            EXECUTE sp_executesql @TestSQLString, N'@p_teststring VARCHAR(25) OUTPUT', @teststring OUTPUT
            IF @@ERROR <> 0
              SET @v_currentstringvalue = ''
            ELSE IF @teststring is not null AND datalength(@teststring) > 0
              SET @v_currentstringvalue =  @teststring
            
            --print '@v_currentstringvalue: ' + COALESCE(@v_currentstringvalue, 'null') 
          END
      
          IF LOWER(@ActionTable) = 'qsicomments' AND COALESCE(@v_citation_bookkey,0) > 0
          BEGIN
            SET @v_citation_dbitemcolumn = 'commenttext'
            EXEC qtitle_update_titlehistory @ActionTable, @v_citation_dbitemcolumn, @v_citation_bookkey, 
              @PrintingKey, @DateTypeCode, @DBItemDesc, @ActionType, @UserID, 
              @v_citation_history_order, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT 
          END 
          ELSE IF LOWER(@ActionTable) = 'filelocation' AND @FilelocationgeneratedKey > 0 BEGIN
			SELECT @v_filelocation_bookkey = bookkey,@v_filelocation_fielddesc = filedescription 
				FROM filelocation WHERE filelocationgeneratedkey = @FilelocationgeneratedKey 
			EXEC qtitle_update_titlehistory @ActionTable, @HistoryColumn, @v_filelocation_bookkey, 
              @PrintingKey, @DateTypeCode, @v_currentstringvalue, @ActionType, @UserID, 
              @HistoryOrder, @v_filelocation_fielddesc, @o_error_code OUTPUT, @o_error_desc OUTPUT
          END             
          ELSE
            EXEC qtitle_update_titlehistory @ActionTable, @HistoryColumn, @BookKey, 
              @PrintingKey, @DateTypeCode, @v_currentstringvalue, @ActionType, @UserID, 
              @HistoryOrder, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT          

	        IF @o_error_code <> 0 BEGIN
	          GOTO ExitHandler
	        END

          SET @v_count = 0
          IF LOWER(@ActionTable) = 'qsicomments' AND COALESCE(@v_citation_bookkey,0) > 0 BEGIN
            SELECT @v_count = COUNT(*)
            FROM #propagatetitle
            WHERE bookkey = @v_citation_bookkey
              AND tablename = @ActionTable
              AND coalesce(columnname, '') = coalesce(@DBItemColumn, '')

            IF @v_count = 0 BEGIN
              INSERT INTO #propagatetitle (bookkey,tablename,columnname)
              VALUES (@v_citation_bookkey,@ActionTable,@DBItemColumn)
            END           
          END  
          ELSE BEGIN   
            SELECT @v_count = COUNT(*)
            FROM #propagatetitle
            WHERE bookkey = @BookKey
              AND tablename = @ActionTable
              AND coalesce(columnname, '') = coalesce(@DBItemColumn, '')

            IF @v_count = 0 BEGIN
              INSERT INTO #propagatetitle (bookkey,tablename,columnname)
              VALUES (@BookKey,@ActionTable,@DBItemColumn)
            END                  
		  END

          IF @@ERROR <> 0 BEGIN
            SET @o_error_code = @@ERROR
            SET @o_error_desc = 'Error occurred while inserting to #propagatetitle'
            GOTO ExitHandler
          END
        END --titlehistory
        
        -- ********* GLOBALCONTACTHISTORY **********
        IF @IsContactHistoryTable = 1
        BEGIN
          SET @v_currentstringvalue = ''
          
          EXEC qcontact_update_globalcontacthistory @ActionTable, @HistoryColumn, @GlobalContactKey,
            @v_currentstringvalue, @ActionType, @UserID, @FieldDescDetail, @o_error_code OUTPUT, @o_error_desc OUTPUT
            
	        IF @o_error_code <> 0 BEGIN
	          GOTO ExitHandler
	        END             
        END --globalcontacthistory      
          
        FETCH NEXT FROM column_cursor INTO @HistoryColumn

        IF @@ERROR <> 0 BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Error occurred while fetching history columns cursor'
          GOTO ExitHandler
        END

        -- Get the values_cursor fetch status - variable must be used (infinite loop problems)
        SET @FetchColumns = @@FETCH_STATUS

      END --END Loop titlehistory columns cursor
      
      CLOSE column_cursor
      DEALLOCATE column_cursor
                
    END


    IF @ActionType = 'insert'
      SET @SQLString = @SQLString + @SQLInsertColumnString + @SQLInsertValueString
    ELSE IF @ActionType = 'update'
      SET @SQLString = @SQLString + @SQLUpdateString + @SQLWhereString
    ELSE IF @ActionType = 'delete'
      SET @SQLString = @SQLString + @SQLDeleteString + @SQLWhereString
    ELSE IF @ActionType = 'insertupdate'
      BEGIN
        /*** Check if this record already exists ****/
        DECLARE @testcount INT

        SET @TestSQLString = @TestSQLString + N'SELECT @p_testcount = COUNT(*) FROM ' + @ActionTable + ' ' + @SQLWhereString
	
        EXECUTE sp_executesql @TestSQLString, N'@p_testcount INT OUTPUT', @testcount OUTPUT
        IF @@ERROR <> 0
        BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Error checking ' + @ActionTable + ' : @@Error : ' + CAST(@o_error_code AS VARCHAR)
          GOTO ExitHandler
        END

        IF @testcount = 0  -- no row found - use INSERT
          SET @SQLString = @SQLString + @SQLInsertColumnString + @SQLInsertValueString
        ELSE 	-- row already exists - use UPDATE
          SET @SQLString = @SQLString + @SQLUpdateString + @SQLWhereString
      END

    if @SQLString is not null and  @SQLString <> ''  
    BEGIN
      PRINT 'FINAL SQL (non blank)'
      PRINT @SQLString
      
      /***** EXECUTE the generated statement *******/
      EXECUTE sp_executesql @SQLString
      SET @o_error_code = @@ERROR
      IF @o_error_code <> 0 OR @@ROWCOUNT = 0
      BEGIN
        SET @o_error_desc = 'Error executing SQL : @@Error : ' + CAST(@o_error_code AS VARCHAR) + ' @@ROWCOUNT : ' + CAST(@@ROWCOUNT AS VARCHAR) 
        GOTO ExitHandler
      END
    END

    /*** Now take care of columns of type TEXT - there will be only 1 per table, if any ***/
    -- Set the XML Action search string based on this Action's sequence number
    -- (INCLUDE only object column type values - columns of type long TEXT)
    SET @XMLSearchString = '/Transaction/DBAction[ActionSequence=''' + @ActionSequence + ''']/DBItem[DBType=''longtext'']'    
    -- Get the name of the TEXT column
    SET @DBItemColumn = null
    SELECT @DBItemColumn = DBItemColumn
    FROM OPENXML(@DocNum,  @XMLSearchString)
    WITH (DBItemColumn VARCHAR(120) 'DBItemColumn')
    
    IF @@ERROR <> 0 BEGIN
      SET @o_error_code = @@ERROR
      SET @o_error_desc = 'Error getting TEXT Column Name from XML string for ActionSequence ' + @ActionSequence
      GOTO ExitHandler
    END    

	--mk20140306> Specialized code to bypass the rest of the ptr/chunking pre 2005 code
	--this is to fix a bug for GWK Case#26778
	if @DBItemColumn='commenthtml'	
	BEGIN
		DECLARE @DEBUG INT
		SET @DEBUG=0
		
		IF @DEBUG>0 PRINT ' ************* NEW CODE TO UPDATE COMMENTS (START) ************* '
		IF @DEBUG>0 PRINT '@DocNum: '  + coalesce(cast(@DocNum as varchar(max)),'*NULL*')
		IF @DEBUG>0 PRINT '@XMLSearchString: '  + coalesce(@XMLSearchString,'*NULL*')
		IF @DEBUG>0 PRINT '@ActionTable: '  + coalesce(@ActionTable,'*NULL*')
		IF @DEBUG>0 PRINT '@DBItemColumn: '  + coalesce(@DBItemColumn,'*NULL*')
		
		DECLARE @XMLNodeValue NVARCHAR(max)
		SELECT @XMLNodeValue = DBItemValueLong
		FROM OPENXML(@DocNum, @XMLSearchString) WITH (DBItemValueLong NVARCHAR(max) 'DBItemValueLong')
		
		IF @DEBUG>0 PRINT '@XMLNodeValue(before adding quotes): '  + coalesce(cast(@XMLNodeValue as varchar(max)),'*NULL*')
		IF @DEBUG>0 PRINT 'LEN(@XMLNodeValue): '  + cast(LEN(coalesce(cast(@XMLNodeValue as varchar(max)),'*NULL*')) as varchar(max))
		SET @XMLNodeValue=''''+REPLACE(@XMLNodeValue,'''','''''')+''''
		
		IF @DEBUG>0 PRINT '@XMLNodeValue(before after quotes): '  + coalesce(cast(@XMLNodeValue as varchar(max)),'*NULL*')
		IF @DEBUG>0 PRINT 'LEN(@XMLNodeValue): '  + cast(LEN(coalesce(cast(@XMLNodeValue as varchar(max)),'*NULL*')) as varchar(max))

		BEGIN TRY
			DECLARE @sznSQLUpdateString AS NVARCHAR(MAX)
			DECLARE @sznSQLString AS NVARCHAR(MAX)
			SET @sznSQLUpdateString='UPDATE ' + @ActionTable + ' SET ' + @DBItemColumn + ' = N' + @XMLNodeValue + ' '
			SET @sznSQLString=@sznSQLUpdateString + @SQLWhereString

			IF @DEBUG>0 PRINT '@sznSQLUpdateString: '  + coalesce(@sznSQLUpdateString,'*NULL*')
			IF @DEBUG>0 PRINT 'LEN(@sznSQLUpdateString): '  + cast(LEN(coalesce(@sznSQLUpdateString,'*NULL*')) as varchar(max))
			IF @DEBUG>0 PRINT '@SQLWhereString: '  + coalesce(@SQLWhereString,'*NULL*')
			IF @DEBUG>0 PRINT '@sznSQLString: '  + coalesce(@sznSQLString,'*NULL*')
			IF @DEBUG>0 PRINT 'LEN(@sznSQLString): '  + cast(LEN(coalesce(@sznSQLString,'*NULL*')) as varchar(max))
			
			EXECUTE sp_executesql @sznSQLString			
		END TRY
		BEGIN CATCH
			SET @o_error_code = @@ERROR
			SET @o_error_desc=ERROR_MESSAGE()
			SET @o_error_desc = 'Error in Update CommentHTML inside qutl_dbchange_request: ' + @o_error_desc
			GOTO ExitHandler
		END CATCH
		
		IF @DEBUG>0 PRINT ' ************* NEW CODE TO UPDATE COMMENTS (END) ************* '
	END 	
		
    if @DBItemColumn!='commenthtml'	AND @DBItemColumn is not null
    BEGIN

      --
      -- Do the update for the selected column
      --

      -- Start by getting a pointer to the column that
      -- needs to be updated.
      DECLARE @select_pointer_sql nvarchar(2000)
      DECLARE @txtptrval binary(16)
     
      -- Get the pointer to the existing text field.
      SET @select_pointer_sql = N'select @txtptrval= TEXTPTR(' + @DBItemColumn + ') FROM '
           + @ActionTable + @SQLWhereString
      --print ''
      --print @SQLWhereString
      --print @select_pointer_sql
      --print ''

      DECLARE @update_pointer_sql nvarchar(2000)
      EXECUTE sp_executesql @select_pointer_sql, N'@txtptrval binary(16) output', @txtptrval = @txtptrval output
      IF @@ERROR <> 0 or @txtptrval is null BEGIN
        --print 'Having to fill null in with blank value'
        
        SET @update_pointer_sql = N'UPDATE ' + + @ActionTable + ' SET ' + @DBItemColumn + '= ''''' +  @SQLWhereString
        --print @update_pointer_sql
        
        EXECUTE sp_executesql @update_pointer_sql
        IF @@ERROR <> 0 BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Could not update null pointer to a blank for continued processing'
          GOTO ExitHandler
        END
        
        EXECUTE sp_executesql @select_pointer_sql, N'@txtptrval binary(16) output', @txtptrval = @txtptrval output
        IF @@ERROR <> 0 or @txtptrval is null BEGIN
          SET @o_error_code = @@ERROR
          SET @o_error_desc = 'Unable to get an existing pointer for a text update on column ' + @ActionTable + '.' + @DBItemColumn
          GOTO ExitHandler
        END    

      END    


      -- Now we have to extract the pieces of the text from the 
      -- XML and replace the temporary value in the table with
      -- this new value.

      DECLARE @UpdateTextColumSQL NVARCHAR(2000)
      DECLARE @UpdateVariables NVARCHAR(2000)
      DECLARE @currentPortion nvarchar(4000)  
      DECLARE @currentPortionLength int
      SET @currentPortionLength = 4000  -- Size parameterized for testing, must match length of varchar above.
      SET @UpdateVariables = N'@txtptrval binary(16), @currentPortion nvarchar(' + CAST(@currentPortionLength as NVARCHAR) + ')'

      DECLARE @currentIndex int
      SET @currentIndex = 1
    
      -- Get the first part of the string before entering the loop.
      SELECT @currentPortion = SUBSTRING(DBItemValueLong, @currentIndex, @currentPortionLength)
        FROM OPENXML(@DocNum,  @XMLSearchString)
        WITH (DBItemValueLong ntext 'DBItemValueLong')
 

        --SET @currentPortion = REPLACE(@currentPortion, '&lt;', '<')
        --SET @currentPortion = REPLACE(@currentPortion, '&gt;', '>')
        --SET @currentPortion = REPLACE(@currentPortion, '&amp;', '&')

        -- Do the first update outside the loop because many loops
        -- may not be needed.
        SET @UpdateTextColumSQL = N'UPDATETEXT ' + @ActionTable + '.' + @DBItemColumn + ' @txtptrval 0 null @currentPortion'
        print '@UpdateTextColumSQL: ' + @UpdateTextColumSQL
        print '@UpdateVariables: ' + @UpdateVariables
        print '@currentPortion: ' + @currentPortion
        
        --mk:20120906> Case: 20905 spaces inserted in bookcomments when comment is updated
        -- .... The CKEditor adds a new line & tab (char(10) + char(9)) right after first <DIV>
        -- .... it also appends a new line (char(10)) after the last <DIV>
        -- .... this code strips out those characters when saving
		DECLARE @ReplaceFrom nvarchar(4000)  
		DECLARE @ReplaceTo nvarchar(4000)  

		set @ReplaceFrom = '<div>' + char(10) + char(9)
		set @ReplaceTo = '<div>'
		
		if LEFT(@currentPortion,len(@Replacefrom))=@Replacefrom begin
			set @currentPortion = stuff(@currentPortion, charindex(@Replacefrom, @currentPortion), len(@Replacefrom), @ReplaceTo)
		end 

		set @ReplaceFrom = '<div>' + char(10)
		set @ReplaceTo = '<div>'
		
		if RIGHT(@currentPortion,len(@Replacefrom))=@Replacefrom begin
			set @currentPortion = LEFT(@currentPortion,len(@currentPortion)-1)
		end 		
		        
        EXECUTE sp_executesql @UpdateTextColumSQL, @UpdateVariables, @txtptrval, @currentPortion
  
        print 'LEN(@currentPortion): ' + CAST(DATALENGTH(@currentPortion) as varchar)
        print '@currentPortionLength: ' + CAST(@currentPortionLength * 2 as varchar)

        WHILE (DATALENGTH(@currentPortion) = @currentPortionLength * 2)
        BEGIN

          SET @currentIndex = @currentIndex+ @currentPortionLength
          SELECT @currentPortion = SUBSTRING(DBItemValueLong, @currentIndex, @currentPortionLength)
            FROM OPENXML(@DocNum,  @XMLSearchString)
            WITH (DBItemValueLong ntext 'DBItemValueLong')

          SET @UpdateTextColumSQL = N'UPDATETEXT ' + @ActionTable + '.' + @DBItemColumn + ' @txtptrval null null @currentPortion'
          print '@UpdateTextColumSQL: ' + @UpdateTextColumSQL
          print '@UpdateVariables: ' + @UpdateVariables
          print '@currentPortion: ' + @currentPortion
          
		  --mk:20120906> Case: 20905 spaces inserted in bookcomments when comment is updated
		  if RIGHT(@currentPortion,len(@Replacefrom))=@Replacefrom begin
		 	  set @currentPortion = LEFT(@currentPortion,len(@currentPortion)-1)
		  end 		     
		            
          EXECUTE sp_executesql @UpdateTextColumSQL, @UpdateVariables, @txtptrval, @currentPortion

          print 'LEN(@currentPortion): ' + CAST(DATALENGTH(@currentPortion) as varchar)
          print '@currentPortionLength: ' + CAST(@currentPortionLength * 2 as varchar)
        END
      END
--update bookcommenthtml set commenttext = CAST((select book.bookkey from book where bookkey = 188093) as varchar) where bookkey = 188093 AND printingkey = 1 AND commenttypecode = 1 and commenttypesubcode = 2 
--update bookcommenthtml set commenttext = (SELECT DBItemValue FROM OPENXML(@DocNum,  @XMLSearchString) WITH (DBItemValue text 'DBItemValue')) where bookkey = 188093 AND printingkey = 1 AND commenttypecode = 1 and commenttypesubcode = 2 
--UPDATETEXT bookcommenthtml.commenttext @txtptrval 0 NULL  Transaction.DBItemValue @txtptrval2 

--  INSERT INTO importtext ( transactionkey, tempkey1, tempkey2, textvalue, lastmaintdate)
--    SELECT transactionkey=@@SPID, tempkey1=texttypecode_d102, tempkey2=textformat_d103, textvalue=text_d104, lastmaintdate=GETDATE()
--    FROM OPENXML(@intDoc,  '/product/othertext')
--    WITH (texttypecode_d102 varchar(2) 'd102', textformat_d103 varchar(2) 'd103', text_d104 text 'd104')


--SELECT @ptrval = TEXTPTR(pr_info) 
--   FROM pub_info pr, publishers p
--      WHERE p.pub_id = pr.pub_id 
--      AND p.pub_name = 'New Moon Books'
--UPDATETEXT pub_info.pr_info @ptrval 88 1 'b' 
   
    --------------- TEST ----------------
    -- Get the <Transaction/DBAction/DBItem> LONGTEXT element from the passed XML document
--    UPDATE bookcommenthtml 
--    SET commenttext = DBItemValue
--    FROM OPENXML(@DocNum, @XMLSearchString)
--    WITH (DBItemValue text 'DBItemValue')
--    WHERE bookkey = 188093 AND printingkey = 1 AND commenttypecode = 1 and commenttypesubcode = 2

 
--    EXECUTE sp_executesql @SQLString,
--	    N'@p_DocNum INT,@p_XMLSearchString VARCHAR(255)', 
--	      @DocNum, @XMLSearchString
		       
--    PRINT CAST(@@ERROR AS VARCHAR)
--    PRINT CAST(@@ROWCOUNT AS VARCHAR)

--    IF @@ERROR <> 0 BEGIN
--      SET @o_error_code = @@ERROR
--      SET @o_error_desc = 'Error updating text column for bookcommenthtml for ActionSequence ' + @ActionSequence
--      GOTO ExitHandler
--    END
    
    FETCH NEXT FROM action_cursor INTO 
    	@ActionSequence,
    	@ActionType,
    	@ActionTable,
    	@StrHistoryOrder,
    	@FieldDescDetail,
      @ProcedureName,
      @Parameters,
      @XMLParameter
    	
    -- Get the action_cursor fetch status - variable must be used (infinite loop problems)
    SET @FetchAction = @@FETCH_STATUS

    IF @@ERROR <> 0 BEGIN
      SET @o_error_code = @@ERROR
      SET @o_error_desc = 'Error occurred while fetching DBAction cursor rows'
      GOTO ExitHandler
    END


  END --END Loop DBAction cursor

  CLOSE action_cursor
  DEALLOCATE action_cursor


  -- may need to propagate data for a title
  DECLARE propagatetitle_cur CURSOR FOR
   SELECT bookkey,tablename,columnname
     FROM #propagatetitle 
  
  OPEN propagatetitle_cur
  FETCH NEXT FROM propagatetitle_cur INTO @BookKey,@v_tablename,@v_columnname
  WHILE (@@FETCH_STATUS <> -1) BEGIN
    --print '@BookKey= ' + CONVERT(VARCHAR, @BookKey) 
    --print '@v_tablename= ' + @v_tablename
    --print '@v_columnname= ' + @v_columnname
    IF @v_tablename = 'bookcomments' AND @v_columnname = 'releasetoeloquenceind' BEGIN
		  SELECT @v_count = 0

      SELECT @v_count = count(*)
		    FROM #propagatetitle
       WHERE @v_tablename = 'bookcomments' 
         AND @v_columnname = 'commentstring'
         AND bookkey = @BookKey 
       
      IF @v_count = 0 BEGIN
		    EXECUTE qtitle_copy_work_info @BookKey, @v_tablename, @v_columnname, @o_error_code OUTPUT, @o_error_desc OUTPUT
      END
    END 
    ELSE
    BEGIN
		  EXECUTE qtitle_copy_work_info @BookKey, @v_tablename, @v_columnname, @o_error_code OUTPUT, @o_error_desc OUTPUT
    END
    
    IF @o_error_code < 0 BEGIN
      -- Error
      SET @o_error_code = -1
      CLOSE propagatetitle_cur
      DEALLOCATE propagatetitle_cur
      goto ExitHandler
    END
    FETCH NEXT FROM propagatetitle_cur INTO @BookKey,@v_tablename,@v_columnname
  END

  CLOSE propagatetitle_cur
  DEALLOCATE propagatetitle_cur

  -- scales need to maintain corescaleparameters table  
  DECLARE scales_cur CURSOR FOR
   SELECT distinct key1,tablename,projectkey
     FROM #scaleprojectkeys p
           
  OPEN scales_cur
  FETCH NEXT FROM scales_cur INTO @Key1,@v_tablename,@ProjectKey
  WHILE (@@FETCH_STATUS <> -1) BEGIN
    print '@v_tablename= ' + @v_tablename
    print '@Key1= ' + cast(@Key1 as varchar)
    print '@ProjectKey= ' + cast(@ProjectKey as varchar)
    
    -- inserts will need to get projectkey
    IF @ProjectKey = 0 and @Key1 > 0 BEGIN
      IF @v_tablename = 'taqprojectcontact' BEGIN
        SELECT DISTINCT @ProjectKey = taqprojectkey
          FROM taqprojectcontact
         WHERE taqprojectcontactkey = @Key1
           AND taqprojectkey > 0
      END
      ELSE IF @v_tablename = 'taqprojectcontactrole' BEGIN
        SELECT DISTINCT @ProjectKey = taqprojectkey
          FROM taqprojectcontactrole
         WHERE taqprojectcontactrolekey = @Key1
           AND taqprojectkey > 0
      END
      ELSE IF @v_tablename = 'taqprojecttask' BEGIN
        SELECT DISTINCT @ProjectKey = taqprojectkey
          FROM taqprojecttask
         WHERE taqtaskkey = @Key1
           AND taqprojectkey > 0
      END
      ELSE BEGIN
        SET @ProjectKey = @Key1
      END
    END
        
    IF @@ERROR <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error occurred while accessing #scaleprojectkeys (' + @v_tablename + ')'
      CLOSE scales_cur
      DEALLOCATE scales_cur
      GOTO ExitHandler
    END
  
    IF @ProjectKey > 0 BEGIN
      print 'Scale ProjectKey= ' + CONVERT(VARCHAR, @ProjectKey) 

      SELECT @v_count = count(*)
        FROM taqproject tp 
       WHERE tp.taqprojectkey = @ProjectKey
         and tp.searchitemcode = 11  --scales

      IF @@ERROR <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error occurred while accessing taqproject (' + @v_tablename + ')'
        CLOSE scales_cur
        DEALLOCATE scales_cur
        GOTO ExitHandler
      END
    
      IF @v_count > 0 BEGIN
  	    EXECUTE qscale_maintain_corescaleparameters @ProjectKey, @UserID, @o_error_code OUTPUT, @o_error_desc OUTPUT
        
        IF @o_error_code < 0 BEGIN
          -- Error
          SET @o_error_code = -1
          CLOSE scales_cur
          DEALLOCATE scales_cur
          goto ExitHandler
        END
      END
    END
    
    FETCH NEXT FROM scales_cur INTO @Key1,@v_tablename,@ProjectKey
  END

  CLOSE scales_cur
  DEALLOCATE scales_cur

  GOTO ExitHandler
  
------------
ExitHandler:
------------
  DROP TABLE #propagatetitle
  DROP TABLE #scaleprojectkeys
  DROP TABLE #deletetaqprojecttask

--  SET @o_new_keys = 'EXITING'
  
  -- Close DBAction cursor if still valid
  IF CURSOR_STATUS('local', 'action_cursor') >= 0
  BEGIN
    CLOSE action_cursor
    DEALLOCATE action_cursor
  END

  -- Close DBAction/Keys cursor is still valid
  IF CURSOR_STATUS('local', 'keys_cursor') >= 0
  BEGIN
    CLOSE keys_cursor
    DEALLOCATE keys_cursor
  END

  -- Close DBAction/Values cursor is still valid
  IF CURSOR_STATUS('local', 'values_cursor') >= 0
  BEGIN
    CLOSE values_cursor
    DEALLOCATE values_cursor
  END

  IF @IsOpen = 1  --document AND transaction are open
  BEGIN
    EXEC sp_xml_removedocument @DocNum
    IF @o_error_code <> 0 AND @o_error_code <> -2
    BEGIN
      IF @ManageTransactions = 1
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
      SET @o_new_keys = @KeyNamePairs
      IF @ManageTransactions = 1
        COMMIT TRANSACTION
    END
  END

  --IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> ''
    --PRINT 'ERROR: ' + @o_error_desc
    
  IF @SPErrorMessage = 'feedback'
    SET @o_error_desc = 'feedback'

  -- If warnings have been generated, return error code -2 to indicate warning(s)
  IF @o_warnings <> ''
    SET @o_error_code = -2
          
END
GO

GRANT EXEC ON qutl_dbchange_request TO PUBLIC
GO
