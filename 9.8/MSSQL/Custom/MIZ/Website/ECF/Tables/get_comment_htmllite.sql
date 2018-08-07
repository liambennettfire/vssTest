USE [MIZ]
GO
/****** Object:  UserDefinedFunction [dbo].[get_Comment_HTMLLITE]    Script Date: 03/02/2011 15:40:07 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  UserDefinedFunction [dbo].[get_Comment_HTMLLITE]    Script Date: 10/20/2008 16:25:35 ******/

alter FUNCTION [dbo].[get_Comment_HTMLLITE](
			@i_bookkey INT,
			@i_commenttypecode INT,
			@i_commenttypesubcode INT)

RETURNS varchar(8000)

AS
BEGIN
	DECLARE @RETURN varchar(8000)

	SELECT @RETURN = commenthtmllite
	FROM		bookcomments
	WHERE	@i_bookkey = bookkey
		AND @i_commenttypecode = commenttypecode
		AND @i_commenttypesubcode = commenttypesubcode 

	RETURN @RETURN
END

