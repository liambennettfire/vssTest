IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_get_newsarchive_dates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_get_newsarchive_dates]
go

create procedure [dbo].[qweb_ecf_get_newsarchive_dates] as

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

