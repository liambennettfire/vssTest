if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getSubTitles') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.WK_getSubTitles
GO

CREATE FUNCTION dbo.WK_getSubTitles (@bookkey int, @type smallint) 

RETURNS varchar(255)
/*
@type should be set to 1 for subtitle1, 2 for subtitle2 
This is a WK specific funtion.

@seperator is the char used to seperate subtitles if both exists

Select bookkey, subtitle, dbo.WK_getSubTitles(bookkey, 1), dbo.WK_getSubTitles(bookkey, 2)
FROM book

*/
as

BEGIN
DECLARE @RETURN varchar(255)
DECLARE @seperator char(4)
SET @RETURN = NULL
DECLARE @subtitle varchar(255)
SET @subtitle = NULL

Select @subtitle = subtitle from book where bookkey = @bookkey

--This is what Paul used for conversion. Update the select cases below after deciding on the final @seperator
--I suggest that we use '|~|' or something unique
SET @seperator = ' -- '

If @type = 1
	BEGIN
		Select @Return = (CASE WHEN CHARINDEX(@seperator, @subtitle, 0) > 0 THEN LTRIM(RTRIM(SUBSTRING(@subtitle, 1, CHARINDEX(@seperator, @subtitle, 0) -1)))
	   ELSE @subtitle END)

	END
IF @type = 2
	BEGIN
		Select @Return = (CASE WHEN ltrim(rtrim(@subtitle)) = '--' OR @subtitle = '  --  ' OR LEN(ltrim(rtrim(@subtitle))) = 2 THEN NULL
		WHEN CHARINDEX(@seperator, @subtitle, 0) > 0 THEN LTRIM(RTRIM(SUBSTRING(@subtitle, CHARINDEX(@seperator, @subtitle, 0) + 3, (LEN(@subtitle) - CHARINDEX(@seperator, @subtitle, 0)-2))))
	   ELSE NULL END)

	END

RETURN @RETURN

END