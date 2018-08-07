IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_productidentities]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_productidentities]
GO

CREATE FUNCTION [dbo].[qcs_get_productidentities](@listkey int = NULL, @userkey int = NULL, @bookkey int = NULL, @allworksfortitle bit = 0)
RETURNS @products TABLE(
	Id uniqueidentifier, 
	BookKey int, 
	WorkKey int,
	ShortTitle varchar(50), 
	Title varchar(255), 
	FormatName varchar(120),
	Ean varchar(50),
	Ean13 varchar(50),
	MediaCode int,
	MediaSubCode int,
	CustomerKey int,
    CustomerTag char(6),
    ApprovalCode int)
AS
BEGIN
	INSERT INTO @products
	SELECT
		CAST(i.cloudproductid AS uniqueidentifier) AS Id,
		t.bookkey AS BookKey,
		b.workkey AS WorkKey, 
		t.shorttitle AS ShortTitle, 
		t.title AS Title, 
		t.formatname AS FormatName, 
		t.ean AS Ean, 
		t.eanx AS Ean13,
		t.mediatypecode AS MediaCode,
		t.mediatypesubcode AS MediaSubCode,
		b.customerkey AS CustomerKey,
        b.eloqcustomerid AS CustomerTag,
        b.csapprovalcode AS ApprovalCode
	FROM
		dbo.qcs_get_booklist(@listkey, @userkey, @bookkey, @allworksfortitle) AS b,
		coretitleinfo AS t,
		isbn AS i
	WHERE 
		t.bookkey = b.bookkey AND
		t.printingkey = 1 AND
		i.bookkey = t.bookkey
		
	ORDER BY title, formatname, eanx
	RETURN
END
GO

GRANT SELECT ON dbo.qcs_get_productidentities TO PUBLIC
GO