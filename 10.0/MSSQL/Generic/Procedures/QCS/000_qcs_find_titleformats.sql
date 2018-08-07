IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_find_titleformats]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qcs_find_titleformats]
GO

CREATE PROCEDURE [dbo].[qcs_find_titleformats] (
	@listkey int = NULL, 
	@userkey int = NULL, 
	@bookkey int = NULL, 
	@allworksfortitle tinyint = 0,
	@search VARCHAR(255) = NULL)
AS
BEGIN
	SELECT TOP 20
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
		b.customerkey IS NOT NULL AND
		t.searchfield LIKE @search
	ORDER BY title, formatname, eanx
END
GO

GRANT EXEC ON [dbo].[qcs_find_titleformats] TO PUBLIC
GO

