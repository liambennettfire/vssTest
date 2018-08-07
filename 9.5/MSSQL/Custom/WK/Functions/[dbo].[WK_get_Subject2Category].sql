if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[WK_get_Subject2Category]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[WK_get_Subject2Category]
GO
CREATE FUNCTION [dbo].[WK_get_Subject2Category] (
		@bookkey	INT,
		@currentstringvalue		VARCHAR(255),
		@fielddesc  VARCHAR(80))
	
/*	
This function takes the bookkey, currentstringvalue, fielddesc fields from
titlehistory columns and returns which name of the sub subject category this entry belongs to. 
Created for WK. 
where columnkey = 221 subjects
*/
	RETURNS VARCHAR(255)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @SUBJECT		VARCHAR(255)
	DECLARE @SUBJECT1		VARCHAR(255)
	DECLARE @SUBSUBJECT		VARCHAR(255)
	DECLARE @sortorder int
	DECLARE @tableid int


	SET @SUBJECT = NULL
	SET @SUBJECT1 = NULL
	SET @SUBSUBJECT = NULL
	SET @sortorder = 0
	SET @tableid = NULL
	SET @RETURN = NULL

	IF CHARINDEX(' - ', @fielddesc) > 0
		BEGIN
			Select @SUBJECT = LTRIM(RTRIM(SUBSTRING(@fielddesc, 1, CHARINDEX(' - ', @fielddesc)-1)))
			SELECT @SUBJECT1 = LTRIM(RTRIM(SUBSTRING(@fielddesc, CHARINDEX(' - ', @fielddesc)+3, LEN(@fielddesc) - CHARINDEX(' - ', @fielddesc)+3)))
		END
	ELSE --No Subsubject
		BEGIN
			RETURN @RETURN
		END	
	SELECT @SUBSUBJECT = @currentstringvalue

	IF CHARINDEX(' ', @SUBJECT) > 0
		BEGIN
			SELECT @Sortorder = LTRIM(RTRIM(SUBSTRING(@SUBJECT, CHARINDEX(' ', @SUBJECT)+1, LEN(@SUBJECT) - CHARINDEX(' ', @SUBJECT)+1)))
		END 

	IF @SUBJECT1 IS NOT NULL AND @SUBSUBJECT IS NOT NULL 
		BEGIN
			Select @tableid = g.tableid FROM gentables g
			JOIN subgentables sg
			ON g.tableid = sg.tableid and g.datacode = sg.datacode
			WHERE g.datadesc = @SUBJECT1
			and sg.datadesc = @SUBSUBJECT
			
			--Confirm this record exists
			IF EXISTS(Select * FROM booksubjectcategory where bookkey = @bookkey and categorytableid=@tableid and sortorder = @sortorder)
				BEGIN
					Select @RETURN = tabledesclong FROM gentablesdesc
					WHERE tableid = @tableid

				END  
		END
	ELSE
		BEGIN --try to find with the subsubject
			IF @SUBSUBJECT IS NOT NULL 
				BEGIN
					Select @tableid = g.tableid FROM subgentables g
					WHERE g.datadesc = @SUBSUBJECT
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