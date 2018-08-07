/****** Object:  UserDefinedFunction [dbo].[qutl_get_numeric_fromalphanumeric]    Script Date: 02/20/2015 07:15:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_numeric_fromalphanumeric]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qutl_get_numeric_fromalphanumeric]
GO

/****** Object:  UserDefinedFunction [dbo].[qutl_get_numeric_fromalphanumeric]    Script Date: 02/20/2015 07:15:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[qutl_get_numeric_fromalphanumeric]
(@strAlphaNumeric VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
END
END
RETURN ISNULL(@strAlphaNumeric,0)
END

GO


GRANT EXEC on dbo.qutl_get_numeric_fromalphanumeric to PUBLIC
go