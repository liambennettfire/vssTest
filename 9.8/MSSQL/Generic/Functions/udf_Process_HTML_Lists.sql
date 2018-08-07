SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
	SELECT *
	FROM dbo.sysobjects
	WHERE id = Object_id('dbo.udf_Process_HTML_Lists') AND type = 'FN'
	)
BEGIN
	DROP FUNCTION dbo.udf_Process_HTML_Lists
END
GO

CREATE FUNCTION dbo.udf_Process_HTML_Lists (@szINPUT NVARCHAR(max),@BulletChar NVARCHAR(128),@CRLF NVARCHAR(128),@StripMode INT)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @XML XML
	
	--CREATE the @HTMLTags_ListMaker table
	DECLARE @HTMLTags_ListMaker AS TABLE  (
			INCR INT IDENTITY(1,1) NOT NULL
			,TextSegment NVARCHAR(max)
			,NestLevel INT DEFAULT 0
			,IsOpen BIT DEFAULT 0
			,IsClose BIT DEFAULT 0
			,TagType NVARCHAR(4)
			,WorkText NVARCHAR(max)
			,ItemCounter INT
			,ItemCounterStart INT
			,ProcessedText NVARCHAR(max))
	
	--INSERT INTO the @HTMLTags_ListMaker table
	SET @XML=dbo.udf_Parse_HTML_Lists (@szINPUT)
	
	--Because Table Vars can't be returned by functions I have passed back 
	-- ... a serialized @HTMLTags_ListMaker table from inside udf_Parse_HTML_Lists
	-- ... this now needs to get DE-serialized back into a local @HTMLTags_ListMaker (this table can be edited)
	INSERT INTO @HTMLTags_ListMaker 
	SELECT
	a.b.value('TextSegment[1]','NVARCHAR(max)') AS TextSegment
	,a.b.value('NestLevel[1]','INT') AS NestLevel
	,a.b.value('IsOpen[1]','BIT') AS IsOpen
	,a.b.value('IsClose[1]','BIT') AS IsClose
	,a.b.value('TagType[1]','NVARCHAR(4)') AS TagType
	,a.b.value('WorkText[1]','NVARCHAR(max)') AS WorkText
	,a.b.value('ItemCounter[1]','INT') AS ItemCounter
	,a.b.value('ItemCounterStart[1]','INT') AS ItemCounterStart
	,a.b.value('ProcessedText[1]','NVARCHAR(max)') AS ProcessedText
	FROM @XML.nodes('LISTMAKER/ITEMS') a(b)
	
	--SET the IsOpen Flag
	UPDATE @HTMLTags_ListMaker SET IsOPEN =1
	WHERE TextSegment IN ('<OL>','<UL>')
	
	--SET the IsClose Flag
	UPDATE @HTMLTags_ListMaker SET IsCLOSE =1
	WHERE TextSegment IN ('</OL>','</UL>')
	
	--SET the TagType Flag
	UPDATE @HTMLTags_ListMaker SET TagType =TextSegment
	WHERE IsOpen=1	

	--SET the nesting level
	DECLARE 
		@CurrentINCR INT
		,@CurrentNestLevel INT
		,@CurrentIsOpen BIT
		,@CurrentIsClose BIT
		,@CurrentTagType NVARCHAR(4)
		,@PreviousNestLevel INT
		,@PreviousIsClose BIT
		,@PreviousTagType NVARCHAR(4)

	SET @CurrentINCR=0
	SET @CurrentNestLevel=0
	SET @CurrentIsOpen=0
	SET @CurrentIsClose=0
	SET @PreviousNestLevel=0
	SET @PreviousIsClose=0

	DECLARE ListMakerCursor CURSOR FAST_FORWARD
	FOR
	SELECT INCR
		,NestLevel
		,IsOpen
		,IsClose
		,TagType
	FROM @HTMLTags_ListMaker
	ORDER BY INCR ASC

	OPEN ListMakerCursor

	FETCH NEXT
	FROM ListMakerCursor
	INTO @CurrentINCR 
		,@CurrentNestLevel 
		,@CurrentIsOpen 
		,@CurrentIsClose
		,@CurrentTagType 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SET Nesting Levels
		SET @CurrentNestLevel=@PreviousNestLevel+@CurrentIsOpen-@PreviousIsClose
		UPDATE @HTMLTags_ListMaker SET NESTLEVEL=@CurrentNestLevel WHERE INCR=@CurrentINCR
		SET @PreviousNestLevel=@CurrentNestLevel
		SET @PreviousIsClose=@CurrentIsClose

		--SET the TagType Flag for the rest
		IF @CurrentTagType IS NULL 
		BEGIN
			SELECT TOP 1 @PreviousTagType =TagType
			FROM @HTMLTags_ListMaker
			WHERE NestLevel=@CurrentNestLevel 
				AND IsOpen=1
			ORDER BY INCR DESC

			UPDATE @HTMLTags_ListMaker SET TagType=@PreviousTagType WHERE INCR=@CurrentINCR 
		END

		FETCH NEXT
		FROM ListMakerCursor
		INTO @CurrentINCR 
			,@CurrentNestLevel 
			,@CurrentIsOpen 
			,@CurrentIsClose 
			,@CurrentTagType 
	END

	CLOSE ListMakerCursor
	DEALLOCATE ListMakerCursor
	
	--Process WorkText
	-- ... ADD a CRLF to Items that didn't end in </LI> ... the </LI> would have been in its own row later and by now these have been deleted
	UPDATE @HTMLTags_ListMaker 
	SET WorkText = CASE WHEN RIGHT(RTRIM(TextSegment),5)<>'</LI>' THEN TextSegment+COALESCE(@CRLF,CHAR(13)+CHAR(10)) ELSE TextSegment  END
	WHERE NOT (INCR=(SELECT MAX(INCR) FROM @HTMLTags_ListMaker) AND ItemCounter=0) AND WorkText IS NULL

	UPDATE @HTMLTags_ListMaker 
	SET WorkText = TextSegment
	WHERE WorkText IS NULL
	
	-- ... REMOVE a CRLF from Items that START with </LI> 
	UPDATE @HTMLTags_ListMaker 
	SET WorkText = CASE WHEN LEFT(WorkText,5)='</LI>' THEN STUFF(WorkText,1, 5,'') ELSE WorkText END

	-- ... Get rid of the </LI> tags first since they're not collated
	UPDATE @HTMLTags_ListMaker SET WorkText = REPLACE(WorkText,'</LI>',COALESCE(@CRLF,CHAR(13)+CHAR(10))) 

	-- Update the ItemCounter
	UPDATE @HTMLTags_ListMaker
	SET ItemCounter=COALESCE((LEN(WorkText)-LEN(REPLACE(WorkText, '<LI>', '')))/4,0)
	,ItemCounterStart = CASE WHEN isopen = 1 THEN 1 ELSE 0 END
	WHERE TagType='<OL>'
	
	-- Update the ItemCounterStart
	DECLARE @CurrentItemCounter INT
	DECLARE @CurrentItemCounterStart INT
	DECLARE @PreviousItemCounter INT
	DECLARE @PreviousItemCounterStart INT
	
	SET @PreviousItemCounter=0
	SET @PreviousItemCounterStart=0

	DECLARE NestLevelCursor CURSOR FAST_FORWARD
	FOR
	SELECT DISTINCT NestLevel, ItemCounter, ItemCounterStart, INCR
	FROM @HTMLTags_ListMaker
	ORDER BY INCR ASC

	OPEN NestLevelCursor
	FETCH NEXT
	FROM NestLevelCursor
	INTO @CurrentNestLevel
		,@CurrentItemCounter
		,@CurrentItemCounterStart
		,@CurrentINCR

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Update ItemCounterStart
		IF @CurrentNestLevel=@PreviousNestLevel AND @CurrentItemCounterStart = 0 AND @CurrentNestLevel>0
		BEGIN
			UPDATE @HTMLTags_ListMaker SET ItemCounterStart=@PreviousItemCounter * @PreviousItemCounterStart + 1 where INCR=@CurrentINCR
		END
		
		IF @CurrentNestLevel=@PreviousNestLevel-1 AND @CurrentItemCounterStart = 0 AND @PreviousNestLevel>0
		BEGIN
			SELECT TOP 1 @PreviousItemCounter=ItemCounter, @PreviousItemCounterStart=ItemCounterStart 
			FROM @HTMLTags_ListMaker 
			WHERE NestLevel=@CurrentNestLevel AND INCR<@CurrentINCR 
			ORDER BY INCR DESC
			
			UPDATE @HTMLTags_ListMaker SET ItemCounterStart=@PreviousItemCounter * @PreviousItemCounterStart + 1 where INCR=@CurrentINCR
		END
		
		SET @PreviousNestLevel=@CurrentNestLevel
		SET @PreviousItemCounter=@CurrentItemCounter	
		SET @PreviousItemCounterStart=@CurrentItemCounterStart

		FETCH NEXT
		FROM NestLevelCursor
		INTO @CurrentNestLevel
			,@CurrentItemCounter
			,@CurrentItemCounterStart
			,@CurrentINCR
	END

	CLOSE NestLevelCursor
	DEALLOCATE NestLevelCursor
	
	--DELETE List Start/Ends (including </LI>)
	DELETE FROM @HTMLTags_ListMaker WHERE TextSegment IN('<OL>','</OL>','<UL>','</UL>', '</LI>')

	-- Process the WorkText to final
	-- ... do the UL first - no numbering required
	DECLARE @DefaultBullet NVARCHAR(max) 
	SET @DefaultBullet= CHAR(149)+CASE WHEN @StripMode=0 THEN CHAR(9) ELSE '&emsp;' END
	SET @BulletChar = COALESCE(@BulletChar,@DefaultBullet)
	IF @StripMode=0
	BEGIN
		UPDATE @HTMLTags_ListMaker
		SET ProcessedText = REPLACE(WorkText,'<LI>',REPLICATE(CHAR(9), COALESCE(NestLevel,1)-1) + @BulletChar )
		WHERE TagType='<UL>'
	END ELSE BEGIN
		UPDATE @HTMLTags_ListMaker
		SET ProcessedText = REPLACE(WorkText,'<LI>',REPLICATE('&emsp;', 2*COALESCE(NestLevel,1)-1) + @BulletChar )
		WHERE TagType='<UL>'
	END
	
	-- ... Then do the OL 
	-- ... this is for an ordered list (OL) with list items ONLY
	UPDATE @HTMLTags_ListMaker
	SET ProcessedText=dbo.udf_Process_HTML_CollateOL(WorkText,NestLevel,ItemCounterStart,@StripMode)
	WHERE ProcessedText IS NULL

	DECLARE @szOUTPUT NVARCHAR(max)
	SELECT @szOUTPUT= COALESCE(@szOUTPUT, '') + RTRIM(LTRIM(ProcessedText))
	FROM @HTMLTags_ListMaker
	WHERE ProcessedText IS NOT NULL
	
	RETURN @szOUTPUT
	--RETURN (SELECT * FROM @HTMLTags_ListMaker FOR XML PATH('ITEMS'), ROOT('LISTMAKER'))
END
GO
