IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_productassets]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_productassets]
GO

CREATE FUNCTION [dbo].[qcs_get_productassets](@listkey int = NULL, @userKey int, @bookKey int, @allWorksForTitle bit = 0, @metadataOnly bit = 0)
RETURNS @productAssets TABLE (
	BookKey int,
	ElementKey int, 
	AssetId uniqueidentifier,
    StatusCode int,
    StatusTag varchar(25),
    StatusName varchar(40),
	TypeCode int, 
	TypeName varchar(40), 
	TypeShortName varchar(20), 
	TypeTag varchar(25), 	
	TypeQsiCode int)
AS
BEGIN
	DECLARE @productidcode INT
	SELECT @productidcode=datacode FROM gentables WHERE tableid=551 /*ProductIdType*/ AND qsicode=8 /*GUID*/
	
    IF @metadataOnly = 1 BEGIN
	    INSERT INTO @productassets
	    SELECT
		    e.bookkey AS BookKey,
		    e.taqelementkey AS ElementKey,
		    CAST(n.productnumber AS uniqueidentifier) AS AssetId,
            g.datacode AS StatusCode,
            g.eloquencefieldtag AS StatusTag,
            g.datadesc AS StatusName,
		    a.code AS TypeCode,
		    a.name AS TypeName,
		    a.shortname AS TypeShortName,
		    a.tag AS TypeTag,
		    a.qsicode AS TypeQsiCode
	    FROM dbo.qcs_get_booklist(@listkey, @userKey, @bookKey, @allWorksForTitle) AS b
        JOIN taqprojectelement AS e ON e.bookkey = b.bookkey
        JOIN taqproductnumbers AS n ON n.elementkey = e.taqelementkey
        JOIN assettype_view AS a ON a.code = e.taqelementtypecode
        LEFT JOIN gentables AS g ON g.tableid = 593 AND g.datacode = e.elementstatus
	    WHERE
		    n.productnumber IS NOT NULL AND
		    n.productnumber != '' AND
		    n.productidcode = @productidcode AND
            a.tag = 'CLD_AT_Metadata'
	    ORDER BY e.bookkey
    END
    ELSE BEGIN    
	    INSERT INTO @productassets
	    SELECT
		    e.bookkey AS BookKey,
		    e.taqelementkey AS ElementKey,
		    CAST(n.productnumber AS uniqueidentifier) AS AssetId,
            g.datacode AS StatusCode,
            g.eloquencefieldtag AS StatusTag,
            g.datadesc AS StatusName,
		    a.code AS TypeCode,
		    a.name AS TypeName,
		    a.shortname AS TypeShortName,
		    a.tag AS TypeTag,
		    a.qsicode AS TypeQsiCode
	    FROM dbo.qcs_get_booklist(@listkey, @userKey, @bookKey, @allWorksForTitle) AS b
        JOIN taqprojectelement AS e ON e.bookkey = b.bookkey
        JOIN taqproductnumbers AS n ON n.elementkey = e.taqelementkey
        JOIN assettype_view AS a ON a.code = e.taqelementtypecode
        LEFT JOIN gentables AS g ON g.tableid = 593 AND g.datacode = e.elementstatus
	    WHERE
		    n.productnumber IS NOT NULL AND
		    n.productnumber != '' AND
		    n.productidcode = @productidcode
	    ORDER BY e.bookkey
    END

	RETURN
END
GO

GRANT SELECT ON dbo.qcs_get_productassets TO PUBLIC
GO