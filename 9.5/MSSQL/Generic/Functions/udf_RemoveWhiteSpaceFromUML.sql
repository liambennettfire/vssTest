/**************************************************************
Created by: Marcus Keyser
Created on: Jan 17, 2013
Description: This function removes tabs, spaces, CR, and LFs from XML or HTML that are outside the markup tags (doesn't effect data)
**************************************************************/

IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_RemoveWhiteSpaceFromUML]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_RemoveWhiteSpaceFromUML]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_RemoveWhiteSpaceFromUML] (@szInput NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @szOutput NVARCHAR(MAX)
	DECLARE @szBuffer NVARCHAR(MAX)
	DECLARE	@iPosStart INT
	DECLARE	@iPosEnd INT

	--SET @szOutput=@szInput
	--SET @szOutput=REPLACE(@szOutput,CHAR(13),'')
	--SET @szOutput=REPLACE(@szOutput,CHAR(10),'')
	
	SET @szOutput=@szInput
	SET @szOutput=REPLACE(@szOutput,CHAR(13)+CHAR(10),' ')
	SET @szOutput=REPLACE(@szOutput,CHAR(13),' ')
	SET @szOutput=REPLACE(@szOutput,CHAR(10),' ')
	
	--Get rid of any white space before the first UML tag
	SET @iPosStart=1
	SET @iPosEnd=CHARINDEX('<',@szOutput,@iPosStart)-1
	SET @szBuffer=SUBSTRING(@szOutput, @iPosStart, @iPosEnd)
	SET @szBuffer =	REPLACE(REPLACE(@szBuffer, CHAR(32) /*space*/, ''), CHAR(9) /*tab*/, '')
	IF LEN(@szBuffer)=0 SET @szOutput=STUFF(@szOutput,@iPosStart,@iPosEnd,'')

	--Get rid of any white space after the last UML tag
	SET @szOutput=REVERSE(@szOutput)
	SET @iPosStart=1
	SET @iPosEnd=CHARINDEX('>',@szOutput,@iPosStart)-1
	SET @szBuffer=SUBSTRING(@szOutput, @iPosStart, @iPosEnd)
	SET @szBuffer =	REPLACE(REPLACE(@szBuffer, CHAR(32) /*space*/, ''), CHAR(9) /*tab*/, '')
	IF LEN(@szBuffer)=0 SET @szOutput=STUFF(@szOutput,@iPosStart,@iPosEnd,'')
	SET @szOutput=REVERSE(@szOutput)
		
	--Get rid of the rest of the white space
	SET @iPosStart=1
	SET @iPosEnd=1	
	WHILE @iPosStart>0
	BEGIN
		SET @iPosStart=CHARINDEX('>',@szOutput,@iPosStart+1)
		IF @iPosStart>0
		BEGIN
			SET @iPosStart=@iPosStart+1
			SET @iPosEnd=CHARINDEX('<',@szOutput,@iPosStart)
			IF @iPosEnd > 0
			BEGIN
				SET @szBuffer=SUBSTRING(@szOutput, @iPosStart, @iPosEnd-@iPosStart)
				
				--this gets rid of all chars between 2 UML elements ONLY IF THEY ARE WHITE SPACE
				SET @szBuffer=SUBSTRING(@szOutput, @iPosStart, @iPosEnd-@iPosStart)
				SET @szBuffer =	REPLACE(REPLACE(@szBuffer, CHAR(32) /*space*/, ''), CHAR(9) /*tab*/, '')
				IF LEN(@szBuffer)=0 SET @szOutput=STUFF(@szOutput,@iPosStart,@iPosEnd-@iPosStart,'')				
			END		
		END
	END	
	RETURN @szOutput
END
GO

GRANT EXEC ON dbo.udf_RemoveWhiteSpaceFromUML TO public
GO