IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_userlist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_userlist]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_userlist]
 (@b_contactFilter				bit,
  @i_currently_linked_userid	integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_userlist
**  Desc: This stored procedure returns a list of users from the qsiusers table.
**
**  Parameters:
**		b_contactfilter - Determines if users should be returned if they are 
**						  already set as a global contact.  If 1 then don't
**						  return users that are already linked to a contact.
**						  DO return the currently linked user though.
**
**  Auth: Lisa Cormier
**  Date: 21 April 2008
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  if ( @b_contactFilter = 0 ) -- false
  begin
    SELECT	CASE WHEN u.lastname IS NULL OR u.lastname='' 
				THEN
					CASE WHEN u.firstname IS NULL OR u.firstname='' 
						 THEN u.userid
						 ELSE u.firstname
					END
				ELSE LTRIM(u.firstname + ' ' + u.lastname)
			END AS username, 
			u.* 
    FROM qsiusers u
  end
  else -- true, filter out userids that are already linked as a contact but DON'T
	   -- filter out the currently linked user, we need to display that.
  begin
    SELECT	CASE WHEN u.lastname IS NULL OR u.lastname='' 
				THEN
					CASE WHEN u.firstname IS NULL OR u.firstname='' 
						 THEN u.userid
						 ELSE u.firstname
					END
				ELSE LTRIM(u.firstname + ' ' + u.lastname)
			END AS username, 
			u.* 
    FROM qsiusers u
    where u.userkey not in ( select distinct COALESCE(userid,0) from globalcontact 
							 where userid <> @i_currently_linked_userid )
  end

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing qsiusers table from qutl_get_userlist stored proc'  
  END 

GO

GRANT EXEC on qutl_get_userlist TO PUBLIC
GO

