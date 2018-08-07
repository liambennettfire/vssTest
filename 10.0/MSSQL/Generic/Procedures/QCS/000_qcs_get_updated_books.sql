IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_updated_books]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_updated_books]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ====================================================================
-- Author:		Andy Day
-- Create date: 11/27/2012
-- Description:	Get a collection of book keys for any book that has had
--              an asset or distribution updated since the last run.

-- modifed April 2018 - CToolan- added SQL to limit updates to non-metadata assets. See NS case 49188
-- ====================================================================
CREATE PROCEDURE [dbo].[qcs_get_updated_books] @customerkey int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @lastRunAt DATETIME
	SELECT TOP 1 @lastRunAt=booksupdated FROM csupdatetracker

	SELECT e.bookkey
	INTO #bookkeys
	FROM taqprojectelement e
	JOIN book b ON e.bookkey=b.bookkey
	JOIN gentables t ON e.taqelementtypecode=t.datacode -- Element Type
	join taqprojecttask tpt on tpt.taqelementkey=e.taqelementkey and tpt.datetypecode in  (474,477)
	WHERE
		t.tableid=287 AND
		t.gen1ind=1 AND
		t.acceptedbyeloquenceind=1 AND
		t.deletestatus!='Y' AND
		isnull(t.qsicode,0) <> 3 AND -- CT added 3/26/2018
		b.elocustomerkey=@customerkey AND
		(@lastRunAt IS NULL OR tpt.lastmaintdate >= @lastRunAt)
 
	INSERT INTO #bookkeys
	SELECT d.bookkey
	FROM csdistribution d
	JOIN book b ON d.bookkey=b.bookkey
	join taqprojectelement e on e.bookkey=b.bookkey and e.taqelementkey=d.assetkey
	join taqprojecttask tpt on tpt.taqelementkey=e.taqelementkey and tpt.datetypecode in  (474,477)
		JOIN gentables t ON e.taqelementtypecode=t.datacode -- Element Type
	WHERE
		b.elocustomerkey=@customerkey AND
		(@lastRunAt IS NULL OR tpt.lastmaintdate >= @lastRunAt) AND
	    t.tableid=287 AND
		t.gen1ind=1 AND
		t.acceptedbyeloquenceind=1 AND
		t.deletestatus!='Y' AND
		isnull(t.qsicode,0) <> 3 
	
	SELECT DISTINCT bookkey FROM #bookkeys
	
	DROP TABLE #bookkeys
END
GO

GRANT EXEC ON [dbo].[qcs_get_updated_books] TO PUBLIC
GRANT EXEC ON [dbo].[qcs_find_quick_titles] TO PUBLIC