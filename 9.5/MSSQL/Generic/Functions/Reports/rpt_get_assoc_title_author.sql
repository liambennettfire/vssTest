
/****** Object:  UserDefinedFunction [dbo].[rpt_get_assoc_title_author]    Script Date: 03/24/2009 11:43:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_assoc_title_author') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_assoc_title_author
GO
CREATE FUNCTION [dbo].[rpt_get_assoc_title_author]
		(@i_bookkey	INT,
		@i_order	INT,
		@i_type		INT)

RETURNS VARCHAR(80)

/*	The purpose of the rpt_get_assoc_title_author function is to return a the first Author  from associated title table
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

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_author		VARCHAR(80)
	DECLARE @i_assocbookkey		INT

	SELECT @i_assocbookkey = associatetitlebookkey
	FROM	associatedtitles
	WHERE	bookkey = @i_bookkey 
			AND sortorder = @i_order	
			AND associationtypecode = @i_type


	IF @i_assocbookkey > 0
		BEGIN
			SELECT @v_author = dbo.rpt_get_author(@i_assocbookkey,1,0,'D')
			FROM book
			WHERE bookkey = @i_assocbookkey
		END
	ELSE
		BEGIN
			SELECT @v_author = authorname
			FROM	associatedtitles
			WHERE	bookkey = @i_bookkey 
					AND sortorder = @i_order
					AND associationtypecode = @i_type
		END

	IF LEN(@v_author) > 0
		BEGIN
			SELECT @RETURN = @v_author
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END

go
Grant All on dbo.rpt_get_assoc_title_author to Public
go