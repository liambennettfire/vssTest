IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_available_filetypes')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_available_filetypes'
    DROP  Procedure  qutl_get_available_filetypes
  END

GO

PRINT 'Creating Procedure qutl_get_available_filetypes'
GO

CREATE PROCEDURE qutl_get_available_filetypes
 (@i_userkey  integer,
  @i_itemtype integer,
  @i_usageclass integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_available_filetypes
**  Desc: Returns a list of all available filetypes for a user
**
**  Auth: Alan Katzen
**  Date: 10/19/09
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowcatergoryid_var INT,
          @windowid_var INT,
          @windowtitle_var VARCHAR(100),
          @orglevel_access_filterkey_var INT,
          @v_securitystatustypekey TINYINT

  -- Userorglevelaccess filterkey on filterorglevel table
  SET @orglevel_access_filterkey_var = 7

  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get file types: Userid not setup on qsiusers table.'
    RETURN
  END 

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get file types: Userid is not a member of a security group.'
    RETURN
  END 

  -- Get window information
  SELECT @windowcatergoryid_var=windowcategoryid,@windowid_var=q.windowid,@windowtitle_var=windowtitle
    FROM qsiwindows q
   WHERE lower(q.windowname) = 'filelocations'

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get file types: Database Error accessing qsiwindows table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  IF @windowtitle_var IS NULL BEGIN
    SET @windowtitle_var = 'filetypecode'
  END
  
  SELECT @v_securitystatustypekey = securitystatustypekey
    FROM securitystatustype
   WHERE lower(tablename) = 'filelocation' 
     and lower(columnname) = 'filetypecode' 
     and gentableid = 354

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get file types: Database Error accessing securitystatustype table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  IF @v_securitystatustypekey > 0 BEGIN 
    SELECT g.*
      FROM gentables g
     WHERE g.tableid = 354
       and g.datacode in (SELECT datacode FROM dbo.qutl_get_gentable_itemtype_filtering(354,@i_itemtype,@i_usageclass))
       and g.datacode not in (SELECT securityobjectvalue 'filetypecode'     -- user override no access or read only rows
                                FROM securityobjects o,securityobjectsavailable a
                               WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
                                     a.windowid = @windowid_var AND
                                     o.userkey = @i_userkey  AND
                                     COALESCE(o.accessind,0) in (0,1) and
                                     o.securitystatustypekey = @v_securitystatustypekey 
                               UNION
                              -- security group no access or read only rows that have no user override of update
                              SELECT securityobjectvalue 'filetypecode'   
                                FROM securityobjects o,securityobjectsavailable a
                               WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
                                     a.windowid = @windowid_var AND
                                     o.securitygroupkey = @securitygroupkey_var AND
                                     COALESCE(o.accessind,0) in (0,1) and
                                     o.securitystatustypekey = @v_securitystatustypekey AND
                                     o.securityobjectvalue NOT IN (SELECT securityobjectvalue    
                                                                     FROM securityobjects o,securityobjectsavailable a
                                                                    WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
                                                                          a.windowid = @windowid_var AND
                                                                          o.userkey = @i_userkey  AND
                                                                          COALESCE(o.accessind,0) = 2  and
                                                                          o.securitystatustypekey = @v_securitystatustypekey))
    ORDER BY g.sortorder, g.datadesc
  END
  ELSE BEGIN
    SELECT g.*
      FROM gentables g
     WHERE g.tableid = 354
       and g.datacode in (SELECT datacode FROM dbo.qutl_get_gentable_itemtype_filtering(354,@i_itemtype,@i_usageclass))
    ORDER BY g.sortorder, g.datadesc
  END
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get file types: Database Error accessing securityobjects table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END   
GO

GRANT EXEC ON qutl_get_available_filetypes TO PUBLIC
GO




















