if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_recent_contacts') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_recent_contacts
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_recent_contacts
 (@i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_recent_contacts
**  Desc: This stored procedure returns all contact information
**        from the corecontact table for the user's most recently 
**        accessed contacts.
**              
**  Auth: Alan Katzen
**  Date: 28 May 2004  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT c.* , dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate
    FROM corecontactinfo c, 
         qse_searchlist l, 
         qse_searchresults r
   WHERE c.contactkey = r.key1 and 
         r.listkey = l.listkey and
         l.searchtypecode = 8 and 
         l.listtypecode = 6 and
         l.userkey = @i_userkey 
  ORDER BY r.lastuse desc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error looking for recent contacts: userkey = ' + cast(@i_userkey AS VARCHAR) 
  END
GO

GRANT EXEC ON qutl_get_recent_contacts TO PUBLIC
GO


