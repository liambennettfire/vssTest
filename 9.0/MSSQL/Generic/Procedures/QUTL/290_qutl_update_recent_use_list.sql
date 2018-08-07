IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_update_recent_use_list')
  BEGIN
    PRINT 'Dropping Procedure qutl_update_recent_use_list'
    DROP  Procedure  qutl_update_recent_use_list
  END
GO

PRINT 'Creating Procedure qutl_update_recent_use_list'
GO

CREATE PROCEDURE qutl_update_recent_use_list
 (@i_userkey        integer,
  @i_searchtypecode integer,
  @i_listtypecode   integer,
  @i_key1           integer,
  @i_key2           integer,
  @i_actiontype     tinyint,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_update_recent_use_list
**  Desc: This stored procedure is used to update the recent use list
**        for the user based on the type of the list that is chosen
**        and the key sent.
**
**  @i_actiontype: (QSolution.Framework.Search.ActionTypes)
**    0 - UPDATE (default) - update/add item to list
**    1 - RENAME - this procedure is not called for Rename DBAction
**    2 - DELETE - delete from list
**
**  Auth: James P. Weber
**  Date: 29 May 2004
**
**  9/20/06 - KW - Functionality to allow recent list of lists by type,
**                 and to remove an item from the given recent list.
*******************************************************************************/

  DECLARE
    @Count  INT,
    @MaxInList  INT,
    @CurrentCount INT,
    @CurrentListKey INT,
    @RecentListKey  INT,
    @UserID VARCHAR(25),
    @SearchItemCode INT,
    @ListDesc   VARCHAR(100),    
    @error_var    INT,
    @rowcount_var INT,
    @UsageClassCode INT,
    @ClientDefaultId INT
   
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @Count = 0  
  SET @CurrentListKey = null
  SET @RecentListKey = null
 
  -- Get User ID
  SELECT @UserID = userid 
  FROM qsiusers 
  WHERE userkey = @i_userkey
  
  -- Get list description for the passed searchtypecode and listtypecode
  SELECT @listdesc = listdesc 
  FROM qse_searchlist 
  WHERE userkey = -1 AND 
    searchtypecode = @i_searchtypecode AND
    listtypecode = @i_listtypecode
  
  -- Get SearchItemCode - hardcoding results table here, based on search type
  SET @ClientDefaultId = 0
  IF @i_searchtypecode = 1 OR @i_searchtypecode = 6 BEGIN
    -- Titles
    SET @SearchItemCode = 1
    SET @ClientDefaultId = 6
  END
  ELSE IF @i_searchtypecode = 7 OR @i_searchtypecode = 10 BEGIN
    -- Projects
    SET @SearchItemCode = 3
    SET @ClientDefaultId = 8
  END
  ELSE IF @i_searchtypecode = 8 BEGIN
    -- Contacts
    SET @SearchItemCode = 2   
    SET @ClientDefaultId = 7
  END
  ELSE IF @i_searchtypecode = 16 BEGIN
    -- Lists
    SET @SearchItemCode = 4
    SET @ClientDefaultId = 9
  END
  ELSE IF @i_searchtypecode = 17 BEGIN
    -- P&L Templates
    SET @SearchItemCode = 5
  END
  ELSE IF @i_searchtypecode = 18 BEGIN
    -- Journals
    SET @SearchItemCode = 6
    SET @ClientDefaultId = 33
  END
  ELSE IF @i_searchtypecode = 19 OR @i_searchtypecode = 20 BEGIN
    -- Task Views/Groups
    SET @SearchItemCode = 8
  END
  ELSE IF @i_searchtypecode = 22 BEGIN      
    -- works
    SET @SearchItemCode = 9
  END
  ELSE IF @i_searchtypecode = 24 BEGIN
    -- Scales
    SET @SearchItemCode = 11
  END
  ELSE IF @i_searchtypecode = 25 BEGIN
    -- Contracts
    SET @SearchItemCode = 10
  END
  ELSE IF @i_searchtypecode = 28 BEGIN
    -- Printings
    SET @SearchItemCode = 14
  END 
  ELSE IF @i_searchtypecode = 29 BEGIN
    -- Purchase Orders
    SET @SearchItemCode = 15
  END  
   
  
  -- Maintain 10 as a default
  --Case #30524 Default @MaxInList = 25 
  SET @MaxInList = 25
  IF @ClientDefaultId > 0 BEGIN
    SELECT @Count = count(*)
    FROM clientdefaults
    WHERE clientdefaultid = @ClientDefaultId

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT

    IF @Count > 0 BEGIN
      SELECT @MaxInList = COALESCE(clientdefaultvalue, 25)
      FROM clientdefaults
      WHERE clientdefaultid = @ClientDefaultId

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    END
  END

  -- Make sure that 'Current Working List' search results list exists for this user
  SELECT @CurrentListKey = listkey 
  FROM qse_searchlist 
  WHERE userkey = @i_userkey AND 
      searchtypecode = @i_searchtypecode AND listtypecode = 1
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
 
  IF @CurrentListKey IS NULL
  BEGIN   
    -- Generate new ListKey
    EXEC next_generic_key @UserID, @CurrentListKey output, @o_error_code output, @o_error_desc output 
    
    -- Insert 'Current Working List' search results list into QSE_SEARCHLIST table for this user
    INSERT INTO qse_searchlist 
      (listkey, userkey, searchtypecode, searchitemcode, 
      listtypecode, listdesc, defaultind, lastuserid, lastmaintdate, createdbyuserid)
    VALUES
      (@CurrentListKey, @i_userkey, @i_searchtypecode, @SearchItemCode,
      1, 'Current Working List', 1, @UserID, getdate(), @UserID)
    
    -- For P&L Template searches, also set usageclasscode  
    IF @i_searchtypecode = 17
      UPDATE qse_searchlist
      SET usageclasscode = 1
      WHERE listkey = @CurrentListKey
  END 
  
  -- Make sure that 'Recent List' search results list exists for this user
  SELECT @RecentListKey = listkey 
  FROM qse_searchlist 
  WHERE userkey = @i_userkey AND 
      searchtypecode = @i_searchtypecode AND 
      listtypecode = @i_listtypecode
  
  BEGIN TRANSACTION 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
 
  IF @RecentListKey IS NULL
  BEGIN   
    -- Generate new ListKey
    EXEC next_generic_key @UserID, @RecentListKey output, @o_error_code output, @o_error_desc output 
    
    -- Insert 'Recent' list into QSE_SEARCHLIST table for this user
    INSERT INTO qse_searchlist 
      (listkey, userkey, searchtypecode, searchitemcode, 
      listtypecode, listdesc, lastuserid, lastmaintdate, createdbyuserid)
    VALUES 
      (@RecentListKey, @i_userkey, @i_searchtypecode, @SearchItemCode,
      @i_listtypecode, @ListDesc, @UserID, getdate(), @UserID)

    -- For P&L Template searches, also set usageclasscode  
    IF @i_searchtypecode = 17
      UPDATE qse_searchlist
      SET usageclasscode = 1
      WHERE listkey = @RecentListKey
      
    INSERT INTO qse_searchresults 
      (listkey, key1, key2, lastuse) 
    VALUES 
      (@RecentListKey, @i_key1, @i_key2, getdate())

    GOTO ExitHandler
  END 


  -- If requested actiontype is Delete (2), remove passed item from recent list
  IF @i_actiontype = 2  --remove
  BEGIN
    DELETE FROM qse_searchresults 
    WHERE listkey = @RecentListKey AND key1 = @i_key1 AND key2 = @i_key2
  
    GOTO ExitHandler
  END
  
  
  SELECT @Count = COUNT(*) 
  FROM qse_searchresults 
  WHERE listkey = @RecentListKey AND key1 = @i_key1 AND key2 = @i_key2

  IF @Count = 1
    BEGIN
      --print 'update'
      UPDATE qse_searchresults 
      SET lastuse = getdate() 
      WHERE listkey = @RecentListKey AND key1 = @i_key1 AND key2 = @i_key2
    END
  ELSE
    BEGIN 
      --print 'insert/possible remove'
    
      -- This is where we will eventually look it up.
      IF @SearchItemCode = 3 OR @SearchItemCode = 5 OR @SearchItemCode = 9 --Project or User Admin or Works
        BEGIN
          -- projects are by usage class
          SELECT @UsageClassCode = COALESCE(usageclasscode,0)
          FROM coreprojectinfo
          WHERE projectkey = @i_key1

          IF @UsageClassCode > 0
            -- how many in recent list have the same usage class
            SELECT @Count = COUNT(*) 
            FROM qse_searchresults r, coreprojectinfo c
            WHERE r.key1 = c.projectkey AND
                r.listkey = @RecentListKey AND
                c.usageclasscode = @UsageClassCode
          ELSE
            SELECT @Count = COUNT(*) 
            FROM qse_searchresults 
            WHERE listkey = @RecentListKey 

        END
      ELSE IF @SearchItemCode = 1 --Title
        BEGIN
          -- projects are by usage class
          SELECT @UsageClassCode = COALESCE(usageclasscode,0)
          FROM coretitleinfo
          WHERE bookkey = @i_key1
            AND printingkey = @i_key2

          IF @UsageClassCode > 0
            -- how many in recent list have the same usage class
            SELECT @Count = COUNT(*) 
            FROM qse_searchresults r, coretitleinfo c
            WHERE r.key1 = c.bookkey AND
                r.key2 = c.printingkey AND
                r.listkey = @RecentListKey AND
                c.usageclasscode = @UsageClassCode
          ELSE
            SELECT @Count = COUNT(*) 
            FROM qse_searchresults 
            WHERE listkey = @RecentListKey 

        END
      ELSE
        BEGIN
          SELECT @Count = COUNT(*) 
          FROM qse_searchresults 
          WHERE listkey = @RecentListKey 
        END

      IF (@Count < @MaxInList)
        BEGIN
          --print 'insert only'
          INSERT INTO qse_searchresults (listkey, key1, key2, lastuse) 
          VALUES (@RecentListKey, @i_key1, @i_key2, getdate())
        END
      ELSE
        BEGIN
          -- This is where the complexity starts.  At this point we have to 
          -- find the oldest value and remove it from the list.
          IF (@Count >= @MaxInList)
          BEGIN
            -- Do this to clean up any invalid entries in the list.
            --print 'deleting null entries for last use'
            DELETE FROM qse_searchresults 
            WHERE listkey = @RecentListKey AND lastuse IS NULL
          END 

          DECLARE @v_listkey int, @v_key1 int, @v_key2 int, @v_lastuse datetime

          IF @SearchItemCode = 3 OR @SearchItemCode = 5 OR @SearchItemCode = 9
            -- projects, user admin and works items are by usage class
            DECLARE search_results_cursor CURSOR FOR
              SELECT listkey, key1, key2, lastuse
              FROM qse_searchresults r, coreprojectinfo c
              WHERE r.key1 = c.projectkey AND
                  listkey = @RecentListKey  AND
                  COALESCE(c.usageclasscode,0) = COALESCE(@UsageClassCode,0)
              ORDER BY lastuse DESC
          ELSE IF @SearchItemCode = 1
            -- title items are by usage class
            DECLARE search_results_cursor CURSOR FOR
              SELECT listkey, key1, key2, lastuse
              FROM qse_searchresults r, coretitleinfo c
              WHERE r.key1 = c.bookkey AND
                  r.key2 = c.printingkey AND
                  listkey = @RecentListKey  AND
                  COALESCE(c.usageclasscode,0) = COALESCE(@UsageClassCode,0)
              ORDER BY lastuse DESC
          ELSE
            DECLARE search_results_cursor CURSOR FOR
               SELECT listkey, key1, key2, lastuse
               FROM qse_searchresults
               WHERE listkey = @RecentListKey
               ORDER BY lastuse DESC

          OPEN search_results_cursor
          
          SET @CurrentCount = 0
          
          FETCH NEXT FROM search_results_cursor 
          INTO @v_listkey, @v_key1, @v_key2, @v_lastuse
          
          WHILE @@FETCH_STATUS = 0
          BEGIN

            SET @CurrentCount = @CurrentCount + 1            
            --print @CurrentCount
            
            if (@CurrentCount >= @MaxInList)
            BEGIN
              --print 'deleting row'
              DELETE qse_searchresults where current of search_results_cursor
            END
            
            FETCH NEXT FROM search_results_cursor 
            INTO @v_listkey, @v_key1, @v_key2, @v_lastuse
          END

          CLOSE search_results_cursor
          DEALLOCATE search_results_cursor

          INSERT qse_searchresults (listkey, key1, key2, lastuse) 
          VALUES (@RecentListKey, @i_key1, @i_key2, getdate())

          -- For DEBUG Only when calling from query analyzer.
          -- select * from qse_searchresults where listkey = @RecentListKey order by lastuse desc

        END --@Count >= @MaxInList
        
    END --@Count <> 1

  GOTO ExitHandler  

  ------------
  ExitHandler:
  ------------

  COMMIT TRANSACTION
  
  RETURN
GO

GRANT EXEC ON qutl_update_recent_use_list TO PUBLIC
GO
