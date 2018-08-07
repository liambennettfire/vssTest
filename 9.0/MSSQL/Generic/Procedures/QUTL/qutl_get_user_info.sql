if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_user_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_user_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_user_info
 (@i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_user_info
**  Desc: This stored procedure returns all user information.
**
**  Auth: Alan Katzen
**  Date: 9 June 2004
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  9-25-07 KW  Return User Name
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT
  CASE
    WHEN u.lastname IS NULL OR u.lastname='' THEN
      CASE
        WHEN u.firstname IS NULL OR u.firstname='' THEN u.userid
        ELSE u.firstname
      END
    ELSE LTRIM(u.firstname + ' ' + u.lastname)
  END AS username,
  dbo.qutl_get_dateformatcode(u.userid) AS dateformatcodevalue,
  dbo.qutl_get_culturecode(u.userid) AS culturecodevalue,
  (SELECT gentext1 FROM gentables_ext WHERE tableid = 607 AND datacode = dbo.qutl_get_dateformatcode(u.userid)) AS internaldotnetdateformat,
  (SELECT s.date_format FROM sys.dm_exec_sessions s where s.session_id = @@SPID) SQLSessionDateFormat,   
  (SELECT s.language FROM sys.dm_exec_sessions s where s.session_id = @@SPID) SQLSessionLanguage,
  u.* 
  FROM qsiusers u
  WHERE u.userkey = @i_userkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing qsiusers table: userkey = ' + cast(@i_userkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qutl_get_user_info TO PUBLIC
GO


