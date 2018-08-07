IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_gentable_object_security')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_gentable_object_security'
    DROP  Procedure  qutl_get_gentable_object_security
  END

GO

PRINT 'Creating Procedure qutl_get_gentable_object_security'
GO

CREATE PROCEDURE qutl_get_gentable_object_security
 (@i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_accesscode integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_gentable_object_security
**  Desc: 
**    Parameters:
**    Input              
**    ----------         
**    userkey - userkey for userid trying to access window
**    windowname - Name of Page to check security
**    tableid - tableid of gentable to check
**    accessind - retrieve rows that have this accesscode - pass -1 for all rows 
**                returned with their accesscode
**                
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Alan Katzen
**    Date: 6/22/10
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    06/07/18  Colman          Case 50971 - Implemented availsecurityobjectkey.firstprintingind support
*******************************************************************************/

  DECLARE @error_var    INT,
          @rowcount_var INT

  IF COALESCE(@i_tableid,0) = 0 BEGIN
    return
  END
  
  IF @i_accesscode >= 0 BEGIN
    SELECT @i_accesscode accesscode, g.*
      FROM gentables g
     WHERE g.tableid = @i_tableid
       AND dbo.qutl_check_gentable_value_security(@i_userkey,@i_windowname,@i_tableid,g.datacode,NULL) = @i_accesscode
  END
  ELSE BEGIN
    SELECT dbo.qutl_check_gentable_value_security(@i_userkey,@i_windowname,@i_tableid,g.datacode,NULL) accesscode, g.*
      FROM gentables g
     WHERE g.tableid = @i_tableid
  END
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get gentables values: Database Error accessing gentables table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

GO

GRANT EXEC ON qutl_get_gentable_object_security TO PUBLIC
GO
