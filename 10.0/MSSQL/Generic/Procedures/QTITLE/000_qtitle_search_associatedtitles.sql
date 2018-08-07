if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_search_associatedtitles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_search_associatedtitles
GO

CREATE PROCEDURE qtitle_search_associatedtitles
 (@i_searchtype     varchar(50),
  @i_searchterm	    varchar(500),
  @i_userkey	    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_search_associatedtitles
**  Desc: This stored procedure is used for the associated title typeahead searches
**
**  Auth: Dustin Miller
**  Date: 2/16/2018
*************************************************************************************/

BEGIN

	DECLARE @v_error INT

	SET @o_error_code = 0
	SET @o_error_desc = ''
  
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
	WHERE userkey = @i_userkey
		AND orglevelkey <= @filterlevel

	--find group based security settings, only when user security not already specified
	INSERT INTO @orgentryaccess
	SELECT DISTINCT orgentrykey, accessind
	FROM securityorglevel
	WHERE (securitygroupkey IN (SELECT securitygroupkey FROM qsiusers WHERE userkey = @i_userkey))
		AND orglevelkey <= @filterlevel
		AND orgentrykey NOT IN (SELECT orgentrykey FROM @orgentryaccess)

	IF @i_searchtype = 'title'
	BEGIN
		SELECT DISTINCT TOP 20
			t.bookkey AS BookKey,
			t.printingkey AS PrintingKey,
			t.shorttitle AS ShortTitle, 
			t.title AS Title,
			t.authorname AS Author,
			t.formatname AS FormatName, 
			t.ean AS Ean, 
			t.eanx AS Ean13,
			t.productnumber AS ProductNumber,
			t.itemnumber AS ItemNumber
		FROM coretitleinfo t
		JOIN bookorgentry b
		ON (t.bookkey = b.bookkey)
		WHERE (t.title LIKE @i_searchterm OR t.shorttitle LIKE @i_searchterm)
			AND t.printingkey = 1
			AND b.orglevelkey <= @filterlevel
			AND b.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
		ORDER BY t.title, t.formatname, t.eanx
	END
	ELSE IF @i_searchtype = 'itemnumber'
	BEGIN
		SELECT DISTINCT TOP 20
			t.bookkey AS BookKey,
			t.printingkey AS PrintingKey,
			t.shorttitle AS ShortTitle, 
			t.title AS Title,
			t.authorname AS Author,
			t.formatname AS FormatName, 
			t.ean AS Ean, 
			t.eanx AS Ean13,
			t.productnumber AS ProductNumber,
			t.itemnumber AS ItemNumber
		FROM coretitleinfo t
		JOIN bookorgentry b
		ON (t.bookkey = b.bookkey)
		WHERE (t.itemnumber LIKE @i_searchterm)
			AND t.printingkey = 1
			AND b.orglevelkey <= @filterlevel
			AND b.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
		ORDER BY t.itemnumber, t.title, t.formatname, t.eanx
	END
	ELSE IF @i_searchtype = 'productnumber'
	BEGIN
		SELECT DISTINCT TOP 20
			t.bookkey AS BookKey,
			t.printingkey AS PrintingKey,
			t.shorttitle AS ShortTitle, 
			t.title AS Title,
			t.authorname AS Author,
			t.formatname AS FormatName, 
			t.ean AS Ean, 
			t.eanx AS Ean13,
			t.productnumber AS ProductNumber,
			t.itemnumber AS ItemNumber
		FROM coretitleinfo t
		JOIN bookorgentry b
		ON (t.bookkey = b.bookkey)
		WHERE (t.productnumber LIKE @i_searchterm OR t.productnumberx LIKE @i_searchterm OR t.upc LIKE @i_searchterm)
			AND t.printingkey = 1
			AND b.orglevelkey <= @filterlevel
			AND b.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
		ORDER BY t.title, t.formatname, t.eanx
	END
	ELSE IF @i_searchtype = 'author'
	BEGIN
		SELECT DISTINCT TOP 20
			t.bookkey AS BookKey,
			t.printingkey AS PrintingKey,
			t.shorttitle AS ShortTitle, 
			t.title AS Title,
			t.authorname AS Author,
			t.formatname AS FormatName, 
			t.ean AS Ean, 
			t.eanx AS Ean13,
			t.productnumber AS ProductNumber,
			t.itemnumber AS ItemNumber
		FROM coretitleinfo t
		JOIN bookorgentry b
		ON (t.bookkey = b.bookkey)
		WHERE (t.authorname LIKE @i_searchterm)
			AND t.printingkey = 1
			AND b.orglevelkey <= @filterlevel
			AND b.orgentrykey IN (SELECT o.orgentrykey FROM @orgentryaccess o WHERE (o.accessind = 1 OR o.accessind = 2))
		ORDER BY t.authorname, t.formatname, t.eanx
	END

	SELECT @v_error = @@ERROR
	IF @v_error <> 0  BEGIN
	SET @o_error_code = 1
	SET @o_error_desc = 'Could not get associated title data.'
	END
  
END
GO

GRANT EXEC ON qtitle_search_associatedtitles TO PUBLIC
GO
