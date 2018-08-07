/******************************************************************************
**  Name: Marcus Keyser
**  Desc: IKE 
**  Auth: Bennett     
**  Date: Jan 17, 2013
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     
*******************************************************************************/
/**************************************************************
Description: This function Converts IDSI style TOC XML to HTML table columns

the basic format of an IDSI TOC XML looks like this:
<toc_item page_num="8">A World About Clay Pots</toc_item>

this should converted to this:
<td>A World About Clay Pots</td><td>8</td>

test code:
print dbo.udf_ConvertXMLtoc2HTMLtoc('<toc_item page_num="8">A World About Clay Pots</toc_item>  <toc_item page_num="12">Soups</toc_item>  <toc_item page_num="15">Fish Main Dishes</toc_item>  <toc_item page_num="24">Poultry Main Dishes</toc_item>  <toc_item page_num="36">Meat Main Courses</toc_item>  <toc_item page_num="54">Vegetarian Main Courses</toc_item>  <toc_item page_num="62">Side Dishes</toc_item>  <toc_item page_num="82">Breads</toc_item>  <toc_item page_num="88">Desserts</toc_item>  <toc_item page_num="95">Conversion Tables</toc_item>  <toc_item page_num="96">Index</toc_item>')

**************************************************************/

IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_ConvertXMLtoc2HTMLtoc]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_ConvertXMLtoc2HTMLtoc]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_ConvertXMLtoc2HTMLtoc] (@szInput NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @szOutput NVARCHAR(MAX)
	DECLARE @szTOCText NVARCHAR(MAX)
	DECLARE @szTOCPageNum NVARCHAR(MAX)
	DECLARE @szColumnDelimiter NCHAR(2)
	DECLARE @szColumnDelimiter2 NCHAR(1)
	DECLARE @szRowDelimiter NCHAR(11)
	DECLARE @szRowDelimiter2 NCHAR(1)
	DECLARE @PrefixJUNK as VARCHAR(100)
	DECLARE	@iPos INT
	DECLARE	@iCounter INT
	DECLARE	@RowsTable TABLE (id INT, text NVARCHAR(MAX))
	DECLARE @TOCMaxLineLength INT
	DECLARE @Counter INT
	
	SET @szColumnDelimiter='">'
	SET @szColumnDelimiter2=CHAR(1)
	SET @szRowDelimiter='</toc_item>'
	SET @szRowDelimiter2=CHAR(2)
	SET @Counter=0
		
	SET @PrefixJUNK='<toc_item page_num="'
	
	IF CHARINDEX('<toc_item',@szInput)>0 AND @szInput IS NOT NULL 
	BEGIN
		SET @szInput = REPLACE(@szInput,'<toc_item>', '<toc_item page_num="">')
		SET @szInput = REPLACE(@szInput,'&amp;', '&')

		SET @szInput = REPLACE(@szInput,@szRowDelimiter, @szRowDelimiter2)
		SET @szInput = REPLACE(@szInput,@szColumnDelimiter, @szColumnDelimiter2)
		SET @szInput = REPLACE(@szInput,@PrefixJUNK, '')
	END ELSE BEGIN
		RETURN NULL
	END
	
	DECLARE @RowText nvarchar(max)

	SELECT @TOCMaxLineLength = MAX(LEN(rtrim(ltrim(replace(replace(replace(part,char(13),''),char(10),''),char(9),'')))))+5 from dbo.udf_SplitString(@szInput,@szRowDelimiter2)

	DECLARE RowCursor CURSOR FOR 
	SELECT rtrim(ltrim(replace(replace(replace(part,char(13),''),char(10),''),char(9),''))) FROM dbo.udf_SplitString(@szInput,@szRowDelimiter2)	
 	
	OPEN RowCursor
	FETCH NEXT FROM RowCursor INTO @RowText

	SET @szOutput = '<table>'
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @RowText is not null and len(@RowText)>0
		BEGIN
			SET @Counter=@Counter+1
			SET @iPos=CHARINDEX(@szColumnDelimiter2,@RowText)
			IF @iPos <> 0
			BEGIN
				SET @szTOCText = RTRIM(LTRIM(RIGHT(@RowText, LEN(@RowText) - @iPos)))
				SET @szTOCPageNum = RTRIM(LTRIM(Left(@RowText, @iPos-1)))

				--put in the dots
				SET @szTOCText=@szTOCText+  REPLICATE('.',@TOCMaxLineLength-len(@szTOCText))
			
				SET @szOutput = @szOutput + '<tr>'
				SET @szOutput = @szOutput + '<td>' + @szTOCText + '</td><td>' + CAST(@szTOCPageNum AS varchar(100)) + '</td>'
				SET @szOutput = @szOutput + '</tr>'
			END
		END
		FETCH NEXT FROM RowCursor INTO @RowText
	END
	CLOSE RowCursor
	DEALLOCATE RowCursor
	
	SET @szOutput = @szOutput + '</table>'
	RETURN @szOutput 
END
