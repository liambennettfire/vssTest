IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_add_object_lock')
  BEGIN
    PRINT 'Dropping Procedure qutl_add_object_lock'
    DROP  Procedure  qutl_add_object_lock
  END

GO

PRINT 'Creating Procedure qutl_add_object_lock'
GO

CREATE PROCEDURE qutl_add_object_lock
 (@i_userid          varchar(30),
  @i_tablename       varchar(100),
  @i_key1columnname  varchar(100),
  @i_key2columnname  varchar(100),
  @i_key1            integer,
  @i_key2            integer,
  @i_locktype        varchar(30),
  @i_systemind       varchar(4),
  @o_accesscode      integer output,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_add_object_lock
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
**    userid - Userid of user trying to access object - Required
**    tablename - Table Name table used to store locks (ie booklock) - Required
**    key1columnname - Column Name of first column used to store locks (ie bookkey) - Required
**    key2columnname - Column Name of second column used to store locks (ie printingkey) - Pass empty string if not used
**    key1 - Key that corresponds to key1columnname - Required
**    key2 - Key that corresponds to key2columnname - Pass 0 if not applicable
**    locktype - String that tells us what type of lock (title,printing,catalog,contract are some examples) - Required
**    systemind - String that tells us what system is calling this Procedure (TMM,POMS,TAQ are some examples) - Required
**    
**    Output
**    -----------
**    accesscode - 0(Locked By Another User - No editing allowed - look at error_desc for message)
**                 1(Not Locked or Locked By This User already - Object will be locked for this user - Editing Allowed)
**                -1(Error)
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
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to lock object: userid is empty.'
    RETURN
  END 

  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to lock object: tablename is empty.'
    RETURN
  END 

  IF @i_key1columnname IS NULL OR ltrim(rtrim(@i_key1columnname)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to lock object: key1columnname is empty.'
    RETURN
  END 

  IF @i_key1 IS NULL OR @i_key1 = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to lock object: key1 is empty.'
    RETURN
  END 

  IF @i_locktype IS NULL OR ltrim(rtrim(@i_locktype)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to lock object: locktype is empty.'
    RETURN
  END 

  IF @i_systemind IS NULL OR ltrim(rtrim(@i_systemind)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to lock object: systemind is empty.'
    RETURN
  END 

  IF @i_key2 IS NULL BEGIN
    -- key2 cannot be null
    SET @i_key2 = 0
  END 

  SET @o_accesscode = -1
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
          @v_propagatefrombookkey INT,
          @v_count INT

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
      WHEN 'title' THEN 1
      WHEN 'printing' THEN 2
      WHEN 'covercombo' THEN 3
      WHEN 'catalog' THEN 4
      WHEN 'contract' THEN 5
      WHEN 'project' THEN 6
      WHEN 'journal' THEN 7
      WHEN 'contact' THEN 8
      ELSE 1   -- assume title lock
   END   

  -- see if any lock exists for key1 (and key2) 
  IF (@i_key2columnname IS NOT NULL AND @i_key2 > 0) BEGIN 
    SET @SQLString_var = N'SELECT @key1_var=' + cast(@i_key1columnname AS NVARCHAR) + N',' +
                               N' @key2_var=' + cast(@i_key2columnname AS NVARCHAR) + 
                               N',@locktimestamp_var=locktimestamp,@userid_var=userid' +
                               N',@systemind_var=systemind,@locktypecode_db_var=locktypecode ' +  
                         N' FROM ' + cast(@i_tablename AS NVARCHAR) +
                         N' WHERE ' + @i_key1columnname + N'=' + cast(@i_key1 AS NVARCHAR) + N' AND ' +
                                      @i_key2columnname + N'=' + cast(@i_key2 AS NVARCHAR)

    SET @SQLparams_var = N'@key1_var INT output,@key2_var INT output,@locktimestamp_var DATETIME output,' + 
                         N'@userid_var VARCHAR(30) output,@systemind_var VARCHAR(4) output,@locktypecode_db_var INT output'

    EXECUTE sp_executesql @SQLString_var, @SQLparams_var,
                          @key1_var = @key1_var output,@key2_var = @key2_var output,@locktimestamp_var=@locktimestamp_var output,
                          @userid_var = @userid_var output,@systemind_var = @systemind_var output,@locktypecode_db_var=@locktypecode_db_var output
  END
  ELSE BEGIN
    SET @SQLString_var = N'SELECT @key1_var=' + cast(@i_key1columnname AS NVARCHAR) +
                               N',@locktimestamp_var=locktimestamp,@userid_var=userid' +
                               N',@systemind_var=systemind,@locktypecode_db_var=locktypecode ' +  
                         N' FROM ' + cast(@i_tablename AS NVARCHAR) +
                         N' WHERE ' + @i_key1columnname + N'=' + cast(@i_key1 AS NVARCHAR)

    SET @SQLparams_var = N'@key1_var INT output,@locktimestamp_var DATETIME output,' + 
                         N'@userid_var VARCHAR(30) output,@systemind_var VARCHAR(4) output,@locktypecode_db_var INT output'

    EXECUTE sp_executesql @SQLString_var, @SQLparams_var,
                          @key1_var = @key1_var output,@locktimestamp_var=@locktimestamp_var output,
                          @userid_var = @userid_var output,@systemind_var = @systemind_var output,@locktypecode_db_var=@locktypecode_db_var output
  END 		 

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check table ' + @i_tablename + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  
  IF @rowcount_var = 0 BEGIN
    -- not currently locked - need to lock it    
    SET @systemind_var = @i_systemind
    SET @lastuserid_var = @i_userid

    IF (@i_key2columnname IS NOT NULL AND @i_key2 > 0) BEGIN 
      SET @SQLString_var = N'INSERT INTO ' + cast(@i_tablename AS NVARCHAR) + N' (' +
                             cast(@i_key1columnname AS NVARCHAR) + N',' +
                             cast(@i_key2columnname AS NVARCHAR) + N',' +
                           N'locktimestamp,userid,systemind,locktypecode,lastuserid,lastmaintdate) VALUES (' + 
                             cast(@i_key1 AS NVARCHAR) + N',' +
                             cast(@i_key2 AS NVARCHAR) + N',' +                           
                           N'getdate(),@lastuserid_var,@systemind_var,@locktypecode_var,@lastuserid_var,getdate())'
    END
    ELSE BEGIN
      -- printingkey on booklock cannot be null so we need to set it to 0
      IF lower(@i_tablename) = 'booklock' BEGIN
        SET @key2columnname_temp = 'printingkey'

        SET @SQLString_var = N'INSERT INTO ' + cast(@i_tablename AS NVARCHAR) + N' (' +
                             cast(@i_key1columnname AS NVARCHAR) + N',' +
                             cast(@key2columnname_temp AS NVARCHAR) + N',' +
                           N'locktimestamp,userid,systemind,locktypecode,lastuserid,lastmaintdate) VALUES (' + 
                             cast(@i_key1 AS NVARCHAR) + N',' +
                             cast(@i_key2 AS NVARCHAR) + N',' +                           
                           N'getdate(),@lastuserid_var,@systemind_var,@locktypecode_var,@lastuserid_var,getdate())'
      END
      ELSE BEGIN
        SET @SQLString_var = N'INSERT INTO ' + cast(@i_tablename AS NVARCHAR) + N' (' +
                             cast(@i_key1columnname AS NVARCHAR) + N',' +
                           N'locktimestamp,userid,systemind,locktypecode,lastuserid,lastmaintdate) VALUES (' + 
                             cast(@i_key1 AS NVARCHAR) + N',' +
                           N'getdate(),@lastuserid_var,@systemind_var,@locktypecode_var,@lastuserid_var,getdate())'
      END
    END
    
    --print '@SQLString_var: ' + cast(@SQLString_var as varchar)

    SET @SQLparams_var = N'@lastuserid_var VARCHAR(30),@systemind_var VARCHAR(4),@locktypecode_var INT'

    EXECUTE sp_executesql @SQLString_var,@SQLparams_var,@lastuserid_var,@systemind_var,@locktypecode_var

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_accesscode = -1
      SET @o_error_desc = 'Unable to insert into table ' + @i_tablename + ' (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 

    -- if locking a title - need to lock all related titles that also propagate (primary and subordinate)
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
        -- this is a title with propagation turned on - need to lock the title that 
        -- it is propagating from and the other titles that also propagate from the same title
        SELECT @v_count = count(*)
          FROM booklock
         WHERE bookkey = @v_this_propagatefrombookkey

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_accesscode = -1
          SET @o_error_desc = 'Unable to lock primary title (' + cast(@error_var AS VARCHAR) + ').'
          RETURN
        END 
         
        IF @v_count = 0 BEGIN  
          INSERT INTO booklock (bookkey,printingkey,locktimestamp,userid,systemind,locktypecode,lastuserid,lastmaintdate)
          VALUES (@v_this_propagatefrombookkey,0,getdate(),@lastuserid_var,@systemind_var,@locktypecode_var,@lastuserid_var,getdate())

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @o_error_code = -1
            SET @o_accesscode = -1
            SET @o_error_desc = 'Unable to lock primary title (' + cast(@error_var AS VARCHAR) + ').'
            RETURN
          END 
        END
        
        -- lock other titles that are propagated from same bookkey
        INSERT INTO booklock (bookkey,printingkey,locktimestamp,userid,systemind,locktypecode,lastuserid,lastmaintdate)
        SELECT bookkey,0,getdate(),@lastuserid_var,@systemind_var,@locktypecode_var,@lastuserid_var,getdate()
          FROM book
         WHERE workkey = @v_workkey
           AND bookkey <> @i_key1
           AND propagatefrombookkey = @v_this_propagatefrombookkey
           AND bookkey not in (SELECT bookkey FROM booklock) 
      END
      ELSE BEGIN
        -- this title is not propagating from another title, but it may have other titles propagating from it -
        -- need to lock these titles
        INSERT INTO booklock (bookkey,printingkey,locktimestamp,userid,systemind,locktypecode,lastuserid,lastmaintdate)
        SELECT bookkey,0,getdate(),@lastuserid_var,@systemind_var,@locktypecode_var,@lastuserid_var,getdate()
          FROM book
         WHERE workkey = @v_workkey
           AND bookkey <> @i_key1
           AND propagatefrombookkey = @i_key1
           AND bookkey not in (SELECT bookkey FROM booklock) 
      END
      
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_accesscode = -1
        SET @o_error_desc = 'Unable to lock subordinate titles (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END  
    END

    SET @o_error_code = 0
    SET @o_accesscode = 1
    SET @o_error_desc = ''
    RETURN
  END
  ELSE BEGIN
    IF @userid_var IS NOT NULL AND ltrim(rtrim(@userid_var)) <> '' BEGIN
      -- locked by someone
      IF (lower(ltrim(rtrim(@i_userid))) <> lower(ltrim(rtrim(@userid_var)))) OR 
         (lower(ltrim(rtrim(@i_systemind))) <> lower(ltrim(rtrim(@systemind_var)))) BEGIN
        -- locked by another user or by this user in another system
        SET @o_error_code = 0
        SET @o_accesscode = 0
        SET @o_error_desc = 'This ' + ltrim(rtrim(@i_locktype)) + ' is currently being used by ' + ltrim(rtrim(@userid_var)) + 
                            ' in ' + ltrim(rtrim(@systemind_var)) + '.  No changes will be allowed as long as the ' + 
                            ltrim(rtrim(@i_locktype)) + ' is in use.'
        RETURN
      END
      ELSE BEGIN
        -- already locked by this user - nothing to do
        SET @o_error_code = 0
        SET @o_accesscode = 1
        SET @o_error_desc = ''
        RETURN
      END
    END
    ELSE BEGIN
      -- row exists, but userid is not filled in - locked by someone
      SET @o_error_code = 0
      SET @o_accesscode = 0
      SET @o_error_desc = 'This ' + ltrim(rtrim(@i_locktype)) + ' is currently being used by someone' + 
                          ' in ' + ltrim(rtrim(@systemind_var)) + '.  No changes will be allowed as long as the ' + 
                          ltrim(rtrim(@i_locktype)) + ' is in use.'
      RETURN
    END
  END

  RETURN 
GO

GRANT EXEC ON qutl_add_object_lock TO PUBLIC
GO




















