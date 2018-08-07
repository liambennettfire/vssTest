IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_page_object_security')
  BEGIN
    PRINT 'Dropping Procedure qutl_check_page_object_security'
    DROP  Procedure  qutl_check_page_object_security
  END

GO

PRINT 'Creating Procedure qutl_check_page_object_security'
GO

CREATE PROCEDURE qutl_check_page_object_security
 (@i_userkey  integer,
  @i_windowname varchar(100),
  @i_wherecolumnkey1 integer,
  @i_wherecolumnkey2 integer,
  @i_wherecolumnkey3 integer,
  @o_accesscode  integer output,
  @o_objectlist_xml varchar(4000) output,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/*****************************************************************************************
**  Name: qutl_check_page_object_security
**  Desc: This stored procedure is used to get the object security for the current page.
**
**    Parameters:
**    Input              
**    ----------         
**    userkey - userkey for userid trying to access window
**    windowname - Name of Page to check security
**    wherecolumnkey1 - first key needed to check status - Pass 0 if not applicable
**    wherecolumnkey2 - second key needed to check status - Pass 0 if not applicable
**    
**    Output
**    -----------
**    accesscode - 0(No Access)/1(Read Only)/2(Update)
**    objectlist_xml - XML string listing all objects that have readonly and no access 
**                     security
**    error_code - error code
**    error_desc - error message or no access message - empty if read only or update
**
**    Auth: Alan Katzen
**    Date: 2/25/04
*******************************************************************************/

  -- default accesscode to 2 - only "ALL" object security OR error can change it
  SET @o_accesscode = 2
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_objectlist_xml = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @windowcatergoryid_var INT,
          @windowid_var INT,
          @windowtitle_var VARCHAR(100),
          @securitystatustypekey_var INT,   
          @hold_statustypekey_var INT,   
          @securityobjectvalue_var INT,  
          @securityobjectsubvalue_var INT,              
          @remote_statusvalue_var INT,
          @remote_substatusvalue_var INT,             
          @object_accessind_var INT,   
          @firstprintingind_var CHAR(1),   
          @availobjectid_var VARCHAR(50),   
          @availobjectname_var VARCHAR(50),   
          @availobjectdesc_var VARCHAR(50),   
          @menuitemid_var VARCHAR(50),   
          @menuitemname_var VARCHAR(50),   
          @menuitemdesc_var VARCHAR(50),
          @orglevel_access_filterkey_var INT,
          @tablename_var NVARCHAR(50),
          @columnname_var NVARCHAR(50),
          @subcolumnname_var NVARCHAR(50),          
          @wherecolumn1_var VARCHAR(50), 
          @wherecolumn2_var VARCHAR(50),
          @wherecolumn3_var VARCHAR(50),
          @wherestring_var NVARCHAR(4000),
          @SQLString_var NVARCHAR(4000),
          @xmlstring_var VARCHAR(4000),
          @printingnum_var INT,
          @objectstring_var VARCHAR(2000),
          @count_var TINYINT,
          @roString_var VARCHAR(100),
          @naString_var VARCHAR(100),
          @strPos INT,
          @v_count  INT

  -- Userorglevelaccess filterkey on filterorglevel table
  SET @orglevel_access_filterkey_var = 7
  SET @xmlstring_var = '<Security>'
  SET @count_var = 0

  SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
    FROM qsiusers
   WHERE userkey = @i_userkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Userid not setup on qsiusers table.'
    RETURN
  END 

  -- All users must be part of a security group
  IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Userid is not a member of a security group.'
    RETURN
  END 

  -- Get window information
  SELECT @windowcatergoryid_var=windowcategoryid,@windowid_var=q.windowid,@windowtitle_var=windowtitle
    FROM qsiwindows q
   WHERE q.windowname = @i_windowname

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_accesscode = 0
    SET @o_error_desc = 'Unable to check object security: Database Error accessing qsiwindows table (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  -- Some pages/windows should always be accessible (like a home page) - just return update access
  IF @windowcatergoryid_var=6 OR @windowcatergoryid_var=26 OR @windowcatergoryid_var=40 OR 
     @windowcatergoryid_var=104 OR @windowcatergoryid_var = 120 BEGIN
    SET @o_error_code = 0
    SET @o_accesscode = 2
    SET @o_error_desc = ''
    RETURN
  END

  IF @windowtitle_var IS NULL
    SET @windowtitle_var = @i_windowname

  -- Object Security
  -- This will return all objects on the page that have "Read Only" or "No Access" security as an XML string
  -- If "Read Only" or "No Access" security is set for all objects - change the accesscode if applicable
  -- Must check both security group rows and user override rows - Check security group rows first so that 
  -- user override rows will come last in the XML string so that the page will set the correct security
  WHILE @count_var < 2 BEGIN
    SET @count_var = @count_var + 1
    SET @hold_statustypekey_var = 0

    --PRINT @count_var

    -- Sortorder is used in order by as descending because 'ALL' should have the highest sortorder
    -- and we may not have to check all the individual controls (depending on how security is set for 'ALL')  
    IF @count_var = 1 BEGIN 
     -- Check security for group security rows - must be before override rows
     DECLARE securityobjects_cursor CURSOR FOR
      SELECT securitystatustypekey,securityobjectvalue,securityobjectsubvalue,accessind,firstprintingind,availobjectid,availobjectname,   
             availobjectdesc,menuitemid,menuitemname,menuitemdesc   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey and  
             a.windowid = @windowid_var AND
             o.securitygroupkey = @securitygroupkey_var AND
             --a.availobjectname is not null AND
             COALESCE(a.availobjectwholerowind,0) = 0
    ORDER BY securitystatustypekey ASC, a.sortorder DESC, accessind DESC
    END 
    ELSE BEGIN
      -- Check security for user override rows
     DECLARE securityobjects_cursor CURSOR FOR
      SELECT securitystatustypekey,securityobjectvalue,securityobjectsubvalue,accessind,firstprintingind,availobjectid,availobjectname,   
             availobjectdesc,menuitemid,menuitemname,menuitemdesc   
        FROM securityobjects o,securityobjectsavailable a
       WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
             a.windowid = @windowid_var AND
             o.userkey = @i_userkey AND
             --a.availobjectname is not null AND
             COALESCE(a.availobjectwholerowind,0) = 0
    ORDER BY securitystatustypekey ASC, a.sortorder DESC, accessind DESC
    END

    OPEN securityobjects_cursor

    FETCH NEXT FROM securityobjects_cursor INTO
           @securitystatustypekey_var,@securityobjectvalue_var,@securityobjectsubvalue_var,@object_accessind_var,@firstprintingind_var,   
           @availobjectid_var,@availobjectname_var,@availobjectdesc_var,@menuitemid_var,@menuitemname_var,   
           @menuitemdesc_var   

    WHILE @@FETCH_STATUS = 0 BEGIN

--      PRINT '--'
--      PRINT '@securitystatustypekey_var: ' + convert(varchar, @securitystatustypekey_var)
--      PRINT '@securityobjectvalue_var: ' + convert(varchar, @securityobjectvalue_var)
--      PRINT '@object_accessind_var: ' + convert(varchar, @object_accessind_var)
--      PRINT '@firstprintingind_var: ' + @firstprintingind_var

      -- check firstprintingind - if it is 'Y', then object security is only for the first printing
      IF upper(@firstprintingind_var) = 'Y' BEGIN
        SET @printingnum_var = 0
        -- Need to have @i_wherecolumnkey1 AND @i_wherecolumnkey2 be bookkey and printingkey
        -- there is no way to verify this here, so responsibility falls on calling location
        IF @i_wherecolumnkey1 > 0 AND @i_wherecolumnkey2 > 0 BEGIN
          SELECT @printingnum_var=printingnum
            FROM printing
           WHERE bookkey = @i_wherecolumnkey1 AND printingkey = @i_wherecolumnkey2;

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
            SET @o_error_code = -1
            SET @o_accesscode = 0
            SET @o_error_desc = 'Unable to check object security: Database Error accessing printing table (' + cast(@error_var AS VARCHAR) + ').'
            CLOSE securityobjects_cursor
            DEALLOCATE securityobjects_cursor
            RETURN
          END 
        END
        ELSE BEGIN
          -- error - need both bookkey and printingkey to be filled in - go on to next object
          GOTO fetchnext
        END
        IF @printingnum_var <> 1 BEGIN
          -- not first printing
          GOTO fetchnext
        END
      END

      IF @securityobjectvalue_var IS NULL OR @securityobjectvalue_var <= 0 BEGIN
        -- no object status chosen so no restriction on status
        -- write to xml file if "Read Only" OR "No Access"
        IF upper(@availobjectid_var) = 'ALL' BEGIN
        
          -- 2/7/11 - KW - Check if user override row exists for this windowid and availobjectid = 'ALL'.
          -- If so, continue processing - we want to get to the processing of the override row
          SELECT @v_count = COUNT(*)
          FROM securityobjects o, securityobjectsavailable a
          WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
            a.windowid = @windowid_var AND
            o.userkey = @i_userkey AND
            o.securityobjectvalue = @securityobjectvalue_var AND
            o.securityobjectsubvalue = @securityobjectsubvalue_var AND               
            UPPER(a.availobjectid) = 'ALL' AND
            COALESCE(a.availobjectwholerowind,0) = 0          
        
          IF @v_count > 0 BEGIN
            GOTO fetchnext
          END
          ELSE BEGIN        
            -- "ALL" means all objects on the page - Page level security
            SET @o_accesscode = @object_accessind_var
            IF @object_accessind_var = 0 AND @count_var > 1 BEGIN
              -- Done. Page security is "No Access" - doesn't matter what individual object security is
              SET @o_error_code = 0
              SET @o_error_desc = 'Access Denied: ' + @userid_var + ' does not have access to ' + @windowtitle_var + '.'
              CLOSE securityobjects_cursor
              DEALLOCATE securityobjects_cursor
              RETURN
            END
          END
        END
        ELSE BEGIN
          SET @objectstring_var = @availobjectid_var
          IF @availobjectname_var IS NOT NULL AND ltrim(rtrim(@availobjectname_var)) <> '' BEGIN
            SET @objectstring_var = @objectstring_var + '.' + @availobjectname_var
          END
   
          IF @object_accessind_var = 0 BEGIN
            -- no access 
            SET @xmlstring_var = @xmlstring_var + ' <NA>' + @objectstring_var + '</NA>'  
          END  
          IF @object_accessind_var = 1 BEGIN
            -- read only
            SET @xmlstring_var = @xmlstring_var + ' <RO>' + @objectstring_var + '</RO>'  
            SET @naString_var = '% <NA>' + @objectstring_var + '</NA>%'
              select @strPos = patindex(@naString_var, @xmlstring_var)
              IF @strPos > 0
              BEGIN
                  select @xmlstring_var = REPLACE(@xmlstring_var,REPLACE(@naString_var,'%',''),'')
              END 
          END 
          IF @object_accessind_var = 2 BEGIN
                -- Update option has been set for a specific field.  By default, TMMWeb considers all fields update
                -- accessible.  If a field has been individually set for update, this can indicate that at the group 
                -- level users by default have NA or RO.  If a specific user is give update, remove the group level
                -- permission.
                IF @count_var = 2 
                BEGIN
                    SET @roString_var = '% <RO>' + @objectstring_var + '</RO>%'
                    SET @naString_var = '% <NA>' + @objectstring_var + '</NA>%'

                    select @strPos = patindex(@roString_var, @xmlstring_var)
                    IF @strPos > 0
                    BEGIN
                        select @xmlstring_var = REPLACE(@xmlstring_var,REPLACE(@roString_var,'%',''),'')
                    END

                    select @strPos = patindex(@naString_var, @xmlstring_var)
                    IF @strPos > 0
                    BEGIN
                        select @xmlstring_var = REPLACE(@xmlstring_var,REPLACE(@naString_var,'%',''),'')
                    END            
                END
            END
        END
        GOTO fetchnext
      END

      IF @securitystatustypekey_var > 0 AND @hold_statustypekey_var <> @securitystatustypekey_var BEGIN
        SET @hold_statustypekey_var = @securitystatustypekey_var

        -- get "current" status
        SELECT @tablename_var=tablename, @columnname_var=columnname, @subcolumnname_var=subcolumnname,
               @wherecolumn1_var=wherecolumn1, @wherecolumn2_var=wherecolumn2, @wherecolumn3_var=wherecolumn3
          FROM securitystatustype
         WHERE securitystatustypekey = @securitystatustypekey_var;

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
          SET @o_error_code = -1
          SET @o_accesscode = 0
          SET @o_error_desc = 'Unable to check object security: Database Error accessing securitystatustype table (' + cast(@error_var AS VARCHAR) + ').'
          CLOSE securityobjects_cursor
          DEALLOCATE securityobjects_cursor
          RETURN
        END 

        -- dynamically build SQL statement to retrieve status (@remote_statusvalue_var)
        IF @columnname_var IS NULL OR @tablename_var IS NULL BEGIN
          -- can't create SQL statement, so can't check status
          SET @o_error_code = -1
          SET @o_accesscode = 0
          SET @o_error_desc = 'Unable to check object security: Data Error on securitystatustype table. Either tablename ' 
                            + 'or columnname is empty (securitystatustypekey = ' + cast(@securitystatustypekey_var AS VARCHAR) + ').'
          CLOSE securityobjects_cursor
          DEALLOCATE securityobjects_cursor
          RETURN
        END

        SET @remote_statusvalue_var = 0
        SET @SQLString_var = N'SELECT @remote_statusvalue_var=COALESCE(' + @columnname_var + N',9999), @remote_substatusvalue_var=COALESCE(' + COALESCE(@subcolumnname_var, 'NULL') + N',9999) FROM ' +  @tablename_var

        -- Reset @wherestring_var
        SET @wherestring_var = N''
        IF (@wherecolumn1_var IS NOT NULL AND @i_wherecolumnkey1 > 0) OR (@wherecolumn2_var IS NOT NULL AND @i_wherecolumnkey2 > 0)
            OR (@wherecolumn3_var IS NOT NULL AND @i_wherecolumnkey3 > 0)
        BEGIN
          -- dynamically build where clause
          IF (@wherecolumn1_var IS NOT NULL AND @i_wherecolumnkey1 > 0) AND (@wherecolumn2_var IS NOT NULL AND @i_wherecolumnkey2 > 0)
              AND (@wherecolumn3_var IS NOT NULL AND @i_wherecolumnkey3 > 0) BEGIN
            SET @wherestring_var = N' WHERE ' + @wherecolumn1_var + N'=' + cast(@i_wherecolumnkey1 AS NVARCHAR) + N' AND ' 
                                              + @wherecolumn2_var + N'=' + cast(@i_wherecolumnkey2 AS NVARCHAR) + N' AND ' 
                                              + @wherecolumn3_var + N'=' + cast(@i_wherecolumnkey3 AS NVARCHAR)
          END
          ELSE IF (@wherecolumn1_var IS NOT NULL AND @i_wherecolumnkey1 > 0) AND (@wherecolumn2_var IS NOT NULL AND @i_wherecolumnkey2 > 0) BEGIN
            SET @wherestring_var = N' WHERE ' + @wherecolumn1_var + N'=' + cast(@i_wherecolumnkey1 AS NVARCHAR) + N' AND ' 
                                              + @wherecolumn2_var + N'=' + cast(@i_wherecolumnkey2 AS NVARCHAR)
          END
          ELSE BEGIN
            IF (@wherecolumn1_var IS NOT NULL AND @i_wherecolumnkey1 > 0) BEGIN
              SET @wherestring_var = N' WHERE ' + @wherecolumn1_var + N'=' + cast(@i_wherecolumnkey1 AS NVARCHAR) 
            END
            ELSE BEGIN
              SET @wherestring_var = N' WHERE ' + @wherecolumn2_var + N'=' + cast(@i_wherecolumnkey2 AS NVARCHAR) 
            END
          END
          --PRINT @wherestring_var

          SET @SQLString_var = @SQLString_var + @wherestring_var
          --PRINT @SQLString_var
      
          EXECUTE sp_executesql @SQLString_var, N'@remote_statusvalue_var int output, @remote_substatusvalue_var int output',
								@remote_statusvalue_var = @remote_statusvalue_var output, @remote_substatusvalue_var = @remote_substatusvalue_var output
          --PRINT '@remote_statusvalue_var = ' + cast(@remote_statusvalue_var AS VARCHAR)
        END
      END

      IF @securityobjectvalue_var > 0 AND (@remote_statusvalue_var IS NULL OR @remote_statusvalue_var <= 0) BEGIN
        -- nothing to check object status with 
        GOTO fetchnext
      END

     --PRINT '@availobjectid_var = ' + @availobjectid_var
     --PRINT '@securityobjectvalue_var = ' + cast(@securityobjectvalue_var AS VARCHAR)
     --PRINT '@remote_statusvalue_var = ' + cast(@remote_statusvalue_var AS VARCHAR)
     IF @securityobjectvalue_var > 0 AND @remote_statusvalue_var > 0 BEGIN
        IF @securityobjectvalue_var = @remote_statusvalue_var AND
          (@securityobjectsubvalue_var = @remote_substatusvalue_var OR COALESCE(@securityobjectsubvalue_var, 0) = 0)BEGIN
          -- write to xml file if "Read Only" OR "No Access"
          IF upper(@availobjectid_var) = 'ALL' BEGIN
          
            -- 2/7/11 - KW - Check if user override row exists for this windowid and availobjectid = 'ALL'.
            -- If so, continue processing - we want to get to the processing of the override row
            SELECT @v_count = COUNT(*)
            FROM securityobjects o, securityobjectsavailable a
            WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
              a.windowid = @windowid_var AND
              o.userkey = @i_userkey AND
              o.securityobjectvalue = @securityobjectvalue_var AND
              o.securityobjectsubvalue = @securityobjectsubvalue_var AND              
              a.availobjectid = 'ALL' AND
              COALESCE(a.availobjectwholerowind,0) = 0          
          
            IF @v_count > 0 AND @count_var = 1 BEGIN
              GOTO fetchnext
            END
            ELSE BEGIN
              -- "ALL" means all objects on the page - Page level security
              SET @o_accesscode = @object_accessind_var
              IF @object_accessind_var = 0 BEGIN
                -- Done. Page security is "No Access" - doesn't matter what individual object security is
                SET @o_error_code = 0
                SET @o_error_desc = 'Access Denied: ' + @userid_var + ' does not have access to ' + @windowtitle_var + '.'
                CLOSE securityobjects_cursor
                DEALLOCATE securityobjects_cursor
                RETURN
              END
            END
          END
          ELSE BEGIN
            -- 3/1/11 - KW - Check if user override row exists for this windowid and availobjectid.
            -- If so, continue processing - we want to get to the processing of the override row
            SELECT @v_count = COUNT(*)
            FROM securityobjects o, securityobjectsavailable a
            WHERE o.availsecurityobjectkey = a.availablesecurityobjectskey AND  
              a.windowid = @windowid_var AND
              o.userkey = @i_userkey AND
              o.securityobjectvalue = @securityobjectvalue_var AND
              o.securityobjectsubvalue = @securityobjectsubvalue_var AND              
              UPPER(a.availobjectid) = UPPER(@availobjectid_var) AND
              COALESCE(a.availobjectwholerowind,0) = 0          
          
            IF @v_count > 0 AND @count_var = 1 BEGIN
              GOTO fetchnext
            END
            ELSE BEGIN          
              SET @objectstring_var = @availobjectid_var
              IF @availobjectname_var IS NOT NULL AND ltrim(rtrim(@availobjectname_var)) <> '' BEGIN
                SET @objectstring_var = @objectstring_var + '.' + @availobjectname_var
              END
     
              IF @object_accessind_var = 0 BEGIN
                -- no access 
                SET @xmlstring_var = @xmlstring_var + ' <NA>' + @objectstring_var + '</NA>'  
              END  
              IF @object_accessind_var = 1 BEGIN
                -- read only
                SET @xmlstring_var = @xmlstring_var + ' <RO>' + @objectstring_var + '</RO>'  
              END
              IF @object_accessind_var = 2 BEGIN
                  -- Update option has been set for a specific field.  By default, TMMWeb considers all fields update
                  -- accessible.  If a field has been individually set for update, this can indicate that at the group 
                  -- level users by default have NA or RO.  If a specific user is give update, remove the group level
                  -- permission.
                  IF @count_var = 2 
                  BEGIN
                      SET @roString_var = '% <RO>' + @objectstring_var + '</RO>%'
                      SET @naString_var = '% <NA>' + @objectstring_var + '</NA>%'

                      select @strPos = patindex(@roString_var, @xmlstring_var)
                      IF @strPos > 0
                      BEGIN
                          select @xmlstring_var = REPLACE(@xmlstring_var,REPLACE(@roString_var,'%',''),'')
                      END

                      select @strPos = patindex(@naString_var, @xmlstring_var)
                      IF @strPos > 0
                      BEGIN
                          select @xmlstring_var = REPLACE(@xmlstring_var,REPLACE(@naString_var,'%',''),'')
                      END            
                  END
              END
            END
          END
        END
      END

      fetchnext:
      FETCH NEXT FROM securityobjects_cursor INTO
             @securitystatustypekey_var,@securityobjectvalue_var,@securityobjectsubvalue_var,@object_accessind_var,@firstprintingind_var,   
             @availobjectid_var,@availobjectname_var,@availobjectdesc_var,@menuitemid_var,@menuitemname_var,   
             @menuitemdesc_var   
    END  --while

    CLOSE securityobjects_cursor
    DEALLOCATE securityobjects_cursor
  END  --while

  
  
  SET @xmlstring_var = @xmlstring_var + ' </Security>'
  SET @o_objectlist_xml = @xmlstring_var
  RETURN 
GO

GRANT EXEC ON qutl_check_page_object_security TO PUBLIC
GO
