IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qrpt_copy_list_to_rpt_table')
  BEGIN
    PRINT 'Dropping Procedure qrpt_copy_list_to_rpt_table'
    DROP  Procedure  qrpt_copy_list_to_rpt_table
  END

GO

PRINT 'Creating Procedure qrpt_copy_list_to_rpt_table'
GO

CREATE PROCEDURE qrpt_copy_list_to_rpt_table
 (@i_listkey  integer,
  @i_userkey  integer,
  @o_instancekey  integer output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/********************************************************************************************
**  Name: qrpt_copy_list_to_rpt_table
**  Desc: This procedure copies search list results to report table qsrpt_instance_item.
**
**    Parameters:
**    Input              
**    ----------         
**    listkey - listkey of list to copy keys from
**    userkey - userkey of current user
**    searchtype - type of search that produced saved list
**    
**    Output
**    -----------
**    instancekey - new report instancekey
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Alan Katzen
**    Date: 7/11/04
********************************************************************************************/

  SET @o_instancekey = -1
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @instancekey_var INT,
          @searchtype_var INT,
          @key1_var INT,
          @key2_var INT,
          @key3_var INT,
          @SQLString_var NVARCHAR(4000),
          @count_var INT

  SET @count_var = 0

  -- verify inputs
  IF @i_listkey IS NULL OR @i_listkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to generate report: listkey is empty.'
    RETURN
  END 

  BEGIN TRANSACTION

  -- "generate" new instancekey
  SELECT @instancekey_var = max(instancekey) + 1
    FROM qsrpt_instance_item;

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    ROLLBACK
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access qsrpt_instance_item table:  Could not generate new instancekey.'
    RETURN
  END 

  IF @instancekey_var is null OR @instancekey_var = 0 BEGIN
    SET @instancekey_var = 1
  END

  -- get all keys for the list
  DECLARE searchresults_cursor CURSOR FOR
   SELECT key1, key2, key3   
     FROM qse_searchresults r
    WHERE r.listkey = @i_listkey 

  OPEN searchresults_cursor

  FETCH NEXT FROM searchresults_cursor INTO @key1_var, @key2_var, @key3_var

  WHILE @@FETCH_STATUS = 0 BEGIN
    SET @count_var = @count_var + 1

    INSERT INTO qsrpt_instance_item 
      (instancekey, userkey, sortorder, key1, key2, key3, key4, key5, lastuserid, lastmaintdate)
    VALUES
      (@instancekey_var, @i_userkey, @count_var, @key1_var, @key2_var, @key3_var, 0, 0, 'COPY FROM LIST PROC', getdate())

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
      ROLLBACK
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to insert rows to qsrpt_instance_item (' + cast(@error_var AS VARCHAR) + ').'
      CLOSE searchresults_cursor
      DEALLOCATE searchresults_cursor
      RETURN
    END 

    fetchnext:
    FETCH NEXT FROM searchresults_cursor INTO @key1_var, @key2_var, @key3_var
  END  --while

  CLOSE searchresults_cursor
  DEALLOCATE searchresults_cursor
  
  COMMIT

  IF @count_var = 0 BEGIN
    -- list was empty
    SET @o_instancekey = 0
  END
  ELSE BEGIN
    SET @o_instancekey = @instancekey_var
  END

  RETURN 
GO

GRANT EXEC ON qrpt_copy_list_to_rpt_table TO PUBLIC
GO




















