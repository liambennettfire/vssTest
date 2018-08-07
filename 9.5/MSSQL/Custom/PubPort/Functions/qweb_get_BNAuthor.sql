SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BNAuthor]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BNAuthor]
GO





CREATE FUNCTION dbo.qweb_get_BNAuthor 
			(@i_bookkey	INT)


RETURNS	VARCHAR(120)

/*  The purpose of the qweb_get_BNAuthor functions is to return a specific author name 
    formatted correctly for the BN buy sheet.  It gets the first author on the bookauthor that is primary
	and checks the author type.  if the author type is anything other than an author, then it 
	will append the author type in '()' to the author name, which will be formatted as Lastname, Firstname, MI

	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(120)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @v_authortypedesc	VARCHAR(40)
	DECLARE @i_count		INT		
	DECLARE @i_authorkey		INT
	DECLARE @i_authortypecode	INT
	DECLARE @v_firstname		VARCHAR(40)
	DECLARE @v_middlename		VARCHAR(20)
	DECLARE @v_lastname		VARCHAR(40)
	DECLARE @v_nameabbrev		VARCHAR(10)
	DECLARE @v_suffix		VARCHAR(10)
	DECLARE @i_corporatename	INT


/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	
	SELECT 	distinct @i_authorkey = authorkey, @i_authortypecode = authortypecode
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
			AND primaryind = 1

		


/* GET AUTHOR NAME		*/

	SELECT @i_corporatename = corporatecontributorind
	FROM author
	WHERE authorkey = @i_authorkey


	IF @i_corporatename = 1	
		BEGIN
			SELECT @v_desc = lastname
			FROM	author
			WHERE authorkey = @i_authorkey
		END

	ELSE
		BEGIN

			SELECT @v_firstname = firstname,
				@v_middlename = middlename,
				@v_desc = lastname,
				@v_suffix = authorsuffix
			FROM author
			WHERE authorkey = @i_authorkey
		 
			IF @v_firstname IS  NOT NULL 
				BEGIN
					SELECT @v_desc = @v_desc + ', ' + @v_firstname
	            		END

			IF @v_middlename IS  NOT NULL 
				BEGIN
					SELECT @v_desc = @v_desc + ' ' + @v_middlename
	            		END

			IF @i_authortypecode <> 12 -- If the author type is not an 'Author' then put it in parenthesis 
				BEGIN
					SELECT @v_authortypedesc = LTRIM(RTRIM(datadesc))
					FROM	gentables  
					WHERE  tableid = 134
					AND datacode = @i_authortypecode

					SELECT @v_desc = @v_desc + ' (' + @v_authortypedesc + ')'
	            		END



		END


		IF LEN(@v_desc) > 0
			BEGIN
				SELECT @RETURN = LTRIM(RTRIM(@v_desc))
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

