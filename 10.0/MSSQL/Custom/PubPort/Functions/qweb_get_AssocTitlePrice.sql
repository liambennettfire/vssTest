SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_AssocTitlePrice]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_AssocTitlePrice]
GO




CREATE FUNCTION dbo.qweb_get_AssocTitlePrice
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(10)

/*	The purpose of the qweb_get_AssocTitleAuthor function is to return a the Price  from associated title table
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


*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(10)
	DECLARE @v_price		VARCHAR(10)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type


	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_price = dbo.qweb_get_BestUSPrice(@i_assocbookkey,8)
			FROM book
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_price = CONVERT(VARCHAR,price)
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_price) > 0
		BEGIN
			SELECT @RETURN = @v_price
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

