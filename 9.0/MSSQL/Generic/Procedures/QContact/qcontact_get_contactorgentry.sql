if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contactorgentry') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_contactorgentry
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_contactorgentry
 (@i_contactkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_contactorgentry
**  Desc: This stored procedure returns all organizational levels
**        for a global contact, regardless if they are filled in or not. 
**
**    Auth: Alan Katzen
**    Date: 15 May 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT o.*, go.*, dbo.qutl_get_orgentrydesc(go.orglevelkey,go.orgentrykey,'F') orgentrydesc
  FROM orglevel o 
    LEFT OUTER JOIN globalcontactorgentry go ON o.orglevelkey = go.orglevelkey AND go.globalcontactkey = @i_contactkey
  ORDER BY o.orglevelkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on globalcontactorgentry (' + cast(@error_var AS VARCHAR) + '): globalcontactkey = ' + cast(@i_contactkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qcontact_get_contactorgentry TO PUBLIC
GO



