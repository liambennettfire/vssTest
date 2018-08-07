
/****** Object:  UserDefinedFunction [dbo].[rpt_get_previous_edition_isbn]    Script Date: 03/24/2009 13:13:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_previous_edition_isbn') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_previous_edition_isbn
GO
CREATE FUNCTION [dbo].[rpt_get_previous_edition_isbn](
		@i_bookkey	INT,
		@i_isbn_type	INT)

/*	PARAMETER @i_isbn_type
		10 = ISBN10
		13 = ISBN 13
		16 = EAN
		17 = EAN (no dashes)
		18 = GTIN
		19 = GTIN (no dashes)
		20 = LCCN
		21 = UPC
*/
	RETURNS VARCHAR(50)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)
	DECLARE @v_desc			VARCHAR(50)
	DECLARE @v_curr_title		VARCHAR(255)
	DECLARE @i_curr_authorkey	INT
	DECLARE @i_prev_authorkey	INT
	DECLARE @i_prev_bookkey		INT
	DECLARE @i_prev_bookkey_count	INT

	SELECT @v_curr_title = dbo.rpt_get_title(@i_bookkey,'T')
	SELECT @i_curr_authorkey = authorkey
		FROM bookauthor
		WHERE bookkey=@i_bookkey
		AND   sortorder = 1

/* try to find an exact match on Title and author key */
	SELECT @i_prev_bookkey = 0
	SELECT @i_prev_bookkey_count = 0
	SELECT @i_prev_bookkey_count = count(*)
		FROM book
		WHERE SUBSTRING(Title,1,25) = SUBSTRING(@v_curr_title,1,25)
		AND  bookkey <> @i_bookkey
		AND dbo.rpt_get_best_pub_date(bookkey,1) < dbo.rpt_get_best_pub_date(@i_bookkey,1)
		AND dbo.rpt_get_author_key(bookkey,1) = dbo.rpt_get_author_key(@i_bookkey,1)

	IF @i_prev_bookkey_count = 0
		BEGIN
			SELECT @RETURN = ''
		END
	ELSE 
		BEGIN
			SELECT TOP 1 @i_prev_bookkey = bookkey
				FROM book
				WHERE SUBSTRING(Title,1,25) = SUBSTRING(@v_curr_title,1,25)
				AND  bookkey <> @i_bookkey
				AND dbo.rpt_get_best_pub_date(bookkey,1) < dbo.rpt_get_best_pub_date(@i_bookkey,1)
				AND dbo.rpt_get_author_key(bookkey,1) = dbo.rpt_get_author_key(@i_bookkey,1)
				ORDER BY dbo.rpt_get_best_pub_date(bookkey,1)
		
		

			IF @i_isbn_type = 10
				BEGIN
					SELECT @v_desc = isbn10
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END
		
			ELSE IF @i_isbn_type = 13
				BEGIN
					SELECT @v_desc = isbn
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END								

			ELSE IF @i_isbn_type = 16
				BEGIN
					SELECT @v_desc = ean
					FROM isbn
					WHERE bookkey = @i_bookkey
				END
			ELSE IF @i_isbn_type = 17
				BEGIN
					SELECT @v_desc = ean13
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END
			ELSE IF @i_isbn_type = 18
				BEGIN
					SELECT @v_desc = gtin
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END
			ELSE IF @i_isbn_type = 19
				BEGIN
					SELECT @v_desc = gtin14
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END
			ELSE IF @i_isbn_type = 20
				BEGIN
					SELECT @v_desc = lccn
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END
			ELSE IF @i_isbn_type = 21
				BEGIN
					SELECT @v_desc = upc
					FROM isbn
					WHERE bookkey = @i_prev_bookkey
				END
			IF LEN(@v_desc) > 0
				BEGIN
					SELECT @RETURN = LTRIM(RTRIM(@v_desc))
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
  RETURN @RETURN
END
go
Grant exec on dbo.rpt_get_previous_edition_isbn to Public
go