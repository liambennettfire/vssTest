/******************************************************************************
**  Name: udf_SplitString
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_SplitString]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_SplitString]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_SplitString] (
	@sString NVARCHAR(2048)
	,@cDelimiter NCHAR(1)
	)
RETURNS @tParts TABLE (id int, part NVARCHAR(2048))
AS
BEGIN
	IF @sString IS NULL RETURN
	IF @cDelimiter IS NULL SET @cDelimiter=','

	DECLARE	@iStart INT
			,@iPos INT
			,@iCounter INT

	IF substring(@sString, 1, 1) = @cDelimiter
		BEGIN
			SET @iStart = 2

			INSERT INTO @tParts
			VALUES (1,NULL)
			
			SET @iCounter=2
		
		END ELSE BEGIN
		
			SET @iStart = 1
			SET @iCounter=1
		END
	
	WHILE 1 = 1
		BEGIN
			SET @iPos = charindex(@cDelimiter, @sString, @iStart)

			IF @iPos = 0
				SET @iPos = len(@sString) + 1

			IF @iPos - @iStart > 0
				INSERT INTO @tParts
				VALUES (@iCounter, substring(@sString, @iStart, @iPos - @iStart))
			ELSE
				INSERT INTO @tParts
				VALUES (@iCounter, NULL)

			SET @iStart = @iPos + 1
			IF @iStart > len(@sString) BREAK
			
			SET @iCounter=@iCounter+1
		END

	RETURN
END
