SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_TitlePrefix]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_TitlePrefix]
GO





CREATE FUNCTION dbo.qweb_get_TitlePrefix
		(@i_bookkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the qweb_get_TitlePrefix function is to return a the title prefix for the book

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(10)
	DECLARE @v_desc				VARCHAR(10)
	
	SELECT @v_desc = ltrim(rtrim(titleprefix))
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

