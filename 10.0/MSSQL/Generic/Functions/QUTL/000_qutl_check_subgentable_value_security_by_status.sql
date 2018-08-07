if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_check_subgentable_value_security_by_status') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_check_subgentable_value_security_by_status
GO

CREATE FUNCTION dbo.qutl_check_subgentable_value_security_by_status
(
  @i_userkey  integer,
  @i_windowname varchar(100),
  @i_tableid integer,
  @i_datacode integer,
  @i_datasubcode integer,
  @i_key1 integer,
  @i_key2 integer,
  @i_key3 integer
) 
RETURNS integer

/*******************************************************************************************************
**  Name: qutl_check_subgentable_value_security_by_status
**  Desc: This function returns accesscode for a subgentable value on a specific window
**        based on a status
**        0(No Access)/1(Read Only)/2(Update)
**
**  Auth: Alan Katzen
**  Date: September 1, 2011
*******************************************************************************************************
**  Change History
*******************************************************************************************************
**  Date:       Author:            Description:
**  -------   ------------      -----------------------------------------------------------------------
**  03/17/17   Uday A. Khisty   Case 43529
**  06/07/18   Colman           Case 50971 Implemented availsecurityobjectkey.firstprintingind support
*******************************************************************************************************/

BEGIN 
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowid_var INT,
          @object_accessind_var INT,   
          @return_accessind_var INT,   
          @v_count INT,
          @v_statustypekey INT,
          @v_current_status INT,
          @v_current_status_subvalue INT,            
          @v_status_tablename varchar(50),
          @v_status_columnname varchar(50),
          @v_at_least_one_status_setup tinyint,
          @v_itemtype INT,
          @v_printingkey INT,
          @v_printing_rolecode INT

  IF COALESCE(@i_tableid,0) = 0 OR COALESCE(@i_datacode,0) = 0 OR COALESCE(@i_datasubcode,0) = 0 BEGIN
    RETURN 2
  END
  
  IF COALESCE(@i_userkey,-1) = -1 BEGIN
    RETURN 2
  END

  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    RETURN 0
  END 

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
    RETURN 0
  END 

  -- Get window information
  SELECT @windowid_var=q.windowid
    FROM qsiwindows q
   WHERE lower(q.windowname) = lower(@i_windowname)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    RETURN 0
  END 
 
  -- default to securityobjectsavailable.defaultaccesscode
  SELECT @return_accessind_var = COALESCE(defaultaccesscode, 2)
    FROM securityobjectsavailable a
   WHERE a.windowid = @windowid_var AND
         a.availobjectcodetableid = @i_tableid
         
  SET @object_accessind_var = @return_accessind_var 
  SET @v_at_least_one_status_setup = 0

  DECLARE status_cur CURSOR FOR 
   SELECT securitystatustypekey, tablename, columnname
     FROM securitystatustype
  
   OPEN status_cur 
  FETCH status_cur INTO @v_statustypekey,@v_status_tablename,@v_status_columnname

  WHILE @@fetch_status = 0 BEGIN                   
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
       SET @v_printingkey = @i_key2
    END
    ELSE IF @v_statustypekey = 2 BEGIN
      -- titlestatus     
      SELECT @v_current_status = titlestatuscode
        FROM book
       WHERE bookkey = @i_key1       
       SET @v_printingkey = @i_key2
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
       SET @v_printingkey = @i_key2
    END 
    ELSE IF @v_statustypekey = 8 BEGIN
      -- hidden status     
      SELECT @v_current_status = hiddenstatuscode
        FROM book
       WHERE bookkey = @i_key1       
       SET @v_printingkey = @i_key2
    END    
    ELSE IF @v_statustypekey = 10 BEGIN
      -- project status     
      SELECT @v_itemtype = searchitemcode, @v_current_status = taqprojectstatuscode
        FROM taqproject
       WHERE taqprojectkey = @i_key1       

      -- Need printingkey for printing projects to evaluate the 'First printing only' security flag
      IF @v_itemtype = 14
      BEGIN
        SELECT @v_printing_rolecode = datacode FROM gentables WHERE tableid = 604 AND qsicode = 3
      
        SELECT @v_printingkey = printingkey 
        FROM taqprojecttitle
            WHERE taqprojectkey = @i_key1
              AND projectrolecode = @v_printing_rolecode
      END
    END	  
    ELSE BEGIN
      goto get_next_status
    END
 
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      CLOSE status_cur 
      DEALLOCATE status_cur 
      RETURN 0
    END 
 
    IF @rowcount_var = 0 OR COALESCE(@v_current_status,0) = 0 BEGIN
      goto get_next_status
    END 
 
    SET @v_at_least_one_status_setup = 1
    
    -- Check security for status
    -- user override 
    SELECT @v_count = count(*)   
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
           a.windowid = @windowid_var AND
           o.userkey = @i_userkey AND
           o.datacode = @i_datacode AND
           o.datasubcode = @i_datasubcode AND
           a.availobjectcodetableid = @i_tableid AND
           o.securitystatustypekey = @v_statustypekey AND
           o.securityobjectvalue = @v_current_status AND
          (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
		       COALESCE(o.securityobjectsubvalue, 0) = COALESCE(@v_current_status_subvalue, 0)            

    IF @v_count > 0 BEGIN 
      SELECT @object_accessind_var = accessind   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
             a.windowid = @windowid_var AND
             o.userkey = @i_userkey AND
             o.datacode = @i_datacode AND
             o.datasubcode = @i_datasubcode AND
             a.availobjectcodetableid = @i_tableid AND
             o.securitystatustypekey = @v_statustypekey AND
             o.securityobjectvalue = @v_current_status AND
            (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
	    	     COALESCE(o.securityobjectsubvalue, 0) = COALESCE(@v_current_status_subvalue, 0)              
    END 
    ELSE BEGIN
      -- group
      SELECT @v_count = count(*)   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             o.datacode = @i_datacode AND
             o.datasubcode = @i_datasubcode AND
             a.availobjectcodetableid = @i_tableid AND
             o.securitystatustypekey = @v_statustypekey AND
             o.securityobjectvalue = @v_current_status AND
            (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
	    	     COALESCE(o.securityobjectsubvalue, 0) = COALESCE(@v_current_status_subvalue, 0)              
             
      IF @v_count > 0 BEGIN
        SELECT @object_accessind_var = accessind
          FROM securityobjects o,securityobjectsavailable a
         WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
               a.windowid = @windowid_var AND
               o.securitygroupkey = @securitygroupkey_var AND
               o.datacode = @i_datacode AND
               o.datasubcode = @i_datasubcode AND
               a.availobjectcodetableid = @i_tableid AND
               o.securitystatustypekey = @v_statustypekey AND
               o.securityobjectvalue = @v_current_status AND
              (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
		           COALESCE(o.securityobjectsubvalue, 0) = COALESCE(@v_current_status_subvalue, 0)                
      END
      ELSE BEGIN
        -- Check security for no status
        -- user override 
        SELECT @v_count = count(*)   
          FROM securityobjects o,securityobjectsavailable a
         WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
               a.windowid = @windowid_var AND
               o.userkey = @i_userkey AND
               o.datacode = @i_datacode AND
               o.datasubcode = @i_datasubcode AND
               a.availobjectcodetableid = @i_tableid AND
              (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
               COALESCE(o.securitystatustypekey,0) = 0 AND
               COALESCE(o.securityobjectvalue,0) = 0

        IF @v_count > 0 BEGIN 
          SELECT @object_accessind_var = accessind
            FROM securityobjects o,securityobjectsavailable a
           WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
                 a.windowid = @windowid_var AND
                 o.userkey = @i_userkey AND
                 o.datacode = @i_datacode AND
                 o.datasubcode = @i_datasubcode AND
                 a.availobjectcodetableid = @i_tableid AND
                (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
                 COALESCE(o.securitystatustypekey,0) = 0 AND
                 COALESCE(o.securityobjectvalue,0) = 0 
        END 
        ELSE BEGIN
          -- group 
          SELECT @v_count = count(*)   
            FROM securityobjects o,securityobjectsavailable a
           WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
                 a.windowid = @windowid_var AND
                 o.securitygroupkey = @securitygroupkey_var AND
                 o.datacode = @i_datacode AND
                 o.datasubcode = @i_datasubcode AND
                 a.availobjectcodetableid = @i_tableid AND
                (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
                 COALESCE(o.securitystatustypekey,0) = 0 AND
                 COALESCE(o.securityobjectvalue,0) = 0 
                 
          IF @v_count > 0 BEGIN
            SELECT @object_accessind_var = accessind
              FROM securityobjects o,securityobjectsavailable a
             WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
                   a.windowid = @windowid_var AND
                   o.securitygroupkey = @securitygroupkey_var AND
                   o.datacode = @i_datacode AND
                   o.datasubcode = @i_datasubcode AND
                   a.availobjectcodetableid = @i_tableid AND
                  (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
                   COALESCE(o.securitystatustypekey,0) = 0 AND
                   COALESCE(o.securityobjectvalue,0) = 0
          END
        END
      END
    END
   
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      CLOSE status_cur 
      DEALLOCATE status_cur 
      RETURN 0
    END 
     
    IF @object_accessind_var = 0 BEGIN
      -- no access found for a status - nothing more to check
      CLOSE status_cur 
      DEALLOCATE status_cur 
      RETURN 0
    END
    
    if @object_accessind_var <> @return_accessind_var begin
      set @return_accessind_var = @object_accessind_var
    end  
 
    get_next_status:
    FETCH status_cur INTO @v_statustypekey,@v_status_tablename,@v_status_columnname
  END
  CLOSE status_cur 
  DEALLOCATE status_cur 
  
  IF @v_at_least_one_status_setup = 0 BEGIN
    -- No statuses that are configured for security were filled in 
    -- Check security for no status
    -- user override 
    SELECT @v_count = count(*)   
      FROM securityobjects o,securityobjectsavailable a
     WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
           a.windowid = @windowid_var AND
           o.userkey = @i_userkey AND
           o.datacode = @i_datacode AND
           o.datasubcode = @i_datasubcode AND
           a.availobjectcodetableid = @i_tableid AND
          (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
           COALESCE(o.securitystatustypekey,0) = 0 AND
           COALESCE(o.securityobjectvalue,0) = 0

    IF @v_count > 0 BEGIN 
      SELECT @object_accessind_var = accessind
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
             a.windowid = @windowid_var AND
             o.userkey = @i_userkey AND
             o.datacode = @i_datacode AND
             o.datasubcode = @i_datasubcode AND
             a.availobjectcodetableid = @i_tableid AND
            (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
             COALESCE(o.securitystatustypekey,0) = 0 AND
             COALESCE(o.securityobjectvalue,0) = 0 
    END 
    ELSE BEGIN
      -- group 
      SELECT @v_count = count(*)   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             o.datacode = @i_datacode AND
             o.datasubcode = @i_datasubcode AND
             a.availobjectcodetableid = @i_tableid AND
            (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
             COALESCE(o.securitystatustypekey,0) = 0 AND
             COALESCE(o.securityobjectvalue,0) = 0 
             
      IF @v_count > 0 BEGIN
        SELECT @object_accessind_var = accessind
          FROM securityobjects o,securityobjectsavailable a
         WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
               a.windowid = @windowid_var AND
               o.securitygroupkey = @securitygroupkey_var AND
               o.datacode = @i_datacode AND
               o.datasubcode = @i_datasubcode AND
               a.availobjectcodetableid = @i_tableid AND
              (ISNULL(o.firstprintingind, 'N') = 'N' OR ISNULL(@v_printingkey, 1) = 1) AND
               COALESCE(o.securitystatustypekey,0) = 0 AND
               COALESCE(o.securityobjectvalue,0) = 0
      END
    END
  END
  
  IF @object_accessind_var <> @return_accessind_var BEGIN
    SET @return_accessind_var = @object_accessind_var
  END  
  
  RETURN @return_accessind_var
END
GO

GRANT EXEC ON dbo.qutl_check_subgentable_value_security_by_status TO public
GO
