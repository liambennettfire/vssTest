
/****** Object:  UserDefinedFunction [dbo].[rpt_get_previous_edition_book_key]    Script Date: 03/24/2009 13:12:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_previous_edition_book_key') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_previous_edition_book_key
GO
CREATE FUNCTION [dbo].[rpt_get_previous_edition_book_key](
		@i_bookkey	INT)
		

/*	Find the most recent previous edition of the same title and author based on an exact match on Title and author key 
and most recent pub date
*/
	RETURNS INT
	
AS
BEGIN
	DECLARE @RETURN			INT
	DECLARE @v_curr_title		VARCHAR(255)
	DECLARE @i_curr_authorkey	INT
	DECLARE @i_prev_authorkey	INT
	DECLARE @i_prev_bookkey_count	INT

	SELECT @v_curr_title = dbo.rpt_get_title(@i_bookkey,'T')
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
		AND dbo.rpt_get_best_pub_date(bookkey,1) < dbo.rpt_get_best_pub_date(@i_bookkey,1)
		AND dbo.rpt_get_author_key(bookkey,1) = dbo.rpt_get_author_key(@i_bookkey,1)

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
				AND dbo.rpt_get_best_pub_date(bookkey,1) < dbo.rpt_get_best_pub_date(@i_bookkey,1)
				AND dbo.rpt_get_author_key(bookkey,1) = dbo.rpt_get_author_key(@i_bookkey,1)
				--ORDER BY dbo.rpt_get_best_pub_date(bookkey,1)
		
		END
  RETURN @RETURN
END

go
Grant All on dbo.rpt_get_previous_edition_book_key to Public
go
