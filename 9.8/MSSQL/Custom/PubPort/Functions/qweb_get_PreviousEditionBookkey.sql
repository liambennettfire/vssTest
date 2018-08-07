SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_PreviousEditionBookkey]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_PreviousEditionBookkey]
GO



CREATE FUNCTION dbo.qweb_get_PreviousEditionBookkey(
		@i_bookkey	INT)
		

/*	Find the most recent previous edition of the same title and author
*/
	RETURNS INT
	
AS
BEGIN
	DECLARE @RETURN			INT
	DECLARE @v_curr_title		VARCHAR(255)
	DECLARE @i_curr_authorkey	INT
	DECLARE @i_prev_authorkey	INT
	DECLARE @i_prev_bookkey_count	INT

	SELECT @v_curr_title = dbo.qweb_get_Title(@i_bookkey,'T')
	SELECT @i_curr_authorkey = authorkey
		FROM bookauthor
		WHERE bookkey=@i_bookkey
		AND   sortorder = 1

/* try to find an exact match on Title and author key */

	SELECT @i_prev_bookkey_count = 0
	SELECT @i_prev_bookkey_count = count(*)
		FROM book
		WHERE SUBSTRING(Title,1,25) = SUBSTRING(@v_curr_title,1,25)
		AND  bookkey <> @i_bookkey
		AND dbo.qweb_get_BestPubDate(bookkey,1) < dbo.qweb_get_BestPubDate(@i_bookkey,1)
		AND dbo.qweb_get_Authorkey(bookkey,1) = dbo.qweb_get_Authorkey(@i_bookkey,1)

	IF @i_prev_bookkey_count = 0
		BEGIN
			SELECT @RETURN = 0
		END
	ELSE 
		BEGIN
			SELECT  DISTINCT TOP 1 @RETURN = bookkey
				FROM book
				WHERE SUBSTRING(Title,1,25) = SUBSTRING(@v_curr_title,1,25)
				AND  bookkey <> @i_bookkey
				AND dbo.qweb_get_BestPubDate(bookkey,1) < dbo.qweb_get_BestPubDate(@i_bookkey,1)
				AND dbo.qweb_get_Authorkey(bookkey,1) = dbo.qweb_get_Authorkey(@i_bookkey,1)
				ORDER BY dbo.qweb_get_BestPubDate(bookkey,1)
		
		END
  RETURN @RETURN
END













GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

