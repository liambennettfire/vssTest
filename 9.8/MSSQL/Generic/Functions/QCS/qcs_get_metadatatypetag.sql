IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_metadatatypetag]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qcs_get_metadatatypetag]
GO

CREATE FUNCTION [dbo].[qcs_get_metadatatypetag]()
RETURNS varchar(25)
AS
BEGIN
	DECLARE @typeTag varchar(25)
	SET @typeTag = NULL
	SELECT TOP 1 @typeTag = eloquencefieldtag	
	FROM gentables WHERE qsicode = 3 AND tableid = 287 -- ElementType

	RETURN @typeTag
END
GO

GRANT EXEC ON dbo.qcs_get_metadatatypetag TO PUBLIC
GO