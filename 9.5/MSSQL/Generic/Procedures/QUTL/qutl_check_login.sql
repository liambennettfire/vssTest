IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_login')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_login'
    DROP  Procedure  qutl_check_login
  END

GO

PRINT 'Creating Procedure qutl_check_login'
GO

CREATE PROCEDURE qutl_check_login
 (@i_userid       varchar(30),
  @o_first_name   varchar(75)   output,
  @o_last_name    varchar(75)   output,
  @o_user_key     integer       output,
  @o_error_code   integer       output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_check_login
**  Desc: 
**
**              
**    Return values:
** 
**    Called by:   
**              
**    Parameters:
**    Input              Output
**    ----------              -----------
**
**    Auth: 
**    Date: 
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = -1
  SET @o_error_desc = 'Did not complete processing.'
  SET @o_user_key = 0
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @securitygroupkey_var INT

  SELECT @o_first_name=firstname, @o_last_name=lastname, @o_user_key=userkey, @securitygroupkey_var=securitygroupkey
    FROM qsiusers
    where UPPER(userid) = UPPER(@i_userid);

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: userid = ' + @i_userid
    RETURN
  END 
  
  SELECT @rowcount_var=count(*)
    FROM qsiwindows q, securitywindows s
    WHERE q.windowid = s.windowid AND
         userkey = @o_user_key;

  SELECT @error_var = @@ERROR
  IF @error_var < 0 BEGIN
    SET @o_error_code = @error_var
    SET @o_error_desc = 'Unable to check security: Database Error accessing securitywindows table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  IF @rowcount_var = 0 BEGIN
    -- No User override row, check group security
    SELECT @rowcount_var=count(*)
      FROM qsiwindows q, securitywindows s
     WHERE q.windowid = s.windowid AND
           securitygroupkey = @securitygroupkey_var;
           
    SELECT @error_var = @@ERROR
  END

  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'No security found for  groupkey = ' + @securitygroupkey_var
    RETURN
  END
  ELSE BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'Login ok for user: ' + @i_userid
  END 
  
GO

GRANT EXEC ON qutl_check_login TO PUBLIC

GO
