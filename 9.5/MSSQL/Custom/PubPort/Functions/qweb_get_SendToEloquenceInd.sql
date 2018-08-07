SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_SendToEloquenceInd]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_SendToEloquenceInd]
GO




CREATE FUNCTION dbo.qweb_get_SendToEloquenceInd
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_SendToEloquenceInd function is to return a 'Y' or 'N' for this indicator on the Book table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = sendtoeloind
	FROM	book
	WHERE	bookkey = @i_bookkey 


	IF @i_indicator = 1
		BEGIN
			SELECT @RETURN = 'Y'
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'N'
		END


RETURN @RETURN


END











GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

