if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_rpt_get_CategoryDesc_from_TitleHistory]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[WK_rpt_get_CategoryDesc_from_TitleHistory]
GO

CREATE FUNCTION [dbo].[WK_rpt_get_CategoryDesc_from_TitleHistory] (
		@bookkey	INT,
		@currentstringvalue		VARCHAR(255),
		@fielddesc  VARCHAR(80),
		@columnkey int)
	
	RETURNS VARCHAR(255)
	
AS

BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @SUBJECT1		VARCHAR(255)
	DECLARE @SUBJECT2		VARCHAR(255)
	DECLARE @SUBJECT3		VARCHAR(255)
	DECLARE @sortorder int
	DECLARE @tableid int
	DECLARE @SUBJECT		VARCHAR(255)

	SET @SUBJECT = NULL
	SET @SUBJECT1 = NULL
	SET @SUBJECT2 = NULL
	SET @SUBJECT3 = NULL
	SET @sortorder = 0
	SET @tableid = NULL
	SET @RETURN = NULL

IF @columnkey = 220 OR @columnkey = 221 OR @columnkey = 222
BEGIN

	Select @currentstringvalue = REPLACE(REPLACE(@currentstringvalue,'(DELETED) - ', ''), '(DELETED)', '')

	IF @columnkey = 220
	BEGIN

		DECLARE @SUB_AND_SUB2   VARCHAR(255)
		SET @SUB_AND_SUB2 = NULL

		--just get the sortorder, we should have SUBJECT X in fielddesc  where x denotes sortorder
		--we don't need to return sortorder at this point. All we need is to know which subject category is changed. 
		--The exe that consumes CSI should get the correct sortorders from booksubjectcategory
		--Don't check on sortorder in this step, the category might be deleted and it won't be in there anymore

		SELECT @Sortorder = LTRIM(RTRIM(SUBSTRING(@fielddesc, CHARINDEX(' ', @fielddesc)+1, LEN(@fielddesc) - CHARINDEX(' ', @fielddesc)+1)))

		--currentstringvalue should display at least subject and possibly subsubject and sub2subject seperated by ' - '
		--BUG IN TITLEHISTORY, APP IS ASSIGNING STRING VALUE NULL instead of database NULL
		--THIS SHOULD NOT HAPPEN BUT CHECK and ASSIGN EMPTY STRING JUST IN CASE
		IF 	@currentstringvalue IS NULL or @currentstringvalue = '' or @currentstringvalue = 'NULL'
			SELECT @currentstringvalue = ''

		IF LEN(@currentstringvalue) > 0
			BEGIN
				IF CHARINDEX(' - ', @currentstringvalue) > 0
					BEGIN
						Select @SUBJECT1 = LTRIM(RTRIM(SUBSTRING(@currentstringvalue, 1, CHARINDEX(' - ', @currentstringvalue)-1)))
						SELECT @SUB_AND_SUB2 = LTRIM(RTRIM(SUBSTRING(@currentstringvalue, CHARINDEX(' - ', @currentstringvalue)+3, LEN(@currentstringvalue) - CHARINDEX(' - ', @currentstringvalue)+3)))
						IF CHARINDEX(' - ', @SUB_AND_SUB2) > 0
							BEGIN
								Select @SUBJECT2 = LTRIM(RTRIM(SUBSTRING(@SUB_AND_SUB2, 1, CHARINDEX(' - ', @SUB_AND_SUB2)-1)))
								SELECT @SUBJECT3 = LTRIM(RTRIM(SUBSTRING(@SUB_AND_SUB2, CHARINDEX(' - ', @SUB_AND_SUB2)+3, LEN(@SUB_AND_SUB2) - CHARINDEX(' - ', @SUB_AND_SUB2)+3)))
							END
						ELSE
							BEGIN
								Select @SUBJECT2 = @SUB_AND_SUB2
							END
					END
				ELSE
					BEGIN
						--Only subject is there
						Select @SUBJECT1 = LTRIM(RTRIM(@currentstringvalue))
					END
			END
		ELSE
			BEGIN 
				RETURN NULL 
			END

		IF @SUBJECT1 IS NULL OR @SUBJECT1 = ''
			RETURN NULL

		IF LEN(@SUBJECT1) > 0 AND (@SUBJECT2 IS NULL OR @SUBJECT2 = '')
			BEGIN
				--Should not have more than one record but just in case different categories
				--have the same datadesc on gentableid
				Select TOP 1 @tableid = g.tableid FROM gentables g
				WHERE ((g.datadescshort IS NOT NULL AND datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and g.tableid in (412, 433,  432)
				ORDER BY g.tableid
	--					AND EXISTS(Select * FROM booksubjectcategory bsc where bsc.bookkey = @bookkey and categorytableid=g.tableid and sortorder = @sortorder) 
				--Titlehistory uses short desc if available otherwise datadesc

				--Confirm this record exists
				--Cant do this because the booksubjectcategory could be deleted from 
	--			IF EXISTS(Select * FROM booksubjectcategory where bookkey = @bookkey and categorytableid=@tableid and sortorder = @sortorder)
	--				BEGIN
	--					Select @RETURN = tabledesclong FROM gentablesdesc
	--					WHERE tableid = @tableid
	--
	--				END  
			END


		IF LEN(@SUBJECT1) > 0 AND LEN(@SUBJECT2)> 0 AND @SUBJECT3 IS NULL
			BEGIN
				Select @tableid = g.tableid FROM gentables g
				JOIN subgentables sg
				ON g.tableid = sg.tableid and g.datacode = sg.datacode
				WHERE ((g.datadescshort IS NOT NULL AND g.datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and ((sg.datadescshort IS NOT NULL AND sg.datadescshort= @SUBJECT2) OR sg.datadesc = @SUBJECT2)
				and g.tableid in (412, 433,  432)


			END
		
		IF LEN(@SUBJECT1) > 0  AND LEN(@SUBJECT2) > 0 AND LEN(@SUBJECT3) > 0
			BEGIN
				Select @tableid = g.tableid 
				FROM gentables g
				JOIN subgentables sg
				ON g.tableid = sg.tableid and g.datacode = sg.datacode
				JOIN sub2gentables s2g
				ON sg.tableid = s2g.tableid and sg.datasubcode = s2g.datasubcode 
				WHERE ((g.datadescshort IS NOT NULL AND g.datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and ((sg.datadescshort IS NOT NULL AND sg.datadescshort= @SUBJECT2) OR sg.datadesc = @SUBJECT2)
				and ((s2g.datadescshort IS NOT NULL AND s2g.datadescshort= @SUBJECT3) OR s2g.datadesc = @SUBJECT3)
				and g.tableid in (412, 433,  432)
			END
			
	END


	IF @columnkey = 221
	BEGIN

		IF CHARINDEX(' - ', @fielddesc) > 0
			BEGIN
				Select @SUBJECT = LTRIM(RTRIM(SUBSTRING(@fielddesc, 1, CHARINDEX(' - ', @fielddesc)-1)))
				--Only first level subject should be in here
				SELECT @SUBJECT1 = LTRIM(RTRIM(SUBSTRING(@fielddesc, CHARINDEX(' - ', @fielddesc)+3, LEN(@fielddesc) - CHARINDEX(' - ', @fielddesc)+3)))
			END
		ELSE --No Subsubject
			BEGIN
				RETURN @RETURN
			END

		--BUG IN TITLEHISTORY, APP IS ASSIGNING STRING VALUE NULL instead of database NULL
		IF 	@currentstringvalue IS NULL or @currentstringvalue = '' or @currentstringvalue = 'NULL'
			SELECT @currentstringvalue = ''

	--	SELECT @currentstring = @currentstringvalue
		--SUBJECT1 should be in fielddesc, and we either have nothing in currentstringvalue, just SUBJECT2 or both SUBJECT2 and 3
		IF LEN(@currentstringvalue) > 0
			BEGIN
				IF CHARINDEX(' - ', @currentstringvalue) > 0
					BEGIN
						Select @SUBJECT2 = LTRIM(RTRIM(SUBSTRING(@currentstringvalue, 1, CHARINDEX(' - ', @currentstringvalue)-1)))
						SELECT @SUBJECT3 = LTRIM(RTRIM(SUBSTRING(@currentstringvalue, CHARINDEX(' - ', @currentstringvalue)+3, LEN(@currentstringvalue) - CHARINDEX(' - ', @currentstringvalue)+3)))
					END
				ELSE
					BEGIN
						Select @SUBJECT2 = LTRIM(RTRIM(@currentstringvalue))
					END
			END

		IF CHARINDEX(' ', @SUBJECT) > 0
			BEGIN
				SELECT @Sortorder = LTRIM(RTRIM(SUBSTRING(@SUBJECT, CHARINDEX(' ', @SUBJECT)+1, LEN(@SUBJECT) - CHARINDEX(' ', @SUBJECT)+1)))
			END 

		IF @SUBJECT1 IS NULL OR @SUBJECT1 = ''
			RETURN NULL

		IF LEN(@SUBJECT1) > 0 AND (@SUBJECT2 IS NULL OR @SUBJECT2 = '')
			BEGIN
				--Should not have more than one record but just in case different categories
				--have the same datadesc on gentableid
				Select TOP 1 @tableid = g.tableid FROM gentables g
				WHERE ((g.datadescshort IS NOT NULL AND datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and g.tableid in (412, 433, 432)
				ORDER BY g.tableid
	--					AND EXISTS(Select * FROM booksubjectcategory bsc where bsc.bookkey = @bookkey and categorytableid=g.tableid and sortorder = @sortorder) 
				--Titlehistory uses short desc if available otherwise datadesc

				--Confirm this record exists
				--Cant do this because the booksubjectcategory could be deleted from 
	--			IF EXISTS(Select * FROM booksubjectcategory where bookkey = @bookkey and categorytableid=@tableid and sortorder = @sortorder)
	--				BEGIN
	--					Select @RETURN = tabledesclong FROM gentablesdesc
	--					WHERE tableid = @tableid
	--
	--				END  
			END


		IF LEN(@SUBJECT1) > 0 AND LEN(@SUBJECT2)> 0 AND (@SUBJECT3 IS NULL OR @SUBJECT3 = '')
			BEGIN
				Select @tableid = g.tableid FROM gentables g
				JOIN subgentables sg
				ON g.tableid = sg.tableid and g.datacode = sg.datacode
				WHERE ((g.datadescshort IS NOT NULL AND g.datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and ((sg.datadescshort IS NOT NULL AND sg.datadescshort= @SUBJECT2) OR sg.datadesc = @SUBJECT2)
				and g.tableid in (412, 433,  432)


			END


		IF LEN(@SUBJECT1) > 0  AND LEN(@SUBJECT2) > 0 AND LEN(@SUBJECT3) > 0
			BEGIN
				Select @tableid = g.tableid 
				FROM gentables g
				JOIN subgentables sg
				ON g.tableid = sg.tableid and g.datacode = sg.datacode
				JOIN sub2gentables s2g
				ON sg.tableid = s2g.tableid and sg.datasubcode = s2g.datasubcode 
				WHERE ((g.datadescshort IS NOT NULL AND g.datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and ((sg.datadescshort IS NOT NULL AND sg.datadescshort= @SUBJECT2) OR sg.datadesc = @SUBJECT2)
				and ((s2g.datadescshort IS NOT NULL AND s2g.datadescshort= @SUBJECT3) OR s2g.datadesc = @SUBJECT3)
				and g.tableid in (412, 433, 432)
			END
	END

	IF @columnkey = 222
	BEGIN

		DECLARE @HOLDER1	VARCHAR(255)
		DECLARE @HOLDER2	VARCHAR(255)
		SET @HOLDER1 =  NULL
		SET @HOLDER2 = NULL


		--VALUE FOR 3rd level should not be in fielddesc but check just in case
		IF CHARINDEX(' - ', @fielddesc) > 0
			BEGIN
					Select @SUBJECT = LTRIM(RTRIM(SUBSTRING(@fielddesc, 1, CHARINDEX(' - ', @fielddesc)-1)))
					SELECT @HOLDER1 = LTRIM(RTRIM(SUBSTRING(@fielddesc, CHARINDEX(' - ', @fielddesc)+3, LEN(@fielddesc) - CHARINDEX(' - ', @fielddesc)+3)))
					IF CHARINDEX(' - ', @HOLDER1) > 0
						BEGIN
							Select @SUBJECT1 = LTRIM(RTRIM(SUBSTRING(@HOLDER1, 1, CHARINDEX(' - ', @HOLDER1)-1)))
							SELECT @HOLDER2 = LTRIM(RTRIM(SUBSTRING(@HOLDER1, CHARINDEX(' - ', @HOLDER1)+3, LEN(@HOLDER1) - CHARINDEX(' - ', @HOLDER1)+3)))
							IF CHARINDEX(' - ', @HOLDER2) > 0
								BEGIN
									Select @SUBJECT2 = LTRIM(RTRIM(SUBSTRING(@HOLDER2, 1, CHARINDEX(' - ', @HOLDER2)-1)))
									SELECT @SUBJECT3 = LTRIM(RTRIM(SUBSTRING(@HOLDER2, CHARINDEX(' - ', @HOLDER2)+3, LEN(@HOLDER2) - CHARINDEX(' - ', @HOLDER2)+3)))
								END
							ELSE
								BEGIN
									Select @SUBJECT2 = @HOLDER2
								END
						END
					ELSE
						BEGIN
							Select @SUBJECT1 = @HOLDER1
						END
			END
		ELSE
			BEGIN
				--Only subject is there
				Select @SUBJECT1 = LTRIM(RTRIM(@currentstringvalue))
			END


	--Now check currentstring value, only sub2 level should be in here
	--BUG IN TITLEHISTORY, APP IS ASSIGNING STRING VALUE NULL instead of database NULL
	IF 	@currentstringvalue IS NULL or @currentstringvalue = '' or @currentstringvalue = 'NULL'
		SELECT @currentstringvalue = ''


	--	SELECT @currentstring = @currentstringvalue
		--SUBJECT1 should be in fielddesc, and we either have nothing in currentstringvalue, just SUBJECT2 or both SUBJECT2 and 3
		IF LEN(@currentstringvalue) > 0
			BEGIN
				IF CHARINDEX(' - ', @currentstringvalue) > 0
					BEGIN
						--THiS SHOULD NOT HAPPEN
						RETURN 'ERROR'
	--					Select @SUBJECT2 = LTRIM(RTRIM(SUBSTRING(@currentstring, 1, CHARINDEX(' - ', @currentstring)-1)))
	--					SELECT @SUBJECT3 = LTRIM(RTRIM(SUBSTRING(@currentstring, CHARINDEX(' - ', @currentstring)+3, LEN(@currentstring) - CHARINDEX(' - ', @currentstring)+3)))
					END
				ELSE
					BEGIN
						Select @SUBJECT3 = LTRIM(RTRIM(@currentstringvalue))
					END
			END

		IF CHARINDEX(' ', @SUBJECT) > 0
			BEGIN
				SELECT @Sortorder = LTRIM(RTRIM(SUBSTRING(@SUBJECT, CHARINDEX(' ', @SUBJECT)+1, LEN(@SUBJECT) - CHARINDEX(' ', @SUBJECT)+1)))
			END 

		IF @SUBJECT1 IS NULL OR @SUBJECT1 = ''
			RETURN NULL

		IF LEN(@SUBJECT1) > 0 AND (@SUBJECT2 IS NULL OR @SUBJECT2 = '')
			BEGIN
				--Should not have more than one record but just in case different categories
				--have the same datadesc on gentableid
				Select TOP 1 @tableid = g.tableid FROM gentables g
				WHERE ((g.datadescshort IS NOT NULL AND datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and g.tableid in (412, 433,  432)
				ORDER BY g.tableid
	--					AND EXISTS(Select * FROM booksubjectcategory bsc where bsc.bookkey = @bookkey and categorytableid=g.tableid and sortorder = @sortorder) 
				--Titlehistory uses short desc if available otherwise datadesc

				--Confirm this record exists
				--Cant do this because the booksubjectcategory could be deleted from 
	--			IF EXISTS(Select * FROM booksubjectcategory where bookkey = @bookkey and categorytableid=@tableid and sortorder = @sortorder)
	--				BEGIN
	--					Select @RETURN = tabledesclong FROM gentablesdesc
	--					WHERE tableid = @tableid
	--
	--				END  
			END


		IF LEN(@SUBJECT1) > 0 AND LEN(@SUBJECT2)> 0 AND (@SUBJECT3 IS NULL OR @SUBJECT3 = '')
			BEGIN
				Select @tableid = g.tableid FROM gentables g
				JOIN subgentables sg
				ON g.tableid = sg.tableid and g.datacode = sg.datacode
				WHERE ((g.datadescshort IS NOT NULL AND g.datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and ((sg.datadescshort IS NOT NULL AND sg.datadescshort= @SUBJECT2) OR sg.datadesc = @SUBJECT2)
				and g.tableid in (412, 433,  432)


			END


		IF LEN(@SUBJECT1) > 0  AND LEN(@SUBJECT2) > 0 AND LEN(@SUBJECT3) > 0
			BEGIN
				Select @tableid = g.tableid 
				FROM gentables g
				JOIN subgentables sg
				ON g.tableid = sg.tableid and g.datacode = sg.datacode
				JOIN sub2gentables s2g
				ON sg.tableid = s2g.tableid and sg.datasubcode = s2g.datasubcode 
				WHERE ((g.datadescshort IS NOT NULL AND g.datadescshort= @SUBJECT1) OR g.datadesc = @SUBJECT1)
				and ((sg.datadescshort IS NOT NULL AND sg.datadescshort= @SUBJECT2) OR sg.datadesc = @SUBJECT2)
				and ((s2g.datadescshort IS NOT NULL AND s2g.datadescshort= @SUBJECT3) OR s2g.datadesc = @SUBJECT3)
				and g.tableid in (412, 433, 432)
			END

	END

		IF @tableid IS NOT NULL
					BEGIN
						Select @RETURN = tabledesclong FROM gentablesdesc
						WHERE tableid = @tableid
					END  
END 

IF @columnkey = 261 --Editorial BookComments, if more fields are added for marketing, title, project track them here
	BEGIN
		SELECT @RETURN = @fielddesc
	END

IF @columnkey = 225 OR @columnkey = 226 OR @columnkey = 227 OR @columnkey = 247 OR @columnkey = 248 --Misc Items
	BEGIN
		SELECT @RETURN = @fielddesc
	END

--IF @columnkey = 70 AND @fielddesc like 'Citation%'
--	BEGIN
--		SELECT @RETURN = 'Citation'
--	END

IF (@columnkey = 67 OR @columnkey = 68 OR @columnkey = 69 OR @columnkey = 201) AND @fielddesc like 'Citation%'
	BEGIN
		SELECT @RETURN = 'Citation'
	END

IF @columnkey = 6 OR @columnkey = 40 OR @columnkey = 60
	BEGIN
		Select @Return = 'Author'
	END

IF @columnkey = 65 --Personnel
	BEGIN
		Select @Return = 'Personnel'
	END

--IF @columnkey = 70 AND @fielddesc = '(E) New Features'
--	BEGIN
--		SELECT @RETURN = '(E) New Features'
--	END

RETURN @RETURN

END
