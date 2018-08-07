if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_rpt_get_SubSubject2Category]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[WK_rpt_get_SubSubject2Category]
GO
CREATE FUNCTION [dbo].[WK_rpt_get_SubSubject2Category] (
		@bookkey	INT,
		@currentstringvalue		VARCHAR(255),
		@fielddesc  VARCHAR(80))
	
/*	
This function takes the bookkey, currentstringvalue, fielddesc fields from
titlehistory columns and returns the name of the sub2 subject category this entry belongs to. 
Created for WK.
Currentstringvalue should be passed by removing all (DELETE) clauses. Only 
text values should stay in there. 
REPLACE(REPLACE(currentstringvalue,'(DELETED) - ', ''), '(DELETED)', '')
where columnkey = 222 subjects
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @SUBJECT		VARCHAR(255)
	DECLARE @SUBJECT1		VARCHAR(255)
	DECLARE @SUBJECT2		VARCHAR(255)
	DECLARE @SUBJECT3		VARCHAR(255)
	DECLARE @HOLDER1	VARCHAR(255)
	DECLARE @HOLDER2	VARCHAR(255)
	DECLARE @sortorder int
	DECLARE @tableid int


	SET @SUBJECT = NULL
	SET @SUBJECT1 = NULL
	SET @SUBJECT2 = NULL
	SET @SUBJECT3 = NULL
	SET @HOLDER1 =  NULL
	SET @HOLDER2 = NULL
	SET @sortorder = 0
	SET @tableid = NULL
	SET @RETURN = NULL

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


	IF LEN(@SUBJECT1) > 0 AND LEN(@SUBJECT2)> 0 AND (@SUBJECT3 IS NULL OR @SUBJECT3 = '')
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