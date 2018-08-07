if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_assoc_title_format') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_assoc_title_format
GO
CREATE FUNCTION [dbo].[rpt_get_assoc_title_format]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_assoc_title_format function is to return the format from associated title view
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

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_format		VARCHAR(255)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type

	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_format = formatname
			FROM	associatedtitles_view
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_format) > 0
		BEGIN
			SELECT @RETURN = @v_format
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN

END


GO
GRANT EXECUTE ON dbo.rpt_get_assoc_title_format TO PUBLIC
GO