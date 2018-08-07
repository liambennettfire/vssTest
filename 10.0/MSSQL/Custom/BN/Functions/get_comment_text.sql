if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_Comment_Text]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[get_Comment_Text]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION dbo.get_Comment_Text(
			@i_bookkey INT,
			@i_commenttypecode INT,
			@i_commenttypesubcode INT)

RETURNS CHAR(4000)

AS
BEGIN
	DECLARE @RETURN CHAR(4000)

	SELECT @RETURN = commenttext
	FROM		bkcomments_view
	WHERE	@i_bookkey = bookkey
		AND @i_commenttypecode = commenttypecode
		AND @i_commenttypesubcode = commenttypesubcode 

	RETURN @RETURN
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON [dbo].[get_Comment_Text]  TO [public]
GO

