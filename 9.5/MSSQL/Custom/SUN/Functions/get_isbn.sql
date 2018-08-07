set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




CREATE FUNCTION [dbo].[get_isbn](
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
		22 = Item Number
*/
	RETURNS VARCHAR(50)
	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)
	DECLARE @v_desc			VARCHAR(50)

	IF @i_isbn_type = 10
		BEGIN
			SELECT @v_desc = isbn10
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	
	ELSE IF @i_isbn_type = 13
		BEGIN
			SELECT @v_desc = isbn
			FROM isbn
			WHERE bookkey = @i_bookkey
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
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 18
		BEGIN
			SELECT @v_desc = gtin
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 19
		BEGIN
			SELECT @v_desc = gtin14
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 20
		BEGIN
			SELECT @v_desc = lccn
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 21
		BEGIN
			SELECT @v_desc = upc
			FROM isbn
			WHERE bookkey = @i_bookkey
		END
	ELSE IF @i_isbn_type = 22
		BEGIN
			SELECT @v_desc = itemnumber
			FROM isbn
			WHERE bookkey = @i_bookkey
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





