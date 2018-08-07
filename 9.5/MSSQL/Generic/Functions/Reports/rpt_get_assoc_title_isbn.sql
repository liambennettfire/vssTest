
/****** Object:  UserDefinedFunction [dbo].[rpt_get_assoc_title_isbn]    Script Date: 03/24/2009 11:44:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_assoc_title_isbn') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_assoc_title_isbn
GO
CREATE FUNCTION [dbo].[rpt_get_assoc_title_isbn]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(20)

/*	The purpose of the rpt_get_assoc_title_isbn function is to return a the ISBN column from associated title table
	for the row specified by the @i_order (sort order) parameter.  

	Parameter Options
		bookkey


		Order
			1 = Returns first Associate Title Type
			2 = Returns second Associate Title Type
			3 = Returns third Associate Title Type
			4
			5
			.
			.
			.
			n			
		Type
			1 = Competitive Titles
			2 = Comparative Titles
			3 = Author Sales Track
			4 = BISAC Related Titles		

*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(20)
	DECLARE @v_isbn			VARCHAR(20)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type

	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_isbn = ean
			FROM isbn
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_isbn = isbn
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_isbn) > 0
		BEGIN
			SELECT @RETURN = @v_isbn
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END

go
Grant All on dbo.rpt_get_assoc_title_isbn to Public
go