IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_remove_object_lock')
  BEGIN
    PRINT 'Dropping Procedure qutl_remove_object_lock'
    DROP  Procedure  qutl_remove_object_lock
  END

GO

PRINT 'Creating Procedure qutl_remove_object_lock'
GO

CREATE PROCEDURE qutl_remove_object_lock
 (@i_userid          varchar(30),
  @i_tablename       varchar(100),
  @i_key1columnname  varchar(100),
  @i_key2columnname  varchar(100),
  @i_key1            integer,
  @i_key2            integer,
  @i_locktype        varchar(30),
  @i_systemind       varchar(4),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_remove_object_lock
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
**    userid - Userid of user trying to remove lock of object - Required
**    tablename - Table Name table used to store locks (ie booklock) - Required
**    key1columnname - Column Name of first column used to store locks (ie bookkey) - Required unless locktype is ALL
**    key2columnname - Column Name of second column used to store locks (ie printingkey) - Pass empty string if not used
**    key1 - Key that corresponds to key1columnname - Required unless locktype is ALL
**    key2 - Key that corresponds to key2columnname - Pass 0 if not applicable
**    locktype - String that tells us what type of lock - Pass ALL to remove all current locks for this user in this system
**               (title,printing,catalog,contract are some other examples) - Required
**    systemind - String that tells us what system is calling this Procedure (TMM,POMS,TAQ are some examples) - Required
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
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to lock object: userid is empty.'
    RETURN
  END 

  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to lock object: tablename is empty.'
    RETURN
  END 

  IF @i_systemind IS NULL OR ltrim(rtrim(@i_systemind)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to lock object: systemind is empty.'
    RETURN
  END 

  IF @i_locktype IS NULL OR ltrim(rtrim(@i_locktype)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to lock object: locktype is empty.'
    RETURN
  END 

  IF (@i_key1columnname IS NULL OR ltrim(rtrim(@i_key1columnname)) = '') AND 
     (upper(ltrim(rtrim(@i_locktype))) <> 'ALL') BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to lock object: key1columnname is empty.'
    RETURN
  END 

  IF (@i_key1 IS NULL OR @i_key1 = 0) AND (upper(ltrim(rtrim(@i_locktype))) <> 'ALL') BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to lock object: key1 is empty.'
    RETURN
  END 

  IF @i_key2 IS NULL BEGIN
    -- key2 cannot be null
    SET @i_key2 = 0
  END 

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @locktypecode_var INT,
          @SQLString_var NVARCHAR(4000),
          @key1_var INT,
          @key2_var INT,
          @locktimestamp_var DATETIME,
          @userid_var VARCHAR(30),
          @systemind_var VARCHAR(4),
          @locktypecode_db_var INT,
          @SQLparams_var NVARCHAR(4000),
          @key2columnname_temp VARCHAR(100),
          @lastuserid_var varchar(30),
          @v_itemtype INT,
          @v_workkey INT,
          @v_primary_bookkey INT,
          @v_this_linklevelcode INT,
          @v_this_propagatefrombookkey INT,
          @v_linklevelcode INT,
          @v_propagatefrombookkey INT

IF lower(ltrim(rtrim(@i_locktype))) = 'project' BEGIN
  -- may be a journal
  SELECT @v_itemtype = searchitemcode
    FROM coreprojectinfo
   WHERE projectkey = @i_key1
   
   IF @v_itemtype = 6 BEGIN
     SET @i_locktype = 'journal'
   END
END

SELECT @locktypecode_var =
   CASE lower(ltrim(rtrim(@i_locktype)))
      WHEN 'all' THEN 99
      WHEN 'title' THEN 1
      WHEN 'printing' THEN 2
      WHEN 'covercombo' THEN 3
      WHEN 'catalog' THEN 4
      WHEN 'contract' THEN 5
      WHEN 'journal' THEN 7
      WHEN 'contact' THEN 8
      ELSE 1   -- assume title lock
   END   

  SET @SQLString_var = N'DELETE FROM ' + cast(@i_tablename AS NVARCHAR) + 
                       N' WHERE userid = @i_userid AND systemind = @i_systemind ' 

  IF (upper(ltrim(rtrim(@i_locktype))) <> 'ALL') BEGIN
    -- @i_key1columnname and @i_key1 cannot be null at this point
    SET @SQLString_var = @SQLString_var + N' AND ' + @i_key1columnname + N'=' + cast(@i_key1 AS NVARCHAR)

    IF (@i_key2columnname IS NOT NULL AND @i_key2 > 0) BEGIN 
      SET @SQLString_var = @SQLString_var + N' AND ' + @i_key2columnname + N'=' + cast(@i_key2 AS NVARCHAR)
    END
  END

  SET @SQLparams_var = N'@i_userid VARCHAR(30),@i_systemind VARCHAR(4)'

  EXECUTE sp_executesql @SQLString_var,@SQLparams_var,@i_userid,@i_systemind

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  -- NOTE: @rowcount_var will have the number of rows deleted
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to delete from table ' + @i_tablename + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  -- if unlocking a title - need to unlock all related titles that also propagate (primary and subordinate)
  IF @locktypecode_var = 1 AND lower(@i_tablename) = 'booklock' BEGIN
    SET @v_workkey = 0
    SET @v_primary_bookkey = 0
    SET @v_this_linklevelcode = 0
    SET @v_this_propagatefrombookkey = 0
    
    SELECT @v_workkey = coalesce(workkey,0),
           @v_this_linklevelcode = coalesce(linklevelcode,0),
           @v_this_propagatefrombookkey = coalesce(propagatefrombookkey,0)
      FROM book
     WHERE bookkey = @i_key1         

    IF @v_this_propagatefrombookkey > 0 BEGIN
      -- this is a title with propagation turned on - need to unlock the title that 
      -- it is propagating from and the other titles that also propagate from the same title
      DELETE FROM booklock 
       WHERE userid = @i_userid 
         AND systemind = @i_systemind 
         AND bookkey = @v_this_propagatefrombookkey     

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to unlock primary title (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END 

      -- unlock other titles that are propagated from same bookkey         
      DELETE FROM booklock 
       WHERE userid = @i_userid 
         AND systemind = @i_systemind 
         AND bookkey in (SELECT bookkey
                           FROM book
                          WHERE workkey = @v_workkey
                            AND bookkey <> @i_key1
                            AND propagatefrombookkey = @v_this_propagatefrombookkey)
         
    END
    ELSE BEGIN
      -- this title is not propagating from another title, but it may have other titles propagating from it -
      -- need to unlock these titles
      DELETE FROM booklock 
       WHERE userid = @i_userid 
         AND systemind = @i_systemind 
         AND bookkey in (SELECT bookkey
                           FROM book
                          WHERE workkey = @v_workkey
                            AND bookkey <> @i_key1
                            AND propagatefrombookkey = @i_key1)
            
    END
    
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to lock unsubordinate titles (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END  
  END
    
  RETURN 
GO

GRANT EXEC ON qutl_remove_object_lock TO PUBLIC
GO




















