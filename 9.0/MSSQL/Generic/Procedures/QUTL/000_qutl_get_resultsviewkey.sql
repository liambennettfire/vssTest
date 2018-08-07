IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_resultsviewkey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_resultsviewkey]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_resultsviewkey]
 (@i_searchtypecode     integer,
  @i_userkey            integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @i_popupind           tinyint,
  @o_resultsviewkey     integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/*****************************************************************************************
**  Name: qutl_get_resultsviewkey
**  Desc: This stored procedure returns the default windowviewkey for a user
**        based on the criteria passed in.
**
**  Parameters:
**    searchtypecode - Search Type
**    userkey - userkey for userid accessing page
**    itemtypecode - itemtype for page - Pass 0 if not applicable
**    usageclasscode - usageclass page - Pass 0 if not applicable
**    popupind - pass 1 if results viewkey is for search popup, 0 for search page
**
**  Auth: Alan Katzen
**  Date: May 8, 2012
*****************************************************************************************/

DECLARE @error_var         INT,
        @rowcount_var      INT,
        @v_count           INT,
        @v_resultsviewkey  INT,
        @v_usageclasscode  INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_resultsviewkey = 0
  SET @v_resultsviewkey = 0
  SET @v_usageclasscode = COALESCE(@i_usageclasscode,0)
  
  --PRINT '@i_searchtypecode: ' + CONVERT(VARCHAR, @i_searchtypecode)
  --PRINT '@i_userkey: ' + CONVERT(VARCHAR, @i_userkey)
  --PRINT '@i_itemtypecode: ' + CONVERT(VARCHAR, @i_itemtypecode)
  --PRINT '@i_usageclasscode: ' + CONVERT(VARCHAR, @i_usageclasscode)
  
  -- Try qsiusersusageclass/qsiusersitemtype first to try to get the user's saved default search results viewkey  
  -- If usage class is passed, get the saved results viewkey for this user/itemtype/usageclass from qsiusersusageclass 
  IF @v_usageclasscode > 0
  BEGIN
    SELECT @v_count = COUNT(*) 
    FROM qsiusersusageclass
    WHERE itemtypecode = @i_itemtypecode
      AND COALESCE(usageclasscode,0) = @v_usageclasscode
      AND userkey = @i_userkey

    IF @v_count > 0
    BEGIN
      IF @i_popupind = 1
        SELECT @v_resultsviewkey = searchpopupresultsviewkey 
        FROM qsiusersusageclass
        WHERE itemtypecode = @i_itemtypecode
          AND COALESCE(usageclasscode,0) = @v_usageclasscode
          AND userkey = @i_userkey
      ELSE        
        SELECT @v_resultsviewkey = searchresultsviewkey 
        FROM qsiusersusageclass
        WHERE itemtypecode = @i_itemtypecode
          AND COALESCE(usageclasscode,0) = @v_usageclasscode
          AND userkey = @i_userkey
  
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load search results view: Database Error accessing qsiusersusageclass (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END     
    END
  END
  
  IF @v_resultsviewkey IS NULL
    SET @v_resultsviewkey = 0
  
  -- If no saved view exists for this user/itemtype/usageclass on qsiusersusageclass OR if no usageclass was passed,
  -- get the saved search results view for this user/itemtype from qsiusersitemtype
  IF @v_resultsviewkey = 0
  BEGIN
    SELECT @v_count = COUNT(*) 
    FROM qsiusersitemtype
    WHERE itemtypecode = @i_itemtypecode
      AND userkey = @i_userkey

    IF @v_count > 0
    BEGIN
      IF @i_popupind = 1
        SELECT @v_resultsviewkey = searchpopupresultsviewkey 
        FROM qsiusersitemtype 
        WHERE itemtypecode = @i_itemtypecode
          AND userkey = @i_userkey
      ELSE
        SELECT @v_resultsviewkey = searchresultsviewkey 
        FROM qsiusersitemtype
        WHERE itemtypecode = @i_itemtypecode
          AND userkey = @i_userkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load search results view: Database Error accessing qsiusersitemtype (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END     
    END
  END
  
  IF @v_resultsviewkey IS NULL
    SET @v_resultsviewkey = 0
      
  --PRINT 'saved resultsviewkey: ' + CONVERT(VARCHAR, @v_resultsviewkey)
  
  -- Since we didn't find user's SAVED search results view above, 
  -- try to get the results view for the passed criteria from qse_searchresultsview table
  IF @v_resultsviewkey = 0
  BEGIN
    SELECT @v_count = COUNT(*)
      FROM qse_searchresultsview
     WHERE searchtypecode = @i_searchtypecode AND
           itemtypecode = @i_itemtypecode AND
           usageclasscode = @i_usageclasscode AND
           userkey = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load search results view: Database Error accessing qse_searchresultsview (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END     

    IF @v_count > 0
    BEGIN
      SELECT @v_resultsviewkey = resultsviewkey
        FROM qse_searchresultsview
       WHERE searchtypecode = @i_searchtypecode AND
             itemtypecode = @i_itemtypecode AND
             usageclasscode = @i_usageclasscode AND
             userkey = @i_userkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load search results view: Database Error accessing qse_searchresultsview (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END     
    END
  END
  
  -- If there is no results view for this user, try default userkey (-1) for this usage class
  IF @v_resultsviewkey = 0
  BEGIN
    SELECT @v_count = COUNT(*)
      FROM qse_searchresultsview
     WHERE searchtypecode = @i_searchtypecode AND
           itemtypecode = @i_itemtypecode AND
           usageclasscode = @i_usageclasscode AND
           userkey = -1 AND
           defaultind = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load search results view: Database Error accessing qse_searchresultsview (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END     

    IF @v_count > 0
    BEGIN
      SELECT @v_resultsviewkey = resultsviewkey
        FROM qse_searchresultsview
       WHERE searchtypecode = @i_searchtypecode AND
             itemtypecode = @i_itemtypecode AND
             usageclasscode = @i_usageclasscode AND
             userkey = -1 AND
             defaultind = 1
             
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load search results view: Database Error accessing qse_searchresultsview (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END                  
    END
  END

  -- If still nothing found, try default userkey (-1) for this item type
  IF @v_resultsviewkey = 0
  BEGIN    
    SELECT @v_count = COUNT(*)
      FROM qse_searchresultsview
     WHERE searchtypecode = @i_searchtypecode AND
           itemtypecode = @i_itemtypecode AND
           usageclasscode = 0 AND
           userkey = -1 AND
           defaultind = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load search results view: Database Error accessing qse_searchresultsview (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END     

    IF @v_count > 0
    BEGIN
      SELECT @v_resultsviewkey = resultsviewkey
        FROM qse_searchresultsview
       WHERE searchtypecode = @i_searchtypecode AND
             itemtypecode = @i_itemtypecode AND
             usageclasscode = 0 AND
             userkey = -1 AND
             defaultind = 1
             
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load search results view: Database Error accessing qse_searchresultsview (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END                  
    END
  END    
     
  IF @v_resultsviewkey > 0 BEGIN
    SET @o_resultsviewkey = @v_resultsviewkey
  END
  
END
GO

GRANT EXEC on qutl_get_resultsviewkey TO PUBLIC
GO

