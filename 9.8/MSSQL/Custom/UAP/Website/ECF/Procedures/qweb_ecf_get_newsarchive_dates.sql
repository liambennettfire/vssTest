if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_get_newsarchive_dates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_get_newsarchive_dates]

CREATE procedure [dbo].[qweb_ecf_get_newsarchive_dates] 
@NewsCategoryId int
as

SET NOCOUNT ON
DECLARE @Err int

BEGIN

  SELECT distinct datepart(YY,pubdate) 'PubYear',datepart(MM,pubdate) 'PubMonth',
         cast(datepart(YY,pubdate) as varchar) + '|' + cast(datepart(MM,pubdate) as varchar) 'PubYearMonth',
         DATENAME(MM, pubdate) + ' ' + CAST(YEAR(pubdate) AS VARCHAR(4)) AS 'FormattedDesc'
    FROM newsmain
   WHERE published = 1
and NewsCategoryid = @NewsCategoryId
ORDER BY PubYear desc, PubMonth desc 

	SET @Err = @@Error
	RETURN @Err
END
GO
Grant execute on dbo.qweb_ecf_get_newsarchive_dates to Public
GO