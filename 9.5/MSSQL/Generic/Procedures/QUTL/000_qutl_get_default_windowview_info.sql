IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_default_windowview_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_default_windowview_info]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_default_windowview_info]
 (@i_userkey            integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_default_windowview_info
**  Desc: This stored procedure returns the default windowview info for a user
**        based on qsiusersusageclass table.
**
**  Parameters:
**    userkey - userkey for userid accessing page
**    itemtypecode - itemtype for page
**    usageclasscode - usageclass page - Pass 0 if not applicable
**
**  Auth: Alan Katzen
**  Date: May 20, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var         INT,
          @rowcount_var      INT,
          @v_usageclass      INT,
          @v_count           INT,
          @v_windowviewkey   INT,
          @v_userid          VARCHAR(30),
          @v_usageclassdesc  VARCHAR(255)
  
  IF COALESCE(@i_userkey,-1) < 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to find default window view: Invalid userkey.'
    RETURN
  END

  IF COALESCE(@i_itemtypecode,0) = 0 BEGIN
    -- itemtype 0 is assumed to be home page for now
    SELECT @v_windowviewkey = homewindowviewkey
      FROM qsiusers
     WHERE userkey = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find default window view: Database Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END     
  END
  ELSE BEGIN
    SET @v_usageclass = COALESCE(@i_usageclasscode,0)
    SET @v_usageclassdesc = cast(@v_usageclass AS VARCHAR)
    IF @v_usageclass > 0 BEGIN
      SET @v_usageclassdesc = dbo.get_subgentables_desc(550, @i_itemtypecode, @v_usageclass, 'long')
    END
    
    SET @v_count = 0
    
    -- make sure qsiusersusageclass row exists
    IF @v_usageclass > 0 BEGIN
      SELECT @v_count = count(*)
        FROM qsiusersusageclass
       WHERE userkey = @i_userkey
         AND itemtypecode = @i_itemtypecode
         AND usageclasscode = @v_usageclass

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to find default window view: Database Error accessing qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END
      
      IF @v_count = 0 BEGIN
        -- user may have been setup for all usageclasses for the itemtype 
        -- if that is the case insert a row for the item/typeusage class
        SELECT @v_count = count(*)
          FROM qsiusersusageclass
         WHERE userkey = @i_userkey
           AND itemtypecode = @i_itemtypecode
           AND usageclasscode = 0

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var < 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to find default window view: Database Error accessing qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
          RETURN
        END
        
        IF @v_count > 0 BEGIN
          SELECT @v_userid = userid
            FROM qsiusers
           WHERE userkey = @i_userkey

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var < 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to find default window view: Database Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
          END     
        
          -- insert a row for the item/typeusage class 
          INSERT INTO qsiusersusageclass (userkey,itemtypecode,usageclasscode,lastuserid,lastmaintdate)
          VALUES (@i_userkey,@i_itemtypecode,@v_usageclass,@v_userid,getdate())

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var < 0 BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Unable to find default window view: Database Error inserting into qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
          END      
        END
        ELSE BEGIN
          -- user does not have access to the item type - return error
          SET @o_error_code = -99
          SET @o_error_desc = 'User does not have access to Item Type: ' + COALESCE(dbo.get_gentables_desc(550, @i_itemtypecode, 'long'),cast(@i_itemtypecode AS VARCHAR)) +
                              ' / Usage Class: ' +  @v_usageclassdesc + '.'
          RETURN
        END
      END
    END
    
    SELECT @v_windowviewkey = summarywindowviewkey
      FROM qsiusersusageclass
     WHERE userkey = @i_userkey
       AND itemtypecode = @i_itemtypecode
       AND usageclasscode = @v_usageclass

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to find default window view: Database Error accessing qsiusersusageclass table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END     
  END
  
  IF @v_windowviewkey > 0 BEGIN
    SELECT wv.*
      FROM qsiwindowview wv
     WHERE wv.qsiwindowviewkey = @v_windowviewkey
  END
  
GO

GRANT EXEC on qutl_get_default_windowview_info TO PUBLIC
GO

