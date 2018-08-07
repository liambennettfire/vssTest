if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_user_orgsecurity') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_user_orgsecurity
GO

CREATE FUNCTION dbo.qutl_get_user_orgsecurity
(
  @i_userkey      integer,
  @i_orgentrykey   integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qutl_get_user_orgsecurity
**  Desc: Function returns the orglevel security access code for the given user
**        and orgentrykey.
**  Parameters:
**    Input              
**    ----------         
**    userkey - userkey for userid trying to access window
**    orgentrykey - orgentrykey at level to check security - Pass 0 if not applicable
**    
**    Output
**    -----------
**    accesscode - 0(No Access)/1(Read Only)/2(Update)
**
**  Auth: Uday A. Khisty
**  Date: April 27 2016
********************************************************************************************************
**  Change History
********************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  01/29/18  Colman    Case 49071 Performance
*******************************************************************************************************/

BEGIN
  DECLARE @AccessInd INT,
      @CheckCount INT
  
  -- Initialize accesscode to 0 - 'NoAccess'
  SET @AccessInd = 0

  SELECT @AccessInd = accessind
  FROM securityorglevel 
  WHERE userkey = @i_userkey AND 
      orgentrykey = @i_orgentrykey                           
  
  IF (@@ROWCOUNT = 0)
  BEGIN
    SELECT @AccessInd = accessind
    FROM securityorglevel 
    WHERE securitygroupkey IN (SELECT securitygroupkey FROM qsiusers WHERE userkey = @i_userkey) AND
        orgentrykey = @i_orgentrykey		          	          
	END
	
	RETURN @AccessInd
	
	-- NOTE: When NO orglevel security row was found for this orgentrykey (user OR group row),
	-- we assume 'No Access' and accesscode of 0 will be returned
  
END
GO

GRANT EXEC ON dbo.qutl_get_user_orgsecurity TO public
GO
