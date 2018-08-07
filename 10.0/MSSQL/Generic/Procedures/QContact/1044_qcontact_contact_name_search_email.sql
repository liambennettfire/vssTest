IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcontact_contact_name_search_email]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcontact_contact_name_search_email]
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER OFF
GO

/******************************************************************************
**    Change History
*******************************************************************************
**  Date        Who      Change
**  ----------  -------  ------------------------------------------------------
**  10/11/2017  Colman   Case 47714 - Purge SSN references
*******************************************************************************/

CREATE PROCEDURE [dbo].[qcontact_contact_name_search_email]
(
  @i_SearchName     VARCHAR(255),
  @i_ActiveOnlyInd	BIT,
  @i_PrivateOnlyInd	BIT,
  @i_UserKey        INT,
  @i_PBSelect       TINYINT,
  @i_contract_ind   TINYINT,
  @i_role_code      INT,
  @o_NumberOfRows   INT OUT,
  @o_error_code     INT OUT,
  @o_error_desc     VARCHAR(2000) OUT 
)
AS


BEGIN
  DECLARE 
	@ErrorVar	    INT,
	@RowcountVar        INT,
	@AccessInd          TINYINT,
	@FilterOrglevelKey  INT,
   	@v_optionvalue      INT,
	@CheckUserKey       INT,
	@LastOrgentryKey    INT,
	@OrgentryKey        INT,
	@UserID             VARCHAR(30),
	@OrgSecurityFilter  VARCHAR(2000),
	@SearchSQLUnion     VARCHAR(4000),
	@SQLString		      NVARCHAR(4000)

  SET NOCOUNT ON
  
  -- ******** Get the UserID for the given userkey ****** --
  -- UserID is referenced in get_next_key and contact's private search
  SELECT @UserID = userid
  FROM qsiusers
  WHERE userkey = @i_UserKey

  -- Make sure qsiusers record exists for this userkey
  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get UserID from qsiusers table for UserKey ' + CONVERT(VARCHAR, @i_UserKey)
    RETURN
  END  

  -- Build and EXECUTE the dynamic SELECT statement
  IF @i_PBSelect = 1 BEGIN
    -- 10/3/05 - AK - PB requires additional columns
    SET @SQLString = N'SELECT gc.globalcontactkey,         
        CASE
          WHEN cc.displayname IS NULL THEN
            CASE
              WHEN gc.groupname IS NOT NULL THEN gc.groupname
              ELSE gc.lastname
            END
          ELSE cc.displayname
         END AS displayname,
        gc.searchname, gc.firstname, gc.middlename, gc.suffix, NULL ssn,
        0 selectedind, gc.activeind, cc.email, cc.phone, cc.keyroles, cc.privateind
    FROM globalcontact gc, corecontactinfo cc, globalcontactorgentry o
    WHERE gc.globalcontactkey = cc.contactkey AND
          cc.contactkey = o.globalcontactkey AND
          gc.searchname LIKE UPPER(''' + @i_SearchName + '%'')'

	--if is not called from contract screen exclude private authors
	if @i_contract_ind = 0 begin
    		SET @SQLString = @SQLString + N' and gc.globalcontactkey not in (select gr.globalcontactkey
							from globalcontactrole gr
							where gr.globalcontactkey = gc.globalcontactkey
							and gr.rolecode in ( select datacode
										from gentables 
										where tableid = 285 
										and qsicode =  8)
							)'
	end
	if @i_contract_ind = 1 and @i_role_code > 0 begin
	   SET @SQLString = @SQLString + N' and gc.globalcontactkey  in (select gr.globalcontactkey
					    from globalcontactrole gr
					    where gr.globalcontactkey = gc.globalcontactkey
					    and gr.rolecode = ' + cast(@i_role_code as varchar(20)) + ')'

       end

  END
  ELSE BEGIN
    -- 9/27/05 - KW - Only 4 columns are needed - key, displayname, phone and email
    SET @SQLString = N'SELECT gc.globalcontactkey, 
        CASE
          WHEN cc.displayname IS NULL THEN
            CASE
              WHEN gc.groupname IS NOT NULL THEN gc.groupname
              ELSE gc.lastname
            END
          ELSE cc.displayname
        END AS displayname,
        cc.phone, cc.email
      FROM globalcontact gc, corecontactinfo cc, globalcontactorgentry o
      WHERE gc.globalcontactkey = cc.contactkey AND
        cc.contactkey = o.globalcontactkey AND
        gc.searchname LIKE UPPER(''' + @i_SearchName + '%'')'
  END

  -- If return only active flag is set to TRUE (1), limit results to active contacts only.
  IF @i_ActiveOnlyInd = 1
    SET @SQLString = @SQLString + N' AND gc.activeind = 1'

  -- If return only private flag is set to TRUE (1), limit results to userid's contacts and public contacts only.
  IF @i_PrivateOnlyInd = 1
    SET @SQLString = @SQLString + N' AND (gc.privateind = 1 AND UPPER(gc.lastuserid) = ''' + UPPER(@UserId) + ''')'
  ELSE
    SET @SQLString = @SQLString + N' AND (gc.privateind is null OR gc.privateind = 0 OR 
                                         (gc.privateind = 1 AND UPPER(gc.lastuserid) = ''' + UPPER(@UserId) + '''))' 

  -- ************ ORGENTRY SECURITY FILTER ************ --
  -- Get all orglevel security rows for this user (will appear first) and user's security group
  SET @LastOrgentryKey = 0
  SET @OrgSecurityFilter = ' '  --initialize to single space

  -- Get the optionvalue for clientoption for 'Use Contact Orgentry'
  SELECT @v_optionvalue = optionvalue
  FROM clientoptions
  WHERE optionid = 59
  
  IF @v_optionvalue = 1 BEGIN
	  -- Get the level for org access security
	  SELECT @FilterOrglevelKey = filterorglevelkey
	  FROM filterorglevel
	  WHERE filterkey = 7 --User Org Access Level
	  
	  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
	  IF @ErrorVar <> 0 OR @RowcountVar = 0
	  BEGIN
		 SET @o_error_code = -1
		 SET @o_error_desc = 'Unable to get filterorglevelkey for User Org Access Level (filterkey=7)'
		 RETURN
	  END
	  
	  DECLARE orgsecurity_cur CURSOR FOR
		 SELECT userkey, orgentrykey, accessind
		 FROM securityorglevel 
		 WHERE userkey = @i_UserKey AND
			  orglevelkey = @FilterOrglevelKey
	  UNION
		 SELECT userkey, orgentrykey, accessind
		 FROM securityorglevel
		 WHERE securitygroupkey IN 
			  (SELECT securitygroupkey FROM qsiusers WHERE userkey = @i_UserKey) AND
			  orglevelkey = @FilterOrglevelKey
	  ORDER BY orgentrykey, userkey DESC   
	  
	  OPEN orgsecurity_cur      	
		FETCH NEXT FROM orgsecurity_cur INTO @CheckUserKey, @OrgentryKey, @AccessInd	
		
	  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
		BEGIN
		 IF @LastOrgentryKey <> @OrgentryKey AND (@AccessInd = 1 OR @AccessInd = 2)
			BEGIN  
			  IF @OrgSecurityFilter = ' '
				 SET @OrgSecurityFilter = CONVERT(VARCHAR, @OrgentryKey)
			  ELSE
				 SET @OrgSecurityFilter = @OrgSecurityFilter + ',' + CONVERT(VARCHAR, @OrgentryKey)
			END
			
		 SET @LastOrgentryKey = @OrgentryKey
			
		 FETCH NEXT FROM orgsecurity_cur INTO @CheckUserKey, @OrgentryKey, @AccessInd
	  END
		 
	  CLOSE orgsecurity_cur 
	  DEALLOCATE orgsecurity_cur
  END

  IF @OrgSecurityFilter <> ' '  --single space
  BEGIN
    -- Add the complete orglevel filter string to the main SQL string
    SET @SQLString = @SQLString + ' AND o.orgentrykey IN (' + @OrgSecurityFilter + ') '
  END 
  ELSE BEGIN
    SET @SQLString = @SQLString
  END

    -- Build search SQL union string to retrieve contact records without orglevel classification
    IF @i_PBSelect = 1 BEGIN
      SET @SearchSQLUnion = N'' + CHAR(13) + ' UNION ' + CHAR(13) + 
      'SELECT gc.globalcontactkey, 
              CASE
                WHEN cc.displayname IS NULL THEN
                  CASE
                    WHEN gc.groupname IS NOT NULL THEN gc.groupname
                    ELSE gc.lastname
                  END
                ELSE cc.displayname
              END AS displayname,
              gc.searchname, gc.firstname, gc.middlename, gc.suffix, NULL ssn,
              0 selectedind, gc.activeind, cc.email, cc.phone, cc.keyroles, cc.privateind
        FROM globalcontact gc, corecontactinfo cc 
       WHERE gc.globalcontactkey = cc.contactkey AND 
             gc.searchname LIKE UPPER(''' + @i_SearchName + '%'')'
    END
    ELSE BEGIN
      SET @SearchSQLUnion = N'' + CHAR(13) + ' UNION ' + CHAR(13) + 
      'SELECT gc.globalcontactkey, 
        CASE
          WHEN cc.displayname IS NULL THEN
            CASE
              WHEN gc.groupname IS NOT NULL THEN gc.groupname
              ELSE gc.lastname
            END
          ELSE cc.displayname
        END AS displayname,
        cc.phone, cc.email
      FROM globalcontact gc, corecontactinfo cc 
      WHERE gc.globalcontactkey = cc.contactkey AND 
          gc.searchname LIKE UPPER(''' + @i_SearchName + '%'')'
    END

	--if is not called from contract screen exclude private authors
	if @i_contract_ind = 0 begin
    		SET @SearchSQLUnion = @SearchSQLUnion + N' and gc.globalcontactkey not in (select gr.globalcontactkey
							from globalcontactrole gr
							where gr.globalcontactkey = gc.globalcontactkey
							and gr.rolecode in ( select datacode
										from gentables 
										where tableid = 285 
										and qsicode =  8)
							)'
	end
	if @i_contract_ind = 1 and @i_role_code > 0 begin
	   SET @SearchSQLUnion = @SearchSQLUnion + N' and gc.globalcontactkey  in (select gr.globalcontactkey
					    from globalcontactrole gr
					    where gr.globalcontactkey = gc.globalcontactkey
					    and gr.rolecode = ' + cast(@i_role_code as varchar(20)) + ')'

       end
          
    -- If return only active flag is set to TRUE (1), limit results to active contacts only.
    IF @i_ActiveOnlyInd = 1
      SET @SearchSQLUnion = @SearchSQLUnion + N' AND gc.activeind = 1'

    -- If return only private flag is set to TRUE (1), limit results to userid's contacts and public contacts only.
    IF @i_PrivateOnlyInd = 1
      SET @SearchSQLUnion = @SearchSQLUnion + N' AND (gc.privateind = 1 AND UPPER(gc.lastuserid) = ''' + UPPER(@UserId) + ''')'
    ELSE
      SET @SearchSQLUnion = @SearchSQLUnion + N' AND (gc.privateind is null OR gc.privateind = 0 OR 
                                          (gc.privateind = 1 AND UPPER(gc.lastuserid) = ''' + UPPER(@UserId) + '''))' 
          
          
    SET @SQLString = @SQLString + @SearchSQLUnion + ' AND NOT EXISTS (SELECT * FROM globalcontactorgentry o WHERE cc.contactkey = o.globalcontactkey) '
 -- END  
  

  -- Add Order By
  SET @SQLString = @SQLString + N' ORDER BY displayname'

  EXECUTE sp_executesql @SQLString

  SELECT @o_NumberOfRows = @@ROWCOUNT

--DEBUG
PRINT @SQLString

END




GRANT EXEC on qcontact_contact_name_search_email TO PUBLIC
GO