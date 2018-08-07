SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_FullAuthorDisplayName]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_FullAuthorDisplayName]
GO





CREATE FUNCTION dbo.qweb_get_FullAuthorDisplayName
		(@i_bookkey	INT)

RETURNS VARCHAR(255)

/*	The purpose of the qweb_get_FullAuthorDisplayName function is to return a the author display name on bookdetail

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	
	SELECT @v_desc = ltrim(rtrim(fullauthordisplayname))
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey 


	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
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

