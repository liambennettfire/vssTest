SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_Author]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_Author]
GO





CREATE FUNCTION dbo.qweb_get_Author 
			(@i_bookkey	INT,
			@i_order	INT,
			@i_type		INT,
			@v_name		VARCHAR(1))

RETURNS	VARCHAR(120)

/*  The purpose of the qweb_get_Author functions is to return a specific author name from the author table based upon the bookkey.

	PARAMETER OPTIONS

		@i_Order
			1 = Returns first Author
			2 = Returns second Author
			3 = Returns third Author
			4
			5
			.
			.
			.
			n
		

		@i_type = roltype codes to include
			0 = Include all Contributor Role types
			12 = Include just Author Role types (pulls from gentables.tableid=134 for roletypecode


		@v_name = author name field (if corporate indicator = 1, then any options will always pull the lastname)
			D = Display Name
			C = Complete Name (nameabbrev + firstname + mi + lastname + suffix)
			F = First Name
			M = Middle Name
			L = Last Name
			S = Suffix
			
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(120)
	DECLARE @v_desc			VARCHAR(80)
	DECLARE @i_count		INT		
	DECLARE @i_authorkey		INT
	DECLARE @v_firstname		VARCHAR(40)
	DECLARE @v_middlename		VARCHAR(20)
	DECLARE @v_lastname		VARCHAR(40)
	DECLARE @v_nameabbrev		VARCHAR(10)
	DECLARE @v_suffix		VARCHAR(10)
	DECLARE @i_corporatename	INT


/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	IF @i_type = 0
		BEGIN

			SELECT 	@i_authorkey = authorkey
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order

		END

	IF @i_type > 0 
		BEGIN
			SELECT 	@i_authorkey = authorkey				
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND sortorder = @i_order
					AND authortypecode = @i_type
		END

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

			IF @v_name = 'D' 
				BEGIN
					SELECT @v_desc = displayname
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'L' 
				BEGIN
					SELECT @v_desc = lastname
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'F' 
				BEGIN
					SELECT @v_desc = firstname
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'M' 
				BEGIN
					SELECT @v_desc = middlename
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'S' 
				BEGIN
					SELECT @v_desc = authorsuffix
					FROM author
					WHERE authorkey = @i_authorkey
				END

			ELSE IF @v_name = 'C' 
				BEGIN
					SELECT @v_nameabbrev = g.datadesc
					FROM	gentables g, author a
					WHERE	g.tableid = 210
						AND a.authorkey = @i_authorkey
						AND a.nameabbrcode = g.datacode

	
					SELECT @v_firstname = firstname,
						@v_middlename = middlename,
						@v_lastname = lastname,
						@v_suffix = authorsuffix
					FROM author
					WHERE authorkey = @i_authorkey
		 
					SELECT @v_desc =  
						CASE 
							WHEN @v_nameabbrev IS NULL THEN  ''
							WHEN @v_nameabbrev IS NOT NULL THEN @v_nameabbrev + ' '
            						ELSE ''
          					END

						+CASE 
							WHEN @v_firstname IS  NULL THEN ''
	            					ELSE @v_firstname
	          				END

	          				+CASE 
							WHEN @v_middlename IS NULL and @v_firstname is NOT NULL THEN ' '
							WHEN @v_middlename IS NULL and @v_firstname is NULL THEN ''
							WHEN @v_middlename is NOT NULL and @v_firstname is NOT NULL THEN ' '+@v_middlename+ ' '
        	    					ELSE ''
        	  				END

	          				+ @v_lastname

	          				+ CASE 
							WHEN @v_suffix IS NOT NULL THEN ' ' + @v_suffix
					        	ELSE ''
          					END
			
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

