if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getBindingMediaType') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.WK_getBindingMediaType
GO

CREATE FUNCTION dbo.WK_getBindingMediaType (@bookkey int, @type char(1), @seperator char(1)) 

RETURNS varchar(30)
/*
@type should be B for Binding and M for media
This is a WK specific funtion.
Pace Binding and Media Types are in the externalcode of Formats

@seperator is the char used to seperate binding & mediatype codes in the externalcode of format

Select dbo.WK_getBindingMediaType(bookkey, 'B', ',') as bindingType,
dbo.WK_getBindingMediaType(bookkey, 'M', ',') as MediaType
FROM book
WHERE dbo.WK_getBindingMediaType(bookkey, 'B', ',') IS NOT NULL
*/
as

BEGIN
DECLARE @RETURN varchar(30)
DECLARE  @Format_Externalcode varchar(30)
--DECLARE @BINDING_TYPE varchar(30)
--DECLARE @MEDIA_TYPE varchar(30)

SET @RETURN = NULL

--SET @BINDING_TYPE = NULL
--SET @MEDIA_TYPE = NULL


SET  @Format_Externalcode = NULL 

Select  @Format_Externalcode = [dbo].[rpt_get_subgentables_field](312,mediatypecode, mediatypesubcode, 'E') 
FROM bookdetail where bookkey = @bookkey
IF  @Format_Externalcode IS NOT NULL AND LEN( @Format_Externalcode) > 0 AND CHARINDEX(@seperator,  @Format_Externalcode) > 0
	BEGIN
		SET  @Format_Externalcode = LTRIM(RTRIM( @Format_Externalcode))
		IF @type = 'B'
			BEGIN
				SET @RETURN = SUBSTRING( @Format_Externalcode, 1, CHARINDEX(@seperator, @Format_Externalcode) -1)
				SET @RETURN = LTRIM(RTRIM(@RETURN))
				IF @RETURN = 'NULL'
					SET @RETURN = NULL
			END
		IF @type = 'M'
			BEGIN
				SET @RETURN = SUBSTRING( @Format_Externalcode, CHARINDEX(@seperator, @Format_Externalcode) + 1, LEN( @Format_Externalcode) - (CHARINDEX(@seperator, @Format_Externalcode)))
				SET @RETURN = LTRIM(RTRIM(@RETURN))		
				IF @RETURN = 'NULL'
					SET @RETURN = NULL
			END
	END

RETURN @RETURN

END