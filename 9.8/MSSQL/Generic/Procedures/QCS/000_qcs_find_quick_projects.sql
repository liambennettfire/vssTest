IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_find_quick_projects]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qcs_find_quick_projects]
GO

/******************************************************************************
**  Name: qcs_find_quick_projects
**  Desc: 
**  Auth: Colman
**  Date: 11/2/2016
**
**  If @i_itemtype and/or @i_usageclass is 0 or NULL, searches for all types/classes
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  01/04/2017	 DM			 Case 42491
**  02/28/2017   UK          Case 43544
*******************************************************************************/

CREATE PROCEDURE [dbo].[qcs_find_quick_projects] (
	@i_search VARCHAR(255) = NULL,
  @i_itemtype INT,
  @i_usageclass INT,
  @i_includeprimaryids BIT,
	@i_userkey INT,
	@o_error_code int output,
	@o_error_desc varchar(2000) output)
AS
BEGIN
	DECLARE @v_filterlevel INT
	DECLARE @orgentryaccess TABLE
	(
		orgentrykey INT,
		accessind SMALLINT
	)

	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @v_filterlevel = COALESCE(filterorglevelkey, 1)
	FROM filterorglevel
	WHERE filterkey = 20

	--find user based security settings
	INSERT INTO @orgentryaccess
	SELECT DISTINCT orgentrykey, accessind
	FROM securityorglevel
	WHERE userkey = @i_userkey
	  AND orglevelkey <= @v_filterlevel

	--find group based security settings, only when user security not already specified
	INSERT INTO @orgentryaccess
	SELECT DISTINCT orgentrykey, accessind
	FROM securityorglevel
	WHERE (securitygroupkey IN (SELECT securitygroupkey FROM qsiusers WHERE userkey = @i_userkey))
	  AND orglevelkey <= @v_filterlevel
	  AND orgentrykey NOT IN (SELECT orgentrykey FROM @orgentryaccess)

  IF @i_includeprimaryids = 1
    SELECT DISTINCT TOP 10
      p.projectkey AS projectkey,
      p.projecttitle AS projecttitle, 
      p.primaryid1 AS primaryid1, 
      p.primaryid2 AS primaryid2
    FROM coreprojectinfo p
    JOIN taqprojectorgentry o
    ON (p.projectkey = o.taqprojectkey)
    WHERE (p.projecttitle LIKE @i_search OR p.primaryid1 LIKE @i_search OR p.primaryid1 LIKE @i_search)
      AND (COALESCE(@i_itemtype,0) = 0 OR p.searchitemcode = @i_itemtype)
      AND (COALESCE(@i_usageclass,0) = 0 OR p.usageclasscode = @i_usageclass)
      AND o.orglevelkey <= @v_filterlevel
      AND o.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
    ORDER BY p.projecttitle
  ELSE
    SELECT DISTINCT TOP 10
      p.projectkey AS projectkey,
      p.projecttitle AS projecttitle, 
      p.primaryid1 AS primaryid1, 
      p.primaryid2 AS primaryid2
    FROM coreprojectinfo p
    JOIN taqprojectorgentry o
    ON (p.projectkey = o.taqprojectkey)
    WHERE p.projecttitle LIKE @i_search
      AND (COALESCE(@i_itemtype,0) = 0 OR p.searchitemcode = @i_itemtype)
      AND (COALESCE(@i_usageclass,0) = 0 OR p.usageclasscode = @i_usageclass)
      AND o.orglevelkey <= @v_filterlevel
      AND o.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
    ORDER BY p.projecttitle
    
END
GO

GRANT EXEC ON [dbo].[qcs_find_quick_projects] TO PUBLIC
GO