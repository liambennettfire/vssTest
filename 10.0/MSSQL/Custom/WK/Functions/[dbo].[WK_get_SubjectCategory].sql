if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_get_SubjectCategory]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[WK_get_SubjectCategory]
GO
CREATE FUNCTION [dbo].[WK_get_SubjectCategory] (
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
	DECLARE @SUBJECT		VARCHAR(255)
	DECLARE @SUBSUBJECT		VARCHAR(255)
	DECLARE @sortorder int
	DECLARE @tableid int


	SET @SUBJECT = NULL
	SET @SUBSUBJECT = NULL
	SET @sortorder = 0
	SET @tableid = NULL
	SET @RETURN = NULL

	IF CHARINDEX(' - ', @currentstringvalue) > 0
		BEGIN
			Select @SUBJECT = LTRIM(RTRIM(SUBSTRING(@currentstringvalue, 1, CHARINDEX(' - ', @currentstringvalue)-1)))
			SELECT @SUBSUBJECT = LTRIM(RTRIM(SUBSTRING(@currentstringvalue, CHARINDEX(' - ', @currentstringvalue)+3, LEN(@currentstringvalue) - CHARINDEX(' - ', @currentstringvalue)+3)))
		END
	ELSE --No Subsubject
		BEGIN
			Select @SUBJECT = LTRIM(RTRIM(@currentstringvalue))
		END	


	IF CHARINDEX(' ', @fielddesc) > 0
		BEGIN
			SELECT @Sortorder = LTRIM(RTRIM(SUBSTRING(@fielddesc, CHARINDEX(' ', @fielddesc)+1, LEN(@fielddesc) - CHARINDEX(' ', @fielddesc)+1)))
		END 

	IF @SUBJECT IS NOT NULL AND @SUBSUBJECT IS NOT NULL 
		BEGIN
			Select @tableid = g.tableid FROM gentables g
			JOIN subgentables sg
			ON g.tableid = sg.tableid and g.datacode = sg.datacode
			WHERE g.datadesc = @SUBJECT
			and sg.datadesc = @SUBSUBJECT
			
			--Confirm this record exists
			IF EXISTS(Select * FROM booksubjectcategory where bookkey = @bookkey and categorytableid=@tableid and sortorder = @sortorder)
				BEGIN
					Select @RETURN = tabledesclong FROM gentablesdesc
					WHERE tableid = @tableid

				END  
		END
	ELSE
		BEGIN
			IF @SUBJECT IS NOT NULL AND @SUBSUBJECT IS NULL 
				BEGIN
					Select @tableid = g.tableid FROM gentables g
					WHERE g.datadesc = @SUBJECT
					AND EXISTS(Select * FROM booksubjectcategory bsc where bsc.bookkey = @bookkey and categorytableid=g.tableid and sortorder = @sortorder) 
					
					IF @tableid is NOT NULL
						BEGIN
							Select @RETURN = tabledesclong FROM gentablesdesc
							WHERE tableid = @tableid
						END  
				END
		END

RETURN @RETURN
END