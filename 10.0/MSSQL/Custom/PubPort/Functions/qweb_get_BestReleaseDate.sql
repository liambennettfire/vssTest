SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestReleaseDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestReleaseDate]
GO





CREATE FUNCTION dbo.qweb_get_BestReleaseDate
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Release Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Pub Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_releasedate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_releasedate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 32


	IF COALESCE(@d_releasedate,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_releasedate,101)
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

