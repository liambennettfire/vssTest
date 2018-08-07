IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_author_Forword_By') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION dbo.rpt_get_author_Forword_By
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_author_Forword_By]    Script Date: 2/23/2016 4:26:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_author_Forword_By] (@i_bookkey	INT, @i_type		INT, 	@v_name		VARCHAR(1))
	RETURNS	VARCHAR(120)


/*  The purpose of the rpt_get_author functions is to return a specific author name from the author table based upon the bookkey.

	PARAMETER OPTIONS

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
			R = Reverse Name: Last, First Middle
			X = Last, First only without Middle Name
			
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
	DECLARE @i_individualind	INT


/*  GET AUTHOR KEY FOR AUTHOR TYPE and ORDER 	*/
	IF @i_type = 0
		BEGIN

			SELECT 	@i_authorkey = authorkey
			FROM bookauthor
			WHERE	bookkey = @i_bookkey

		END

	IF @i_type > 0 
		BEGIN
			SELECT 	@i_authorkey = authorkey				
			FROM bookauthor
			WHERE	bookkey = @i_bookkey
					AND authortypecode = @i_type
		END

/* GET AUTHOR NAME		*/

	SELECT @i_individualind = individualind
	FROM globalcontact
	WHERE globalcontactkey = @i_authorkey


	IF @i_individualind = 0	
		BEGIN
			SELECT @v_desc = lastname
			FROM	globalcontact
			WHERE globalcontactkey = @i_authorkey
		END

	ELSE
		BEGIN

			IF @v_name = 'D' 
				BEGIN
					SELECT @v_desc = displayname
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
				END

			ELSE IF @v_name = 'L' 
				BEGIN
					SELECT @v_desc = lastname
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
				END

			ELSE IF @v_name = 'F' 
				BEGIN
					SELECT @v_desc = firstname
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
				END

			ELSE IF @v_name = 'M' 
				BEGIN
					SELECT @v_desc = middlename
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
				END

			ELSE IF @v_name = 'S' 
				BEGIN
					SELECT @v_desc = suffix
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
				END

			ELSE IF @v_name = 'C' 
				BEGIN
					SELECT @v_nameabbrev = g.datadesc
					FROM	gentables g, globalcontact a
					WHERE	g.tableid = 210
						AND a.globalcontactkey = @i_authorkey
						AND a.accreditationcode = g.datacode

	
					SELECT @v_firstname = firstname,
						@v_middlename = middlename,
						@v_lastname = lastname,
						@v_suffix = suffix
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
		 
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
			ELSE IF @v_name = 'R' 
				BEGIN
					SELECT @v_firstname = firstname,
						@v_middlename = middlename,
						@v_lastname = lastname
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
		 
					SELECT @v_desc =  
						
						CASE 
							WHEN @v_lastname IS NULL THEN  ''
							WHEN @v_lastname IS NOT NULL THEN @v_lastname
            			ELSE ''
          			END

						+CASE 
							WHEN @v_firstname IS  NULL THEN ''
	            		ELSE ', ' + @v_firstname
	          		END
          			+CASE 
							WHEN @v_middlename IS NULL and @v_firstname is NOT NULL THEN ''
							WHEN @v_middlename IS NULL and @v_firstname is NULL THEN ''
							WHEN @v_middlename is NOT NULL and @v_firstname is NOT NULL THEN ' '+@v_middlename+ ' '
        	    			ELSE ''
        	  			END
				END
			ELSE IF @v_name = 'X' 
				BEGIN
					SELECT @v_firstname = firstname,
						   @v_lastname = lastname
					FROM globalcontact
					WHERE globalcontactkey = @i_authorkey
		 
					SELECT @v_desc =  
						
						CASE 
							WHEN @v_lastname IS NULL THEN  ''
							WHEN @v_lastname IS NOT NULL THEN @v_lastname
            			ELSE ''
          			END

						+CASE 
							WHEN @v_firstname IS  NULL THEN ''
	            		ELSE ', ' + @v_firstname
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

Grant all on dbo.rpt_get_author_Forword_By to public
go
