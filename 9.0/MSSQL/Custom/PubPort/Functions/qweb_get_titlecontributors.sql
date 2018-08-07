if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_titlecontributors]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_titlecontributors]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO




CREATE FUNCTION qweb_get_titlecontributors(@bookkey	INT)
RETURNS @titlecontributors TABLE(
			bookkey			INT,
			isbn			VARCHAR(20),
			authorkey		INT,
			lastname		VARCHAR(75),
			firstname		VARCHAR(75),
			displayname		VARCHAR(150),
			primaryind		CHAR(1),
			roletypecode		VARCHAR(40),
			roletype		VARCHAR(40),
			sortorder		INT)
AS
BEGIN
	DECLARE @isbn			VARCHAR(20),
	 	@authorkey		INT,
		@primaryind		INT,
		@roletypecode		INT,
	 	@sortorder		INT,
	 	@lastname		VARCHAR(75),
	 	@firstname		VARCHAR(75),
	 	@displayname		VARCHAR(150),
	 	@roletype		VARCHAR(40),
	 	@role			VARCHAR(40),
	 	@count			INT,
		 @row_count		INT,
		@primary		CHAR(1)


	SELECT @isbn = dbo.qweb_get_ISBN(@bookkey,10)
	SET @count = 0

	SELECT @count = COUNT(*)
	FROM bookauthor
	WHERE bookkey = @bookkey

	IF @count > 0
		BEGIN

			DECLARE c_author CURSOR FOR
				SELECT authorkey
				FROM bookauthor 
				WHERE bookkey = @bookkey
				ORDER BY sortorder
			FOR READ ONLY

			OPEN c_author

			FETCH FROM c_author 
			INTO  @authorkey

			SET @row_count = 1

			WHILE @row_count <= @count
				BEGIN
					SET @role = ''
					SET @roletype = ''
					SET @primaryind = 0
					SET @roletypecode = 0
					SET @sortorder = 0
					SET @lastname = ''
					SET @firstname = ''
					SET @displayname = ''

					SELECT	@primaryind = primaryind,
						@roletypecode = authortypecode,
						@sortorder = sortorder
					FROM bookauthor
					WHERE bookkey = @bookkey
							AND authorkey = @authorkey

					SELECT @primary = CASE
								WHEN @primaryind = 1	THEN 'Y'
								ELSE 'N'
							  END

					SELECT @lastname = lastname,
						@firstname = firstname,
						@displayname = displayname
					FROM author
					WHERE authorkey = @authorkey

					SELECT @role = datadesc,
						@roletype = bisacdatacode
					FROM gentables
					WHERE tableid = 134
						AND datacode = @roletypecode


					INSERT INTO @titlecontributors(bookkey,authorkey,isbn,lastname,firstname,displayname,roletype,roletypecode,primaryind,sortorder)
					VALUES (@bookkey,@authorkey,@isbn,@lastname,@firstname,@displayname,@role,@roletype,@primary,@sortorder)
							
					SET @row_count = @row_count+1
					FETCH NEXT FROM c_author 
					INTO  @authorkey

				END
							
		CLOSE c_author
		DEALLOCATE c_author
	END
RETURN

END
		







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

