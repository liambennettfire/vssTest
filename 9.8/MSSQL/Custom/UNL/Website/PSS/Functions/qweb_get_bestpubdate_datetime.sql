if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_get_BestPubDate_datetime') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qweb_get_BestPubDate_datetime
GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_BestPubDate_datetime]    Script Date: 09/03/2007 13:20:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[qweb_get_BestPubDate_datetime]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS DATETIME

/*	The purpose of the get Best Pub Date function is to return the date from the Best Date column on book dates
		This function returns a datetime.

	The parameters for the get Best Pub Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		DATETIME
	DECLARE @d_pubdate	DATETIME
	DECLARE @v_char_date	DATETIME
	
	SELECT @v_char_date = ''

	SELECT @d_pubdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 8


	IF COALESCE(@d_pubdate,0) <> 0
		BEGIN
			SELECT @v_char_date = @d_pubdate
		END
	ELSE
		BEGIN
			SELECT @v_char_date = NULL
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END





