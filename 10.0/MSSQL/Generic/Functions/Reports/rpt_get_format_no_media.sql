
/****** Object:  UserDefinedFunction [dbo].[rpt_get_format_no_media]    Script Date: 03/24/2009 13:07:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_format_no_media') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_format_no_media
GO
CREATE FUNCTION [dbo].[rpt_get_format_no_media]
		(@i_bookkey	INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_format_2 is usedby the ELO preflight Report. It is function is to return a specific description column from gentables for a Format.
It differs from the rpt_get_format function in that the select statement does not screen out titles for which the mediatypecode or mediatypesubcode = 0

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
		Q = eloquencefieldtag
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
	WHERE	bookkey = @i_bookkey 


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

	ELSE IF @v_column = 'Q' --eloquencefieldtag
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

go
Grant All on dbo.rpt_get_format_no_media to Public
go
