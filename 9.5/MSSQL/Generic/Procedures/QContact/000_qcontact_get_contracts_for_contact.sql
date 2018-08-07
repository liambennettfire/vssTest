IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contracts_for_contact') )
DROP PROCEDURE dbo.qcontact_get_contracts_for_contact
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qcontact_get_contracts_for_contact]
 (@i_contactkey     integer,
  @i_datacode       integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_contracts_for_contact
**  Desc: This stored procedure returns all Contracts for the given Contact
**        that the user has access to.  Returns data based on configured 
**        fields in the taqprelationshiptabconfig table.
**
**  Auth: Kate Wiewiora
**  Date: 4 December 2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**	06/07/2016   Colman      38278 - Return sortable string value for numeric misc columns
*******************************************************************************/

DECLARE 
  @v_datetypecode1 VARCHAR(255),
  @v_datetypecode2 VARCHAR(255),
  @v_datetypecode3 VARCHAR(255),
  @v_datetypecode4 VARCHAR(255),
  @v_datetypecode5 VARCHAR(255),
  @v_datetypecode6 VARCHAR(255),
  @v_error  INT,
  @v_miscitemkey1 VARCHAR(255),
  @v_miscitemkey2 VARCHAR(255),
  @v_miscitemkey3 VARCHAR(255),
  @v_miscitemkey4 VARCHAR(255),
  @v_miscitemkey5 VARCHAR(255),
  @v_miscitemkey6 VARCHAR(255),
  @v_orgsecurityfilter  VARCHAR(MAX),
  @v_prodidcode1 VARCHAR(255),
  @v_prodidcode2 VARCHAR(255),
  @v_roletypecode1 VARCHAR(255),
  @v_roletypecode2 VARCHAR(255),
  @v_rowcount INT,
  @v_sqlstring  NVARCHAR(MAX)

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Make sure we have only one config row for this configuration
  SELECT @v_rowcount = COUNT(*) 
  FROM taqrelationshiptabconfig 
  WHERE relationshiptabcode = @i_datacode AND itemtypecode = 2  --contacts

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqrelationshiptabconfig table.'
    RETURN  
  END
  
  IF @v_rowcount > 1 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Multiple rows found in taqrelationshiptabconfig for : taqrelationshiptabcode = ' + cast(@i_datacode AS VARCHAR)
    RETURN  
  END    
  
  -- Get the tab configuration
  SELECT @v_miscitemkey1 = COALESCE(CONVERT(VARCHAR, miscitemkey1), 'NULL'), 
    @v_miscitemkey2 = COALESCE(CONVERT(VARCHAR, miscitemkey2), 'NULL'), 
    @v_miscitemkey3 = COALESCE(CONVERT(VARCHAR, miscitemkey3), 'NULL'), 
    @v_miscitemkey4 = COALESCE(CONVERT(VARCHAR, miscitemkey4), 'NULL'), 
    @v_miscitemkey5 = COALESCE(CONVERT(VARCHAR, miscitemkey5), 'NULL'),
    @v_miscitemkey6 = COALESCE(CONVERT(VARCHAR, miscitemkey6), 'NULL'),
    @v_datetypecode1 = COALESCE(CONVERT(VARCHAR, datetypecode1), 'NULL'),
    @v_datetypecode2 = COALESCE(CONVERT(VARCHAR, datetypecode2), 'NULL'),
    @v_datetypecode3 = COALESCE(CONVERT(VARCHAR, datetypecode3), 'NULL'), 
    @v_datetypecode4 = COALESCE(CONVERT(VARCHAR, datetypecode4), 'NULL'),
    @v_datetypecode5 = COALESCE(CONVERT(VARCHAR, datetypecode5), 'NULL'),
    @v_datetypecode6 = COALESCE(CONVERT(VARCHAR, datetypecode6), 'NULL'),
    @v_prodidcode1 = COALESCE(CONVERT(VARCHAR, productidcode1), 'NULL'), 
    @v_prodidcode2 = COALESCE(CONVERT(VARCHAR, productidcode2), 'NULL'),	
    @v_roletypecode1 = COALESCE(CONVERT(VARCHAR, roletypecode1), 'NULL'),
    @v_roletypecode2 = COALESCE(CONVERT(VARCHAR, roletypecode2), 'NULL')
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @i_datacode AND itemtypecode = 2 AND usageclass IS NULL
	
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqrelationshiptabconfig table.'
    RETURN  
  END
  	
  -- Call procedure that builds the orgentry security filter string for this user,
  -- which will consist of all orgentrykeys this user has ReadOnly of Update access
  -- (orgentrykeys at the level we check security and all their parent orgentrykeys)
  EXEC qutl_get_user_orgsecurityfilter @i_userkey, 0, 7, @v_orgsecurityfilter OUTPUT, 
    @o_error_code OUTPUT, @o_error_desc OUTPUT	
    
  IF @v_error <> 0
    RETURN
    
  -- *******************************************************************
  SET @v_sqlstring = N'SELECT DISTINCT p.projectkey,
    p.projectparticipants,
    p.projecttitle,
    p.projecttype,
    p.projecttypedesc,
    p.projectstatus,
    p.projectstatusdesc,
    p.usageclasscode,
    p.usageclasscodedesc,
    p.projectowner,' + 
    @v_miscitemkey1 + ' as miscitemkey1, dbo.qproject_get_misc_value(p.projectkey, ' + @v_miscitemkey1 + ') miscItem1value,' +
    @v_miscitemkey2 + ' as miscitemkey2, dbo.qproject_get_misc_value(p.projectkey, ' + @v_miscitemkey2 + ') miscItem2value,' +
    @v_miscitemkey3 + ' as miscitemkey3, dbo.qproject_get_misc_value(p.projectkey, ' + @v_miscitemkey3 + ') miscItem3value,' +
    @v_miscitemkey4 + ' as miscitemkey4, dbo.qproject_get_misc_value(p.projectkey, ' + @v_miscitemkey4 + ') miscItem4value,' +
    @v_miscitemkey5 + ' as miscitemkey5, dbo.qproject_get_misc_value(p.projectkey, ' + @v_miscitemkey5 + ') miscItem5value,' +
    @v_miscitemkey6 + ' as miscitemkey6, dbo.qproject_get_misc_value(p.projectkey, ' + @v_miscitemkey6 + ') miscItem6value,' +
    'dbo.qproject_get_misc_sortvalue(p.projectkey, ' + @v_miscitemkey1 + ') miscItem1sortvalue,' +
    'dbo.qproject_get_misc_sortvalue(p.projectkey, ' + @v_miscitemkey2 + ') miscItem2sortvalue,' +
    'dbo.qproject_get_misc_sortvalue(p.projectkey, ' + @v_miscitemkey3 + ') miscItem3sortvalue,' +
    'dbo.qproject_get_misc_sortvalue(p.projectkey, ' + @v_miscitemkey4 + ') miscItem4sortvalue,' +
    'dbo.qproject_get_misc_sortvalue(p.projectkey, ' + @v_miscitemkey5 + ') miscItem5sortvalue,' +
    'dbo.qproject_get_misc_sortvalue(p.projectkey, ' + @v_miscitemkey6 + ') miscItem6sortvalue,' +
    'dbo.qutl_get_misc_fieldformat(' + @v_miscitemkey1 + ') fieldformat1,' +
    'dbo.qutl_get_misc_fieldformat(' + @v_miscitemkey2 + ') fieldformat2,' +
    'dbo.qutl_get_misc_fieldformat(' + @v_miscitemkey3 + ') fieldformat3,' +
    'dbo.qutl_get_misc_fieldformat(' + @v_miscitemkey4 + ') fieldformat4,' +
    'dbo.qutl_get_misc_fieldformat(' + @v_miscitemkey5 + ') fieldformat5,' +
    'dbo.qutl_get_misc_fieldformat(' + @v_miscitemkey6 + ') fieldformat6,' +    
    @v_datetypecode1 + ' as datetypecode1, dbo.qproject_get_last_taskdate(p.projectkey, ' + @v_datetypecode1 + ') as date1value,' +
    @v_datetypecode2 + ' as datetypecode2, dbo.qproject_get_last_taskdate(p.projectkey, ' + @v_datetypecode2 + ') as date2value,' +
    @v_datetypecode3 + ' as datetypecode3, dbo.qproject_get_last_taskdate(p.projectkey, ' + @v_datetypecode3 + ') as date3value,' +
    @v_datetypecode4 + ' as datetypecode4, dbo.qproject_get_last_taskdate(p.projectkey, ' + @v_datetypecode4 + ') as date4value,' +
    @v_datetypecode5 + ' as datetypecode5, dbo.qproject_get_last_taskdate(p.projectkey, ' + @v_datetypecode5 + ') as date5value,' +
    @v_datetypecode6 + ' as datetypecode6, dbo.qproject_get_last_taskdate(p.projectkey, ' + @v_datetypecode6 + ') as date6value,' +
    @v_prodidcode1 + ' as productidcode1, 
    (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey=p.projectkey AND productidcode=' + @v_prodidcode1 + ') as productIdCode1Value,' +
    @v_prodidcode2 + ' as productidcode2, 
    (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey=p.projectkey AND productidcode=' + @v_prodidcode2 + ') as productIdCode2Value,' +
    @v_roletypecode1 + ' as roletypecode1, dbo.qproject_get_participant_name_by_role(p.projectkey, ' + @v_roletypecode1 + ') as roletypecode1Value,' +
    @v_roletypecode2 + ' as roletypecode2, dbo.qproject_get_participant_name_by_role(p.projectkey, ' + @v_roletypecode2 + ') as roletypecode2Value
  FROM coreprojectinfo p, taqprojectcontact c, taqprojectorgentry o
  WHERE p.projectkey = c.taqprojectkey AND 
    p.projectkey = o.taqprojectkey AND 
    p.searchitemcode = 10 AND 
    c.globalcontactkey = ' + CONVERT(VARCHAR, @i_contactkey) + ' AND 
    o.orgentrykey IN (' + @v_orgsecurityfilter + ')'
    
  PRINT @v_sqlstring    
  EXECUTE sp_executesql @v_sqlstring    

END
go

GRANT EXEC ON dbo.qcontact_get_contracts_for_contact TO PUBLIC
GO

