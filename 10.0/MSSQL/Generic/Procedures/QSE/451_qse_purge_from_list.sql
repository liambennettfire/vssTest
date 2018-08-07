IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_purge_from_list')
BEGIN
  PRINT 'Dropping Procedure qse_purge_from_list'
  DROP  Procedure  qse_purge_from_list
END
GO

PRINT 'Creating Procedure qse_purge_from_list'
GO

CREATE PROCEDURE qse_purge_from_list
 (@i_primary_listkey    integer,
  @i_other_listkey      integer,
  @i_userid           VARCHAR(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qse_purge_from_list
**
**  primary_listkey - Key of List being purged from - Required
**  other_listkey - Key of List of items to be purged - Required
**
**  Auth: Alan Katzen
**  Date: 7/31/06
**
**  10/18/06 - KW - Private lists functionality.
*******************************************************************************/
BEGIN
  DECLARE
    @error_var    INT,
    @rowcount_var INT,
    @errormsg_var varchar(2000),
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
    SET @o_error_desc = 'Unable to purge from list: primary_listkey is empty.'
    RETURN
  END 

  -- verify other listkey is filled in
  IF @i_other_listkey IS NULL OR @i_other_listkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to purge from list: other_listkey is empty.'
    RETURN
  END 

  DECLARE other_list_cur CURSOR FOR 
    SELECT q.key1,q.key2
    FROM qse_searchresults q
    WHERE q.listkey = @i_other_listkey
    ORDER BY q.key1,q.key2

  OPEN other_list_cur 
  FETCH other_list_cur INTO @key1_var, @key2_var 

  WHILE @@fetch_status = 0
  BEGIN
  
    SELECT @count_var = count(*)
    FROM qse_searchresults q
    WHERE q.listkey = @i_primary_listkey AND
        q.key1 = @key1_var AND
        COALESCE(q.key2,0) = COALESCE(@key2_var,0)

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to purge from list: Error accessing qse_searchresults table (' + cast(@error_var AS VARCHAR) + ').'
      CLOSE other_list_cur 
      DEALLOCATE other_list_cur
      RETURN 
    END 

    -- purge key1/key2 from primary list
    IF @count_var > 0 BEGIN      
      DELETE FROM qse_searchresults
      WHERE listkey = @i_primary_listkey AND
            key1 = @key1_var AND
            key2 = @key2_var

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to purge from list: Error deleting from qse_searchresults table (' + cast(@error_var AS VARCHAR) + ').'
        CLOSE other_list_cur 
        DEALLOCATE other_list_cur
        RETURN
      END 
    END

    FETCH other_list_cur INTO @key1_var, @key2_var 
  END
  
  CLOSE other_list_cur 
  DEALLOCATE other_list_cur
  
  
  -- Check the private status of the primary list.
  -- NOTE: If list is private after the PURGE, this procedure will remove it 
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

GRANT EXEC ON qse_purge_from_list TO PUBLIC
GO
