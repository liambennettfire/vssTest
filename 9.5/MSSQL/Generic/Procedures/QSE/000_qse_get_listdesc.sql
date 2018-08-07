IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_listdesc')
BEGIN
  DROP PROCEDURE  qse_get_listdesc
END
GO

CREATE PROCEDURE qse_get_listdesc
(
  @i_UserKey		INT,
  @i_SearchType		INT,
  @i_SearchItem   INT,
  @i_SaveAsCriteria	BIT,
  @i_ExcludeResultsListType INT,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/**********************************************************************************
**  Name: qse_get_listdesc
**  Desc: This stored procedure returns all lists meeting the passed criteria
**        to populate the Search Criteria List/Search Results List drop-down.
**
**  @i_UserKey      - userkey of the user who owns the lists to be returned
**  @i_SearchType   - searchtype of the lists to be returned
**  @i_SearchItem   - itemtype of the lists to be returned
**  @i_SaveAsCriteria - passes 0 if criteria lists should be returned
**                      passes 1 if results lists should be returned
**  @i_ExcludeResultsListType - on search pages, we must exclude Temp lists (4)
**                              but in search popups, we must exclude Current Working List (1)
**
**  Auth: Kate
**  Date: 3 May 2004
**
**  9/29/06 - KW - changes for recent lists
**********************************************************************************/

BEGIN
  DECLARE
  @v_ClientDefaultID  INT,
  @v_ClientMax  INT,
  @v_Count      INT,
  @v_DefaultInd TINYINT,
  @v_Error      INT,	
  @v_ListKey    INT,
  @v_ListType   INT,
  @v_ListDesc   VARCHAR(100),
  @v_NumLists   INT,
  @v_RecentListType INT,
  @v_Rowcount   INT,
  @v_RowDiff    INT,
  @v_SearchItem SMALLINT,
  @v_SearchSQL  NVARCHAR(4000),
  @v_UsageClass INT,
  @v_UserID     VARCHAR(30)
	
  SET NOCOUNT ON

  -- Get all criteria lists for that user and the given searchtype
  -- (including any default search criteria existing for the "fake" user -1)
  IF @i_SaveAsCriteria = 1  --criteria list
     SELECT listkey,   
       userkey,   
       searchtypecode,   
       listtypecode,   
       listdesc,
       defaultind,
       defaultonpopupsind,
       autofindind,
       hidecriteriaind,
       hideorgfilterind,
       firebrandlockind
     FROM qse_searchlist
     WHERE (userkey = @i_UserKey OR userkey = -1) AND
       searchtypecode = @i_SearchType AND
       saveascriteriaind = 1
     ORDER BY listdesc

  ELSE   --results list
   BEGIN
  
    -- Get the UserID for the passed userkey
    SELECT @v_Count = COUNT(*)
    FROM qsiusers
    WHERE userkey = @i_UserKey
    
    IF @v_Count > 0
      SELECT @v_UserID = userid
      FROM qsiusers
      WHERE userkey = @i_UserKey
    ELSE
      SET @v_UserID = 'QSIDBA'   
  
    -- For results lists, we must loop through all default rows for "fake" userkey -1
    -- to make sure that all default rows exist for this user
    DECLARE searchlist_cursor CURSOR FOR
      SELECT listtypecode, listdesc, defaultind, searchitemcode, usageclasscode
      FROM qse_searchlist
      WHERE userkey = -1 AND
          searchtypecode = @i_SearchType AND
          saveascriteriaind = 0
    
    OPEN searchlist_cursor

    FETCH NEXT FROM searchlist_cursor
    INTO @v_ListType, @v_ListDesc, @v_DefaultInd, @v_SearchItem, @v_UsageClass

    -- Loop to insert any missing default row for this user
    WHILE @@FETCH_STATUS = 0
    BEGIN
    
      -- Check if this row already exists for this user
      SELECT @v_Count = COUNT(*)
      FROM qse_searchlist
      WHERE userkey = @i_UserKey AND
          searchtypecode = @i_SearchType AND
          listtypecode = @v_ListType AND
          saveascriteriaind = 0
          
      -- If the processed default row doesn't exist for this user, add it
      IF @v_Count = 0
      BEGIN
      
        BEGIN TRANSACTION
        
        -- Generate new listkey
        EXEC next_generic_key 0, @v_ListKey OUTPUT, @o_error_code OUTPUT, @o_error_desc

        -- INSERT the new row for this user
        INSERT INTO qse_searchlist 
          (listkey,
          userkey,
          searchtypecode,
          searchitemcode,
          usageclasscode,
          listtypecode,
          listdesc,
          defaultind,
          createdbyuserid,
          lastuserid,
          lastmaintdate)
        VALUES
          (@v_ListKey, 
          @i_UserKey, 
          @i_SearchType, 
          @v_SearchItem,
          @v_UsageClass,
          @v_ListType, 
          @v_ListDesc, 
          @v_DefaultInd,
          @v_UserID,
          @v_UserID,
          getdate())

        SELECT @v_Error = @@ERROR, @v_Rowcount = @@ROWCOUNT
        IF @v_Error <> 0
        BEGIN
          CLOSE searchlist_cursor
          DEALLOCATE searchlist_cursor
          ROLLBACK TRANSACTION
          SET @o_error_code = -1
          SET @o_error_desc = 'Could not insert default rows into qse_searchlist table'
          RETURN
        END
        
        COMMIT TRANSACTION
                
      END --@v_Count = 0
      
      FETCH NEXT FROM searchlist_cursor
      INTO @v_ListType, @v_ListDesc, @v_DefaultInd, @v_SearchItem, @v_UsageClass

    END --LOOP
    
    CLOSE searchlist_cursor
    DEALLOCATE searchlist_cursor
    

    -- Check the client default for the Number of Recent Lists
    SET @v_ClientMax = 10 --default to 10
    SET @v_ClientDefaultID =
    CASE
      WHEN @i_SearchType=6 THEN 6    --Titles
      WHEN @i_SearchType=7 THEN 8   --Projects
      WHEN @i_SearchType=8 THEN 7     --Contacts
      WHEN @i_SearchType=16 THEN 9    --Lists
      WHEN @i_SearchType=18 THEN 33    --journals
      ELSE 0
    END          
    
    SELECT @v_Count = COUNT(*)
    FROM clientdefaults
    WHERE clientdefaultid = @v_ClientDefaultID
    
    IF @v_Count > 0
      SELECT @v_ClientMax = clientdefaultvalue
      FROM clientdefaults
      WHERE clientdefaultid = @v_ClientDefaultID
    
    -- Check how many results list rows exist for this user right now (exclude Temp list)
    SELECT @v_NumLists = COUNT(*)
    FROM qse_searchlist
    WHERE userkey = @i_UserKey AND
      searchtypecode = @i_SearchType AND 
      listtypecode <> @i_ExcludeResultsListType AND
      saveascriteriaind = 0
    
    -- Determine "recent" list type from the passed item type.
    -- If item type not passed in, use passed search type.
    -- NOTE: By default, item type is not passed in (@i_SearchItem=0).
    -- Item type MUST be passed in for lists (when @i_SearchType=16).
    SET @v_RecentListType =
    CASE @i_SearchItem
      WHEN 1 THEN 5 --Titles
      WHEN 2 THEN 6 --Contacts
      WHEN 3 THEN 7 --Projects
      WHEN 5 THEN 8 --P&L Templates
      WHEN 6 THEN 9 --Journals
      WHEN 9 THEN 11 --Work
      WHEN 10 THEN 12 --Contracts
      WHEN 11 THEN 13 --Scales
      WHEN 14 THEN 14 --Printings
      WHEN 15 THEN 15 -- Purchase Orders
      ELSE
      CASE @i_SearchType
        WHEN 6 THEN 5 --Titles
        WHEN 8 THEN 6 --Contacts
        WHEN 7 THEN 7 --Projects
        WHEN 17 THEN 8  --P&L Templates
        WHEN 18 THEN 9  --Journals
        WHEN 22 THEN 11 --Work
        WHEN 25 THEN 12 --Contracts
        WHEN 24 THEN 13 --Scales
        WHEN 28 THEN 14 --Printings
        WHEN 29 THEN 15 -- Purchase Orders
        WHEN 30 THEN 16  --Specification Templates              
      END
    END
    
    -- Check the total number of lists in "recent list"
    SELECT @v_Count = COUNT(*)
    FROM qse_searchresults
    WHERE listkey = 
        (SELECT listkey FROM qse_searchlist 
        WHERE userkey = @i_UserKey AND
        listtypecode = @v_RecentListType AND 
        searchtypecode = 16 AND saveascriteriaind = 0)
        
    PRINT 'recentlisttype=' + CONVERT(VARCHAR(20), isNull(@v_RecentListType,'99'))
    PRINT 'v_count=' + CONVERT(VARCHAR, @v_Count)
        
    -- When there are less list rows for this user than the client default (@v_ClientMax),
    -- OR the number of rows in "recent" list is less than @v_ClientMax, return:
    --    ALL current "recent" rows if any
    --    PLUS user-defined rows up to the client default max number,
    --    PLUS default list rows but not Temp lists (Current Working List and Recent)
    -- Otherwise, get the recent lists of that type (number of rows will equal @v_ClientMax)
    -- PLUS the default list rows (Current Working List and Recent)
    IF @v_NumLists < @v_ClientMax OR @v_Count < @v_ClientMax
      BEGIN
        -- Return the top 10 rows (or whatever the client's max number is)
        -- of ALL current "recent" rows and random other user-defined rows
        -- PLUS default lists - Current Working List and Recent list
        -- (exclude Temp lists - listtypecode=4)
        SET @v_RowDiff = @v_ClientMax - @v_Count
        
        SET @v_SearchSQL = N'SELECT DISTINCT 
            c.listkey, c.userkey, c.searchtypecode, c.listtypecode, c.listdesc,
            c.defaultind, c.searchitemcode, c.usageclasscode, c.createdbyuserid, 1 sortby
          FROM qse_searchlist c, qse_searchlist l, qse_searchresults r
          WHERE c.listkey = r.key1 AND 
            r.listkey = l.listkey AND
            l.listtypecode = ' + CONVERT(VARCHAR, COALESCE(@v_RecentListType,'0')) + ' AND
            l.userkey = ' + CONVERT(VARCHAR, COALESCE(@i_UserKey,'0')) + ' AND
            c.searchtypecode = ' + CONVERT(VARCHAR, COALESCE(@i_SearchType,'0')) + ' 
          UNION
          SELECT DISTINCT TOP ' + CONVERT(VARCHAR, @v_RowDiff) + 
            'listkey, userkey, searchtypecode, listtypecode, listdesc,
            defaultind, searchitemcode, usageclasscode, createdbyuserid, 1 sortby
          FROM qse_searchlist
          WHERE userkey = ' + CONVERT(VARCHAR, COALESCE(@i_UserKey,'0')) + ' AND
            searchtypecode = ' + CONVERT(VARCHAR, COALESCE(@i_SearchType,'0')) + ' AND
            saveascriteriaind = 0 AND
            listtypecode = 3
          UNION
          SELECT listkey, userkey, searchtypecode, listtypecode, CASE listtypecode WHEN 4 THEN ''Temp Working List'' ELSE listdesc END listdesc,
            defaultind, searchitemcode, usageclasscode, createdbyuserid, 0 sortby
          FROM qse_searchlist
          WHERE userkey = ' + CONVERT(VARCHAR, COALESCE(@i_UserKey,'0')) + ' AND
            searchtypecode = ' + CONVERT(VARCHAR, COALESCE(@i_SearchType,'0')) + ' AND
            saveascriteriaind = 0 AND
            listtypecode <> 3 AND listtypecode <> ' + CONVERT(VARCHAR, COALESCE(@i_ExcludeResultsListType,'0')) + ' 
          ORDER BY sortby DESC, c.listdesc'
          
        PRINT CONVERT(VARCHAR,@v_ClientMax)
        PRINT CONVERT(VARCHAR,@v_RowDiff)
        PRINT @v_SearchSQL
        
        EXECUTE sp_executesql @v_SearchSQL
        
        SELECT @v_Error = @@ERROR, @v_Rowcount = @@ROWCOUNT
        IF @v_Error <> 0 OR @v_Rowcount = 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'ERROR: Could not return lists. Error executing dynamic SQL - ' + @v_SearchSQL
          RETURN
        END
      END
      
    ELSE
      -- Return only the most recent user-defined lists, but always include
      -- default lists (i.e. not user-defined). Exclude Temp lists (listtypecode=4)
      BEGIN
        SELECT c.listkey, c.userkey, c.searchtypecode, c.listtypecode, c.listdesc,
            c.defaultind, c.searchitemcode, c.usageclasscode, c.createdbyuserid, 1 sortby
          FROM qse_searchlist c, 
              qse_searchlist l, 
              qse_searchresults r
          WHERE c.listkey = r.key1 AND 
              r.listkey = l.listkey AND
              l.listtypecode = @v_RecentListType AND
              l.userkey = @i_UserKey
        UNION
          SELECT c.listkey, c.userkey, c.searchtypecode, c.listtypecode, CASE listtypecode WHEN 4 THEN 'Temp Working List' ELSE listdesc END listdesc,
            c.defaultind, c.searchitemcode, c.usageclasscode, c.createdbyuserid, 0 sortby
          FROM qse_searchlist c
          WHERE c.searchtypecode = @i_SearchType AND            
              c.userkey = @i_UserKey AND
              c.listtypecode <> 3 AND c.listtypecode <> @i_ExcludeResultsListType
        ORDER BY sortby DESC, c.listdesc
      END
      
   END  --results list

  SELECT @v_Error = @@ERROR, @v_Rowcount = @@ROWCOUNT
  IF @v_Error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'ERROR: Could not access qse_searchlist table.'
    RETURN
  END

  IF @o_error_desc IS NOT NULL AND LTRIM(@o_error_desc) <> ''
    PRINT 'ERROR: ' + @o_error_desc

END
GO

GRANT EXEC ON qse_get_listdesc TO PUBLIC
GO
