USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_get_newsarchive_dates]    Script Date: 01/27/2010 16:23:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_get_newsarchive_dates] as

SET NOCOUNT ON
DECLARE @Err int

BEGIN

  SELECT distinct datepart(YY,pubdate) 'PubYear',datepart(MM,pubdate) 'PubMonth',
         cast(datepart(YY,pubdate) as varchar) + '|' + cast(datepart(MM,pubdate) as varchar) 'PubYearMonth',
         DATENAME(MM, pubdate) + ' ' + CAST(YEAR(pubdate) AS VARCHAR(4)) AS 'FormattedDesc'
    FROM newsmain
   WHERE published = 1
ORDER BY PubYear desc, PubMonth desc 

	SET @Err = @@Error
	RETURN @Err
END



