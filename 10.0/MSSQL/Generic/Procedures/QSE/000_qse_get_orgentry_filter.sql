IF EXISTS (
    SELECT *
    FROM sysobjects
    WHERE type = 'P'
      AND name = 'qse_get_orgentry_filter'
    )
BEGIN
  DROP PROCEDURE qse_get_orgentry_filter
END
GO

SET NOCOUNT ON
GO

/******************************************************************************
**  Name: qse_get_orgentry_filter
**  Desc: Break the org entry filter logic out of the bloated qse_search_request
**  Auth: 
**  Date: 05/02/2018
--*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*******************************************************************************/
CREATE PROCEDURE qse_get_orgentry_filter (
  @i_searchtype INT,
  @i_orgentry_filter VARCHAR(MAX),
  @i_userkey INT,
  @i_include_non_orgentries INT,
  @o_orgentry_tablename VARCHAR(50) OUTPUT,
  @o_orgentry_joinwhere VARCHAR(max) OUTPUT,
  @o_orgentry_wherecriteria VARCHAR(max) OUTPUT,
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(max) OUTPUT
  )
AS
BEGIN
    DECLARE
    @AccessInd INT,
    @CheckOrgentryKey INT,
    @CheckOrglevelKey INT,
    @FilterKey INT,
    @FilterOrglevelKey INT,
    @OrgSecurityFilter VARCHAR(MAX),
    @OrgentryKey INT,
    @OrgentryParentKey INT,
    @OrgentrySQLUnion VARCHAR(MAX),
    @FilterOrgCriteria VARCHAR(MAX),
    @TempOrgentryKey INT,
    @SearchItem INT,
    @OrglevelKey INT

  SET @o_orgentry_joinwhere = ''
  SET @o_orgentry_wherecriteria = ''
  SET @o_orgentry_tablename = ''

  -- ************ ORGENTRY SECURITY FILTER ************ -- 
  IF @i_searchtype <> 16 --not for list searches
  BEGIN  
    IF @i_searchtype = 1 OR @i_searchtype = 6 OR @i_searchtype = 9 OR @i_searchtype = 26 OR @i_searchtype = 27		-- Titles
      BEGIN
        SET @SearchItem = 1
        SET @o_orgentry_tablename = 'bookorgentry'
      END
    ELSE IF @i_searchtype = 7 OR @i_searchtype = 10     -- Projects
      BEGIN
        SET @SearchItem = 3
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END
    ELSE IF @i_searchtype = 8						-- Contacts
      BEGIN
        SET @SearchItem = 2
        SET @o_orgentry_tablename = 'globalcontactorgentry'
      END
    ELSE IF @i_searchtype = 16        -- Search Results Lists
      BEGIN
        SET @SearchItem = 4
        SET @o_orgentry_tablename = ''
      END
    ELSE IF @i_searchtype = 17        -- User Admin
      BEGIN
        SET @SearchItem = 5
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END
    ELSE IF @i_searchtype = 18        -- journals
      BEGIN
        SET @SearchItem = 6
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END
    ELSE IF (@i_searchtype = 19 or @i_searchtype = 20)    -- task view and task group
      BEGIN
        SET @SearchItem = 8
        SET @o_orgentry_tablename = 'taskview'
      END
    ELSE IF @i_searchtype = 22        -- works
      BEGIN
        SET @SearchItem = 9
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END
    ELSE IF @i_searchtype = 23		-- P&L versions
      BEGIN
        SET @SearchItem = 12
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END
    ELSE IF @i_searchtype = 25     -- Contracts
      BEGIN
        SET @SearchItem = 10
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END
    ELSE IF @i_searchtype = 24     -- Scales
      BEGIN
        SET @SearchItem = 11
        SET @o_orgentry_tablename = 'taqprojectscaleorgentry'
      END
    ELSE IF @i_searchtype = 28     -- Printings
      BEGIN
        SET @SearchItem = 14
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END  
    ELSE IF @i_searchtype = 29     -- Purchase Orders
      BEGIN
        SET @SearchItem = 15
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END   
    ELSE IF @i_searchtype = 30     -- Specification Template
      BEGIN
        SET @SearchItem = 5          -- User Admin
        SET @o_orgentry_tablename = 'taqprojectorgentry'
      END

    IF @i_searchtype = 24
      SET @FilterKey = 11 --Scales
    ELSE
      SET @FilterKey = 7  --User Org Access Level
      
    SELECT @FilterOrglevelKey = filterorglevelkey
    FROM filterorglevel
    WHERE filterkey = @FilterKey
    
    IF @@ERROR <> 0 OR @@ROWCOUNT = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to get filterorglevelkey for filterkey=' + CONVERT(VARCHAR, @FilterKey) + '.'
      GOTO ExitHandler
    END
    
    -- Initialize Org security filter to single space
    SET @OrgSecurityFilter = ' '  
    
    -- When no Orgentry Filter was entered on the screen by the user, user requests all items:
    -- must use orglevel security for this user to limit access only to items user has access to.
    -- do not use user orglevel security for task view and group searches
    IF @i_orgentry_filter = ' ' and @i_searchtype <> 19 and @i_searchtype <> 20
    BEGIN    
      -- Call procedure that builds the orgentry security filter string for this user,
      -- which will consist of all orgentrykeys this user has ReadOnly or Update access
      -- (orgentrykeys at the level we check security and all their parent orgentrykeys)
      EXEC qutl_get_user_orgsecurityfilter @i_userkey, 0, @FilterKey, @OrgSecurityFilter OUTPUT, 
        @o_error_code OUTPUT, @o_error_desc OUTPUT
    END

    -- When OrgentryFilter is passed inside the XML file, we must include the Orgentry Filter entered on the screen
    -- BUT only if the orgentry filter selection belongs under the orgentry this user has security for.
    -- If the user has no access to the selection, we should retrieve nothing.
    -- (NOTE: OrgentryFilter holds the LAST entered orgentrykey selection)
    IF @i_orgentry_filter <> ' ' --Orgentry Filter entered on the screen
      BEGIN
        -- Set OrgentryKey to the last entry entered on the screen as filter
        SET @OrgentryKey = CONVERT(INT, @i_orgentry_filter)
        
        -- Set OrglevelKey to the corresponding level of the OrgentryKey above
        SELECT @OrglevelKey = orglevelkey
        FROM orgentry
        WHERE orgentrykey = @OrgentryKey
        
        IF @@ERROR <> 0 OR @@ROWCOUNT = 0
        BEGIN    
          SET @o_error_code = -1
          SET @o_error_desc = 'Unable to get orglevelkey from orgentry table (orgentrykey=' + CONVERT(VARCHAR, @OrgentryKey) + ')'
          GOTO ExitHandler
        END
        
        -- If the level of the Orgentry Filter on the screen matches the level at which we check security,
        -- check if user has security to the orgentrykey entered on the screen as Orgentry Filter
        IF @OrglevelKey = @FilterOrglevelKey
        BEGIN
          -- Check security
          EXEC qutl_check_user_orgsecurity @i_userkey, @OrgentryKey, @AccessInd OUTPUT, 
            @o_error_code OUTPUT, @o_error_desc OUTPUT
            
          IF @AccessInd = 1 OR @AccessInd = 2 --ReadOnly of FullAccess security
          BEGIN
            -- The orgentry filter entered on search page is valid
            -- because it falls under one of the orgentries user DOES have security for.
            -- OVERRIDE orgsecurityfilter with the more detailed filter entered on search page.
            SET @OrgSecurityFilter = @i_orgentry_filter
          END
          ELSE
            SET @OrgSecurityFilter = '-1' --fake filter will retrieve nothing
        END --@OrglevelKey = @FilterOrglevelKey

        -- If the level of the Orgentry Filter of the screen is more detailed than (below) the level at which we check security,
        -- loop through parentorgentrykeys to get to the security level, and check security
        IF @OrglevelKey > @FilterOrglevelKey
        BEGIN
          --****** Must filter by what's on screen, but only if user has security ******--
          -- Initialize filter to fake filter which will retrieve nothing
          SET @OrgSecurityFilter = '-1'
          -- Initialize CheckOrgentryKey to first perform the check on lowest orgentrykey in Orgentry Filter on the screen
          SET @CheckOrgentryKey = @OrgentryKey
          
          -- Loop to check the parent orgentrykey until we can read orgentry security for this user      
          WHILE (@CheckOrgentryKey <> 0)
          BEGIN
          
            -- Get the parent orgentrykey for the selected orgentry
            SELECT @OrgentryParentKey = orgentryparentkey
            FROM orgentry
            WHERE orgentrykey = @CheckOrgentryKey
            
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Unable to get orgentryparentkey from orgentry table (orgentrykey=' + CONVERT(VARCHAR, @CheckOrgentryKey) + ')'
              GOTO ExitHandler
            END
            
            -- Get the orglevelkey for the parentorgentrykey above
            SELECT @CheckOrglevelKey = orglevelkey
            FROM orgentry
            WHERE orgentrykey = @OrgentryParentKey
            
            IF @@ERROR <> 0 OR @@ROWCOUNT = 0
            BEGIN           
              SET @o_error_code = -1
              SET @o_error_desc = 'Unable to get orglevelkey from orgentry table (orgentrykey=' + CONVERT(VARCHAR, @OrgentryParentKey) + ')'
              GOTO ExitHandler
            END
                       
            -- If this org level is the level where we check org access security, check orglevel security for this user
            IF (@CheckOrglevelKey = @FilterOrglevelKey)
            BEGIN
              -- Check security
              EXEC qutl_check_user_orgsecurity @i_userkey, @OrgentryParentKey, @AccessInd OUTPUT, 
                @o_error_code OUTPUT, @o_error_desc OUTPUT
                
              IF @AccessInd = 1 OR @AccessInd = 2 --ReadOnly or FullAccess security
              BEGIN
                -- The orgentry filter entered on search page is valid
                -- because it falls under one of the orgentries user DOES have security for.
                -- OVERRIDE orgsecurityfilter with the more detailed filter entered on search page.
                SET @OrgSecurityFilter = @i_orgentry_filter
              END
      		    
              -- We are at the level org security is checked, so we are done - EXIT
              BREAK
                  	      
            END --IF (@CheckOrglevelKey = @FilterOrglevelKey)
              
            -- Initialize orgentrykey to the parentkey
            SET @CheckOrgentryKey = @OrgentryParentKey          
           
          END --WHILE (@CheckOrgentryKey <> 0)                
        END --@OrglevelKey > @FilterOrglevelKey
          
          
        -- If the level of the Orgentry Filter of the screen is LESS detailed than the level at which we check security,
        -- loop through all org security rows and for each, loop through parentorgentrykeys up until we get to the level
        -- of the Orgentry Filter to check if the Filter's orgentrykey falls under security for this user.
        IF @OrglevelKey < @FilterOrglevelKey  --level ABOVE the security level
        BEGIN
          -- ****** Must filter by what's on screen, but only if user has security ****** --
          IF @i_searchtype = 24 OR @i_searchtype = 19 OR @i_searchtype = 20  -- for Scales and task groups/views, initialize filter to 0-All orgentries
            SET @OrgSecurityFilter = '0'
          ELSE -- in all other cases, initialize filter to fake filter which will retrieve nothing
            SET @OrgSecurityFilter = '-1'
	        
          -- Loop through org security rows for this user to get to the level of the Orgentry Filter on the screen
          DECLARE orgsecurity_cur CURSOR FOR
            SELECT orgentrykey, accessind
            FROM securityorglevel 
            WHERE orglevelkey = @FilterOrglevelKey AND
              userkey = @i_userkey AND
              accessind > 0
          UNION
            SELECT orgentrykey, accessind
            FROM securityorglevel
            WHERE orglevelkey = @FilterOrglevelKey AND
              accessind > 0 AND
              securitygroupkey IN 
                (SELECT securitygroupkey FROM qsiusers 
                WHERE userkey = @i_userkey) AND
              orgentrykey NOT IN 
                (SELECT orgentrykey FROM securityorglevel s
                WHERE s.orglevelkey = @FilterOrglevelKey AND
                      s.userkey = @i_userkey AND
                      s.accessind = 0)
                	        
          OPEN orgsecurity_cur
          
          FETCH NEXT FROM orgsecurity_cur INTO @CheckOrgentryKey, @AccessInd	
	                  
          WHILE (@@FETCH_STATUS = 0)
          BEGIN
        	  -- Initialize parentkey to the org security orgentrykey being processed so that it gets processed first
            SET @TempOrgentryKey = @CheckOrgentryKey
           
            WHILE (@TempOrgentryKey <> 0 )
            BEGIN  
              -- Get the parent orgentrykey for the selected orgentry
              SELECT @OrgentryParentKey = orgentryparentkey
              FROM orgentry
              WHERE orgentrykey = @TempOrgentryKey
              
              IF @@ERROR <> 0 OR @@ROWCOUNT = 0
              BEGIN
                CLOSE orgsecurity_cur
                DEALLOCATE orgsecurity_cur
                SET @o_error_code = -1
                SET @o_error_desc = 'Unable to get orgentryparentkey from orgentry table (orgentrykey=' + CONVERT(VARCHAR, @TempOrgentryKey) + ')'
                GOTO ExitHandler
              END
              
              -- Get the orglevelkey for the parentorgentrykey above
              SELECT @CheckOrglevelKey = orglevelkey
              FROM orgentry
              WHERE orgentrykey = @OrgentryParentKey
              
              IF @@ERROR <> 0
              BEGIN
                CLOSE orgsecurity_cur
                DEALLOCATE orgsecurity_cur
                SET @o_error_code = -1
                SET @o_error_desc = 'Unable to get orglevelkey from orgentry table (orgentrykey=' + CONVERT(VARCHAR, @OrgentryParentKey) + ')'
                GOTO ExitHandler
              END                   
              
              -- Check if orgentryparentkey's level matches the level of the Orgentry Filter on the screen
              IF @CheckOrglevelKey = @OrglevelKey
              BEGIN
                IF @i_searchtype = 24 OR @i_searchtype = 19 OR @i_searchtype = 20  --Scales, Task Groups/Views
                BEGIN
                  -- For Scales, set orgentry security filter to the orgentrykeys the user has access to
                  IF @OrgentryParentkey = @OrgentryKey
                    SET @OrgSecurityFilter = @OrgSecurityFilter + ',' + CONVERT(VARCHAR, @TempOrgentryKey)
                END
                ELSE
                BEGIN
                  -- Check if orgentrykeys match (the orgentry entered on the screen and the security orgentry)
                  IF @OrgentryParentkey = @OrgentryKey
                  BEGIN
                    --user has access to this orgentry 
                    IF @OrgSecurityFilter = '-1' BEGIN
                      SET @OrgSecurityFilter = @CheckOrgentryKey
                    END
                    ELSE BEGIN
                      SET @OrgSecurityFilter = @OrgSecurityFilter + ',' + CONVERT(VARCHAR, @CheckOrgentryKey)
                    END
                  END

                  -- we are at the level of the Orgentry Filter from the screen - exit this loop
                  BREAK
                END                        
              END

              SET @TempOrgentryKey = @OrgentryParentKey
                              
            END --WHILE (@TempOrgentryKey <> 0)  
              
            IF @OrgSecurityFilter = @i_orgentry_filter
              BREAK
                                      
            FETCH NEXT FROM orgsecurity_cur INTO @CheckOrgentryKey, @AccessInd

          END --WHILE (@@FETCH_STATUS = 0)
               
          CLOSE orgsecurity_cur 
          DEALLOCATE orgsecurity_cur
	        
        END --IF @OrglevelKey < @FilterOrglevelKey    	      
      END --@i_orgentry_filter <> ' '
    
    -- If orglevel security filter is populated,
    -- add corresponding orgentry table join to the search source SQL
    IF @OrgSecurityFilter <> ' ' AND @i_searchtype <> 10
    BEGIN
      IF @i_searchtype <> 19 and @i_searchtype <> 20  -- task view and group searches (orgentrykey is on taskview)
      BEGIN
        -- Get orgentry join from qse_searchtableinfo table
        SELECT @o_orgentry_joinwhere = jointoresultstablewhere
        FROM qse_searchtableinfo
        WHERE searchitemcode = @SearchItem AND 
              UPPER(tablename) = UPPER(@o_orgentry_tablename)

        -- Check if qse_searchtableinfo record exists for this search type and orgentry tablename
        IF @@ERROR <> 0 OR @@ROWCOUNT = 0
        BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Missing qse_searchtableinfo record (SearchItem=' + 
            CONVERT(VARCHAR, @SearchItem) + ', TableName=''' + @o_orgentry_tablename + ''')'
          GOTO ExitHandler
        END
      
	    -- return values with no orgentries as well
  	  IF @i_include_non_orgentries = 1
        SET @o_orgentry_wherecriteria = 'ISNULL(' + @o_orgentry_tablename + '.orgentrykey,0) IN (0,' + @OrgSecurityFilter + ')'
  	  ELSE
        SET @o_orgentry_wherecriteria = @o_orgentry_tablename + '.orgentrykey IN (' + @OrgSecurityFilter + ')'
  	  END

	  END
  END --IF @i_searchtype <> 16

  ExitHandler:

END
GO

GRANT EXEC
  ON qse_get_orgentry_filter
  TO PUBLIC
GO


