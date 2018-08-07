IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_fixtag]') AND type in (N'FN'))
DROP FUNCTION [dbo].[qcs_fixtag]
GO

CREATE FUNCTION [dbo].[qcs_fixtag](@tag varchar(50), @prefix varchar(10)) 
RETURNS varchar(50)
AS
BEGIN
	RETURN @prefix + '-' + substring(@tag, patindex('%-%', @tag)+1, len(@tag)-patindex('%-%', @tag)) 
END
GO

GRANT EXEC ON qcs_fixtag TO PUBLIC
GO