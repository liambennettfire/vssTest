/******************************************************************************
**  Name: udf_ConvertHTMLtoc2XMLtoc
**  Desc: IKE 
**  Auth: Marcus Keyser     
**  Date: Jan 17, 2013
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016    
*******************************************************************************/
/**************************************************************
Description: This function Converts HTML TOC to IDSI XML style table columns

the basic format of a TABLE BASED HTML TOC looks like this (from IDSI):
3 COLUMN
<table><tr><td>A World About Clay Pots</td><td>8</td></tr><tr><td>Soups</td><td>12</td><td>XXXXX</td></tr><tr><td>Fish Main Dishes</td><td>15</td><td>XXXXX</td></tr><tr><td>Poultry Main Dishes</td><td>24</td><td>XXXXX</td></tr><tr><td>Meat Main Courses</td><td>36</td><td>XXXXX</td></tr><tr><td>Vegetarian Main Courses</td><td>54</td><td>XXXXX</td></tr><tr><td>Side Dishes</td><td>62</td><td>XXXXX</td></tr><tr><td>Breads</td><td>82</td><td>XXXXX</td></tr><tr><td>Desserts</td><td>88</td><td>XXXXX</td></tr><tr><td>Conversion Tables</td><td>95</td><td>XXXXX</td></tr><tr><td>Index</td><td>96</td><td>XXXXX</td></tr><table>
2 COLUMN
<table><tr><td>A World About Clay Pots</td><td>8</td></tr><tr><td>Soups</td><td>12</td></tr><tr><td>Fish Main Dishes</td><td>15</td></tr><tr><td>Poultry Main Dishes</td><td>24</td></tr><tr><td>Meat Main Courses</td><td>36</td></tr><tr><td>Vegetarian Main Courses</td><td>54</td></tr><tr><td>Side Dishes</td><td>62</td></tr><tr><td>Breads</td><td>82</td></tr><tr><td>Desserts</td><td>88</td></tr><tr><td>Conversion Tables</td><td>95</td></tr><tr><td>Index</td><td>96</td></tr><table>
1 COLUMN
<table><tr><td>A World About Clay Pots</td><td>8</td></tr><tr><td>Soups</td></tr><tr><td>Fish Main Dishes</td></tr><tr><td>Poultry Main /td></tr><tr><td>Meat Main Courses</td></tr><tr><td>Vegetarian Main Courses</td></tr><tr><td>Side Dishes</td></tr><tr><td>Breads</td></tr><tr><td>Desserts</td></tr><tr><td>Conversion Tables</td></tr><tr><td>Index</td></tr><table>

this should converted to this:
<toc_item page_num="8">A World About Clay Pots</toc_item>  <toc_item page_num="12">Soups</toc_item>  <toc_item page_num="15">Fish Main Dishes</toc_item>  <toc_item page_num="24">Poultry Main Dishes</toc_item>  <toc_item page_num="36">Meat Main Courses</toc_item>  <toc_item page_num="54">Vegetarian Main Courses</toc_item>  <toc_item page_num="62">Side Dishes</toc_item>  <toc_item page_num="82">Breads</toc_item>  <toc_item page_num="88">Desserts</toc_item>  <toc_item page_num="95">Conversion Tables</toc_item>  <toc_item page_num="96">Index</toc_item>

It could also be non table based
Foreword<br>Introduction<br>&#160;<br><b>PART 1 </b>The Detour into Fear<br>1. A Tiny Mad Idea<br>2. Anxiety and Ashrams<br>3. Somethin&rsquo; Special<br>4. Ask~<i>ing </i>for Help<br>&#160;<br><b>PART 2 </b>The Answer<br>5. The <i>F </i>Word<br>6. Relationships Are Assignments<br>7. The Holy Instant<br>8. Accepting My Invitation<br><b><br>PART 3 </b>The Miracle<br>9. Spirit Became My Boyfriend<br>10. Love Wins<br>11. Expect Miracles<br>12. Spirit Junkie<br>Acknowledgments

test code:
print dbo.udf_ConvertHTMLtoc2XMLtoc('<table><tr><td>A World About Clay Pots</td><td>8</td></tr><tr><td>Soups</td><td>12</td></tr><tr><td>Fish Main Dishes</td><td>15</td></tr><tr><td>Poultry Main Dishes</td><td>24</td></tr><tr><td>Meat Main Courses</td><td>36</td></tr><tr><td>Vegetarian Main Courses</td><td>54</td></tr><tr><td>Side Dishes</td><td>62</td></tr><tr><td>Breads</td><td>82</td></tr><tr><td>Desserts</td><td>88</td></tr><tr><td>Conversion Tables</td><td>95</td></tr><tr><td>Index</td><td>96</td></tr></table>')
print dbo.udf_ConvertHTMLtoc2XMLtoc('Foreword<br>Introduction<br>&#160;<br><br><br><br><br><br><br><br><br><br><br><br><b>PART 1 </b>The Detour into Fear<br>1. A Tiny Mad Idea<br>2. Anxiety and Ashrams<br>3. Somethin&rsquo; Special<br>4. Ask~<i>ing </i>for Help<br>&#160;<br><b>PART 2 </b>The Answer<br>5. The <i>F </i>Word<br>6. Relationships Are Assignments<br>7. The Holy Instant<br>8. Accepting My Invitation<br><b><br>PART 3 </b>The Miracle<br>9. Spirit Became My Boyfriend<br>10. Love Wins<br>11. Expect Miracles<br>12. Spirit Junkie<br>Acknowledgments')

<table>
<tr><td>Col 1</td><td>Col 2</td><td>Col 3</td><td>Col 4</td></tr>
<tr><td>Col 1</td><td>Col 2</td><td>Col 3</td><td>Col 4</td></tr>
<tr><td>Col 1</td><td>Col 2</td><td>Col 3</td><td>Col 4</td></tr>
<table>

print dbo.udf_ConvertHTMLtoc2XMLtoc('<table><tr><td>Col 1</td><td>Col 2</td><td>Col 3</td><td>Col 4</td></tr><tr><td>Col 1</td><td>Col 2</td><td>Col 3</td><td>Col 4</td></tr><tr><td>Col 1</td><td>Col 2</td><td>Col 3</td><td>Col 4</td></tr><table>')
print dbo.udf_ConvertHTMLtoc2XMLtoc('<table><tr><td>Col 1</td><td>Col 2</td><td>Col 3</td></tr><tr><td>Col 1</td><td>Col 2</td><td>Col 3</td></tr><tr><td>Col 1</td><td>Col 2</td><td>Col 3</td></tr><table>')
print dbo.udf_ConvertHTMLtoc2XMLtoc('<table><tr><td>Col 1</td><td>Col 2</td></tr><tr><td>Col 1</td><td>Col 2</td></tr><tr><td>Col 1</td><td>Col 2</td></tr><table>')
print dbo.udf_ConvertHTMLtoc2XMLtoc('<table><tr><td>Col 1</td></tr><tr><td>Col 1</td></tr><tr><td>Col 1</td></tr><table>')

print dbo.udf_ConvertHTMLtoc2XMLtoc('Foreword<br>Introduction<br>&#160;<br><br><br><br><br><br><br><br><br><br><br><br><b>PART 1 </b>The Detour into Fear<br>1. A Tiny Mad Idea<br>2. Anxiety and Ashrams<br>3. Somethin&rsquo; Special<br>4. Ask~<i>ing </i>for Help<br>&#160;<br><b>PART 2 </b>The Answer<br>5. The <i>F </i>Word<br>6. Relationships Are Assignments<br>7. The Holy Instant<br>8. Accepting My Invitation<br><b><br>PART 3 </b>The Miracle<br>9. Spirit Became My Boyfriend<br>10. Love Wins<br>11. Expect Miracles<br>12. Spirit Junkie<br>Acknowledgments')
print dbo.udf_ConvertHTMLtoc2XMLtoc('<p>Foreword</p><p>Introduction</p><p>&#160;</p><p></p><p></p><p></p><p></p><p></p><p></p><p></p><p></p><p></p><p></p><p></p><p><b>PART 1 </b>The Detour into Fear</p><p>1. A Tiny Mad Idea</p><p>2. Anxiety and Ashrams</p><p>3. Somethin&rsquo; Special</p><p>4. Ask~<i>ing </i>for Help</p><p>&#160;</p><p><b>PART 2 </b>The Answer</p><p>5. The <i>F </i>Word</p><p>6. Relationships Are Assignments</p><p>7. The Holy Instant</p><p>8. Accepting My Invitation</p><p><b></p><p>PART 3 </b>The Miracle</p><p>9. Spirit Became My Boyfriend</p><p>10. Love Wins</p><p>11. Expect Miracles</p><p>12. Spirit Junkie</p><p>Acknowledgments</p>')
print dbo.udf_ConvertHTMLtoc2XMLtoc('<div>Foreword</div><div>Introduction</div><div>&#160;</div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div><b>PART 1 </b>The Detour into Fear</div><div>1. A Tiny Mad Idea</div><div>2. Anxiety and Ashrams</div><div>3. Somethin&rsquo; Special</div><div>4. Ask~<i>ing </i>for Help</div><div>&#160;</div><div><b>PART 2 </b>The Answer</div><div>5. The <i>F </i>Word</div><div>6. Relationships Are Assignments</div><div>7. The Holy Instant</div><div>8. Accepting My Invitation</div><div><b></div><div>PART 3 </b>The Miracle</div><div>9. Spirit Became My Boyfriend</div><div>10. Love Wins</div><div>11. Expect Miracles</div><div>12. Spirit Junkie</div><div>Acknowledgments</div>')

print dbo.udf_ConvertHTMLtoc2XMLtoc(replace(dbo.udf_StripSelectedHTMLTags(replace ('Foreword<br>Introduction<br>&#160;<br><br><br><br><br><br><br><br><br><br><br><br><b>PART 1 </b>The Detour into Fear<br>1. A Tiny Mad Idea<br>2. Anxiety and Ashrams<br>3. Somethin&rsquo; Special<br>4. Ask~<i>ing </i>for Help<br>&#160;<br><b>PART 2 </b>The Answer<br>5. The <i>F </i>Word<br>6. Relationships Are Assignments<br>7. The Holy Instant<br>8. Accepting My Invitation<br><b><br>PART 3 </b>The Miracle<br>9. Spirit Became My Boyfriend<br>10. Love Wins<br>11. Expect Miracles<br>12. Spirit Junkie<br>Acknowledgments','<br>','*CRLF*'),0),'*CRLF*',CHAR(13)+CHAR(10)))
**************************************************************/

IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[udf_ConvertHTMLtoc2XMLtoc]')
			AND type IN (N'FN',N'IF',N'TF',N'FS',N'FT')
		)
	DROP FUNCTION [dbo].[udf_ConvertHTMLtoc2XMLtoc]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_ConvertHTMLtoc2XMLtoc] (@szInput NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
--ALTER PROCEDURE [dbo].[mk_ConvertHTMLtoc2XMLtoc]
--(@szInput NVARCHAR(MAX))
AS
BEGIN
	DECLARE @szOutput NVARCHAR(MAX)
	DECLARE @szTOCText NVARCHAR(MAX)
	DECLARE @szTOCPageNum NVARCHAR(MAX)
	DECLARE @szColumnDelimiter NCHAR(5)
	DECLARE @szColumnDelimiter2 NCHAR(1)
	DECLARE @szRowDelimiter NCHAR(5)
	DECLARE @szRowDelimiter2 NCHAR(1)
	DECLARE @szRowText nvarchar(max)
	DECLARE	@iPosCloseTR INT
	DECLARE	@iPosOpenTR INT
	DECLARE	@iPosOpenTD INT
	DECLARE	@iCounter INT
	DECLARE	@iInputType INT
	DECLARE	@iColumnCount INT
	
	SET @szColumnDelimiter='</td>'
	SET @szColumnDelimiter2=CHAR(1)
	SET @szRowDelimiter='</tr>'
	SET @szRowDelimiter2=CHAR(2)
	SET @iInputType=0
	SET @iColumnCount=0
	SET @iCounter=0
			
	IF CHARINDEX(@szColumnDelimiter,@szInput)>0 AND @szInput IS NOT NULL 
	BEGIN
		--This is a table 
		-- ... get rid of any extra white space
		SET @szInput = dbo.udf_RemoveWhiteSpaceFromUML(@szInput)
		-- ... fix <tr /> single tags
		SET @szInput=REPLACE(@szInput,'<tr />', '<tr></tr>')
		-- ... get rid of table markup
		SET @szInput=REPLACE(@szInput,'<table>', '')
		SET @szInput=REPLACE(@szInput,'</table>', '')
		SET @szInput=REPLACE(@szInput,'<tr>', '')
		SET @szInput=REPLACE(@szInput,'<td>', '')
		SET @szInput=REPLACE(@szInput,'<div>', '')
		SET @szInput=REPLACE(@szInput,'</div>', '')
		--get rid of remaining markup
		SET @szInput=REPLACE(@szInput,@szRowDelimiter, @szRowDelimiter2)
		SET @szInput=REPLACE(@szInput,@szColumnDelimiter, @szColumnDelimiter2)
		SET @iInputType = 1

	END ELSE BEGIN

		--get rid of CRLF (<BR>, <DIV>, <P>, CRLF)
		IF CHARINDEX('</',@szInput)=0
		BEGIN
			SET @szInput = REPLACE(@szInput,CHAR(13)+CHAR(10),@szRowDelimiter2)		
		END ELSE BEGIN
			SET @szInput = REPLACE(@szInput,'<br>',@szRowDelimiter2)
			SET @szInput = REPLACE(@szInput,'<br\>',@szRowDelimiter2)
			SET @szInput = REPLACE(@szInput,'<br \>',@szRowDelimiter2)
			SET @szInput = REPLACE(@szInput,'<p>','')
			SET @szInput = REPLACE(@szInput,'</p>',@szRowDelimiter2)
			SET @szInput = REPLACE(@szInput,'<div>','')	
			SET @szInput = REPLACE(@szInput,'</div>',@szRowDelimiter2)		
		END

		--Clean out any remaining markup (render as ASCII text)	
		SET @szInput = dbo.udf_StripSelectedHTMLTags(@szInput,0)
		
		---get rid of redundant white space
		SET @szInput = REPLACE(@szInput,CHAR(160),'')
		WHILE charindex('  ', @szInput) > 0
		BEGIN
			SET @szInput = replace(@szInput, '  ', ' ')
		END
		
		--get rid of redundant CRLFs
		WHILE charindex(@szRowDelimiter2 + @szRowDelimiter2, @szInput) > 0
		BEGIN
			SET @szInput = REPLACE(@szInput,@szRowDelimiter2 + @szRowDelimiter2,@szRowDelimiter2)
		END
		
		SET @iInputType = 2
	END
	
	DECLARE RowCursor CURSOR FOR 
	SELECT part FROM dbo.udf_SplitString(@szInput,@szRowDelimiter2)
	OPEN RowCursor
	FETCH NEXT FROM RowCursor INTO @szRowText

	SET @szOutput = ''
	SET @szTOCPageNum=''

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @szRowText is not null and len(@szRowText)>0
		BEGIN
			IF @iInputType = 1
			BEGIN
				set @iCounter = @iCounter+1

				-- ... how many columns does it have?
				DECLARE @szRowTextLength INT
				DECLARE @szRowTextLengthMinusTokens INT
				DECLARE @szRowTextLengthDifference INT
				
				SET @szRowTextLength = LEN(@szRowText)
				SET @szRowTextLengthMinusTokens = LEN(REPLACE(@szRowText, @szColumnDelimiter2, ''))
				SET @szRowTextLengthDifference = @szRowTextLength - @szRowTextLengthMinusTokens
				
				SET @iColumnCount=@szRowTextLengthDifference
	
				--if @iCounter=1 return @iColumnCount

				SET @szRowText = LEFT(@szRowText,len(@szRowText)-1) 
				IF @iColumnCount = 1
				BEGIN
					SET @szTOCPageNum = ''
					SET @szTOCText = RTRIM(LTRIM(@szRowText))
				END ELSE IF @iColumnCount=2
				BEGIN
					SET @szTOCPageNum = RTRIM(LTRIM(RIGHT(@szRowText, LEN(@szRowText) - CHARINDEX(@szColumnDelimiter2,@szRowText))))				
					SET @szTOCText = RTRIM(LTRIM(Left(@szRowText, CHARINDEX(@szColumnDelimiter2,@szRowText)-1)))
				END ELSE IF @iColumnCount>2
				BEGIN
					SET @szTOCPageNum = ''
					SET @szRowText=REPLACE(@szRowText,@szColumnDelimiter2,' | ')
					SET @szTOCText = RTRIM(LTRIM(@szRowText))				
				END
				SET @szOutput = @szOutput + '<toc_item page_num="' + @szTOCPageNum + '">' + @szTOCText + '</toc_item>'
								
			END ELSE IF @iInputType = 2
			BEGIN
				----Check to page numbers
				--IF ISNUMERIC(LEFT(@RowText,1))>0
				--BEGIN
				--	SET @szTOCPageNum = LEFT(@RowText, 1)
				--END ELSE IF ISNUMERIC(RIGHT(@RowText,1))>0
				--BEGIN
				--	SET @szTOCPageNum = RIGHT(@RowText,1)
				--	print @RowText
				--	print @szTOCPageNum
				--	SET @RowText=LEFT(@RowText,len(@RowText)-1)
				--	SET @szOutput = @szOutput + '<toc_item page_num="' + @szTOCPageNum + '">' + @RowText + '</toc_item>'
				--END
				SET @szOutput = @szOutput + '<toc_item page_num="' + @szTOCPageNum + '">' + @szRowText + '</toc_item>'				
			END
		END		

		FETCH NEXT FROM RowCursor INTO @szRowText
		SET @szTOCPageNum=''
	END
	CLOSE RowCursor
	DEALLOCATE RowCursor

	RETURN @szOutput 
END
