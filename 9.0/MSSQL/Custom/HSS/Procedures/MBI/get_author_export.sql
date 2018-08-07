SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_author_export]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[get_author_export]
GO





CREATE PROCEDURE get_author_export(@bookkey	INT,
				@o_errorcode	INT OUT,
				@o_errormsg	VARCHAR(1000) OUT)
AS

DECLARE @isbn			VARCHAR(20)
DECLARE @authorkey		INT
DECLARE	@primaryind		INT
DECLARE	@roletypecode		INT
DECLARE @sortorder		INT
DECLARE @lastname		VARCHAR(75)
DECLARE @firstname		VARCHAR(75)
DECLARE @roletype		VARCHAR(40)
DECLARE @role			VARCHAR(40)
DECLARE @cstatus		INT


SELECT @isbn = isbn10
FROM isbn
WHERE bookkey = @bookkey


DECLARE c_author INSENSITIVE CURSOR FOR
	SELECT ba.authorkey
	FROM bookauthor ba, author a
	WHERE ba.bookkey = @bookkey
			AND ba.authorkey = a.authorkey
	ORDER BY ba.sortorder
FOR READ ONLY

OPEN c_author

FETCH NEXT FROM c_author 
INTO  @authorkey

SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <> -1
	BEGIN
		IF @cstatus <>-2
			BEGIN
				SET @role = ''
				SET @roletype = ''
				SET @primaryind = 0
				SET @roletypecode = 0
				SET @sortorder = 0
				SET @lastname = ''
				SET @firstname = ''
				
				SELECT @primaryind = primaryind,
					@roletypecode = authortypecode,
					@sortorder = sortorder
				FROM bookauthor
				WHERE bookkey = @bookkey
						AND authorkey = @authorkey

				SELECT @lastname = lastname,
					@firstname = firstname
				FROM author
				WHERE authorkey = @authorkey

				SELECT @role = datadesc,
					@roletype = bisacdatacode
				FROM gentables
				WHERE tableid = 134
						AND datacode = @roletypecode


				
				INSERT INTO export_author(bookkey,isbn10,lastname,firstname,roletype,roletypecode,primaryind,sortorder)
				VALUES (@bookkey,@isbn,@lastname,@firstname,@role,@roletype,@primaryind,@sortorder)
							
			END						

		FETCH NEXT FROM c_author 
		INTO  @authorkey

			
		SELECT @cstatus = @@FETCH_STATUS

	END
							
CLOSE c_author
DEALLOCATE c_author
					


SET QUOTED_IDENTIFIER OFF 





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

