if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_userprimaryorgentry') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_userprimaryorgentry
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_userprimaryorgentry
 (@i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qutl_get_userprimaryorgentry
**  Desc: This stored procedure returns all organizational levels
**        for a user, regardless if they are filled in or not. 
**
**  Auth: Alan Katzen
**  ate: 9 June 2004
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
**  02/22/2016   UK          Case 36517 - TMM contacts error
*****************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT o.*, p.*, dbo.qutl_get_orgentrydesc(p.orglevelkey,p.orgentrykey,'F') orgentrydesc
  FROM orglevel o LEFT OUTER JOIN userprimaryorgentry p ON o.orglevelkey = p.orglevelkey AND p.userkey = @i_userkey 
  ORDER BY o.orglevelkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing userprimaryorgentry table: userkey = ' + cast(@i_userkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qutl_get_userprimaryorgentry TO PUBLIC
GO
