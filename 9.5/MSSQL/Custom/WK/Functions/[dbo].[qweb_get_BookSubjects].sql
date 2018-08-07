if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[qweb_get_BookSubjects]') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.[qweb_get_BookSubjects]
GO
CREATE FUNCTION [dbo].[qweb_get_BookSubjects](
		@i_bookkey	INT,
		@i_subjectnum	INT,
		@i_order	INT,
		@v_column	VARCHAR(1),
		@i_subj_order int
)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_Subject function is to return a specific description column from gentables for any of the 
	configurable subject categories

	Parameter Options
		@i_subjectnum
			1-10	Returns the respective subject category

		@i_order	-> Each book may have multipe subjects - enter the sort order number to pull
			1...n
					-> Added by TOLGA TUNCER on 03/01/2010 
			If sortorder of 0 is passed, the function returns min sortorder entry

		@v_column  (column from gentables)
			D = Data Description
			E = External code
			S = Short Description
			B = BISAC Data Code
			T = Eloquence Field Tag
			1 = Alternative Description 1
			2 = Alternative Deccription 2

		@i_subj_order
			1- gentables
			2-subgentables
			3-sub2gentables
*/	

AS

BEGIN


	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_tableid		INT
	DECLARE @i_categorycode		INT
	DECLARE @i_categorysubcode	INT
	DECLARE @i_categorysub2code	INT

	SELECT @i_tableid =   CASE @i_subjectnum    
			WHEN 1 	THEN  	412
			WHEN 2	THEN	413
			WHEN 3 	THEN  	414
			WHEN 4	THEN	431
			WHEN 5 	THEN  	432
			WHEN 6	THEN	433
			WHEN 7 	THEN  	434
			WHEN 8	THEN	435
			WHEN 9 	THEN  	436
			WHEN 10	THEN	437
		END

	IF @i_order > 0 
		BEGIN
			SELECT @i_categorycode = categorycode,
				@i_categorysubcode = categorysubcode,
				@i_categorysub2code = categorysub2code
			FROM	booksubjectcategory
			WHERE	bookkey = @i_bookkey
					And categorytableid = @i_tableid
					AND sortorder = @i_order
		END
	ELSE
		BEGIN
			SELECT TOP 1 @i_categorycode = categorycode,
				@i_categorysubcode = categorysubcode,
				@i_categorysub2code = categorysub2code
			FROM	booksubjectcategory
			WHERE	bookkey = @i_bookkey
					And categorytableid = @i_tableid
			ORDER BY sortorder

		END


	IF @i_categorycode IS NOT NULL AND @i_subj_order = 1
--			AND (@i_categorysubcode = 0 OR @i_categorysubcode IS NULL)
--			AND (@i_categorysub2code = 0 OR @i_categorysub2code IS NULL)
		BEGIN
			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	gentables  
					WHERE  tableid = @i_tableid
						AND datacode = @i_categorycode
				END
		END

	IF @i_categorycode IS NOT NULL 
			AND (@i_categorysubcode > 0 OR @i_categorysubcode IS NOT NULL) and @i_subj_order = 2
--			AND (@i_categorysub2code = 0 OR @i_categorysub2code IS NULL)

		BEGIN
			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))

					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	subgentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
				END
		END

	IF @i_categorycode IS NOT NULL 
			AND (@i_categorysubcode > 0 OR @i_categorysubcode IS NOT NULL)
			AND (@i_categorysub2code > 0 OR @i_categorysub2code IS NOT NULL) AND @i_subj_order = 3

		BEGIN
			IF @v_column = 'D'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = 'E'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(externalcode))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = 'S'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadescshort))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = 'B'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = '1'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END

			ELSE IF @v_column = '2'
				BEGIN
					SELECT @v_desc = LTRIM(RTRIM(datadesc))
					FROM	sub2gentables  
					WHERE	tableid = @i_tableid
							AND datacode = @i_categorycode
							AND datasubcode = @i_categorysubcode
							AND datasub2code = @i_categorysub2code
				END
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





