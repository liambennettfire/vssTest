
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_pub_date_borders]    Script Date: 03/24/2009 12:51:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_pub_date_borders') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_pub_date_borders
GO
CREATE FUNCTION [dbo].[rpt_get_best_pub_date_borders]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Pub Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Pub Date are the book key and the printing key	
	Returns date in MM/DD/YY format NOT mm/dd/yyyy
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_pubdate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_pubdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 8


	IF COALESCE(@d_pubdate,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_pubdate,1)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END

go
Grant All on dbo.rpt_get_best_pub_date_borders to Public
go