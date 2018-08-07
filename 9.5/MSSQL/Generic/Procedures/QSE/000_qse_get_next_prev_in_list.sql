IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_next_prev_in_list')
BEGIN
  PRINT 'Dropping Procedure qse_get_next_prev_in_list'
  DROP  Procedure  qse_get_next_prev_in_list
END
GO

PRINT 'Creating Procedure qse_get_next_prev_in_list'
GO

CREATE PROCEDURE qse_get_next_prev_in_list
 (@i_listkey      INT,
  @i_current_key1 INT,
  @i_current_key2 INT,
  @o_next_key1    INT OUT,
  @o_next_key2    INT OUT,
  @o_prev_key1    INT OUT,
  @o_prev_key2    INT OUT,
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT)
AS

/******************************************************************************
**  Name: qse_get_next_prev_in_list
**
**  Parameters:
**    @i_listkey - listkey of current list
**    @i_current_key1 - key1 of current item in list
**    @i_current_key2 - key2 of current item in list
**    @i_next_prev - 'next' or 'prev' - direction to look in list
**    @o_return_key1 - key1 of next/prev item in list
**    @o_return_key2 - key2 of next/prev item in list
**
**  Auth: Alan Katzen
**  Date: 11/3/2010
**
*******************************************************************************/
BEGIN
  DECLARE
    @error_var         INT,
    @rowcount_var      INT,
    @errormsg_var      VARCHAR(2000),
    @v_sortorder       INT,
    @v_next_sortorder  INT,
    @v_prev_sortorder  INT,
    @v_cnt             INT,
    @v_next_found      TINYINT,
    @v_prev_found      TINYINT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_next_key1 = 0
  SET @o_next_key2 = 0
  SET @o_prev_key1 = 0
  SET @o_prev_key2 = 0
  SET @v_next_found = 0
  SET @v_prev_found = 0
  
  -- verify listkey is filled in
  IF @i_listkey IS NULL OR @i_listkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get next/previous in list: listkey is empty.'
    RETURN
  END 

  IF @i_current_key1 IS NULL OR @i_current_key1 <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get next/previous in list: current key1 is empty.'
    RETURN
  END 

  IF @i_current_key2 IS NULL OR @i_current_key2 < 0 BEGIN
    SET @i_current_key2 = 0
  END 
  
  SELECT @v_cnt = count(*) 
    FROM qse_searchresults
   WHERE listkey = @i_listkey
     AND key1 = @i_current_key1
     AND key2 = @i_current_key2
     
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END
  IF @rowcount_var = 0 OR @v_cnt = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'Could not find qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END

  SELECT @v_sortorder = COALESCE(sortorder,0)
    FROM qse_searchresults
   WHERE listkey = @i_listkey
     AND key1 = @i_current_key1
     AND key2 = @i_current_key2
     
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END
  
  -- next
  SELECT @v_cnt = count(*) 
    FROM qse_searchresults
   WHERE listkey = @i_listkey
     AND sortorder > @v_sortorder

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing next qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END
  IF @rowcount_var = 0 OR @v_cnt = 0 BEGIN
    SET @o_error_code = 0
    goto LookForPrevious
  END
  
  SELECT @v_next_sortorder = MIN(sortorder)
    FROM qse_searchresults
   WHERE listkey = @i_listkey
     AND sortorder > @v_sortorder

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing next qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END
 
  IF @v_next_sortorder >= 0 BEGIN
    SELECT @o_next_key1 = key1, @o_next_key2 = key2
      FROM qse_searchresults
     WHERE listkey = @i_listkey
       AND sortorder = @v_next_sortorder

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                          + ' / sortorder: ' + cast(@v_prev_sortorder as VARCHAR)
      RETURN
    END  
    
    SET @v_next_found = 1  
  END    
  
  LookForPrevious:
  -- previous
  SELECT @v_cnt = count(*) 
    FROM qse_searchresults
   WHERE listkey = @i_listkey
     AND sortorder < @v_sortorder

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing previous qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END
  IF @rowcount_var = 0 OR @v_cnt = 0 BEGIN
    SET @o_error_code = 0
    goto Finished
  END
  
  SELECT @v_prev_sortorder = MAX(sortorder)
    FROM qse_searchresults
   WHERE listkey = @i_listkey
     AND sortorder < @v_sortorder

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing previous qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
    RETURN
  END
  
  IF @v_prev_sortorder >= 0 BEGIN
    SELECT @o_prev_key1 = key1, @o_prev_key2 = key2
      FROM qse_searchresults
     WHERE listkey = @i_listkey
       AND sortorder = @v_prev_sortorder

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                          + ' / sortorder: ' + cast(@v_prev_sortorder as VARCHAR)
      RETURN
    END  
    
    SET @v_prev_found = 1        
  END    
  
  Finished:
  IF @v_prev_found = 0 AND @v_next_found = 0 BEGIN
    SET @o_error_desc = 'Could not find a next/previous qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
  END
  IF @v_prev_found = 0 AND @v_next_found = 1 BEGIN
    SET @o_error_desc = 'Could not find a previous qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
  END
  IF @v_prev_found = 1 AND @v_next_found = 0 BEGIN
    SET @o_error_desc = 'Could not find a next qse_searchresults record for listkey: ' + cast(@i_listkey as VARCHAR) 
                        + ' / key1: ' + cast(@i_current_key1 as VARCHAR)
                        + ' / key2: ' + cast(@i_current_key2 as VARCHAR)
  END
  
END
GO

GRANT EXEC ON qse_get_next_prev_in_list TO PUBLIC
GO
