if exists (select * from dbo.sysobjects where id = object_id(N'qtitle_get_edition_number') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function qtitle_get_edition_number
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[qtitle_get_edition_number]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	

The purpose of the qtitle_get_edition function is to return a specific description column from gentables for a Edition Number

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_editionnumber		INT
	
	SELECT @i_editionnumber = editionnumber
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 557
					AND datacode = @i_editionnumber
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(externalcode))
			FROM	gentables  
			WHERE  tableid = 557
					AND datacode = @i_editionnumber
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			FROM	gentables  
			WHERE  tableid = 557
					AND datacode = @i_editionnumber
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			FROM	gentables  
			WHERE  tableid = 557
					AND datacode = @i_editionnumber
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			FROM	gentables  
			WHERE  tableid = 557
					AND datacode = @i_editionnumber
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 557
					AND datacode = @i_editionnumber
		END


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END
    RETURN @RETURN
END
go

Grant All on dbo.qtitle_get_edition_number to Public
go

