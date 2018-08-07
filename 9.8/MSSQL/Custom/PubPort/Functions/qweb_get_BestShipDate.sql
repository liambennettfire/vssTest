SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestShipDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestShipDate]
GO





CREATE FUNCTION dbo.qweb_get_BestShipDate
		(@i_bookkey	INT,
		@i_printingkey	INT,
		@i_yearchars	INT)

RETURNS VARCHAR(10)

/*	The purpose of the get Best Ship Date function is to create a date type that typically doesn't exist in our client's minds.
	This is specifically necessary for the Borders spreadsheet, but has other uses as well.  The rules for creating the ship date are:
	1.  The ship date is the Release Date if the release date exists, and it is not equal to the pub date
	2.  If the release date does not exist or is the same as the Pub date, then the ship date will be the pub date - 30 days
	3.  If the Pub Date doesn't exist, then the ship date can't exist either.

	The parameters for the get Best Pub Date are the book key and the printing key and the # of characters in the Year.

	Note: Borders requires MM/DD/YY and most other applications will want MM/DD/YYYY
	


*/	

AS

BEGIN

	DECLARE @RETURN		VARCHAR(10)
	DECLARE @d_releasedate	DATETIME
	DECLARE @v_char_date	VARCHAR(10)
	DECLARE @v_releasedate	VARCHAR(10)
	DECLARE @v_pubdate	VARCHAR(10)
	DECLARE @v_pubdateYYYYMMDD VARCHAR (8)
	DECLARE @v_shipdateYYYYMMDD VARCHAR (8)
	DECLARE @d_shipdate 	DATETIME
	DECLARE @i_startpos	INT
	
	IF @i_yearchars = 2
		BEGIN
			SELECT @i_startpos = 3
		END
	ELSE -- if it's 4
		BEGIN
			SELECT @i_startpos = 1
		END

/* Get Pub Date and Release Date */

	SELECT @v_pubdate=dbo.qweb_get_BestPubDate(@i_bookkey, @i_printingkey)
	SELECT @v_releasedate=dbo.qweb_get_BestReleaseDate(@i_bookkey, @i_printingkey)



	IF @v_pubdate = ''
		BEGIN
			SELECT @v_char_date = ''
		END
	ELSE IF (@v_releasedate = '')
	     OR (@v_releasedate = @v_pubdate)  -- set ship date (Pub date -30)
		BEGIN
			SELECT @v_pubdateYYYYMMDD = SUBSTRING(@v_pubdate,7,4) + SUBSTRING (@v_pubdate,1,2) + SUBSTRING (@v_pubdate,4,2)
			SELECT @d_shipdate = DATEADD(day, -30, @v_pubdateYYYYMMDD) 
			SELECT @v_char_date = CAST(MONTH(@d_shipdate) as VARCHAR (2)) + '/' +
						CAST(DAY(@d_shipdate) as VARCHAR (2)) + '/' +
						SUBSTRING (CAST(YEAR(@d_shipdate) as VARCHAR(4)),@i_startpos,@i_yearchars) 
		END
	ELSE
		BEGIN
			SELECT @v_char_date = @v_releasedate
		END


	IF LEN(@v_char_date) > 0
		BEGIN
			SELECT @RETURN = @v_char_date	
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

