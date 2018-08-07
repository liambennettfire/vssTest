IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_append_to_list')
BEGIN
  PRINT 'Dropping Procedure qse_append_to_list'
  DROP  Procedure  qse_append_to_list
END
GO

PRINT 'Creating Procedure qse_append_to_list'
GO

CREATE PROCEDURE qse_append_to_list
 (@i_primary_listkey  INT,
  @i_other_listkey    INT,
  @i_userid       VARCHAR(30),
  @i_appendall    TINYINT,
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT)
AS

/******************************************************************************
**  Name: qse_append_to_list
**
**  primary_listkey - Key of List being appended to - Required
**  other_listkey - Key of List to append from - Required
**
**  Auth: Alan Katzen
**  Date: 7/31/06
**
**  10/18/06 - KW - Private lists functionality.
**  08/23/06 - KW - Append All/Append Selected functionality.
*******************************************************************************/
BEGIN
  DECLARE
    @error_var    INT,
    @rowcount_var INT,
    @errormsg_var VARCHAR(2000),
    @key1_var     INT,
    @key2_var     INT,
    @count_var    INT,
    @v_sqlstring  NVARCHAR(4000),
    @v_PrivateInd TINYINT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- verify primary listkey is filled in
  IF @i_primary_listkey IS NULL OR @i_primary_listkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to append to list: primary_listkey is empty.'
    RETURN
  END 

  -- verify other listkey is filled in
  IF @i_other_listkey IS NULL OR @i_other_listkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to append to list: other_listkey is empty.'
    RETURN
  END 

  IF @i_appendall = 1 --Append all items in list
    DECLARE other_list_cur CURSOR FOR 
      SELECT key1, COALESCE(key2,0)
      FROM qse_searchresults
      WHERE listkey = @i_other_listkey
      ORDER BY key1, key2
  ELSE      --Append only the selected items in list
    DECLARE other_list_cur CURSOR FOR 
      SELECT key1, COALESCE(key2,0)
      FROM qse_searchresults
      WHERE listkey = @i_other_listkey AND selectedind = 1
      ORDER BY key1, key2  

  OPEN other_list_cur 
  FETCH other_list_cur INTO @key1_var, @key2_var 

  WHILE @@fetch_status = 0
  BEGIN
  
    SELECT @count_var = count(*)
    FROM qse_searchresults
    WHERE listkey = @i_primary_listkey AND
        key1 = @key1_var AND
        COALESCE(key2, 0) = COALESCE(@key2_var, 0)

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to append to list: Error accessing qse_searchresults table (' + cast(@error_var AS VARCHAR) + ').'
      CLOSE other_list_cur 
      DEALLOCATE other_list_cur
      RETURN 
    END 

    -- append key1/key2 to list
    IF @count_var <= 0 BEGIN      
      INSERT INTO qse_searchresults (listkey, key1, key2)
      VALUES (@i_primary_listkey, @key1_var, @key2_var)

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to append to list: Error inserting into qse_searchresults table (' + cast(@error_var AS VARCHAR) + ').'
        CLOSE other_list_cur 
        DEALLOCATE other_list_cur
        RETURN
      END 
    END

    FETCH other_list_cur INTO @key1_var, @key2_var 
  END
  
  CLOSE other_list_cur 
  DEALLOCATE other_list_cur
  
  
  -- Reset selected indicator to 0 on the temp append list
  UPDATE qse_searchresults
  SET selectedind = 0
  WHERE listkey = @i_other_listkey AND selectedind = 1
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not reset selectedind for listkey = ' + cast(@i_other_listkey AS VARCHAR) + '.'
  END  
  
  
  -- Check the private status of the primary list.
  -- NOTE: If list is private after the APPEND, this procedure will remove it 
  -- from any existing lists of lists for users other than the list owner 
  -- and people on his/her private team.
  EXEC qse_check_private_status @i_primary_listkey, @v_PrivateInd OUTPUT, 
    @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  -- Exit if error was returned from stored procedure
  IF @o_error_code < 0 
    RETURN
      
  -- Set timestamp and private indicator on the primary list just modified above
  SET @v_sqlstring = N'UPDATE qse_searchlist SET lastuserid=''' + @i_userid + ''', 
    lastmaintdate=getdate(), privateind=' + CONVERT(VARCHAR, @v_PrivateInd) +
    ' WHERE listkey = ' + CONVERT(VARCHAR, @i_primary_listkey)
    
  EXECUTE sp_executesql @v_sqlstring
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not set timestamp and private indicator for listkey = ' + cast(@i_primary_listkey AS VARCHAR) + '.'
  END
    
END
GO

GRANT EXEC ON qse_append_to_list TO PUBLIC
GO
