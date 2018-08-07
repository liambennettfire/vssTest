DROP FUNCTION qweb_get_titlecomments
go
CREATE FUNCTION qweb_get_titlecomments(@bookkey	INT)
RETURNS @titlecomments  TABLE(
		bookkey		INT,
		isbn		VARCHAR(20),
		commenttype	VARCHAR(40),
		commentsubtype	VARCHAR(40),
		commenttext	TEXT,
		commenthtml	TEXT,
		commenthtmllite	TEXT,
		releasetoeloind	CHAR(1),
		sortorder	INT)
AS
BEGIN

DECLARE @commenttypecode	INT,
	@commenttype		VARCHAR(40),
	@commenttypesubcode	INT,
	@commentsubtype		VARCHAR(40),
	@releasetoeloind	INT,
	@releaseind		CHAR(1),
	@isbn			VARCHAR(20),
	@sortorder		INT,
	@count			INT,
	@comment_count		INT


	SELECT @count = COUNT(*)
	FROM bookcomments
	WHERE bookkey = @bookkey

	IF @count > 0
		BEGIN
			SELECT @isbn = dbo.qweb_get_ISBN(@bookkey,10)

			DECLARE c_comment cursor for
				SELECT commenttypecode,commenttypesubcode,releasetoeloquenceind
				FROM bookcomments
				WHERE bookkey = @bookkey
			for read only

			open c_comment

			fetch from c_comment
			into @commenttypecode,@commenttypesubcode,@releasetoeloind

			SET @comment_count = 1

			WHILE @comment_count <= @count
				BEGIN

					SELECT @commenttype = datadesc
					FROM gentables
					WHERE tableid = 284 AND datacode = @commenttypecode


					SELECT @commentsubtype = datadesc
					FROM subgentables
					WHERE tableid = 284 
							AND datacode = @commenttypecode
							AND datasubcode = @commenttypesubcode

					SELECT @releaseind = CASE
								WHEN @releasetoeloind = 1 THEN 'Y'
								ELSE
									'N'
								END

					SELECT @sortorder = COALESCE(MAX(sortorder),0)+1
					FROM @titlecomments

					INSERT INTO @titlecomments(bookkey,isbn,commenttype,commentsubtype,commenttext,commenthtml,commenthtmllite,releasetoeloind,sortorder)
					VALUES(@bookkey,@isbn,@commenttype,@commentsubtype,'','','',@releaseind,@sortorder)

					UPDATE @titlecomments
					SET /*commenttext = bc.commenttext,
						commenthtml = bc.commenthtml,*/
						commenthtmllite = bc.commenthtmllite
					FROM @titlecomments t, bookcomments bc
					WHERE t.bookkey = bc.bookkey
							AND bc.commenttypecode = @commenttypecode
							AND bc.commenttypesubcode = @commenttypesubcode
							AND t.sortorder = @sortorder

					SET @comment_count = @comment_count+1

					fetch next from c_comment
					into @commenttypecode,@commenttypesubcode,@releasetoeloind
				END
			CLOSE c_comment
			DEALLOCATE c_comment
		END
	RETURN

END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
