/****** Object:  UserDefinedFunction [dbo].[udf_StripSelectedHTMLTags]    Script Date: 05/13/2015 14:03:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[udf_StripSelectedHTMLTags]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[udf_StripSelectedHTMLTags]
GO



/****** Object:  UserDefinedFunction [dbo].[udf_StripSelectedHTMLTags]    Script Date: 05/13/2015 14:03:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE  FUNCTION[dbo].[udf_StripSelectedHTMLTags] 
	(@HTMLText NVARCHAR(MAX)
	,@StripMode int)

--create procedure [dbo].[udf_StripSelectedHTMLTags] 
--	(@HTMLText NVARCHAR(MAX)
--	,@StripMode int)
	
	--@StripMode=0 for ASCIIMode
	--@StripMode=1 for HTMLLiteMode
	--@StripMode=2 for EscapeCodesOnly ... this is to handle the htmlconvert_tool functionality
	--List of Tags are in the 'HTMLTags' table
	-- ... this is configurable so that only the specified tags get replaced
	
RETURNS NVARCHAR(MAX)
AS
BEGIN
	--declare vars	
	DECLARE @HTMLTagString as NVARCHAR(15)
	DECLARE @HTMLEscapeCode as NVARCHAR(15)
	DECLARE @ReplacementString as NVARCHAR(50)
	DECLARE @ReplacementStringNumber as int	
	DECLARE @TagIndex as INT
	DECLARE @Start as INT
	DECLARE @End as INT
	DECLARE @Length as INT
	DECLARE @IsOrderedList as BIT
	DECLARE @PREVIOUS_IsOrderedList as BIT
	DECLARE @IsTruncated as BIT
	DECLARE @GT as NVARCHAR(3)
	DECLARE @LT as NVARCHAR(3)
	DECLARE @CRLF as NVARCHAR(10)
	DECLARE @CRLF_LITE_OPEN as NVARCHAR(10)
	DECLARE @CRLF_LITE_CLOSE as NVARCHAR(10)
	DECLARE @CRLF_DIV as NVARCHAR(10)
	DECLARE @ProcessCRLF as BIT
	DECLARE @ProcessCRLF_DIV as BIT
	DECLARE @MinifyInput as BIT
	DECLARE @OpenPs INT
	DECLARE @ClosePs INT
	DECLARE @DiffPs INT
	DECLARE @ListTagPosOPEN INT	
	DECLARE @ListTagPosCLOSE INT
	DECLARE @ListTagPosLoop INT

	DECLARE @const_ASCIIMode INT
	DECLARE @const_HTMLLiteMode INT
	DECLARE @const_EscapeCodesOnly INT

	DECLARE @LI_Open_Replacement	as NVARCHAR(128)
	DECLARE @UL_Open_Replacement	as NVARCHAR(128)
	DECLARE @OL_Open_Replacement	as NVARCHAR(128)
	DECLARE @LI_Close_Replacement	as NVARCHAR(128)
	DECLARE @UL_Close_Replacement	as NVARCHAR(128)
	DECLARE @OL_Close_Replacement	as NVARCHAR(128)
	DECLARE @LI_Open_temp			as NVARCHAR(128)
	DECLARE @LI_Close_temp			as NVARCHAR(128)
	DECLARE @UL_Open_temp			as NVARCHAR(128)
	DECLARE @UL_Close_temp			as NVARCHAR(128)
	DECLARE @OL_Open_temp			as NVARCHAR(128)
	DECLARE @OL_Close_temp			as NVARCHAR(128)

	DECLARE @StartListMakerProcess bit
		
	SET @LT='`~?'
	SET @GT='?~`'
	SET @CRLF=@LT+'CRLF'+@GT
	SET @CRLF_DIV=@LT+'CRLF_DIV'+@GT
	SET @CRLF_LITE_OPEN=@LT+'P'+@GT
	SET @CRLF_LITE_CLOSE=@LT+'/P'+@GT

	SET @LI_Open_temp =@LT+'li'+@GT
	SET @LI_Close_temp=@LT+'/li'+@GT
	SET @UL_Open_temp =@LT+'ul'+@GT
	SET @UL_Close_temp=@LT+'/ul'+@GT
	SET @OL_Open_temp =@LT+'ol'+@GT
	SET @OL_Close_temp=@LT+'/ol'+@GT
	
	SET @MinifyInput=0
	SET @ProcessCRLF=0
	SET @ProcessCRLF_DIV=0
	
	SET @ListTagPosOPEN= 1
	SET @ListTagPosCLOSE= 1
	SET @ListTagPosLoop= 1
	
	SET @StartListMakerProcess=0

	SET @const_ASCIIMode=0
	SET @const_HTMLLiteMode=1
	SET @const_EscapeCodesOnly=2
	
		
	--See if there are any unpaired <p> and </p>
	-- I have found tags like this "<P dir=ltr align=left>" that are unpaired in the source and need to be leaned up before lightening 
	SET @OpenPs=(LEN(@HTMLText)-LEN(REPLACE(UPPER(@HTMLText),'<P','')))/2
	SET @ClosePs=(LEN(@HTMLText)-LEN(REPLACE(UPPER(@HTMLText),'</P','')))/3
	SET @DiffPs=@OpenPs-@ClosePs
	IF @DiffPs>0 SET @HTMLText=@HTMLText+REPLICATE('</P>',@DiffPs)	
	
	--see if there are any HTML Tags
	SELECT	@TagIndex=SUM(CHARINDEX(HTMLTagString collate SQL_Latin1_General_CP1_CI_AS,@HTMLText))
	FROM	HTMLTags 
	WHERE	((ASCIIMode=1 and @StripMode=@const_ASCIIMode)
			or (HTMLLiteMode=1 and @StripMode=@const_HTMLLiteMode)
			or (ASCIIMode=1 and @StripMode=@const_EscapeCodesOnly and HTMLEscapeCode=1))
			and CHARINDEX(HTMLTagString collate SQL_Latin1_General_CP1_CI_AS,@HTMLText)<>0

	IF @TagIndex>0
		BEGIN
			--PRE-PROCESS
			-- ... trim leading and trailing CRLFS if the incoming stream is wrapped in a <DIV> .... <BR /><DIV>
			IF @StripMode=@const_ASCIIMode
				BEGIN
					IF	SUBSTRING(@HTMLText,1,len('<DIV>')) = '<DIV>'
					AND  SUBSTRING(@HTMLText,len(@HTMLText)-len('<BR /></DIV>')+1,len('<BR /></DIV>')) = '<BR /></DIV>'
						BEGIN
							SET @HTMLText = STUFF(@HTMLText, 1, len('<DIV>'), '')
							SET @HTMLText = REVERSE(@HTMLText)
							SET @HTMLText = STUFF(@HTMLText, 1, len('<BR /></DIV>'), '')
							SET @HTMLText = REVERSE(@HTMLText)
						END
				END

			--Create Temp HTMLTags
			DECLARE @HTMLTags table (HTMLTagsKey INT,HTMLTagString NVARCHAR(max),HTMLEscapeCode NVARCHAR(max),ReplacementString NVARCHAR(max))
			INSERT INTO @HTMLTags
			SELECT	HTMLTagsKey,
					HTMLTagString, 
					HTMLEscapeCode, 
					CASE	WHEN @StripMode=@const_ASCIIMode THEN ReplacementStringASCIIMode
							WHEN @StripMode=@const_EscapeCodesOnly THEN ReplacementStringASCIIMode
							WHEN @StripMode=@const_HTMLLiteMode THEN ReplacementStringHTMLLiteMode END	as ReplacementString
			FROM	HTMLTags 
			WHERE	((ASCIIMode=1 and @StripMode=@const_ASCIIMode)
					OR (HTMLLiteMode=1 and @StripMode=@const_HTMLLiteMode)
					OR (ASCIIMode=1 and @StripMode=@const_EscapeCodesOnly AND HTMLEscapeCode=1))					
					AND CHARINDEX(HTMLTagString collate SQL_Latin1_General_CP1_CI_AS,@HTMLText)<>0
					AND SYSTEM_RECORD = 0

			INSERT INTO @HTMLTags
			SELECT	HTMLTags.HTMLTagsKey,
					HTMLTags.HTMLTagString, 
					HTMLTags.HTMLEscapeCode, 
					CASE	WHEN @StripMode=@const_ASCIIMode THEN HTMLTags.ReplacementStringASCIIMode
							WHEN @StripMode=@const_EscapeCodesOnly THEN HTMLTags.ReplacementStringASCIIMode
							WHEN @StripMode=@const_HTMLLiteMode THEN HTMLTags.ReplacementStringHTMLLiteMode END	as ReplacementString
			FROM	HTMLTags 
					LEFT JOIN @HTMLTags t ON t.HTMLtagstring collate SQL_Latin1_General_CP1_CI_AS =HTMLTags.HTMLtagstring collate SQL_Latin1_General_CP1_CI_AS
			WHERE	((HTMLTags.ASCIIMode=1 and @StripMode=@const_ASCIIMode)
					OR (HTMLTags.HTMLLiteMode=1 and @StripMode=@const_HTMLLiteMode)
					OR (HTMLTags.ASCIIMode=1 and @StripMode=@const_EscapeCodesOnly AND HTMLTags.HTMLEscapeCode=1))					
					AND CHARINDEX(HTMLTags.HTMLTagString collate SQL_Latin1_General_CP1_CI_AS,@HTMLText)<>0
					AND HTMLTags.SYSTEM_RECORD = 1
					AND t.HTMLTagstring IS NULL
			ORDER BY HTMLTags.HTMLTagsKey
			
			--open a cursor for the tag replacements
			DECLARE TagCursor CURSOR FOR
			SELECT  HTMLTagString, HTMLEscapeCode, ReplacementString
			FROM @HTMLTags
			ORDER BY HTMLTagsKey
			OPEN TagCursor;
			FETCH TagCursor into @HTMLTagString, @HTMLEscapeCode, @ReplacementString;
						
			WHILE @@FETCH_STATUS = 0
				BEGIN
					IF RIGHT(@HTMLTagString,1) = '>' BEGIN -- UK Case 23063  03/14/2013 if the table had a tag like <h1>, it is resolved to be as <h1
						SET @HTMLTagString = LEFT(@HTMLTagString, LEN(@HTMLTagString) - 1)
					END
					--print char(13)+char(10) + 'Looking for: ' + @HTMLTagString + ' and replacing with: ' + coalesce (@ReplacementString,'*N/A*')
					IF @HTMLEscapeCode=1
						BEGIN					
ProcessHTMLEscapeCodes:
							--These are tags escape codes like &amp; and &lt ...
							-- ... they should get replaced by the table driven @ReplacementString (decimal code for CHAR())
							-- ... make sure the replacements are case sensitive as there is a difference between "&Aacute;" AND "&aacute;"
							IF ISNULL(@ReplacementString,'NULL')='NULL'
								BEGIN
									SET @HTMLText = REPLACE (@HTMLText,@HTMLTagString,'');
								END ELSE BEGIN
									IF CHARINDEX('.',@ReplacementString)>0
									BEGIN
										--This is a multiple character replacement
										-- ... basic assumption is that there can be only 2 chars that can be replaced such as &#64257; = F & I = (102.105)
										SET @ReplacementString=CHAR(CAST(PARSENAME(@ReplacementString,2) as INT))+ CHAR(CAST(PARSENAME(@ReplacementString,1)as INT))
										SET @HTMLText = REPLACE (@HTMLText COLLATE Latin1_General_CS_AS,@HTMLTagString,@ReplacementString)
									END ELSE IF @ReplacementString like '%[^0-9]%'  --... THIS TESTS FOR NOT A NUMBER = TRUE
									BEGIN	
										SET @HTMLText = REPLACE (@HTMLText COLLATE Latin1_General_CS_AS,@HTMLTagString,@ReplacementString);
									END ELSE BEGIN	
										SET @HTMLText = REPLACE (@HTMLText COLLATE Latin1_General_CS_AS,@HTMLTagString,CHAR(CAST(@ReplacementString as INT)));
									END 
								END
						END
					ELSE
						BEGIN
ProcessHTMLTags:
							IF @MinifyInput=0
								BEGIN
									--print 'Before minify = ' + @HTMLText
									SET @HTMLText=dbo.udf_RemoveWhiteSpaceFromUML(@HTMLText)
									--print 'After minify = ' + @HTMLText
									SET @MinifyInput=1
								END

							--These are normal HTML tags like <p> and <H2>
							SET @Start = CHARINDEX(@HTMLTagString + '>' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + '/' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + ' ' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + ':' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + '=' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText) -- UK Case 23063  03/13/2013
							
							SET @End = CHARINDEX('>', @HTMLText, @Start)
							SET @Length = (@End - @Start) + 1
							SET @ReplacementStringNumber = 0
							SET @IsOrderedList=0
							SET @PREVIOUS_IsOrderedList=0
							
							--print 'initial search'
							--print @HTMLTagString
							--print '@Start = ' + cast (@Start as NVARCHAR(max))
							--print '@End = ' + cast (@End as NVARCHAR(max))
							--print '@Length = ' + cast (@Length as NVARCHAR(max))
							--print '@IsOrderedList = ' + cast (@IsOrderedList as NVARCHAR(max))
							--print @HTMLText

							WHILE @Start > 0
								AND @End > 0
								AND @Length > 0
							BEGIN
								IF @HTMLTagString = '<SCRIPT'
									BEGIN
										-- this is a script ... make sure to also remove all text between <SCRIPT>var blah - blah ... return</SCRIPT>
ProcessScript:
										--print char(13) + char(10) + 'this is a script ... make sure to also remove all text between <SCRIPT>var blah - blah ... return</SCRIPT>'
										SET @End = 	CHARINDEX('</SCRIPT>' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText, @Start) + LEN('</SCRIPT>')
										SET @Length = (@End - @Start)
										SET @IsTruncated=0
										
										IF @Length > 8000
											BEGIN
												SET @Length=8000
												SET @IsTruncated=1
											END
											
										--print '@Start = ' + cast (@Start as NVARCHAR(max))
										--print '@End = ' + cast (@End as NVARCHAR(max))
										--print '@Length = ' + cast (@Length as NVARCHAR(max))
										
										--print 'substring(@HTMLText,@Start,@Length) = ' 
										--print  substring(@HTMLText,@Start,@Length)
										
										--print char(13) + char(10) 
										--print 'BEFORE'
										--print @HTMLText
										
										SET @HTMLText = STUFF(@HTMLText, @Start, @Length, @ReplacementString)
										
										--print char(13) + char(10) 
										--print 'AFTER'
										--print @HTMLText
										
										IF @IsTruncated=1 goto ProcessScript
									END

								ELSE IF @HTMLTagString = '<STYLE'
									BEGIN
										-- this is a STYLE ... make sure to also remove all text between <STYLE>h1 {color:red;}</STYLE>
ProcessStyle:
										--print char(13) + char(10) + 'this is a STYLE ... make sure to also remove all text between <STYLE>var blah - blah ... return</STYLE>'
										SET @End = 	CHARINDEX('</STYLE>' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText, @Start) + LEN('</STYLE>')
										SET @Length = (@End - @Start)
										SET @IsTruncated=0
										
										IF @Length > 8000
											BEGIN
												SET @Length=8000
												SET @IsTruncated=1
											END
										
										--print '@Start = ' + cast (@Start as NVARCHAR(max))
										--print '@End = ' + cast (@End as NVARCHAR(max))
										--print '@Length = ' + cast (@Length as NVARCHAR(max))
										
										--print 'substring(@HTMLText,@Start,@Length) = ' 
										--print  substring(@HTMLText,@Start,@Length)
										
										--print char(13) + char(10) 
										--print 'BEFORE'
										--print @HTMLText
										
										SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
										
										--print char(13) + char(10) 
										--print 'AFTER'
										--print @HTMLText
										
										IF @IsTruncated=1 goto ProcessStyle
									END	

								ELSE IF @HTMLTagString IN ('<LI' ,'</LI','<UL' ,'</UL','<OL' ,'</OL' ) AND @StartListMakerProcess<2 
									BEGIN
										-- This is a list item - it can be either ordered (Numbered) or unordered (Bulleted)
ProcessListItems:
										--First off make sure the LIST tags are reduced down to their simplest forms (remove any attributes)
										SET @ListTagPosLoop=1
										WHILE @ListTagPosLoop<7
										BEGIN
											IF @ListTagPosLoop=1 SET @HTMLTagString='<LI'
											IF @ListTagPosLoop=2 SET @HTMLTagString='</LI'
											IF @ListTagPosLoop=3 SET @HTMLTagString='<UL'
											IF @ListTagPosLoop=4 SET @HTMLTagString='</UL'
											IF @ListTagPosLoop=5 SET @HTMLTagString='<OL'
											IF @ListTagPosLoop=6 SET @HTMLTagString='</OL'
											SET @ListTagPosLoop=@ListTagPosLoop+1
											
											SET @ListTagPosOPEN=0
											WHILE @ListTagPosOPEN>-1
											BEGIN
												SET @ListTagPosOPEN=CHARINDEX(@HTMLTagString,@HTMLText collate SQL_Latin1_General_CP1_CI_AS,@ListTagPosOPEN+1)
												IF @ListTagPosOPEN>0 
												BEGIN
													SET @ListTagPosCLOSE=CHARINDEX('>',@HTMLText collate SQL_Latin1_General_CP1_CI_AS,@ListTagPosOPEN)
													SET @HTMLText = STUFF(@HTMLText, @ListTagPosOPEN, @ListTagPosCLOSE-@ListTagPosOPEN+1, @HTMLTagString + '>')
												END ELSE BEGIN
													SET @ListTagPosOPEN=-1
												END
											END 
										END

										--Then make sure that list should actually be processed
										-- ... Don't Process ListMaker
										-- ... ... if the tags are not used for this strip mode (then this case shouldn't get hit in the first place)
										-- ... ... if the tags = their ReplacementString
										-- ... ... ... instead just do the straight substitutions
										-- ... ... if it's already been processed
										
										IF @StripMode=@const_ASCIIMode
										BEGIN
											select top 1 @LI_Open_Replacement  = ReplacementStringASCIIMode from htmltags where HTMLTagString='<LI' order by SYSTEM_RECORD ASC
											select top 1 @LI_Close_Replacement = ReplacementStringASCIIMode from htmltags where HTMLTagString='</LI' order by SYSTEM_RECORD ASC
											set @StartListMakerProcess=1
										END
										IF @StripMode=@const_HTMLLiteMode
										BEGIN
											select top 1 @LI_Open_Replacement  = ReplacementStringHTMLLiteMode from htmltags where HTMLTagString='<LI' order by SYSTEM_RECORD ASC
											select top 1 @LI_Close_Replacement = ReplacementStringHTMLLiteMode from htmltags where HTMLTagString='</LI' order by SYSTEM_RECORD ASC
											set @StartListMakerProcess=case when UPPER(@LI_Open_Replacement)<>'<LI>' OR UPPER(@LI_Close_Replacement)<>'</LI>' then 1 ElSE 0 END
										END
										
										IF @StartListMakerProcess<2
										BEGIN
											-- this is specialty code that removes white space garabage introduced by the ckEditor
											-- specifically - we found instances of this:
													--<div>
													--	<ol>
													--		<li>
													--			item1</li>
													--		<li>
													--			item2</li>
													--	</ol>													
													--</div>
											-- notice the CRLF and tabs after the <LI> ... those need removing
											WHILE CHARINDEX('<LI>' + CHAR(9) collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)>0
											BEGIN
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '<LI>' + CHAR(9),'<LI>')
											END
										END
																					
										IF @StartListMakerProcess=1 
											BEGIN
												SET @HTMLText = dbo.udf_Process_HTML_Lists (@HTMLText,@LI_Open_Replacement,@LI_Close_Replacement,@StripMode)
												SET @StartListMakerProcess=2
											END ELSE BEGIN
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '<LI>',@LI_Open_temp )
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '</LI>',@LI_Close_temp)
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '<UL>',@UL_Open_temp)
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '</UL>',@UL_Close_temp)
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '<OL>',@OL_Open_temp)
												SET @HTMLText = REPLACE(@HTMLText collate SQL_Latin1_General_CP1_CI_AS, '</OL>',@OL_Close_temp)
												SET @StartListMakerProcess=2
											END
									END

								ELSE IF @ReplacementString not like '%[^0-9]%'
									BEGIN
ProcessNumericCHARs:
										-- replace with a Char(###) value
										SET @HTMLText = STUFF(@HTMLText, @Start, @Length, CHAR(CAST(@ReplacementString as INT)))
									END

								
								ELSE IF @ReplacementString ='DIV_CRLF'
									BEGIN
ProcessDIV_CRLF:
										SET @ProcessCRLF_DIV=1
										SET @HTMLText = STUFF(@HTMLText, @Start, @Length, @CRLF_DIV)
										--print CHAR(13)+CHAR(10)
										--print '****************************************'
										--print @HTMLText
										--print '****************************************'
									END

								ELSE IF @ReplacementString ='CRLF'
									BEGIN
ProcessCRLF:
										SET @ProcessCRLF=1
										SET @HTMLText = STUFF(@HTMLText, @Start, @Length, @CRLF)
										--print CHAR(13)+CHAR(10)
										--print '****************************************'
										--print @HTMLText
										--print '****************************************'
									END
								ELSE
									BEGIN
ProcessEverythingElse:
										-- replace with ordinary text (this needs a little markup so the process doesn't infintitely loops in the case of html tags)
										-- example ... replacing <b style="font-family: ''times New Roman''; "> with just a <b> would cause an infintite loop
										-- ... therefore make the temp substitution of `~?b?~` and then reset the markup with <> at the end
										SET @ReplacementString=REPLACE(@ReplacementString,'<',@LT)
										SET @ReplacementString=REPLACE(@ReplacementString,'>',@GT)
										SET @HTMLText = STUFF(@HTMLText, @Start, @Length, @ReplacementString)
									END

							SET @Start = CHARINDEX(@HTMLTagString + '>' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + '/' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + ' ' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + ':' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText)
							IF @Start = 0 SET @Start = CHARINDEX(@HTMLTagString + '=' collate SQL_Latin1_General_CP1_CI_AS, @HTMLText) -- UK Case 23063  03/13/2013
							
							SET @End = CHARINDEX('>', @HTMLText, @Start)
							SET @Length = (@End - @Start) + 1				
							
							--print char(13)+char(10) + 'subsequent search'
							--print '@HTMLTagString = ' + cast (@HTMLTagString as NVARCHAR(max))
							--print '@Start = ' + cast (@Start as NVARCHAR(max))
							--print '@End = ' + cast (@End as NVARCHAR(max))
							--print '@Length = ' + cast (@Length as NVARCHAR(max))
							--print '@IsOrderedList = ' + cast (@IsOrderedList as NVARCHAR(max))							
							--print @HTMLText
						END						
					END
					--print LTRIM(RTRIM(@HTMLText))				
					FETCH TagCursor into @HTMLTagString, @HTMLEscapeCode, @ReplacementString;
				END;
			CLOSE TagCursor;
			DEALLOCATE TagCursor;
		END		

	--Bail out if just processing 
	IF @StripMode=@const_EscapeCodesOnly RETURN @HTMLText 

	--POST-PROCESS
	-- special cases
	SET @HTMLText=REPLACE(@HTMLText,@CRLF_LITE_OPEN+'&#160;'+@CRLF_LITE_CLOSE,'')
	SET @HTMLText=REPLACE(@HTMLText,@CRLF_LITE_OPEN+'&nbsp;'+@CRLF_LITE_CLOSE,'')
	SET @HTMLText=REPLACE(@HTMLText,@CRLF_LITE_OPEN+'&#160; '+@CRLF_LITE_CLOSE,'')
	SET @HTMLText=REPLACE(@HTMLText,@CRLF_LITE_OPEN+'&nbsp; '+@CRLF_LITE_CLOSE,'')					
	
	-- get rid of redundant CRLFs
	IF @ProcessCRLF=1
		BEGIN
			WHILE CHARINDEX(@CRLF+@CRLF, @HTMLText)>0
				BEGIN
					SET @HTMLText=REPLACE(@HTMLText,@CRLF+@CRLF,@CRLF)
				END
			IF @StripMode=@const_HTMLLiteMode
			BEGIN
				SET @HTMLText=REPLACE(@HTMLText,@CRLF,'<BR />')
			END ELSE BEGIN
				SET @HTMLText=REPLACE(@HTMLText,@CRLF,CHAR(13)+CHAR(10))
			END
		END
	-- get rid of redundant DIV_CRLFs
	IF @ProcessCRLF_DIV=1
		BEGIN
			WHILE CHARINDEX(@CRLF_DIV+@CRLF_DIV, @HTMLText)>0
				BEGIN
					SET @HTMLText=REPLACE(@HTMLText,@CRLF_DIV+@CRLF_DIV,@CRLF_DIV)
				END
			IF @StripMode=@const_HTMLLiteMode
			BEGIN
				SET @HTMLText=REPLACE(@HTMLText,@CRLF_DIV,'<BR />')
			END ELSE BEGIN
				SET @HTMLText=REPLACE(@HTMLText,@CRLF_DIV,CHAR(13)+CHAR(10))
			END
		END
	
	-- cleanup any remaing process related markup
	SET @HTMLText=REPLACE(@HTMLText,@LT,'<')
	SET @HTMLText=REPLACE(@HTMLText,@GT,'>')
	
	--Remove non ASCII characters (0-31)
	SET @HTMLText=dbo.udf_RemoveNonASCII(@HTMLText)
	
	-- trim any white space
	SET @HTMLText=LTRIM(RTRIM(@HTMLText))
		
	RETURN @HTMLText
	--print char(13) + char(10) + 'RETURN:'
	--print LTRIM(RTRIM(@HTMLText))
END



GO
grant all on [udf_StripSelectedHTMLTags] to public
GO