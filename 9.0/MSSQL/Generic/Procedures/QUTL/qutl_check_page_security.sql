IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_page_security')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_page_security'
    DROP  Procedure  qutl_check_page_security
  END

GO

PRINT 'Creating Procedure qutl_check_page_security'
GO

CREATE PROCEDURE qutl_check_page_security
 (@i_userkey  integer,
  @i_windowname varchar(100),
  @i_orgentrykey integer,
  @o_accesscode  integer output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_check_page_security
**  Desc: 
**
**              
**    Return values: 
**
**    Called by:   
**              
**    Parameters:
**    Input              
**    ----------         
**    userkey - userkey for userid trying to access window
**    windowname - Name of Page to check security
**    orgentrykey - orgentrykey at level to check security - Pass 0 if not applicable
**    
**    Output
**    -----------
**    accesscode - 0(No Access)/1(Read Only)/2(Update)
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Alan Katzen
**    Date: 2/20/04
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_accesscode = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @accessind_var INT,
          @orglevel_accessind_var INT,
          @orglevelsecurityind_var CHAR(1),
          @orgentrydesc_var VARCHAR(50),
          @windowcatergoryid_var INT,
          @windowid_var INT,
          @windowtitle_var VARCHAR(100),
          @securitystatustypekey_var INT,   
          @securityobjectvalue_var INT,   
          @object_accessind_var INT,   
          @firstprintingind_var CHAR(1),   
          @availobjectid_var VARCHAR(50),   
          @availobjectname_var VARCHAR(50),   
          @availobjectdesc_var VARCHAR(50),   
          @menuitemid_var VARCHAR(50),   
          @menuitemname_var VARCHAR(50),   
          @menuitemdesc_var VARCHAR(50),
          @orglevel_access_filterkey_var INT,
          @v_objectlist_xml varchar(4000),
          @v_detail_accesscode INT

  -- Userorglevelaccess filterkey on filterorglevel table
  SET @orglevel_access_filterkey_var = 7

  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey;

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check security: Userid not setup on qsiusers table.'
    RETURN
  END 

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check security: Userid is not a member of a security group.'
    RETURN
  END 

  -- Page/Window Security
  -- Check security for user override row
  SELECT @orglevelsecurityind_var=q.orglevelsecurityind,@accessind_var=s.accessind,@windowcatergoryid_var=windowcategoryid,
         @windowid_var=q.windowid,@windowtitle_var=windowtitle
    FROM qsiwindows q, securitywindows s
   WHERE q.windowid = s.windowid AND
         q.windowname = @i_windowname AND
         userkey = @i_userkey;

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check security: Database Error accessing securitywindows table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  IF @rowcount_var = 0 BEGIN
    -- No User override row, check group security
    SELECT @orglevelsecurityind_var=q.orglevelsecurityind,@accessind_var=s.accessind,@windowcatergoryid_var=windowcategoryid,
           @windowid_var=q.windowid,@windowtitle_var=windowtitle
      FROM qsiwindows q, securitywindows s
     WHERE q.windowid = s.windowid AND
           q.windowname = @i_windowname AND
           securitygroupkey = @securitygroupkey_var;

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
      SET @o_error_code = -1
      SET @o_accesscode = 0
      IF @rowcount_var = 0 BEGIN 
        SET @o_error_desc = 'Unable to check security: ' + @userid_var + ' has no security setup for ' + @i_windowname + '.'
      END
      ELSE BEGIN
        SET @o_error_desc = 'Unable to check security: Database Error accessing securitywindows table (' + cast(@error_var AS VARCHAR) + ').'
      END 
      RETURN
    END
  END 
  
  -- Some pages/windows should always be accessible (like a home page) - just return update access
  IF @windowcatergoryid_var=6 OR @windowcatergoryid_var=26 OR @windowcatergoryid_var=40 OR 
     @windowcatergoryid_var=104 OR @windowcatergoryid_var = 120 BEGIN
    SET @o_error_code = 0
    SET @o_accesscode = 2
    SET @o_error_desc = ''
    RETURN
  END

  IF @windowtitle_var IS NULL
    SET @windowtitle_var = @i_windowname

  -- IF "No Access" to window, no more to do
  IF @accessind_var is NULL OR @accessind_var <= 0 OR @accessind_var > 2 BEGIN
    SET @o_error_code = 0
    SET @o_accesscode = 0
    SET @o_error_desc = 'Access Denied: ' + @userid_var + ' does not have access to ' + @windowtitle_var + '.'
    RETURN
  END 

  -- User has update or read only access for window
  -- Check if we need to look at orglevel security
  IF @orglevelsecurityind_var IS NULL OR @orglevelsecurityind_var = 'N' OR @i_orgentrykey IS NULL OR @i_orgentrykey = 0 BEGIN
    -- Page doesn't use orglevel security so just return
    SET @o_error_code = 0
    SET @o_accesscode = @accessind_var
    SET @o_error_desc = ''
    --RETURN
    goto DetailSecurityCheck
  END 

  -- Orglevel Security
  -- Get orgentrydesc
  SELECT @orgentrydesc_var=orgentrydesc
    FROM orgentry o,filterorglevel f
   WHERE o.orglevelkey = f.filterorglevelkey AND
         orgentrykey = @i_orgentrykey AND
         filterkey = @orglevel_access_filterkey_var;

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_accesscode = 0
    SET @o_error_code = -1
    IF @rowcount_var = 0 BEGIN 
      SET @o_error_desc = 'Unable to find orgentry description on orgentry table (' + cast(@i_orgentrykey AS VARCHAR) + ').'
    END
    ELSE BEGIN
      SET @o_error_desc = 'Unable to check security: Database Error accessing orgentry table (' + cast(@error_var AS VARCHAR) + ').'
    END 
    RETURN
  END
  IF @orgentrydesc_var IS NULL
    SET @orgentrydesc_var = ''

  -- Check security for user override row
  SELECT @orglevel_accessind_var=accessind
    FROM securityorglevel s
   WHERE orgentrykey = @i_orgentrykey AND
         userkey = @i_userkey;

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check organizational security: Database Error accessing securityorglevel table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  IF @rowcount_var = 0 BEGIN
    -- No User override row, check group security
    SELECT @orglevel_accessind_var=accessind
      FROM securityorglevel
     WHERE orgentrykey = @i_orgentrykey AND
           securitygroupkey = @securitygroupkey_var;

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
      SET @o_error_code = -1
      SET @o_accesscode = 0
      IF @rowcount_var = 0 BEGIN
        -- Page was expecting security, but not setup
        SET @o_error_desc = 'Unable to check organizational security: ' + @userid_var + ' has no security setup for ' + @orgentrydesc_var + '.'
      END
      ELSE BEGIN
        SET @o_error_desc = 'Unable to check organizational security: Database Error accessing securityorglevel table (' + cast(@error_var AS VARCHAR) + ').'
      END 
      RETURN
    END
  END 

  -- "No Access" for orgentry takes precedence 
  IF @orglevel_accessind_var is NULL OR @orglevel_accessind_var <= 0 OR @orglevel_accessind_var > 2 BEGIN
    SET @o_error_code = 0
    SET @o_accesscode = 0
    SET @o_error_desc = 'Access Denied: ' + @userid_var + ' does not have access to ' + @windowtitle_var + '.'
    RETURN
  END 

  -- Neither has "No Access" Security - If either one has "Read Only", return "Read Only", otherwise return "Update"
  IF @accessind_var = 1 OR @orglevel_accessind_var = 1 BEGIN
    -- Read Only
    SET @o_accesscode = 1
  END
  ELSE BEGIN
    -- Update
    SET @o_accesscode = 2    
  END

  DetailSecurityCheck:
  -- Page Level Security can be set at the detail level as well (choose "ALL" from dropdown)    
  IF @o_accesscode = 1 OR @o_accesscode = 2 BEGIN
    exec dbo.qutl_check_page_object_security @i_userkey,@i_windowname,0,0,0,@v_detail_accesscode output,
                                             @v_objectlist_xml output,@o_error_code output,@o_error_desc output
    
    IF @o_error_code < 0 BEGIN
      -- return error message from stored proc
      SET @o_accesscode = 0
      RETURN
    END
    
    IF @v_detail_accesscode = 0 BEGIN
      SET @o_accesscode = 0
    END 
    ELSE IF @v_detail_accesscode = 1 AND @o_accesscode = 2 BEGIN
      SET @o_accesscode = 1
    END
  END
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  RETURN 
GO

GRANT EXEC ON qutl_check_page_security TO PUBLIC
GO




















