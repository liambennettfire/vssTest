
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_wh_date]    Script Date: 03/24/2009 13:01:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_wh_date') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_wh_date
GO
CREATE FUNCTION [dbo].[rpt_get_best_wh_date]
		(@i_bookkey	INT,
		@i_printingkey	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best warehouse Date function is to return the date from the Best Date column on book dates
		This function returns a character date.

	The parameters for the get Best Pub Date are the book key and the printing key	
	
*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_whdate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	
	SELECT @v_char_date = ''

	SELECT @d_whdate = bestdate
	FROM	bookdates
	WHERE	bookkey = @i_bookkey 
			AND printingkey = @i_printingkey
			AND datetypecode = 47


	IF COALESCE(@d_whdate,0) <> 0
		BEGIN
			SELECT @v_char_date = CONVERT(VARCHAR,@d_whdate,101)
		END
	ELSE
		BEGIN
			SELECT @v_char_date = ''
		END	


	
	SELECT @RETURN = @v_char_date	

RETURN @RETURN


END
go
Grant All on dbo.rpt_get_best_wh_date to Public
go