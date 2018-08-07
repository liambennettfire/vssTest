
/****** Object:  UserDefinedFunction [dbo].[rpt_get_bn_author]    Script Date: 03/24/2009 13:02:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_bn_author') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_bn_author
GO
CREATE FUNCTION [dbo].[rpt_get_bn_author] 
			(@i_bookkey	INT)


RETURNS	VARCHAR(120)

/*  The purpose of the rpt_get_bn_author functions is to return a specific author name 
    formatted correctly for the BN buy sheet.  First it looks for an author authortype and uses that first
    otherwise, it will take the first primary authortype it finds.  If the author type is anything other than an author, then it 
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


	Select @i_count = 0

	Select @i_count = count(*) 
	FROM bookauthor
	WHERE	bookkey = @i_bookkey
	AND primaryind = 1
	and authortypecode = 12

       If @i_count > 0 
	begin
	SELECT 	distinct @i_authorkey = authorkey, @i_authortypecode = authortypecode
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
			and authortypecode = 12
			AND primaryind = 1
	end

	else
	
	begin
	/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	
	SELECT 	distinct @i_authorkey = authorkey, @i_authortypecode = authortypecode
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
			AND primaryind = 1
	end


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

go
Grant All on dbo.rpt_get_bn_author to Public
go