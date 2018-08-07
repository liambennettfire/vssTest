IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_titleformats]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_titleformats]
GO

CREATE PROCEDURE [dbo].[qcs_get_titleformats](@listkey int = NULL, @userkey int = NULL, @bookkey int = NULL, @allworksfortitle tinyint = 0)
AS
BEGIN
	SET NOCOUNT ON
	
	CREATE TABLE #TitleFormat (
		BookKey int,
		ShortTitle varchar(50),
		Title varchar(255),
		FormatName varchar(120),
		Ean varchar(50),
		Ean13 varchar(50))
	
	INSERT INTO #TitleFormat(BookKey, ShortTitle, Title, FormatName, Ean, Ean13)
	SELECT
		t.bookkey AS BookKey, 
		t.shorttitle AS ShortTitle, 
		t.title AS Title, 
		t.formatname AS FormatName, 
		t.ean AS Ean, 
		t.eanx AS Ean13
	FROM 
		coretitleinfo AS t,
		dbo.qcs_get_booklist(@listkey, @userkey, @bookkey, @allworksfortitle) AS b
	WHERE 
		t.bookkey = b.bookkey AND
    t.printingkey = 1 AND
		b.customerkey IS NOT NULL
	ORDER BY title, formatname, eanx
	
	SELECT * FROM #TitleFormat
	
	DECLARE @productidcode INT
	SELECT @productidcode=datacode FROM gentables WHERE tableid=551 /*ProductIdType*/ AND qsicode=8 /*GUID*/
	
	SELECT
		e.bookKey AS BookKey,
		a.tag AS AssetTypeTag
	FROM 
		taqprojectelement AS e,
		taqproductnumbers AS n,
		assettype_view AS a
	WHERE
		e.bookkey IN (SELECT BookKey FROM #TitleFormat) AND
		e.taqelementkey = n.elementkey AND
		n.productnumber IS NOT NULL AND
		n.productnumber != '' AND
		n.productidcode = @productidcode AND
		e.taqelementtypecode = a.code
	ORDER BY e.bookkey
	
	DROP TABLE #TitleFormat
END
GO

GRANT EXEC ON qcs_get_titleformats TO PUBLIC
GO
