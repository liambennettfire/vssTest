IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_if_item_exists')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_if_item_exists'
    DROP  Procedure  qutl_check_if_item_exists
  END

GO

PRINT 'Creating Procedure qutl_check_if_item_exists'
GO

CREATE PROCEDURE qutl_check_if_item_exists
 (@i_tablename       varchar(100),
  @i_whereclause     varchar(2000),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_check_if_item_exists
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
**    tablename - Table Name of table to do count on - Required
**    whereclause - Where clause for select statement (what we should do the count on) - Required
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message or locked message - empty if Not Locked or Locked By This User already
**
**    Auth: Alan Katzen
**    Date: 4/22/04
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    
*******************************************************************************/

-- verify that all required values are filled in
  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists: tablename is empty.'
    RETURN
  END 

  IF @i_whereclause IS NULL OR ltrim(rtrim(@i_whereclause)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists: where clause is empty.'
    RETURN
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @SQLString_var NVARCHAR(4000),
          @SQLparams_var NVARCHAR(4000)

  
  SET @SQLString_var = N'SELECT count(*) numitems' +
                       ' FROM ' + @i_tablename +
                       ' WHERE ' + @i_whereclause

print @SQLString_var

  EXECUTE sp_executesql @SQLString_var, @SQLparams_var

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check if item exists on ' + @i_tablename + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  
  RETURN 
GO

GRANT EXEC ON qutl_check_if_item_exists TO PUBLIC
GO




















