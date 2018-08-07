SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_CustomInt08]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_CustomInt08]
GO


CREATE FUNCTION dbo.qweb_get_CustomInt08
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomInt08 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @i_integer			INT
	
	SELECT @i_integer = customint08
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @i_integer > 0
		BEGIN
			SELECT @RETURN = CAST(@i_integer as VARCHAR(23))
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

