IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_remove_from_list')
BEGIN
  PRINT 'Dropping Procedure qse_remove_from_list'
  DROP PROCEDURE  qse_remove_from_list
END
GO

PRINT 'Creating Procedure qse_remove_from_list'
GO

CREATE PROCEDURE qse_remove_from_list
 (@i_ListKey  INT,
  @i_Key1			INT,
  @i_Key2			INT,
  @i_UserID   VARCHAR(30),
  @o_error_code			INT OUT,
  @o_error_desc			VARCHAR(2000) OUT)
AS

BEGIN
  DECLARE 
    @v_sqlstring  NVARCHAR(4000),
    @v_PrivateInd TINYINT,
    @error_var    INT,
    @rowcount_var INT
        
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET @i_Key1 = COALESCE(@i_Key1, 0)
  SET @i_Key2 = COALESCE(@i_Key2, 0)
    
  SET @v_sqlstring = 'DELETE FROM qse_searchresults
    WHERE listkey=' + CAST(@i_ListKey AS VARCHAR)
    
  IF @i_Key1 > 0
    SET @v_sqlstring = @v_sqlstring + ' AND key1 = ' + CAST(@i_Key1 AS VARCHAR)    
  
  IF @i_Key2 > 0
    SET @v_sqlstring = @v_sqlstring + ' AND key2 = ' + CAST(@i_Key2 AS VARCHAR)
  
  -- Execute the full sqlstring
  EXECUTE sp_executesql @v_sqlstring
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'unable to remove from list: listkey = ' + cast(@i_ListKey AS VARCHAR) + 
      ' / key1 = ' + cast(COALESCE(@i_Key1,0) AS VARCHAR) +
      ' / key2 = ' + cast(COALESCE(@i_Key2,0) AS VARCHAR)
    RETURN
  END
  
  
  -- Check the private status of the primary list.
  -- NOTE: If list is private after the REMOVE, this procedure will remove the list 
  -- from any existing lists of lists for users other than the list owner 
  -- and people on his/her private team.
  EXEC qse_check_private_status @i_ListKey, @v_PrivateInd OUTPUT, 
    @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  -- Exit if error was returned from stored procedure
  IF @o_error_code < 0 
    RETURN
      
  -- Set timestamp and private indicator on the primary list just modified above
  SET @v_sqlstring = N'UPDATE qse_searchlist SET lastuserid=''' + @i_UserID + ''', 
    lastmaintdate=getdate(), privateind=' + CONVERT(VARCHAR, @v_PrivateInd) +
    ' WHERE listkey = ' + CONVERT(VARCHAR, @i_ListKey)
    
  EXECUTE sp_executesql @v_sqlstring
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not set timestamp and private indicator for listkey = ' + cast(@i_ListKey AS VARCHAR) + '.'
  END
    
END
GO

GRANT EXEC ON qse_remove_from_list TO PUBLIC
GO
