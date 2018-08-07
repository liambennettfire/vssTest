IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_user_orgsecurity')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_user_orgsecurity'
    DROP  Procedure  qutl_check_user_orgsecurity
  END

GO

PRINT 'Creating Procedure qutl_check_user_orgsecurity'
GO

CREATE PROCEDURE qutl_check_user_orgsecurity
 (@i_userkey  integer,
  @i_orgentrykey integer,
  @o_accesscode  integer output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_check_user_orgsecurity
**  Desc: Procedure returns the orglevel security access code for the given user
**        and orgentrykey.
**
**  Called by:   qse_search_request (orglevel security for searches)
**              
**  Parameters:
**    Input              
**    ----------         
**    userkey - userkey for userid trying to access window
**    orgentrykey - orgentrykey at level to check security - Pass 0 if not applicable
**    
**    Output
**    -----------
**    accesscode - 0(No Access)/1(Read Only)/2(Update)
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Kate Wiewiora
**    Date: 9/29/04
** 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  04/27/2016   UK          Case 37340
*******************************************************************************/

BEGIN

  DECLARE @AccessInd INT,
      @CheckCount INT
  
  -- Initialize accesscode to 0 - 'NoAccess'
  SET @AccessInd = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

	
  SELECT @o_accesscode = dbo.qutl_get_user_orgsecurity(@i_userkey, @i_orgentrykey)
	
	-- NOTE: When NO orglevel security row was found for this orgentrykey (user OR group row),
	-- we assume 'No Access' and accesscode of 0 will be returned

END
GO

GRANT EXEC ON qutl_check_user_orgsecurity TO PUBLIC
GO




















