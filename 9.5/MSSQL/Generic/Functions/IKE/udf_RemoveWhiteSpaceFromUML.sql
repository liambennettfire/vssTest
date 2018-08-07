/******************************************************************************
**  Name: udf_RemoveWhiteSpaceFromUML
**  Desc: IKE This function removes tabs, spaces, CR, and LFs from XML or HTML that are outside the markup tags (doesn't effect data)
**  Auth: Marcus Keyser     
**  Date: Jan 17, 2013
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
	DECLARE @szReplaceBuffer NVARCHAR(MAX)
	DECLARE @szReplaceBuffer_DataNode NVARCHAR(MAX)
	DECLARE	@iPosStart INT
	DECLARE	@iPosEnd INT
	DECLARE	@iInputLength INT
	DECLARE	@iInputBufferLoopCounter INT
	DECLARE	@iReplaceBufferLength INT
	DECLARE	@iReplaceBufferLoopCounter INT
	DECLARE	@iIsWhiteSpace INT

	SET @szOutput=@szInput
	SET @iInputLength=LEN(@szOutput)
	SET @iPosStart=CHARINDEX('>',@szOutput,1)
	SET @iPosEnd=@iPosStart
	SET @iInputBufferLoopCounter=0
	
	SET @szOutput=REPLACE(@szOutput,CHAR(13),'')
	SET @szOutput=REPLACE(@szOutput,CHAR(10),'')
	
	--Get rid of any white space before the first UML tag
	SET @iPosEnd=CHARINDEX('<',@szOutput,1)
	SET @szReplaceBuffer=SUBSTRING(@szOutput, 1, @iPosEnd)
	SET @iReplaceBufferLength=LEN(@szReplaceBuffer)
	SET @iReplaceBufferLoopCounter=2
	WHILE @iReplaceBufferLoopCounter<@iReplaceBufferLength and @iReplaceBufferLoopCounter>0
	BEGIN
		IF ASCII(SUBSTRING(@szReplaceBuffer,@iReplaceBufferLoopCounter,@iReplaceBufferLoopCounter+1)) NOT IN (9,10,13,32)
		BEGIN
			SET @iIsWhiteSpace=0
			BREAK
		END ELSE BEGIN
			SET @iIsWhiteSpace=1
		END
		
		SET @iReplaceBufferLoopCounter=@iReplaceBufferLoopCounter+1
	END
	IF @iIsWhiteSpace=0
	BEGIN
		SET @szReplaceBuffer_DataNode=@szReplaceBuffer
		SET @szReplaceBuffer_DataNode=REPLACE(@szReplaceBuffer_DataNode,'<','[{~')
		SET @szOutput=REPLACE(@szOutput,@szReplaceBuffer,@szReplaceBuffer_DataNode)
	END ELSE BEGIN
		SET @szOutput=REPLACE(@szOutput,@szReplaceBuffer,'[{~')
	END
	
	--Get rid of the rest of the white space
	SET @iPosStart=CHARINDEX('>',@szOutput,1)
	SET @iPosEnd=@iPosStart
	WHILE @iPosStart<@iInputLength and @iPosStart>0 and @iPosEnd>0
	BEGIN
		SET @iInputBufferLoopCounter=@iInputBufferLoopCounter+1
		SET @iPosEnd=CHARINDEX('<',@szOutput,@iPosStart)
		IF @iPosEnd>1 
		BEGIN	
			SET @szReplaceBuffer=SUBSTRING(@szOutput, @iPosStart, @iPosEnd-@iPosStart+1)
			SET @iReplaceBufferLength=LEN(@szReplaceBuffer)
			SET @iReplaceBufferLoopCounter=2
			WHILE @iReplaceBufferLoopCounter<@iReplaceBufferLength and @iReplaceBufferLoopCounter>0
			BEGIN
				IF ASCII(SUBSTRING(@szReplaceBuffer,@iReplaceBufferLoopCounter,@iReplaceBufferLoopCounter+1)) NOT IN (9,10,13,32)
				BEGIN
					SET @iIsWhiteSpace=0
					BREAK
				END ELSE BEGIN
					SET @iIsWhiteSpace=1
				END
				
				SET @iReplaceBufferLoopCounter=@iReplaceBufferLoopCounter+1
			END

			IF @iIsWhiteSpace=0
			BEGIN
				SET @szReplaceBuffer_DataNode=@szReplaceBuffer
				SET @szReplaceBuffer_DataNode=REPLACE(@szReplaceBuffer_DataNode,'>','~}]')
				SET @szReplaceBuffer_DataNode=REPLACE(@szReplaceBuffer_DataNode,'<','[{~')
				SET @szOutput=REPLACE(@szOutput,@szReplaceBuffer,@szReplaceBuffer_DataNode)
			END ELSE BEGIN
				SET @szOutput=REPLACE(@szOutput,@szReplaceBuffer,'~}][{~')
			END
		END
		SET @iPosStart=CHARINDEX('>',@szOutput,1)
	END

	--Get rid of any white space after the last UML tag
	SET @iPosStart=CHARINDEX('>',@szOutput,1)
	SET @iPosEnd=LEN(@szOutput)
	SET @szReplaceBuffer=SUBSTRING(@szOutput, @iPosStart, @iPosEnd)
	SET @iReplaceBufferLength=LEN(@szReplaceBuffer)
	SET @iReplaceBufferLoopCounter=2
	WHILE @iReplaceBufferLoopCounter<@iReplaceBufferLength and @iReplaceBufferLoopCounter>0
	BEGIN
		IF ASCII(SUBSTRING(@szReplaceBuffer,@iReplaceBufferLoopCounter,@iReplaceBufferLoopCounter+1)) NOT IN (9,10,13,32)
		BEGIN
			SET @iIsWhiteSpace=0
			BREAK
		END ELSE BEGIN
			SET @iIsWhiteSpace=1
		END
		
		SET @iReplaceBufferLoopCounter=@iReplaceBufferLoopCounter+1
	END
	IF @iIsWhiteSpace=0
	BEGIN
		SET @szReplaceBuffer_DataNode=@szReplaceBuffer
		SET @szReplaceBuffer_DataNode=REPLACE(@szReplaceBuffer_DataNode,'>','~}]')
		SET @szOutput=REPLACE(@szOutput,@szReplaceBuffer,@szReplaceBuffer_DataNode)
	END ELSE BEGIN
		SET @szOutput=REPLACE(@szOutput,@szReplaceBuffer,'~}]')
	END

	SET @szOutput=REPLACE(@szOutput,'~}]','>')
	SET @szOutput=REPLACE(@szOutput,'[{~','<')

	RETURN @szOutput
END
