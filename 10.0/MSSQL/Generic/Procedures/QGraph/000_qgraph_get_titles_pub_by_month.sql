if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qgraph_get_titles_pub_by_month') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[qgraph_get_titles_pub_by_month]
GO

CREATE PROCEDURE [dbo].[qgraph_get_titles_pub_by_month] 
AS

/******************************************************************************************
**  Name: qgraph_get_titles_pub_by_month
**  Desc: Get Titles Publishing By Month By Imprint
**
**  Auth: Alan Katzen
**  Date: August 22 2014
*******************************************************************************************/

DECLARE
  @v_total_net_units  INT
  
BEGIN

	DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX), @columnsNoIsNull NVARCHAR(MAX)
	SET @columns = N'';
	SET @columnsNoIsNull = N'';

	SELECT @columns += N', isnull(p.' + QUOTENAME(imprintname) + N',0) as ''' + replace(imprintname, '''', '''''') + ''''
	  FROM (select imprintname
			  from coretitleinfo c
			 where (c.printingkey=1 OR c.issuenumber > 1) 
			   AND standardind = 'N' 
			   AND usageclasscode = 1 
			   AND imprintname is not null
			   AND bestpubdate is not null
			   AND (c.bestpubdate BETWEEN getdate() AND DATEADD(YYYY, 1, getdate())) -- in the next year
			group by imprintname) AS x;
            
	SELECT @columnsNoIsNull += N', p.' + QUOTENAME(imprintname) 
	  FROM (select imprintname
			  from coretitleinfo c
			 where (c.printingkey=1 OR c.issuenumber > 1) 
			   AND standardind = 'N' 
			   AND usageclasscode = 1 
			   AND imprintname is not null
			   AND bestpubdate is not null
			   AND (c.bestpubdate BETWEEN getdate() AND DATEADD(YYYY, 1, getdate())) -- in the next year
			group by imprintname) AS y;
	SELECT @columnsNoIsNull = REPLACE(@columnsNoIsNull, ', p.[', ',[')

	SET @sql = N'
	SELECT Month,' + STUFF(@columns, 1, 2, '') + '
	FROM
	(
		select cast(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(bestpubdate)-1),bestpubdate),101) as datetime) as ''Month'', imprintname, Quantity = count(*),
		datepart(MM,bestpubdate) as ''SortMonth'', datepart(YYYY,bestpubdate) as ''SortYear''
		from coretitleinfo c
		where (c.printingkey=1 OR c.issuenumber > 1) 
		AND standardind = ''N'' 
		AND usageclasscode = 1 
		AND imprintname is not null
		AND bestpubdate is not null
		AND (c.bestpubdate BETWEEN DATEADD(YYYY, -1, getdate()) AND DATEADD(YYYY, 1, getdate())) 
		group by cast(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(bestpubdate)-1),bestpubdate),101) as datetime), datepart(YYYY,bestpubdate), datepart(MM,bestpubdate), imprintname
		) AS j
	PIVOT
	(
	  SUM(Quantity) FOR imprintname IN ('
	  + STUFF(@columnsNoIsNull, 1, 1, '')
	  + ')
	) AS p;';

	--PRINT @sql;
	EXEC sp_executesql @sql;

END
GO

GRANT EXEC ON qgraph_get_titles_pub_by_month TO PUBLIC
GO