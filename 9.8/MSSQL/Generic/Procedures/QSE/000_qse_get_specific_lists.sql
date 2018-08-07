IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_specific_lists')
BEGIN
  PRINT 'Dropping Procedure qse_get_specific_lists'
  DROP PROCEDURE  qse_get_specific_lists
END
GO

PRINT 'Creating Procedure qse_get_specific_lists'
GO

CREATE PROCEDURE qse_get_specific_lists
(
  @i_Key1   INT,
  @i_Key2   INT,
  @i_ListTypeCode   INT,
  @i_SearchTypeCode INT,
  @i_UserKey      INT,
  @i_PrivateOnly  TINYINT,
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE 
    @v_sqlstring  NVARCHAR(4000),
    @error_var    INT,
    @rowcount_var INT
      
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF (@i_Key1 is null OR @i_Key1 <= 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get lists (key1 is not filled in).'
    RETURN
  END

  SET @v_sqlstring = 'SELECT l.listkey,l.searchtypecode,l.listdesc,
      l.createdbyuserid,l.createddate,l.lastmaintdate,l.lastuserid,l.privateind
    FROM qse_searchlist l, qse_searchresults r
    WHERE l.listkey = r.listkey AND
      l.saveascriteriaind = 0 AND
      r.key1 = ' + CAST(@i_Key1 AS VARCHAR)
  
  -- If Key2 was passed in, add to where clause
  IF @i_Key2 > 0
    SET @v_sqlstring = @v_sqlstring + ' AND r.key2 = ' + CAST(@i_Key2 AS VARCHAR)
  
  -- Return user-defined lists if listtypecode not passed in
  IF @i_ListTypeCode > 0
    SET @v_sqlstring = @v_sqlstring + ' AND l.listtypecode = ' + CAST(@i_ListTypeCode AS VARCHAR)
  ELSE    
    SET @v_sqlstring = @v_sqlstring + ' AND l.listtypecode = 3' --user defined lists

  -- Return lists of passed search type
  IF @i_SearchTypeCode > 0
    SET @v_sqlstring = @v_sqlstring + ' AND l.searchtypecode = ' + CAST(@i_SearchTypeCode AS VARCHAR)

  -- Always return private lists for the user
  SET @v_sqlstring = @v_sqlstring + ' AND ((l.privateind=1 AND
     (l.userkey=' + CONVERT(VARCHAR, @i_UserKey) + ' OR l.userkey IN 
     (SELECT accesstouserkey FROM qsiprivateuserlist
      WHERE primaryuserkey=' + CONVERT(VARCHAR, @i_UserKey) + ')))'
  
  -- If not PrivateOnly, also return public lists
  IF @i_PrivateOnly = 1
    SET @v_sqlstring = @v_sqlstring + ')'
  ELSE
    SET @v_sqlstring = @v_sqlstring + ' OR l.privateind IS NULL OR l.privateind=0)'
    
  --DEBUG
  PRINT @v_sqlstring
      
  -- Execute the full sqlstring  
  EXECUTE sp_executesql @v_sqlstring
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get lists: key1 = ' + cast(COALESCE(@i_Key1,0) AS VARCHAR) + 
      ' / key2 = ' + cast(COALESCE(@i_Key2,0) AS VARCHAR)
  END
  
END
GO

GRANT EXEC ON qse_get_specific_lists TO PUBLIC
GO
