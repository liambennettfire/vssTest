IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qse_get_default_searchresultsview_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qse_get_default_searchresultsview_info]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qse_get_default_searchresultsview_info]
 (@i_searchtype         integer,
  @i_userkey            integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @i_popupuseind        tinyint,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qse_get_default_searchresultsview_info
**  Desc: This stored procedure returns the default search results view info for a user
**        based on qsiusersusageclass table.
**
**  Parameters:
**    searchtype - type of search (tableid 442)
**    userkey - userkey for userid accessing page
**    itemtypecode - itemtype for search
**    usageclasscode - usageclass for search - Pass 0 if not applicable
**
**  Auth: Alan Katzen
**  Date: May 15, 2012
*******************************************************************************/

DECLARE @error_var         INT,
        @rowcount_var      INT,
        @v_usageclass      INT,
        @v_count           INT,
        @v_resultsviewkey  INT,
        @v_userid          VARCHAR(30),
        @v_usageclassdesc  VARCHAR(255)
  
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF COALESCE(@i_userkey,-1) < 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to find default results view: Invalid userkey.'
    RETURN
  END

  IF COALESCE(@i_itemtypecode,0) = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to find default results view: Invalid item type.'
    RETURN
  END
  
  SET @v_usageclass = COALESCE(@i_usageclasscode,0)
  SET @v_usageclassdesc = cast(@v_usageclass AS VARCHAR)
  IF @v_usageclass > 0 BEGIN
    SET @v_usageclassdesc = dbo.get_subgentables_desc(550, @i_itemtypecode, @v_usageclass, 'long')
  END
  
  SELECT @v_userid = userid
  FROM qsiusers
  WHERE userkey = @i_userkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to find default results view: Database Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END     
  
  IF @v_usageclass > 0
  BEGIN
    -- make sure qsiusersusageclass row exists for this user and passed item type/usage class
    SELECT @v_count = COUNT(*)
    FROM qsiusersusageclass
    WHERE userkey = @i_userkey AND itemtypecode = @i_itemtypecode AND usageclasscode = @v_usageclass

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find default results view: Database Error accessing qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END
    
    IF @v_count = 0
    BEGIN
      -- user may have been set up for all usageclasses for the itemtype 
      -- if that is the case, insert a row for the itemtype/usage class
      SELECT @v_count = COUNT(*)
      FROM qsiusersusageclass
      WHERE userkey = @i_userkey AND itemtypecode = @i_itemtypecode AND usageclasscode = 0

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to find default results view: Database Error accessing qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END
    
      IF @v_count > 0
      BEGIN    
        -- insert a row for the item/typeusage class 
        INSERT INTO qsiusersusageclass (userkey, itemtypecode, usageclasscode, lastuserid, lastmaintdate)
        VALUES (@i_userkey, @i_itemtypecode, @v_usageclass, @v_userid, getdate())

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var < 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to find default results view: Database Error inserting into qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
          RETURN
        END
      END
      ELSE BEGIN
        -- user does not have access to the usage class - return error
        SET @o_error_code = -99
        SET @o_error_desc = 'User does not have access to Item Type: ' + COALESCE(dbo.get_gentables_desc(550, @i_itemtypecode, 'long'),cast(@i_itemtypecode AS VARCHAR)) +
                            ' / Usage Class: ' +  @v_usageclassdesc + '.'
        RETURN
      END
    END
    
    IF @i_popupuseind = 1
      SELECT @v_resultsviewkey = searchpopupresultsviewkey
      FROM qsiusersusageclass
      WHERE userkey = @i_userkey AND 
        itemtypecode = @i_itemtypecode AND 
        usageclasscode = @v_usageclass
    ELSE    
      SELECT @v_resultsviewkey = searchresultsviewkey
      FROM qsiusersusageclass
      WHERE userkey = @i_userkey AND 
        itemtypecode = @i_itemtypecode AND 
        usageclasscode = @v_usageclass

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find default results view: Database Error accessing qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END
  END
  
  ELSE  --@v_usageclass=0 (ALL MY CLASSES)
  BEGIN
    -- check if qsiusersitemtype row exists for this user and passed item type
    SELECT @v_count = COUNT(*)
    FROM qsiusersitemtype
    WHERE userkey = @i_userkey AND itemtypecode = @i_itemtypecode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find default results view: Database Error accessing qsiusersitemtype table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END
    
    IF @v_count = 0
    BEGIN
      INSERT INTO qsiusersitemtype (userkey, itemtypecode, lastuserid, lastmaintdate)
      VALUES (@i_userkey, @i_itemtypecode, @v_userid, getdate())

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to find default results view: Database Error inserting into qsiusersitemtype table (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END
    END
    
    IF @i_popupuseind = 1
      SELECT @v_resultsviewkey = searchpopupresultsviewkey
      FROM qsiusersitemtype
      WHERE userkey = @i_userkey AND 
        itemtypecode = @i_itemtypecode
    ELSE
      SELECT @v_resultsviewkey = searchresultsviewkey
      FROM qsiusersitemtype
      WHERE userkey = @i_userkey AND 
        itemtypecode = @i_itemtypecode

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find default results view: Database Error accessing qsiusersitemtype table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END    
  END

  IF @v_resultsviewkey > 0 BEGIN
    SELECT srv.*
      FROM qse_searchresultsview srv
     WHERE srv.resultsviewkey = @v_resultsviewkey
  END

END
GO

GRANT EXEC on qse_get_default_searchresultsview_info TO PUBLIC
GO

