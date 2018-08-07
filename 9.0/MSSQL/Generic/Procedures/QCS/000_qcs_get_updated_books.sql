IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_updated_books]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_updated_books]
GO

-- ====================================================================
-- Author:		Andy Day
-- Create date: 11/27/2012
-- Description:	Get a collection of book keys for any book that has had
--              an asset or distribution updated since the last run.
-- ====================================================================
CREATE PROCEDURE qcs_get_updated_books @customerkey int
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
	WHERE
		t.tableid=287 AND
		t.gen1ind=1 AND
		t.acceptedbyeloquenceind=1 AND
		t.deletestatus!='Y' AND
		b.elocustomerkey=@customerkey AND
		(@lastRunAt IS NULL OR e.lastmaintdate >= @lastRunAt)
 
	INSERT INTO #bookkeys
	SELECT d.bookkey
	FROM csdistribution d
	JOIN book b ON d.bookkey=b.bookkey
	WHERE
		b.elocustomerkey=@customerkey AND
		(@lastRunAt IS NULL OR d.lastmaintdate >= @lastRunAt)
	
	SELECT DISTINCT bookkey FROM #bookkeys
	
	DROP TABLE #bookkeys
END
GO
