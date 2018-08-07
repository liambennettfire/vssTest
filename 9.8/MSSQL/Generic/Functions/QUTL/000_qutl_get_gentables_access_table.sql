if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentables_access_table') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_gentables_access_table
GO

CREATE FUNCTION dbo.qutl_get_gentables_access_table
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_key1 integer,
  @i_key2 integer,
  @i_key3 integer
) 
RETURNS @SecurityTable TABLE(
  accesscode INT, 
  datacode INT
)

/*******************************************************************************************************
**  Name: qutl_get_gentables_access_table
**  Desc: 
**
**  Auth: Colman
**  Date: 1/25/2018
********************************************************************************************************
**    Change History
********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
*******************************************************************************************************/

BEGIN 
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowid_var INT,
          @v_defaultaccesscode INT,   
          @v_count INT,
          @v_statustypekey INT,
          @v_current_status INT,
          @v_current_status_subvalue INT,          
          @v_status_tablename varchar(50),
          @v_status_columnname varchar(50)

  IF ISNULL(@i_tableid,0) = 0 
    RETURN
  
  IF ISNULL(@i_userkey,-1) = -1
    RETURN

  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    RETURN

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0
    RETURN

  -- Get window information
  SELECT @windowid_var=q.windowid
    FROM qsiwindows q
   WHERE lower(q.windowname) = lower(@i_windowname)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    RETURN
  END 
 
  -- Default to securityobjectsavailable defaultaccesscode
  SELECT @v_defaultaccesscode = ISNULL(defaultaccesscode, 2)   
    FROM securityobjectsavailable a
   WHERE a.windowid = @windowid_var AND
         a.availobjectcodetableid = @i_tableid
  
  -- Do we need to check for status specific entries?
  IF ISNULL(@i_key1, 0) <> 0
     AND EXISTS (SELECT 1
      FROM securityobjects o, securityobjectsavailable a
      WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
            a.windowid = @windowid_var AND
            a.availobjectcodetableid = @i_tableid AND
            ISNULL(o.securitystatustypekey, 0) <> 0)
  BEGIN
    DECLARE status_cur CURSOR FOR 
     SELECT securitystatustypekey, tablename, columnname
       FROM securitystatustype
  
     OPEN status_cur 
    FETCH status_cur INTO @v_statustypekey,@v_status_tablename,@v_status_columnname

    WHILE @@FETCH_STATUS = 0 
    BEGIN                   
      ---------------------------------------------------------------------------------------------------
      -- right now this is hardcoded for each status (due to limitations of functions and dynamic sql) 
      -- that we want to check
      ---------------------------------------------------------------------------------------------------
      SET @v_current_status_subvalue = NULL 
        
      IF @v_statustypekey = 1 BEGIN
        -- bisacstatus     
        SELECT @v_current_status = bisacstatuscode
          FROM bookdetail
         WHERE bookkey = @i_key1       

      END
      ELSE IF @v_statustypekey = 2 BEGIN
        -- titlestatus     
        SELECT @v_current_status = titlestatuscode
          FROM book
         WHERE bookkey = @i_key1       
      END
      ELSE IF @v_statustypekey = 3 BEGIN
        -- verified status     
        SELECT @v_current_status = titleverifystatuscode
          FROM bookverification
         WHERE bookkey = @i_key1 AND verificationtypecode = @i_key2      
      END    
      ELSE IF @v_statustypekey = 4 BEGIN
        -- PO Status     
        SELECT @v_current_status = dwostatuscode
          FROM dwolist
         WHERE dwokey = @i_key1       
      END     
      ELSE IF @v_statustypekey = 6 BEGIN
        -- pl status     
        SELECT @v_current_status = plstatuscode
          FROM taqversion
         WHERE taqprojectkey = @i_key1 AND plstagecode = @i_key2 AND taqversionkey = @i_key3   
      END 
      ELSE IF @v_statustypekey = 7 BEGIN
        -- format type     
        SELECT @v_current_status = mediatypecode, @v_current_status_subvalue = mediatypesubcode
          FROM bookdetail
         WHERE bookkey = @i_key1       
      END 
      ELSE IF @v_statustypekey = 8 BEGIN
        -- hidden status     
        SELECT @v_current_status = hiddenstatuscode
          FROM book
         WHERE bookkey = @i_key1       
      END    
      ELSE IF @v_statustypekey = 10 BEGIN
        -- project status     
        SELECT @v_current_status = taqprojectstatuscode
          FROM taqproject
         WHERE taqprojectkey = @i_key1       
      END          
      ELSE BEGIN
        goto get_next_status
      END
 
      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
        CLOSE status_cur 
        DEALLOCATE status_cur 
        RETURN
      END 
 
      IF @rowcount_var = 0 OR ISNULL(@v_current_status, 0) = 0
        goto get_next_status
 
      -- Check security for status
      -- user override 
      INSERT INTO @SecurityTable (accesscode, datacode)    
      SELECT accessind, o.datacode
        FROM securityobjects o, securityobjectsavailable a
        WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
              a.windowid = @windowid_var AND
              o.userkey = @i_userkey AND
              a.availobjectcodetableid = @i_tableid AND
              o.securitystatustypekey = @v_statustypekey AND
              o.securityobjectvalue = @v_current_status AND 
    		      ISNULL(o.securityobjectsubvalue, 0) = ISNULL(@v_current_status_subvalue, 0)                
              AND (@i_key2 = 1 OR o.firstprintingind = 'N')

      INSERT INTO @SecurityTable (accesscode, datacode)    
      SELECT accessind, o.datacode
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             a.availobjectcodetableid = @i_tableid AND
             o.securitystatustypekey = @v_statustypekey AND
             o.securityobjectvalue = @v_current_status AND 
             ISNULL(o.securityobjectsubvalue, 0) = ISNULL(@v_current_status_subvalue, 0)                  
             AND (@i_key2 = 1 OR o.firstprintingind = 'N')
             AND o.datacode NOT IN (SELECT datacode FROM @SecurityTable)

      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
        CLOSE status_cur 
        DEALLOCATE status_cur 
        RETURN
      END 
     
      get_next_status:
      FETCH status_cur INTO @v_statustypekey, @v_status_tablename, @v_status_columnname
    END
    CLOSE status_cur 
    DEALLOCATE status_cur 
  END
  ELSE BEGIN
    -- Check security without status
    -- user override 
    INSERT INTO @SecurityTable (accesscode, datacode)    
    SELECT accessind, o.datacode
      FROM securityobjects o, securityobjectsavailable a
      WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
            a.windowid = @windowid_var AND
            o.userkey = @i_userkey AND
            a.availobjectcodetableid = @i_tableid

    INSERT INTO @SecurityTable (accesscode, datacode)    
    SELECT accessind, o.datacode
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
           a.windowid = @windowid_var AND
           o.securitygroupkey = @securitygroupkey_var AND
           a.availobjectcodetableid = @i_tableid AND
           o.datacode NOT IN (SELECT datacode FROM @SecurityTable)
  END
    
  -- Check security for no status
  -- user override 
  INSERT INTO @SecurityTable (accesscode, datacode)    
  SELECT accessind, o.datacode
  FROM securityobjects o, securityobjectsavailable a
  WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
        a.windowid = @windowid_var AND
        o.userkey = @i_userkey AND
        a.availobjectcodetableid = @i_tableid AND
        ISNULL(o.securitystatustypekey,0) = 0 AND
        ISNULL(o.securityobjectvalue,0) = 0 
        AND (@i_key2 = 1 OR o.firstprintingind = 'N')

  -- group 
  INSERT INTO @SecurityTable (accesscode, datacode)    
  SELECT accessind, o.datacode
    FROM securityobjects o,securityobjectsavailable a
    WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
          a.windowid = @windowid_var AND
          o.securitygroupkey = @securitygroupkey_var AND
          a.availobjectcodetableid = @i_tableid AND
          ISNULL(o.securitystatustypekey,0) = 0 AND
          ISNULL(o.securityobjectvalue,0) = 0 
          AND (@i_key2 = 1 OR o.firstprintingind = 'N')
          AND o.datacode NOT IN (SELECT datacode FROM @SecurityTable)
    
  IF @i_tableid = 323
    INSERT INTO @SecurityTable (accesscode, datacode)    
    SELECT @v_defaultaccesscode, datetypecode
    FROM datetype 
    WHERE datetypecode NOT IN (SELECT datacode FROM @SecurityTable)
  ELSE
    INSERT INTO @SecurityTable (accesscode, datacode)    
    SELECT @v_defaultaccesscode, datacode
    FROM gentables WHERE tableid = @i_tableid
     AND datacode NOT IN (SELECT datacode FROM @SecurityTable)

  RETURN
END
GO

GRANT SELECT ON dbo.qutl_get_gentables_access_table TO public
GO
