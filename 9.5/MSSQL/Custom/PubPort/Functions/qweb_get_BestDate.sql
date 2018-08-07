SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestDate]
GO




CREATE FUNCTION dbo.qweb_get_BestDate
		(@i_bookkey	INT,
		@i_printingkey	INT,
		@i_datetype	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best  Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Date are the book key and the printing key and the datetypecode from Gentables
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_date	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_date = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = @i_datetype


	IF COALESCE(@d_date,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_date,101)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

