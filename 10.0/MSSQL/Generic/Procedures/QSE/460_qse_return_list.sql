IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_return_list')
BEGIN
  PRINT 'Dropping Procedure qse_return_list'
  DROP PROCEDURE  qse_return_list
END
GO

PRINT 'Creating Procedure qse_return_list'
GO

CREATE PROCEDURE qse_return_list
(
  @i_ListKey          INT,
  @i_UserKey          INT,
  @i_SortString       VARCHAR(1000),
  @i_resultsviewkey   INT,
  @i_popupind         TINYINT,
  @o_ColumnOrderList  VARCHAR(255) OUT,
  @o_StyleList        VARCHAR(2000) OUT,
  @o_error_code       INT OUT,
  @o_error_desc       VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @CheckCount INT,
    @ColumnOrderList VARCHAR(255),
    @ColumnValueSQL VARCHAR(max),
    @DisplayInd INT,    
    @ErrorValue INT,
    @FromTableName  VARCHAR(100),
    @HorizontalAlign VARCHAR(10),
    @JoinToResultsWhere VARCHAR(max),
    @ListType INT,
    @ListOwnerKey INT,
    @ListUsageClass INT,    
    @NextColumn VARCHAR(max),
    @NumVisibleNonMovableColumns INT,
    @Pos INT,    
    @RecentListType INT,
    @ResultsColumnName  VARCHAR(255),
    @ResultsTableName VARCHAR(30),
    @RowcountValue  INT,
    @SearchSQL  NVARCHAR(max),
    @SearchSQLFrom  VARCHAR(max),
    @SearchSQLSelect  VARCHAR(max),
    @SearchSQLWhere VARCHAR(max),
    @SearchItem SMALLINT,
    @SearchType INT,
    @SortOrder INT,
    @SortString VARCHAR(max),
    @StrHorAlign VARCHAR(10),
    @StrWidth VARCHAR(30),
    @StyleList VARCHAR(2000),    
    @TempSortString VARCHAR(max),
    @UsageClass INT,
    @UserKey  INT,
    @Width  INT,
    @v_resultsviewkey int,
    @v_error_code INT,
    @v_error_desc VARCHAR(2000)    

  SET NOCOUNT ON
  
  SET @ColumnOrderList = ''
  SET @StyleList = ''
  
  -- number of visible but not movable columns (like delete button) 
  SET @NumVisibleNonMovableColumns = 1
      
  -- Get list details for the given listkey
  SELECT @SearchType = searchtypecode, @SearchItem = searchitemcode, @ListUsageClass = usageclasscode,
      @ListType = listtypecode, @ListOwnerKey = userkey
  FROM qse_searchlist
  WHERE listkey = @i_ListKey

  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT
  IF @ErrorValue <> 0 OR @RowcountValue = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Missing qse_searchlist record for listkey ' + CONVERT(VARCHAR, @i_ListKey)
    RETURN
  END
  
  -- DEBUG  
  --PRINT '@SearchType:' + CONVERT(VARCHAR, @SearchType)
  --PRINT '@SearchItem:' + CONVERT(VARCHAR, @SearchItem)
  --PRINT '@ListUsageClass:' + CONVERT(VARCHAR, @ListUsageClass)
  --PRINT '@ListType:' + CONVERT(VARCHAR, @ListType)
  --PRINT '@ListOwnerKey:' + CONVERT(VARCHAR, @ListOwnerKey)

  IF @SearchItem IS NULL
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Searchitemcode is NULL for listkey ' + CONVERT(VARCHAR, @i_ListKey)
    RETURN
  END
  
  -- Get necessary table join information from qse_searchtableinfo table
  SELECT @JoinToResultsWhere = jointoresultstablewhere
  FROM qse_searchtableinfo
  WHERE searchitemcode = @SearchItem AND 
        UPPER(tablename) = 'QSE_SEARCHRESULTS'

  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT
  IF @ErrorValue <> 0 OR @RowcountValue = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Record missing on qse_searchtableinfo table for search item ' + 
      CONVERT(VARCHAR, @SearchItem) + ' and tablename ''qse_searchresults'''
    RETURN
  END
  
  -- Set the basic results source table and default sortstring based on search Item Type
  IF @SearchItem = 1 		    -- Titles
  BEGIN
    SET @FromTableName = 'coretitleinfo'
    SET @SortString = 'ORDER BY coretitleinfo.title'
  END
  ELSE IF @SearchItem = 2   -- Contacts
  BEGIN
    SET @FromTableName = 'corecontactinfo'
    SET @SortString = 'ORDER BY corecontactinfo.displayname'
  END    
  ELSE IF @SearchItem = 3   -- Projects
  BEGIN
    SET @FromTableName = 'coreprojectinfo'
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'    
    -- delete and copy
    SET @NumVisibleNonMovableColumns = 2
  END
  ELSE IF @SearchItem = 4   --Lists
  BEGIN
    SET @FromTableName = 'qse_searchlist'
    SET @SortString = 'ORDER BY listdesc'
  END
  ELSE IF @SearchItem = 5 AND @ListUsageClass = 1   --User Admin: P&L templates
  BEGIN
    SET @FromTableName = 'coreprojectinfo, taqversion'
    SET @JoinToResultsWhere = @JoinToResultsWhere + ' AND coreprojectinfo.projectkey=taqversion.taqprojectkey AND taqversion.plstagecode=(SELECT datacode FROM gentables WHERE tableid = 562 AND qsicode = 2) AND taqversion.taqversionkey=1'
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'
  END
  ELSE IF @SearchItem = 6   -- Journals
  BEGIN
    SET @FromTableName = 'coreprojectinfo'
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'
  END
  ELSE IF @SearchItem = 8   -- Task View/Group
  BEGIN
    SET @FromTableName = 'taskview'
    SET @SortString = 'ORDER BY taskview.taskviewdesc'
  END
  ELSE IF @SearchItem = 9   -- Works
  BEGIN
    SET @FromTableName = 'coreprojectinfo, taqproject'
    SET @JoinToResultsWhere = @JoinToResultsWhere + ' AND coreprojectinfo.projectkey=taqproject.taqprojectkey'
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'
  END
  ELSE IF @SearchItem = 10   -- Contracts
  BEGIN
    SET @FromTableName = 'coreprojectinfo'
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'
  END
  ELSE IF @SearchItem = 11   -- Scales
  BEGIN
    SET @FromTableName = 'coreprojectinfo'
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle, coreprojectinfo.projecttypedesc'
    -- delete and copy
    SET @NumVisibleNonMovableColumns = 2
  END
  ELSE IF @SearchItem = 14   -- Printings
  BEGIN
    SET @FromTableName = 'coreprojectinfo, taqprojectprinting_view'
    SET @JoinToResultsWhere = @JoinToResultsWhere + ' AND coreprojectinfo.projectkey=taqprojectprinting_view.taqprojectkey'    
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'
    SET @NumVisibleNonMovableColumns = 2
  END
  ELSE IF @SearchItem = 15   -- Purchase Orders
  BEGIN
    SET @FromTableName = 'coreprojectinfo, taqproductnumbers'
    SET @JoinToResultsWhere = @JoinToResultsWhere + ' AND coreprojectinfo.projectkey=taqproductnumbers.taqprojectkey AND taqproductnumbers.productidcode=(SELECT datacode FROM gentables WHERE tableid = 594 AND qsicode = 7)'    
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'
  END
  ELSE IF @SearchItem = 5 AND @ListUsageClass = 2   -- User Admin: Specification Template
  BEGIN
    SET @FromTableName = 'coreprojectinfo' 
    SET @SortString = 'ORDER BY coreprojectinfo.projecttitle'   
  END    
  ELSE
  BEGIN
    SET @FromTableName = ''
    SET @SortString = ''
  END
  
  --print '@FromTableName'
  --print @FromTableName
  --print '@JoinToResultsWhere'
  --print @JoinToResultsWhere
  
  -- Check if results are for a single usageclass
  SET @UsageClass = 0
  IF @FromTableName = 'coretitleinfo'
  BEGIN
    IF COALESCE(@i_resultsviewkey,0) <= 0
    BEGIN    
      SELECT @CheckCount = COUNT(*) FROM 
        (SELECT DISTINCT c.usageclasscode
        FROM qse_searchresults sr, coretitleinfo c
        WHERE sr.key1 = c.bookkey 
          and sr.key2 = c.printingkey
          and sr.listkey = @i_ListKey) AS d

      IF @CheckCount = 1
        SELECT TOP 1 @UsageClass = c.usageclasscode
        FROM qse_searchresults sr, coretitleinfo c
        WHERE sr.key1 = c.bookkey 
          and sr.key2 = c.printingkey
          and sr.listkey = @i_ListKey      
    END
  END
  ELSE IF @FromTableName = 'coreprojectinfo'
  BEGIN
    IF COALESCE(@i_resultsviewkey,0) <= 0
    BEGIN
      SELECT @CheckCount = COUNT(*) FROM 
        (SELECT DISTINCT c.usageclasscode
        FROM qse_searchresults sr, coreprojectinfo c
        WHERE sr.key1 = c.projectkey 
          and sr.listkey = @i_ListKey) AS d
            
      IF @CheckCount = 1
        SELECT TOP 1 @UsageClass = c.usageclasscode
          FROM qse_searchresults sr, coreprojectinfo c
         WHERE sr.key1 = c.projectkey 
           and sr.listkey = @i_ListKey      
    END   
  END
  
  --PRINT '@UsageClass:' + CONVERT(VARCHAR, @UsageClass)
  
  -- If sortstring was passed, it will be used instead of the default @SortString initialized above (after being processed below)
  SET @TempSortString = ''
  IF @i_SortString IS NOT NULL AND LTRIM(RTRIM(@i_SortString)) <> ''
    SET @TempSortString = @i_SortString
  
  -- Initialize the SELECT list, FROM clause and WHERE clause  
  SET @SearchSQLSelect = 'SELECT '
  SET @SearchSQLFrom = 'FROM qse_searchresults, ' + @FromTableName
  SET @SearchSQLWhere = 'WHERE ' + @JoinToResultsWhere + ' AND qse_searchresults.listkey = ' + CONVERT(VARCHAR, @i_ListKey)
 
  -- Use the results view selected by the user, if passed
  SET @v_resultsviewkey = 0
  IF @i_resultsviewkey > 0 BEGIN
    SET @v_resultsviewkey = @i_resultsviewkey
  END
  
  -- If selected results view is not passed, try to find results view for the passed criteria
  IF @v_resultsviewkey = 0 BEGIN
    EXEC qutl_get_resultsviewkey @SearchType, @i_UserKey, @SearchItem, @UsageClass, @i_popupind,
      @v_resultsviewkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
  
    IF @v_error_code < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = @v_error_desc
      RETURN
    END
  END
      
  --PRINT '@v_resultsviewkey:' + CONVERT(VARCHAR, @v_resultsviewkey)
  
  -- Get all display column results for the given search type 
  IF @v_resultsviewkey > 0 BEGIN
    -- searchresultsview exists
    DECLARE searchresultskeys_cursor CURSOR FOR
      SELECT c.tablename, c.columnname, COALESCE(l.columnorder,0), c.webhorizontalalign, l.columnwidth, c.displayind, c.columnvaluesql
      FROM qse_searchresultscolumns c 
        LEFT OUTER JOIN qse_searchresultsviewlayout l ON c.columnnumber = l.columnnumber AND l.resultsviewkey = @v_resultsviewkey
      WHERE c.searchtypecode = @SearchType AND
        c.searchitemcode = @SearchItem AND
        c.usageclasscode = 0  -- must be rows on qse_searchresultscolumns for usageclass 0 that correspond to all columns on datagrid
     ORDER BY c.defaultsortorder ASC
  END 
  ELSE BEGIN
    --Check if results column rows exist for this Usage Class. If not, use common results columns (UsageClass=0)
    SELECT @CheckCount = COUNT(*)
    FROM qse_searchresultscolumns
    WHERE searchtypecode = @SearchType AND
      searchitemcode = @SearchItem AND
      usageclasscode = @UsageClass
      
    IF @CheckCount = 0
      SET @UsageClass = 0

    DECLARE searchresultskeys_cursor CURSOR FOR
      SELECT tablename, columnname, coalesce(websortorder,0), webhorizontalalign, defaultwidth, displayind, columnvaluesql
      FROM qse_searchresultscolumns
      WHERE searchtypecode = @SearchType AND
        searchitemcode = @SearchItem AND
        usageclasscode = @UsageClass
      ORDER BY defaultsortorder ASC
  END
  
  OPEN searchresultskeys_cursor

  FETCH NEXT FROM searchresultskeys_cursor INTO
	  @ResultsTableName, @ResultsColumnName, @SortOrder, @HorizontalAlign, @Width, @DisplayInd, @ColumnValueSQL

  -- Loop to build the SELECT list
  WHILE @@FETCH_STATUS = 0
  BEGIN
  
    --PRINT '@ResultsTableName:' + @ResultsTableName
    --PRINT '@ResultsColumnName:' + @ResultsColumnName
    --PRINT '@SortOrder:' + CONVERT(VARCHAR, @SortOrder)
    --PRINT '@HorizontalAlign:' + @HorizontalAlign
    --PRINT '@Width:' + CONVERT(VARCHAR, @Width)
    --PRINT '@DisplayInd:' + CONVERT(VARCHAR, @DisplayInd)
    --PRINT '@ColumnValueSQL:' + @ColumnValueSQL

    -- Next results column
    SET @NextColumn = @ResultsTableName + '.' + @ResultsColumnName
    
    -- Special processing is required for date values that are saved with time precision.
    -- Must extract the time portion and search on date only.
    IF UPPER(LEFT(@NextColumn, 5)) = 'DATE('
    BEGIN
      SET @NextColumn = SUBSTRING(@NextColumn, 6, 30)
      SET @NextColumn = 'CONVERT(datetime,CONVERT(varchar,' + @NextColumn + ', 101),101)'
      SET @NextColumn = @NextColumn + ' ' + @ResultsColumnName
    END

    -- 9/27/05 - KW - For contacts, displayname may not be filled in - in that case,
    -- at least show the groupname or lastname so that we can access that contact via
    -- the Contact Name hyperlink on search results
    IF @NextColumn = 'corecontactinfo.displayname'
    BEGIN
      SET @NextColumn =
        'CASE' +
        ' WHEN corecontactinfo.displayname IS NULL THEN' +
        '  CASE' +
        '   WHEN globalcontact.groupname IS NOT NULL THEN globalcontact.groupname' +
        '   ELSE globalcontact.lastname' +
        '  END' +
        ' ELSE corecontactinfo.displayname ' +
        'END AS displayname'
        
      SET @SearchSQLFrom = @SearchSQLFrom + ',globalcontact'      
      SET @SearchSQLWhere = @SearchSQLWhere + ' AND corecontactinfo.contactkey=globalcontact.globalcontactkey'
    END
    
    IF @ColumnValueSQL IS NOT NULL
    BEGIN
      SET @NextColumn = @ColumnValueSQL + ' ' + @ResultsColumnName
      SET @NextColumn = REPLACE(@NextColumn, '@p_userkey', CONVERT(VARCHAR, @i_UserKey))
      SET @TempSortString = REPLACE(@TempSortString, @ResultsColumnName, '(' + @ColumnValueSQL + ')')
      SET @TempSortString = REPLACE(@TempSortString, '@p_userkey', CONVERT(VARCHAR, @i_UserKey))
    END
            
    SET @SearchSQLSelect = @SearchSQLSelect + @NextColumn
    
    IF @DisplayInd = 1
    BEGIN
      -- add number of visible but not movable columns (like delete button) to sortorder
      IF @SortOrder > 0
        SET @ColumnOrderList = @ColumnOrderList + CONVERT(VARCHAR, @SortOrder + @NumVisibleNonMovableColumns)
      ELSE
        SET @ColumnOrderList = @ColumnOrderList + CONVERT(VARCHAR, @SortOrder)
          
      SET @StrWidth = 
      CASE 
        WHEN @Width > 0 THEN CONVERT(VARCHAR, @Width) 
        ELSE '0'
      END
      SET @StrHorAlign = 
      CASE @HorizontalAlign
        WHEN NULL THEN ''
        ELSE @HorizontalAlign
      END
      
      --PRINT '@StrWidth:' + CONVERT(VARCHAR, @StrWidth)
      --PRINT '@StrHorAlign:' + CONVERT(VARCHAR, @StrHorAlign)
      
      IF @StrWidth <> '' AND @StrHorAlign <> ''
      BEGIN
        IF @StyleList <> '' AND RIGHT(@StyleList, 1) <> ';'
          SET @StyleList = @StyleList + ';'
          
        SET @StyleList = @StyleList + @ResultsColumnName + ',' + @StrWidth + ',' + @StrHorAlign
      END
    END

    FETCH NEXT FROM searchresultskeys_cursor INTO
      @ResultsTableName, @ResultsColumnName, @SortOrder, @HorizontalAlign, @Width, @DisplayInd, @ColumnValueSQL

    IF @@FETCH_STATUS = 0
      BEGIN
        SET @SearchSQLSelect = @SearchSQLSelect + ','
        IF @DisplayInd = 1
        BEGIN
          SET @StyleList = @StyleList + ';'
          IF @ColumnOrderList <> ''
            SET @ColumnOrderList = @ColumnOrderList + ','          
        END
      END
    ELSE
      SET @SearchSQLSelect = @SearchSQLSelect + ' '
  END

  CLOSE searchresultskeys_cursor
  DEALLOCATE searchresultskeys_cursor
  
  -- Add tablename in front of contact columns that would otherwise cause 'ambiguous column' errors
  IF @TempSortString <> ''
  BEGIN
    IF @SearchItem = 2 BEGIN  -- Contacts      
      SET @Pos = CHARINDEX('.privateind',@TempSortString)
      IF @Pos = 0
        SET @TempSortString = REPLACE(@TempSortString,'privateind','corecontactinfo.privateind')
      SET @Pos = CHARINDEX('.displayname',@TempSortString)
      IF @Pos = 0
        SET @TempSortString = REPLACE(@TempSortString,'displayname','corecontactinfo.displayname')
    END
    SET @SortString = 'ORDER BY ' + @TempSortString  
  END  
  
  -- add qse_searchresults.selectedind to the select
  SET @SearchSQLSelect = @SearchSQLSelect + ',qse_searchresults.selectedind'
  
  -- Set the search results column order list output parameter value
  SET @o_ColumnOrderList = @ColumnOrderList
  SET @o_StyleList = @StyleList
  
  -- Build and EXECUTE the dynamic SELECT statement
  SET @SearchSQL = N'' + @SearchSQLSelect + ' ' + @SearchSQLFrom + ' ' + @SearchSQLWhere
  IF @SortString <> ''
    SET @SearchSQL = N'' + @SearchSQL + ' ' + @SortString
    
  --DEBUG
  PRINT @SearchSQL
    
  EXECUTE sp_executesql @SearchSQL
  
  SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT
  IF @ErrorValue <> 0 OR @RowcountValue = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not return list. Error executing dynamic SQL - ' + @SearchSQL
    RETURN
  END 
  
  -- Use a temporary table to update sortorder on qse_searchresults 
  SET @SearchSQL = N'  SELECT qse_searchresults.listkey, qse_searchresults.key1, qse_searchresults.key2, newsortorder = IDENTITY(INT,1,1) ' +
                   N'INTO #temp_searchresults ' + @SearchSQLFrom + ' ' + @SearchSQLWhere
  IF @SortString <> ''
    SET @SearchSQL = N'' + @SearchSQL + ' ' + @SortString + '
                     
  '

  SET @SearchSQL = @SearchSQL + N'CREATE INDEX temp_searchresults_idx on #temp_searchresults (listkey, key1, key2)
                      
  '
  
  SET @SearchSQL = @SearchSQL + N'UPDATE qse_searchresults
  SET sortorder = (select newsortorder from #temp_searchresults t where t.listkey = qse_searchresults.listkey  
                                                                       and t.key1 = qse_searchresults.key1  
                                                                       and t.key2 = qse_searchresults.key2)
  WHERE listkey = ' + cast(@i_ListKey as varchar) + '
  
  '
     
  -- clean up
  SET @SearchSQL = @SearchSQL + N'DROP TABLE #temp_searchresults
                     
  '
  
  PRINT ' '
  PRINT @SearchSQL
  
  EXECUTE sp_executesql @SearchSQL
    
  
  -- Update "recent list of lists" for user-defined lists only (listtypecode=3)
  IF @ListType = 3  --user-defined lists
  BEGIN
    -- Set the recent list type based on searchtype
    SET @RecentListType = 
    CASE @SearchType
      WHEN 6 THEN 5 --Titles
      WHEN 7 THEN 7 --Projects
      WHEN 8 THEN 6 --Contacts
      WHEN 17 THEN 8  --P&L Templates
      WHEN 18 THEN 9  --Journals
      WHEN 22 THEN 11  --Works
      WHEN 25 THEN 12  --Contracts
      WHEN 24 THEN 13 --Scales
      WHEN 28 THEN 14  --Printings  
      WHEN 29 THEN 15 --Purchase Orders    
      WHEN 30 THEN 16  --Specification Templates        
    END
    
    -- Set userkey
    IF @i_UserKey IS NULL
      SET @UserKey = @ListOwnerKey
    ELSE
      SET @UserKey = @i_UserKey
    
    -- Update "recent list of lists" of given type (RecentListType)
    EXEC qutl_update_recent_use_list @UserKey, 16, @RecentListType,
      @i_ListKey, 0, 0, @o_error_code OUTPUT, @o_error_desc OUTPUT
      
  END
  
END
GO

GRANT EXEC ON qse_return_list TO PUBLIC
GO
