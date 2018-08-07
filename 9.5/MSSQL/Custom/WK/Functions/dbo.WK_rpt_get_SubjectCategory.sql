if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_rpt_get_SubjectCategory]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[WK_rpt_get_SubjectCategory]
GO
CREATE FUNCTION [dbo].[WK_rpt_get_SubjectCategory] (
		@bookkey	INT,
		@currentstringvalue		VARCHAR(255),
		@fielddesc  VARCHAR(80))
	
/*	
This function takes the bookkey, currentstringvalue, fielddesc fields from
titlehistory columns and returns which name of the subject category this entry belongs to. 
Created for WK. 
where columnkey = 220 subjects
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @SUBJECT1		VARCHAR(255)
	DECLARE @SUBJECT2		VARCHAR(255)
	DECLARE @SUBJECT3		VARCHAR(255)
	DECLARE @SUB_AND_SUB2   VARCHAR(255)
	DECLARE @sortorder int
	DECLARE @tableid int


	SET @SUBJECT1 = NULL
	SET @SUBJECT2 = NULL
	SET @SUBJECT3 = NULL
	SET @SUB_AND_SUB2 = NULL
	SET @sortorder = 0
	SET @tableid = NULL
	SET @RETURN = NULL

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
			and g.tableid in (412, 414, 431, 432)
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
			and g.tableid in (412, 414, 431, 432)


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
			and g.tableid in (412, 414, 431, 432)
		END


		IF @tableid IS NOT NULL
			BEGIN
				Select @RETURN = tabledesclong FROM gentablesdesc
				WHERE tableid = @tableid
			END  


RETURN @RETURN
END