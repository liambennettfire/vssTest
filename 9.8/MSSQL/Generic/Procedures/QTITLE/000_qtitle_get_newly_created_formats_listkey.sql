IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qtitle_get_newly_created_formats_listkey')
  BEGIN
    PRINT 'Dropping Procedure qtitle_get_newly_created_formats_listkey'
    DROP  Procedure  qtitle_get_newly_created_formats_listkey
  END
GO

PRINT 'Creating Procedure qtitle_get_newly_created_formats_listkey'
GO

CREATE PROCEDURE qtitle_get_newly_created_formats_listkey
 (@i_userkey        integer,
  @i_empty_list     tinyint,
  @o_listkey        integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_newly_created_formats_listkey
**  Desc: This stored procedure is used to return the listkey
**        for the Newly Created Formats list for a user.  If
**        the list does not exist yet for the user, it will be 
**        created. If the list does exist and @i_empty_list = 1,
**        all items currently in the list will be removed. 
**
**  Auth: Alan Katzen
**  Date: 2 August 2010
**
*******************************************************************************/

  DECLARE
    @Count  INT,
    @CurrentListKey INT,
    @ListKey  INT,
    @UserID VARCHAR(25),
    @SearchItemCode INT,
    @ListDesc   VARCHAR(100),    
    @error_var    INT,
    @rowcount_var INT,
    @UsageClassCode INT,
    @v_searchtypecode integer,
    @v_listtypecode   integer
   
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_listkey = 0
  SET @ListKey = 0
  SET @Count = 0  
  SET @v_searchtypecode = 6
  SET @v_listtypecode = 10
  SET @SearchItemCode = 1   -- Titles

  -- Get User ID
  SELECT @UserID = userid 
    FROM qsiusers 
   WHERE userkey = @i_userkey
  
  -- Get list description for the passed searchtypecode and listtypecode
  SELECT @listdesc = listdesc 
    FROM qse_searchlist 
   WHERE userkey = -1 AND 
         searchtypecode = @v_searchtypecode AND
         listtypecode = @v_listtypecode
    
  -- Make sure that 'Newly Created Formats List' search results list exists for this user
  SELECT @Count = count(*) 
    FROM qse_searchlist 
   WHERE userkey = @i_userkey AND 
         searchtypecode = @v_searchtypecode AND 
         listtypecode = @v_listtypecode
   
  IF @Count > 0 BEGIN
    SELECT @ListKey = listkey 
      FROM qse_searchlist 
     WHERE userkey = @i_userkey AND 
           searchtypecode = @v_searchtypecode AND 
           listtypecode = @v_listtypecode
    
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find list: Error accessing qse_searchlist table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN 
    END     
    
    -- found the list
    IF @i_empty_list = 1 BEGIN
      -- clear it out
      DELETE FROM qse_searchresults
       WHERE listkey = @ListKey
      
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to clear out list: Error accessing qse_searchlist table (' + cast(@error_var AS VARCHAR) + ').'
        RETURN 
      END     
    END
  END  
  ELSE BEGIN 
    -- Generate new ListKey
    EXEC next_generic_key @UserID, @ListKey output, @o_error_code output, @o_error_desc output 
    
    -- Insert 'Recent' list into QSE_SEARCHLIST table for this user
    INSERT INTO qse_searchlist 
      (listkey, userkey, searchtypecode, searchitemcode, 
      listtypecode, listdesc, lastuserid, lastmaintdate, createdbyuserid)
    VALUES 
      (@ListKey, @i_userkey, @v_searchtypecode, @SearchItemCode,
      @v_listtypecode, @ListDesc, @UserID, getdate(), @UserID)
      
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to create list: Error accessing qse_searchlist table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN 
    END     
  END 

  ------------
  ExitHandler:
  ------------
  
  SET @o_listkey = @ListKey
  RETURN
GO

GRANT EXEC ON qtitle_get_newly_created_formats_listkey TO PUBLIC
GO
