IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_find_quick_titles]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qcs_find_quick_titles]
GO

/******************************************************************************
**  Name: qcs_find_quick_titles
**  Desc: 
**  Auth: Dustin Miller
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/10/2016   UK		     Case 36206
**  03/22/2016	 DM		     Case 37042
**  05/11/2016	 DM			 Case 37042
**  05/12/2016	 DM			 Case 38033
**  01/04/2017	 DM			 Case 42491
*******************************************************************************/

CREATE PROCEDURE [dbo].[qcs_find_quick_titles] (
	@search VARCHAR(255) = NULL,
	@userkey INT,
	@o_error_code int output,
	@o_error_desc varchar(2000) output)
AS
BEGIN
	DECLARE @filterlevel INT
	DECLARE @orgentryaccess TABLE
	(
		orgentrykey INT,
		accessind SMALLINT
	)

	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @filterlevel = COALESCE(filterorglevelkey, 1)
	FROM filterorglevel
	WHERE filterkey = 20

	--find user based security settings
	INSERT INTO @orgentryaccess
	SELECT DISTINCT orgentrykey, accessind
	FROM securityorglevel
	WHERE userkey = @userkey
	  AND orglevelkey <= @filterlevel

	--find group based security settings, only when user security not already specified
	INSERT INTO @orgentryaccess
	SELECT DISTINCT orgentrykey, accessind
	FROM securityorglevel
	WHERE (securitygroupkey IN (SELECT securitygroupkey FROM qsiusers WHERE userkey = @userkey))
	  AND orglevelkey <= @filterlevel
	  AND orgentrykey NOT IN (SELECT orgentrykey FROM @orgentryaccess)

	SELECT distinct TOP 20
		t.bookkey AS BookKey,
		t.printingkey AS PrintingKey,
		t.shorttitle AS ShortTitle, 
		t.title AS Title, 
		t.formatname AS FormatName, 
		t.ean AS Ean, 
		t.eanx AS Ean13,
		t.productnumber ProductNumber,
		t.subtitle AS SubTitle,
    bd.fullauthordisplayname AS Author,
    dbo.qtitle_get_misc_keywords_value(t.bookkey) as Keywords
	FROM coretitleinfo t
	JOIN bookorgentry b
	  ON (t.bookkey = b.bookkey)
	JOIN bookdetail bd
		ON bd.bookkey = b.bookkey
	WHERE t.searchfield LIKE @search
		AND t.printingkey = 1
		AND b.orglevelkey <= @filterlevel
		AND b.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
	ORDER BY t.title, t.formatname, t.eanx
END
GO

GRANT EXEC ON [dbo].[qcs_find_quick_titles] TO PUBLIC
GO