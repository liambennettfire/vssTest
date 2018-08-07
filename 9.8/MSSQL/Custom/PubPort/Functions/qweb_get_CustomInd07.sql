SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_CustomInd07]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_CustomInd07]
GO






CREATE FUNCTION dbo.qweb_get_CustomInd07
		(@i_bookkey	INT)

RETURNS VARCHAR(1)

/*	The purpose of the qweb_get_CustomInd01 function is to return a 'Y' or 'N' for this indicator on the Custom Code table

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(1)
	DECLARE @v_desc				VARCHAR(1)
	DECLARE @i_indicator			INT
	
	SELECT @i_indicator = customind07
	FROM	bookcustom
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

