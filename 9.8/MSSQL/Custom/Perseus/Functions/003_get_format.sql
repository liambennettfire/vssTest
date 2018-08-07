/****** Object:  UserDefinedFunction [dbo].[get_Format]    Script Date: 04/16/2009 15:28:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_Format]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[get_Format]

/****** Object:  UserDefinedFunction [dbo].[get_Format]    Script Date: 03/20/2009 15:09:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create FUNCTION [dbo].[get_Format]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the get_Format function is to return a specific description column from gentables for a Format

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

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	DECLARE @i_mediatypecode		INT
	DECLARE @i_mediatypesubcode		INT
	
	SELECT @i_mediatypecode = mediatypecode,
		@i_mediatypesubcode = mediatypesubcode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey and mediatypecode <> 0


	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	subgentables  
			WHERE  tableid = 312

					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
		
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @v_column = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc2))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @v_column = 'T'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(eloquencefieldtag))
			FROM	subgentables  
			WHERE  tableid = 312
					AND datacode = @i_mediatypecode
					AND datasubcode = @i_mediatypesubcode
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

RETURN @RETURN


END





