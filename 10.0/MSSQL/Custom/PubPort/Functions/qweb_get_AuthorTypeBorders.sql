SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AuthorTypeBorders]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AuthorTypeBorders]
GO






CREATE FUNCTION dbo.qweb_get_AuthorTypeBorders 
			(@i_bookkey	INT,
			@i_order 	INT)


RETURNS	VARCHAR (1)

/*  The purpose of the qweb_get_AuthorTypeBorders function is to return a specIFic author type for a specIFic author 
    formatted correctly for the Borders e-cat spreadsheet.  


	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(1)
	DECLARE @v_desc			VARCHAR(1)
	DECLARE @i_authorkey		INT
	DECLARE @i_authortypecode	INT
	DECLARE @v_authortypedesc	VARCHAR(40)



/*  GET  AUTHOR KEY 	*/
	
	SELECT 	 @i_authorkey = dbo.qweb_get_AuthorPrimaryKey(@i_bookkey, @i_order)

	IF @i_authorkey = 0
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN
		/* GET AUTHOR TYPE		*/

			SELECT @i_authortypecode = authortypecode
			FROM bookauthor
			WHERE bookkey = @i_bookkey
			AND   authorkey = @i_authorkey

		/* GET AUTHOR TYPE DESCRIPTION FROM GENTABLES */

			SELECT @v_authortypedesc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 134
			AND datacode = @i_authortypecode

		/* TRANSLATE TO BORDERS SPECS */

			IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Editor')
			OR (RTRIM(LTRIM(@v_authortypedesc)) = 'Selected by')
			OR (RTRIM(LTRIM(@v_authortypedesc)) = 'Produced by')
			   BEGIN
				SELECT @v_desc = 'E'
			   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Narrated by')
				OR (RTRIM(LTRIM(@v_authortypedesc)) = 'Read by')
				   BEGIN
					SELECT @v_desc = 'R'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Illustrator')
				   BEGIN
					SELECT @v_desc = 'I'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Translator')
				   BEGIN
					SELECT @v_desc = 'T'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) = 'Photographer')
				   BEGIN
					SELECT @v_desc = 'P'
				   END
			ELSE IF (RTRIM(LTRIM(@v_authortypedesc)) is NULL)
				   BEGIN
					SELECT @v_desc = ''
				   END
			ELSE -- any other valid author type will be determined as an author
				   BEGIN
					SELECT @v_desc = 'A'
				   END



		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = UPPER(LTRIM(RTRIM(@v_desc)))
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

