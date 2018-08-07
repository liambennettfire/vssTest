IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_windowviewkey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_windowviewkey]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_windowviewkey]
 (@i_windowname         varchar(100),
  @i_userkey            integer,
  @i_orgentrykey        integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @o_windowviewkey      integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_windowviewkey
**  Desc: This stored procedure returns the default windowviewkey for a user
**        based on the criteria passed in.
**
**  Parameters:
**    windowname - Name of Page
**    userkey - userkey for userid accessing page
**    orgentrykey - orgentrykey at level for sections on page - Pass 0 if not applicable
**    itemtypecode - itemtype for page - Pass 0 if not applicable
**    usageclasscode - usageclass page - Pass 0 if not applicable
**
**  Auth: Alan Katzen
**  Date: May 6, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var         INT,
          @rowcount_var      INT,
          @v_windowid        INT,
          @v_count           INT,
          @v_windowviewkey   INT,
          @v_usageclasscode  INT

  SET @o_windowviewkey = 0
  SET @v_windowviewkey = 0
  SET @v_usageclasscode = COALESCE(@i_usageclasscode,0)
  
  SELECT @v_windowid = windowid
    FROM qsiwindows
   WHERE windowname = @i_windowname
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindows table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
   
  -- Find windowviewkey 
  IF @i_itemtypecode > 0 AND @i_userkey >= 0 BEGIN
    -- try qsiusersusageclass first - default windowviewkey for user within a usageclass
    SELECT @v_count = count(*) 
      FROM qsiusersusageclass uc
     WHERE uc.itemtypecode = @i_itemtypecode
       AND COALESCE(uc.usageclasscode,0) = COALESCE(@i_usageclasscode,0)
       AND uc.userkey = @i_userkey
       AND uc.summarywindowviewkey > 0

    IF @v_count > 0 BEGIN
      -- get the row with the usage class filled in first by sorting descending 
      -- (maybe a row for all usage classes under the itemtype)
      SELECT @v_windowviewkey = uc.summarywindowviewkey 
        FROM qsiusersusageclass uc
       WHERE uc.itemtypecode = @i_itemtypecode
         AND COALESCE(uc.usageclasscode,0) = COALESCE(@i_usageclasscode,0)
         AND uc.userkey = @i_userkey
         AND uc.summarywindowviewkey > 0
    ORDER BY COALESCE(uc.usageclasscode,0) desc 
    
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiusersusageclass table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END     
    END
  END
  ELSE IF COALESCE(@i_itemtypecode,0) = 0 AND @i_userkey >= 0 AND lower(@i_windowname) = 'home' BEGIN
    -- for now itemtype = 0 is assumed to be home page
    -- try qsiusers first - default windowviewkey for user
    SELECT @v_count = count(*) 
      FROM qsiusers u
     WHERE u.userkey = @i_userkey
       AND u.homewindowviewkey > 0

    IF @v_count > 0 BEGIN
      -- get the row for the user
      SELECT @v_windowviewkey = u.homewindowviewkey 
        FROM qsiusers u
       WHERE u.userkey = @i_userkey
         AND u.homewindowviewkey > 0
    
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiusers table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END     
    END
  END
  
  IF @v_windowviewkey = 0 BEGIN   
    -- look for default view for itemtype/usageclass for the window
    SELECT @v_count = count(*) 
      FROM qsiwindowview wv 
     WHERE wv.itemtypecode = @i_itemtypecode
       AND COALESCE(wv.usageclasscode,0) = @v_usageclasscode
       AND wv.defaultind = 1
       AND wv.userkey = -1
       AND wv.qsiwindowviewkey in (select qsiwindowviewkey from qsiconfigdetail
                                    where configobjectkey in (select configobjectkey from qsiconfigobjects
                                                               where windowid in (select windowid from qsiwindows
                                                                                   where lower(windowname) = lower(@i_windowname))))
    IF @v_count > 0 BEGIN
      SELECT @v_windowviewkey = wv.qsiwindowviewkey 
        FROM qsiwindowview wv 
       WHERE wv.itemtypecode = @i_itemtypecode
         AND COALESCE(wv.usageclasscode,0) = @v_usageclasscode
         AND wv.defaultind = 1
         AND wv.userkey = -1
         AND wv.qsiwindowviewkey in (select qsiwindowviewkey from qsiconfigdetail
                                      where configobjectkey in (select configobjectkey from qsiconfigobjects
                                                                 where windowid in (select windowid from qsiwindows
                                                                                     where lower(windowname) = lower(@i_windowname))))
         
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindowview table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END     
    END
  END
  
--  IF @v_windowviewkey = 0 BEGIN
--    -- not found - keep looking
--  END
 
  IF @v_windowviewkey > 0 BEGIN
    SET @o_windowviewkey = @v_windowviewkey
  END 
GO

GRANT EXEC on qutl_get_windowviewkey TO PUBLIC
GO

