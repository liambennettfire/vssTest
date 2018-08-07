IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_object_lock')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_object_lock'
    DROP  Procedure  qutl_check_object_lock
  END

GO

PRINT 'Creating Procedure qutl_check_object_lock'
GO

CREATE PROCEDURE qutl_check_object_lock
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
**  Name: qutl_check_object_lock
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
**                 1(Not Locked or Locked By This User already - Editing Allowed)
**                -1(Error)
**    error_code - error code
**    error_desc - error message or locked message - empty if Not Locked or Locked By This User already
**
**    Auth: Alan Katzen
**    Date: 6/30/09
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
    SET @o_error_desc = 'Unable to check if object is locked: userid is empty.'
    RETURN
  END 

  IF @i_tablename IS NULL OR ltrim(rtrim(@i_tablename)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check if object is locked: tablename is empty.'
    RETURN
  END 

  IF @i_key1columnname IS NULL OR ltrim(rtrim(@i_key1columnname)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check if object is locked: key1columnname is empty.'
    RETURN
  END 

  IF @i_key1 IS NULL OR @i_key1 = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check if object is locked: key1 is empty.'
    RETURN
  END 

  IF @i_locktype IS NULL OR ltrim(rtrim(@i_locktype)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check if object is locked: locktype is empty.'
    RETURN
  END 

  IF @i_systemind IS NULL OR ltrim(rtrim(@i_systemind)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check if object is locked: systemind is empty.'
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
          @v_lock_option INT,
          @v_numlocks INT,
          @v_userlist varchar(2000)

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

  -- check to see if more than one user is allowed access at the same time
  -- 0 - multiple users allowed to update / 1 - only 1 user allowed at a time
  select @v_lock_option = optionvalue from clientoptions where optionid = 124

  create table #locks (
    key1 int not null,
    key2 int not null,
    locktimestamp datetime null,
    userid varchar(30) null,
    systemind char(4) null,
    locktypecode smallint null
  )

   -- see if any lock exists for key1 (and key2) 
  IF (@i_key2columnname IS NOT NULL AND @i_key2 > 0) BEGIN 
    SET @SQLString_var = N'INSERT INTO #locks ' +
                         N'SELECT ' + cast(@i_key1columnname AS NVARCHAR) + N',' +
                               N' ' + cast(@i_key2columnname AS NVARCHAR) + 
                               N',locktimestamp,userid,systemind,locktypecode ' +  
                         N' FROM ' + cast(@i_tablename AS NVARCHAR) +
                         N' WHERE ' + @i_key1columnname + N'=' + cast(@i_key1 AS NVARCHAR) + N' AND ' +
                                      @i_key2columnname + N'=' + cast(@i_key2 AS NVARCHAR)
  END
  ELSE BEGIN
    SET @SQLString_var = N'INSERT INTO #locks ' +
                         N'SELECT ' + cast(@i_key1columnname AS NVARCHAR) +
                               N',0,locktimestamp,userid,systemind,locktypecode ' +  
                         N' FROM ' + cast(@i_tablename AS NVARCHAR) +
                         N' WHERE ' + @i_key1columnname + N'=' + cast(@i_key1 AS NVARCHAR)
  END 		 

  --print '@SQLString_var: ' + cast(@SQLString_var as varchar)

  EXECUTE sp_executesql @SQLString_var

  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = -1
    SET @o_error_desc = 'Unable to check table ' + @i_tablename + ' (' + cast(@error_var AS VARCHAR) + ').'
    drop table #locks
    RETURN
  END 

  -- check to see if any other user has a lock
  SELECT @v_numlocks = count(*) 
    FROM #locks
   WHERE userid <> @i_userid 
     and systemind = @i_systemind
     and key1 = @i_key1
     and key2 = coalesce(@i_key2,0)

  --print '@v_numlocks: ' + cast(@v_numlocks as varchar)
  
  IF @v_numlocks = 0 BEGIN
    -- not currently locked
    SET @o_error_code = 0
    SET @o_accesscode = 1
    SET @o_error_desc = ''
    drop table #locks
    RETURN
  END
  ELSE BEGIN
    IF @v_lock_option = 0 BEGIN
      -- multiples allowed - try to return list of all users currently viewing 
      declare users_cur cursor for 
        SELECT userid from #locks
         WHERE userid <> @i_userid

      open users_cur 
        fetch users_cur into @userid_var

      while @@fetch_status = 0 begin
        if len(@v_userlist)>1 begin
          set @v_userlist = @v_userlist + ', '
        end
        set @v_userlist = ltrim(COALESCE(@v_userlist,' ') + @userid_var)
        fetch users_cur into @userid_var 
      end

      close users_cur 
      deallocate users_cur 

      SET @o_error_desc = 'The following users are also viewing this ' + ltrim(rtrim(@i_locktype)) + ' and may be making updates: ' + @v_userlist 
      SET @o_error_code = 0
      SET @o_accesscode = 1
      drop table #locks
      RETURN
    END
    ELSE BEGIN
      -- only one lock allowed
      SELECT top 1 @userid_var = userid, @systemind_var = systemind 
        FROM #locks
       WHERE userid <> @i_userid

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
          drop table #locks
          RETURN
        END
        ELSE BEGIN
          -- already locked by this user - nothing to do
          SET @o_error_code = 0
          SET @o_accesscode = 1
          SET @o_error_desc = ''
          drop table #locks
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
        drop table #locks
        RETURN
      END
    END
  END

  RETURN 
GO

GRANT EXEC ON qutl_check_object_lock TO PUBLIC
GO




















