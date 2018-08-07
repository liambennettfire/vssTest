IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
			WHERE TABLE_TYPE = 'VIEW'
			AND table_name = 'qse_relatedTitleCompositeSearch_view')
DROP VIEW qse_relatedTitleCompositeSearch_view
GO

/*************************************************************************************************************************
**    Change History
**************************************************************************************************************************
**  Date:        Author:   Description:
**  ----------   -------   -----------------------------------------------------------------------------------------------
**  04/18/2018   Colman    Case 51433 Custom item type filtering for criteria
**************************************************************************************************************************/

--Different clients use different columns on the isbn table to signify what the product number is
--to allow different clients to search on different columns we need the view to be dynamic.
--We also need to search on the string with dashes (in the case of an isbn) and without
--hence the union.  This shouldn't effect performance since we're searching for one or the other value
--The numbers are cast first in case in the future someone does something wild like using bookkey as the primary product number
--or a new product number field is added to isbn that is an int.
DECLARE @sql VARCHAR(MAX)
DECLARE @columnToUse VARCHAR(255) 
SET @columnToUse = (SELECT TOP 1 columnName FROM productnumlocation where note = 'Primary product displayed for titles')

SET @sql = '
CREATE VIEW qse_relatedTitleCompositeSearch_view
AS
SELECT
	tr.taqProjectKey, --ContractKey
	COALESCE(tr.productionbookkey,tpv.bookkey) AS bookkey,
	CAST(i.'+@columnToUse+' AS VARCHAR(255)) AS productNumber,
	b.title AS title,
	p.printingnum,
  cpi.projectstatus printingstatus
FROM
	taqProjectRights tr
LEFT JOIN taqprojectprinting_view tpv
	ON tr.taqprojectprintingkey = tpv.taqProjectKey
LEFT JOIN isbn i
	ON tr.productionbookkey = i.bookkey
LEFT JOIN printing p
	ON tpv.printingkey = p.printingkey
	AND tr.productionbookkey = p.bookkey
LEFT JOIN book b
	ON tr.productionbookkey = b.bookkey	
LEFT JOIN coreprojectinfo cpi
	ON tr.taqprojectprintingkey = cpi.projectKey
WHERE 
	COALESCE(tr.productionbookkey,tpv.bookkey) IS NOT NULL
OR NULLIF(CAST(i.'+@columnToUse+' AS VARCHAR(255)),'''') IS NOT NULL
OR NULLIF(b.title,'''') IS NOT NULL
UNION ALL
SELECT
	tr.taqProjectKey, --ContractKey
	COALESCE(tr.productionbookkey,tpv.bookkey) AS bookkey,
	REPLACE(CAST(i.'+@columnToUse+' AS VARCHAR(255)),''-'','''') AS productNumber,
	b.title AS title,
	p.printingnum,
  cpi.projectstatus printingstatus
FROM
	taqProjectRights tr
LEFT JOIN taqprojectprinting_view tpv
	ON tr.taqprojectprintingkey = tpv.taqProjectKey
LEFT JOIN isbn i
	ON tr.productionbookkey = i.bookkey
LEFT JOIN printing p
	ON tpv.printingkey = p.printingkey
	AND tr.productionbookkey = p.bookkey
LEFT JOIN book b
	ON tr.productionbookkey = b.bookkey	
LEFT JOIN coreprojectinfo cpi
	ON tr.taqprojectprintingkey = cpi.projectKey
WHERE 
	COALESCE(tr.productionbookkey,tpv.bookkey) IS NOT NULL
OR NULLIF(REPLACE(CAST(i.'+@columnToUse+' AS VARCHAR(255)),''-'',''''),'''') IS NOT NULL
OR NULLIF(b.title,'''') IS NOT NULL'
EXEC (@sql)
GO

GRANT SELECT, UPDATE, INSERT, DELETE ON qse_relatedTitleCompositeSearch_view TO PUBLIC
GO
