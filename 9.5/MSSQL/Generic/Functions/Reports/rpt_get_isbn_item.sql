
/****** Object:  UserDefinedFunction [dbo].[rpt_get_isbn_item]    Script Date: 03/24/2009 13:10:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_isbn_item') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_isbn_item
GO
CREATE FUNCTION [dbo].[rpt_get_isbn_item](
		@i_bookkey	INT,
		@i_isbn_type	INT)

/*	PARAMETER @i_isbn_type
		10 = ISBN10
		13 = ISBN 13
        15 = Item Num
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

	ELSE IF @i_isbn_type = 15
		BEGIN
			SELECT @v_desc = itemnumber
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

go
Grant All on dbo.rpt_get_isbn_item to Public
go