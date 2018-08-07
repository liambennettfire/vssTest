IF EXISTS (
	SELECT *
	FROM dbo.sysobjects
	WHERE id = Object_id('dbo.udf_RemoveNonASCII') AND type = 'FN'
	--AND OBJECTPROPERTY(id, N'IsProcedure') = 1 
	)
BEGIN
	DROP FUNCTION dbo.udf_RemoveNonASCII
END

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

CREATE FUNCTION dbo.udf_RemoveNonASCII
	(@HTMLText NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE @Result NVARCHAR(MAX)
   SET @Result = ''
   
   DECLARE @nchar nvarchar(1)
   DECLARE @position int

   SET @position = 1
    WHILE @position <= LEN(@HTMLText)
    BEGIN
        SET @nchar = SUBSTRING(@HTMLText, @position, 1)
        --Unicode & ASCII are the same from 1 to 255.
        --Only Unicode goes beyond 255
        --0 to 31 are non-printable characters
        IF UNICODE(@nchar) < 32
           SET @Result = @Result + ''
        ELSE
           SET @Result = @Result + @nchar

        SET @position = @position + 1
    END

    RETURN @Result
END

GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXEC
	ON dbo.udf_RemoveNonASCII
	TO PUBLIC
GO