SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_CustomFloat04]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_CustomFloat04]
GO


CREATE FUNCTION dbo.qweb_get_CustomFloat04
		(@i_bookkey	INT)

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_CustomFloat04 function is to return the value on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(23)
	DECLARE @f_float			FLOAT
	
	SELECT @f_float = customfloat04
	FROM	bookcustom
	WHERE	bookkey = @i_bookkey 

	IF @f_float > 0
		BEGIN
			SELECT @RETURN = CAST(CAST(@f_float as  NUMERIC (9,2)) as VARCHAR(23))
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

