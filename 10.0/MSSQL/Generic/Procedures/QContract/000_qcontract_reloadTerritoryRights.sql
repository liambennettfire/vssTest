IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontract_reloadTerritoryRights')
  DROP PROCEDURE qcontract_reloadTerritoryRights
GO


CREATE PROCEDURE qcontract_reloadTerritoryRights 
(
	@i_workID INT,
	@o_error_code INT OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT
)
AS

/****************************************************************************************************************************************
**  Name: qcontract_reloadTerritoryRights
**  Desc: This stored procedure will reload all territory rights
**
**  Summary: 
**  CASE: 
**
**  Paramaters:
**		@o_error_code output param, not used but required
**		@o_error_desc output param, not used but required
**		@i_workID input param, if null will run for every record, if populated the single work
**
**  Auth: Joshua Granville
**  Date: 03 January 2017
*****************************************************************************************************************************************
**  Date        Who      Change
**  -------     ---      ---------------------------------------------------------------------------------------------------------------
**  05/17/2017  Uday     Case 45101
**  07/12/2017  Colman   Case 46209 - Rollback changes since 5/17 and support any work/contract relationships
******************************************************************************************************************************************/

BEGIN

SET NOCOUNT ON


DECLARE 
	@contractProjectType INT,
	@subRightsSaleCode INT,
	@clientDefaultValue INT,
	@effectiveDateCode INT,
	@expirationDateCode INT,
	@keepNotForSale INT,
	@v_TurnOnRightsCalculus INT
	
--Get all of our base variables
SET @keepNotForSale = (SELECT dataCode FROM gentables WHERE tableID = 632 AND qsiCode = 3) --Subrights sale code 'Keep not for sale'
SET @contractProjectType = (SELECT dataCode from gentables where tableId = 550 AND qsiCode = 10) --Contract Item Type
SET @subRightsSaleCode = (SELECT dataCode from gentables where tableID = 632 AND qsiCode = 3) --Subrights sale code
SET @clientDefaultValue = (SELECT clientDefaultValue FROM clientdefaults where clientdefaultid = 85) --client default project status code
SET @effectiveDateCode = (SELECT dateTypeCode FROM dateType where qsicode = 14)
SET @expirationDateCode = (SELECT dateTypeCode FROM datetype where qsicode = 15)
SET @v_TurnOnRightsCalculus = (SELECT COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 122)

IF @v_TurnOnRightsCalculus = 0 BEGIN
   RETURN
END

IF @i_workID IS NULL 
PRINT 'Running for all records'



IF @i_workID IS NOT NULL
BEGIN
	PRINT 'Running for single workID: ' + CAST(@i_workID AS VARCHAR(50))
	INSERT INTO CoreWorkRightsProcessLog(workProjectKey,lastUserID,lastMaintDate)
	VALUES (@i_workID,'QSIDBA',GETDATE())
END


/***************************************************************************************************************
								Section: Build base table
***************************************************************************************************************/
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables		
			WHERE table_name = 'fbt_rightsCalculus_contractsWorks')
DROP TABLE fbt_rightsCalculus_contractsWorks

SELECT 
	rel.taqprojectkey1 AS workID,
	rel.taqprojectkey2 AS contractID, --Works linked to contracts
	taq.rightsImpactCode,
	taq.taqprojectstatuscode
INTO
	fbt_rightsCalculus_contractsWorks
FROM 
	taqprojectrelationship rel
INNER JOIN taqProject taq
	ON rel.taqprojectkey2 = taq.taqprojectkey
WHERE 
    taq.searchitemcode = @contractProjectType
AND rel.taqprojectkey1 = ISNULL(@i_workID,rel.taqprojectkey1) --if they passed no workID we run it for all
AND EXISTS(SELECT 1 FROM taqProjectRights tpr
			WHERE tpr.taqprojectkey = rel.taqprojectkey2
			AND (CASE WHEN ISNULL(tpr.workkey,0) = 0 THEN rel.taqprojectkey1 ELSE tpr.workkey END) = rel.taqprojectkey1)
UNION
SELECT 
	rel.taqprojectkey2,
	rel.taqprojectkey1, --Contracts linked to works
	taq.rightsImpactCode,
	taq.taqprojectstatuscode
FROM 
	taqprojectrelationship rel
INNER JOIN taqProject taq
	ON rel.taqprojectkey1 = taq.taqprojectkey
WHERE 
    taq.searchitemcode = @contractProjectType
AND rel.taqprojectkey2 = ISNULL(@i_workID,rel.taqprojectkey2) --if they passed no workID we run it for all
AND EXISTS(SELECT 1 FROM taqProjectRights tpr
			WHERE tpr.taqprojectkey = rel.taqprojectkey1
			AND (CASE WHEN ISNULL(tpr.workkey,0) = 0 THEN rel.taqprojectkey2 ELSE tpr.workkey END) = rel.taqprojectkey2)

--Create a base with the relevant data
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables		
			WHERE table_name = 'fbt_rightsCalculus_base')
DROP TABLE fbt_rightsCalculus_base

;WITH CTE_dates --Find the max effective and expiration date per contract.
AS
(
	SELECT dt.taqprojectkey,dt.datetypecode,MAX(dt.activedate) AS activeDate
	FROM taqprojecttask dt
	WHERE dt.datetypecode = @effectiveDateCode
	GROUP BY dt.taqprojectkey,dt.datetypecode
	UNION	
	SELECT dt.taqprojectkey,dt.datetypecode,MIN(dt.activedate) AS activeDate
	FROM taqprojecttask dt
	WHERE dt.datetypecode = @expirationDateCode
	GROUP BY dt.taqprojectkey,dt.datetypecode
)
SELECT 
	wc.workID,
	wc.contractID,
	tr.rightsKey,
	tr.rightsTypeCode,
	tr.rightsLanguageTypeCode,
	wc.rightsImpactCode,
	wc.taqProjectStatusCode,
	tr.rightspermissioncode,
	tr.subrightssalecode,
	xp.activeDate AS expirationDate,
	ef.activeDate AS effectiveDate,
	tr.formatdesc
INTO
	fbt_rightsCalculus_base
FROM	
	fbt_rightsCalculus_contractsWorks wc
INNER JOIN taqprojectrights tr	--get all rightsKeys 
	ON wc.contractID = tr.taqprojectkey
LEFT JOIN CTE_dates xp
	ON xp.taqprojectkey = wc.contractID
	AND xp.datetypecode = @expirationDateCode
LEFT JOIN cte_dates ef
	ON ef.taqprojectkey = wc.contractID
	AND ef.datetypecode = @effectiveDateCode

CREATE CLUSTERED INDEX idx1 ON fbt_rightsCalculus_base (workID,contractID,rightsKey)




/***************************************************************************************************************
								Section: Grab different rights types
***************************************************************************************************************/
--Get all languages
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables		
			WHERE table_name = 'fbt_rightsCalculus_lang')
DROP TABLE fbt_rightsCalculus_lang

SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	ISNULL(lang.languageCode,0) AS languageCode
INTO
	fbt_rightsCalculus_lang
FROM
	fbt_rightsCalculus_base b
LEFT JOIN taqprojectrightslanguage lang
	ON b.rightsKey = lang.rightskey
	AND ISNULL(lang.excludeind,0) = 0
WHERE 
	lang.languageCode IS NOT NULL OR ISNULL(b.rightslanguagetypecode,0) = 1
UNION --all except the excluded languages
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	g.dataCode AS languageCode
FROM
	fbt_rightsCalculus_base b
INNER JOIN taqprojectrightslanguage lang
	ON b.rightsKey = lang.rightskey
	AND ISNULL(lang.excludeind,0) != 0
CROSS JOIN(SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 318 AND gen.deleteStatus = 'N') g
WHERE g.datacode != lang.languagecode

CREATE INDEX idx1 ON fbt_rightsCalculus_lang (workID,contractID,rightsKey)


--Get all formats
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables		
			WHERE table_name = 'fbt_rightsCalculus_form')
DROP TABLE fbt_rightsCalculus_form

SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	form.mediacode,
	form.formatcode
INTO
	fbt_rightsCalculus_form
FROM
	fbt_rightsCalculus_base b
INNER JOIN taqprojectrightsformat form
	ON b.rightsKey = form.rightskey

CREATE INDEX idx1 ON fbt_rightsCalculus_form (workID,contractID,rightsKey)

--Get all countries
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables		
			WHERE table_name = 'fbt_rightsCalculus_country')
DROP TABLE fbt_rightsCalculus_country

--currentterritorycode	(No column name)
--0						217		-> 
--1						81495   -> WorldWide go to territoryRightsCountries
--2						1472	-> SpecificCountry use singleCountryCode -> gentables 114
--3						6040	-> selected countries go to territoryRightsCountries
--4						3109	-> SingleCountryGroupCode use gentablesrelationships 23 -> gentables 114
--5						918		-> All execpt SingleCountryCode go to gentables 114
--6						202		-> All except singleCountryGroupCode go to gentablesrelationships 23 -> gentables

--Selected countries (3) / (0)
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	co.countrycode,
	co.currentexclusiveind AS currentexclusiveind,
	co.forsaleind,
	cr.updatewithsubrightsind,
	co.exclusivesubrightsoldind,
	co.nonexclusivesubrightsoldind,
	cr.currentterritorycode,
	1 AS includeForSubrightsSelection
INTO
	fbt_rightsCalculus_country
FROM
	fbt_rightsCalculus_base b
INNER JOIN territoryrights cr
	ON b.rightsKey = cr.rightskey
	AND b.contractID = cr.taqprojectkey
INNER JOIN territoryrightcountries co
	ON cr.territoryrightskey = co.territoryrightskey
	AND cr.rightskey = co.rightskey
WHERE 
	cr.currentterritorycode IN (3,0)
UNION
--specific country (2)
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	cj.dataCode,
	cr.exclusiveCode,
	CASE WHEN cj.datacode = cr.singlecountrycode THEN 1 ELSE 0 END forsaleind,
	cr.updatewithsubrightsind,
	0 AS exclusivesubrightsoldind,
	0 AS nonexclusivesubrightsoldind,
	cr.currentterritorycode,
	CASE WHEN cj.datacode = cr.singlecountrycode THEN 1 ELSE 0 END includeForSubrightsSelection
FROM
	fbt_rightsCalculus_base b
INNER JOIN territoryrights cr
	ON b.rightsKey = cr.rightskey
	AND b.contractID = cr.taqprojectkey
CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N' ) cj
WHERE 
	cr.currentterritorycode = 2
UNION
--all countries
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	0 AS countryCode,
	cr.exclusiveCode,
	1 AS forsaleind, 
	cr.updatewithsubrightsind,
	0 AS exclusivesubrightsoldind,
	0 AS nonexclusivesubrightsoldind,
	cr.currentterritorycode,
	1 AS includeForSubrightsSelection
FROM
	fbt_rightsCalculus_base b
INNER JOIN territoryrights cr
	ON b.rightsKey = cr.rightskey
	AND b.contractID = cr.taqprojectkey
WHERE 
	cr.currentterritorycode = 1
--All countries except...5 singleCountryCode
UNION
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	cj.dataCode AS countryCode,
	cr.exclusiveCode,
	CASE WHEN cj.datacode = cr.singlecountrycode THEN 0 ELSE 1 END forsaleind, 
	cr.updatewithsubrightsind,
	0 AS exclusivesubrightsoldind,
	0 AS nonexclusivesubrightsoldind,
	cr.currentterritorycode,
	CASE WHEN cj.datacode = cr.singlecountrycode THEN 1 ELSE 0 END includeForSubrightsSelection
FROM
	fbt_rightsCalculus_base b
INNER JOIN territoryrights cr
	ON b.rightsKey = cr.rightskey
	AND b.contractID = cr.taqprojectkey
CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N') cj
WHERE 
	cr.currentterritorycode = 5
--4 SingleCountryGroupCode
UNION
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	cj.dataCode AS countryCode,
	cr.exclusiveCode,
	CASE WHEN cj.datacode = r.code2 THEN 1 ELSE 0 END forsaleind,
	cr.updatewithsubrightsind,
	0 AS exclusivesubrightsoldind,
	0 AS nonexclusivesubrightsoldind,
	cr.currentterritorycode,
	CASE WHEN cj.datacode = r.code2 THEN 1 ELSE 0 END includeForSubrightsSelection
FROM
	fbt_rightsCalculus_base b
INNER JOIN territoryrights cr
	ON b.rightsKey = cr.rightskey
	AND b.contractID = cr.taqprojectkey
CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N') cj
LEFT JOIN gentablesrelationshipdetail r
	ON r.code1 = cr.singlecountrygroupcode
	AND r.gentablesrelationshipkey = 23
	AND cj.datacode = r.code2
WHERE 
	cr.currentterritorycode = 4
--All except singleCountryGroupCode (6)
UNION
SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	cj.datacode AS countryCode,
	cr.exclusiveCode, 
	CASE WHEN r.code2 IS NOT NULL THEN 1 ELSE 0 END forsaleind, 
	cr.updatewithsubrightsind,
	0 AS exclusivesubrightsoldind,
	0 AS nonexclusivesubrightsoldind,
	cr.currentterritorycode,
	CASE WHEN r.code2 IS NOT NULL THEN 0 ELSE 1 END includeForSubrightsSelection
FROM
	fbt_rightsCalculus_base b
INNER JOIN territoryrights cr
	ON b.rightsKey = cr.rightskey
	AND b.contractID = cr.taqprojectkey
CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N') cj
LEFT JOIN gentablesrelationshipdetail r
	ON r.code1 = cr.singlecountrygroupcode
	AND r.gentablesrelationshipkey = 23
	AND r.code2 = cj.datacode
WHERE
	cr.currentterritorycode = 6


CREATE INDEX idx1 ON fbt_rightsCalculus_country (workID,contractID,rightsKey)


/***************************************************************************************************************
								Section: Build final table for load
***************************************************************************************************************/
--Build final table with all applicable data for the 6 core table inserts
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables		
			WHERE table_name = 'fbt_rightsCalculus_insupd')
DROP TABLE fbt_rightsCalculus_insupd

SELECT
	b.workID,
	b.contractID,
	b.rightsKey,
	b.rightsTypeCode,
	b.rightsImpactCode,
	b.taqProjectStatusCode,
	b.rightspermissioncode,
	b.subrightssalecode,
	lang.languageCode AS languageCode,
	ISNULL(form.mediacode,0) AS mediaCode,
	form.formatcode AS formatCode,
	cn.countryCode AS countryCode,
	cn.currentexclusiveind,
	b.effectiveDate, --DateType 670 -> taqProject ON the contractID
	b.expirationDate, --DateType 630 -> taqProjectTask on the contractID
	cn.forsaleind,
	cn.updatewithsubrightsind,
	cn.exclusivesubrightsoldind,
	cn.nonexclusivesubrightsoldind,
	cn.includeForSubrightsSelection
INTO
	fbt_rightsCalculus_insupd
FROM
	fbt_rightsCalculus_base b
INNER JOIN fbt_rightsCalculus_lang lang
	ON b.workID = lang.workID
	AND b.contractID = lang.contractID
	AND b.rightskey = lang.rightskey
INNER JOIN fbt_rightsCalculus_form form
	ON b.workID = form.workID
	AND b.contractID = form.contractID
	AND b.rightskey = form.rightskey
INNER JOIN fbt_rightsCalculus_country cn
	ON b.workID = cn.workID
	AND b.contractID = cn.contractID
	AND b.rightskey = cn.rightskey

CREATE INDEX IDX1 ON fbt_rightsCalculus_insupd(workId,contractID) INCLUDE(countryCode,languageCode)
CREATE INDEX IDX2 ON fbt_rightsCalculus_insupd(rightsImpactCode)
CREATE NONCLUSTERED INDEX IDX3 ON [dbo].[fbt_rightsCalculus_insupd] ([countryCode])
INCLUDE ([workID],[contractID],[rightsKey],[rightsTypeCode],[rightsImpactCode],[taqProjectStatusCode],[rightspermissioncode],[subrightssalecode],[languageCode],[mediaCode],[formatCode],[currentexclusiveind],[effectiveDate],[expirationDate],[forsaleind],[exclusivesubrightsoldind],[nonexclusivesubrightsoldind],[includeForSubrightsSelection])
CREATE NONCLUSTERED INDEX IDX4 ON [dbo].[fbt_rightsCalculus_insupd] ([languageCode])
INCLUDE ([workID],[contractID],[rightsKey],[rightsTypeCode],[rightsImpactCode],[taqProjectStatusCode],[rightspermissioncode],[subrightssalecode],[mediaCode],[formatCode],[countryCode],[currentexclusiveind],[effectiveDate],[expirationDate],[forsaleind],[exclusivesubrightsoldind],[nonexclusivesubrightsoldind],[includeForSubrightsSelection])

PRINT 'Base built'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
								Section: Truncate destination tables
***************************************************************************************************************/
IF @i_workID IS NULL --WorkID not provided, reload everything
BEGIN
	TRUNCATE TABLE CoreWorkRightsAvailableInternal
	TRUNCATE TABLE CoreWorkRightsNotAvailableInternal
	TRUNCATE TABLE CoreWorkRightsAvailableSubrights
	TRUNCATE TABLE CoreWorkRightsSoldSubrights
	TRUNCATE TABLE CoreWorkRightsInternalConflicting
	TRUNCATE TABLE CoreWorkRightsSubrightsConflicting
	TRUNCATE TABLE CoreWorkRightsSubrightsPending
END
ELSE --WorkID provided delete all traces of this work for reload
BEGIN
	DELETE CoreWorkRightsAvailableInternal WHERE workProjectKey = @i_workID
	DELETE CoreWorkRightsNotAvailableInternal WHERE workProjectKey = @i_workID
	DELETE CoreWorkRightsAvailableSubrights WHERE workProjectKey = @i_workID
	DELETE CoreWorkRightsSoldSubrights WHERE workProjectKey = @i_workID
	DELETE CoreWorkRightsInternalConflicting WHERE workProjectKey = @i_workID
	DELETE CoreWorkRightsSubrightsConflicting WHERE workProjectKey = @i_workID
	DELETE CoreWorkRightsSubrightsPending WHERE workProjectKey = @i_workID
END
PRINT 'Deletes finished'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
								Section: Load CoreWorkRightsNotAvailableInternal
								  Rules->
									RightsPermission is excluded from contract
									subrightsSalesCode us 'keep, not for sale'
									rightsimpactCode = 1
									taqProjectStatus = client default 85
***************************************************************************************************************/

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWRNAI1')
DROP TABLE fbt_rightsCalculus_CWRNAI1

SELECT
	ot.*
INTO
	fbt_rightsCalculus_CWRNAI1
FROM
	fbt_rightsCalculus_insupd ot
WHERE 
	ISNULL(ot.subrightssalecode,0) = @keepNotForSale
AND ISNULL(ot.rightsImpactCode,0) = 1 
AND ISNULL(ot.taqprojectstatuscode,0) = @clientDefaultValue
AND ISNULL(ot.rightspermissioncode,0) IN (SELECT gen.datacode FROM gentables gen WHERE gen.tableID = 463 AND gen.gen1ind = 1)


IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWRNAI3')
DROP TABLE fbt_rightsCalculus_CWRNAI3

SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	ISNULL(ot.forsaleind,0) AS forsaleind,
	0 AS conflicting
INTO
	fbt_rightsCalculus_CWRNAI3
FROM
	fbt_rightsCalculus_CWRNAI1 ot
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languagecode,ISNULL(ot.forsaleind,0)


--UPDATE c2
--SET c2.conflicting = 1
--FROM fbt_rightsCalculus_CWRNAI3 c2
--WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_CWRNAI3 t
--			WHERE c2.workID = t.workID 
--			AND c2.rightstypecode = t.rightstypecode
--			--AND c2.formatCode = t.formatCode
--			AND c2.mediaCode = t.mediaCode
--			AND c2.forsaleind != t.forsaleind
--			AND (c2.countryCode = t.countryCode 
--				OR (c2.countryCode = 0
--				AND t.countryCode != 0))
--			AND (c2.languageCode = t.languageCode
--				OR (c2.languageCode = 0
--				AND t.languageCode != 0))
--			AND (c2.formatCode = t.formatCode 
--				OR (c2.formatCode = 0
--				AND t.formatCode != 0)))

UPDATE c2
SET c2.conflicting = 1
FROM fbt_rightsCalculus_CWRNAI3 c2
WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_CWRNAI3 t
			WHERE c2.workID = t.workID 
			AND c2.rightstypecode = t.rightstypecode
			--AND c2.formatCode = t.formatCode
			AND c2.mediaCode = t.mediaCode
			AND c2.forsaleind != t.forsaleind
			AND (c2.countryCode = t.countryCode 
				OR (t.countryCode = 0
				AND c2.countryCode != 0))
			AND (c2.languageCode = t.languageCode
				OR (t.languageCode = 0
				AND c2.languageCode != 0))
			AND (c2.formatCode = t.formatCode 
				OR (t.formatCode = 0
				AND c2.formatCode != 0)))





INSERT INTO CoreWorkRightsNotAvailableInternal 
(
	workProjectKey, 
	rightsType, 
	mediaCode, 
	formatCode, 
	languageCode, 
	countryCode, 
	effectiveDate, 
	expirationDate, 
	lastUserID, 
	lastMaintDate
)
SELECT
	ins.workID,
	ins.rightsTypeCode,
	ins.mediaCode,
	ins.formatCode,
	ins.languageCode,
	ins.countryCode,
	ins.effectiveDate,
	ins.expirationDate,
	'QSIDBA' AS lastUserID,
	GETDATE() AS lastMaintDate
FROM	
	fbt_rightsCalculus_CWRNAI3 ins
WHERE
	ins.conflicting = 0

INSERT INTO CoreWorkRightsInternalConflicting 
(
	workProjectKey, 
	rightsType, 
	mediaCode, 
	formatCode, 
	languageCode, 
	countryCode, 
	effectiveDate, 
	expirationDate, 
	lastUserID, 
	lastMaintDate
)
SELECT
	ins.workID,
	ins.rightsTypeCode,
	ins.mediaCode,
	ins.formatCode,
	ins.languageCode,
	ins.countryCode,
	ins.effectiveDate,
	ins.expirationDate,
	'QSIDBA' AS lastUserID,
	GETDATE() AS lastMaintDate
FROM	
	fbt_rightsCalculus_CWRNAI3 ins
WHERE
	ins.conflicting = 1

Print 'Block 1 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
					Section: Load CoreWorkRightsAvailableInternal / CoreWorkRightsNotAvailableInternal
						Rules->
							RightsPermission is not excluded from contract
							subrightsSalesCode us 'keep, not for sale'
							rightsimpactCode = 1
							taqProjectStatus = client default 85
						IF for Sale -> CoreWorkRightsAvailableInternal
						ELSE -> CoreWorkRightsNotAvailableInternal
***************************************************************************************************************/

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWRAI1')
DROP TABLE fbt_rightsCalculus_CWRAI1

SELECT
	ot.*
INTO
	fbt_rightsCalculus_CWRAI1
FROM
	fbt_rightsCalculus_insupd ot
WHERE
	ISNULL(ot.subrightssalecode,0) = @keepNotForSale
AND ISNULL(ot.rightsImpactCode,0) = 1
AND ISNULL(ot.taqProjectStatusCode,0) = @clientDefaultValue
AND ISNULL(ot.rightsPermissionCode,0) IN (SELECT gen.datacode FROM gentables gen WHERE gen.tableID = 463 AND ISNULL(gen.gen1ind,0) = 0)

CREATE NONCLUSTERED INDEX idx12 ON [dbo].[fbt_rightsCalculus_CWRAI1] ([workID],[rightsTypeCode],[languageCode],[mediaCode],[formatCode],[countryCode])
INCLUDE ([contractID])

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWRAI3')
DROP TABLE fbt_rightsCalculus_CWRAI3


SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	ISNULL(ot.forsaleind,0) AS forsaleind,
	MAX(ot.currentexclusiveind) AS currentexclusiveind,
	0 AS conflicting
INTO
	fbt_rightsCalculus_CWRAI3
FROM
	fbt_rightsCalculus_CWRAI1 ot
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languagecode,ISNULL(ot.forsaleind,0)

--select * FROM fbt_rightsCalculus_CWRAI3 order by forSaleInd DESC

--UPDATE c2
--SET c2.conflicting = 1
--FROM fbt_rightsCalculus_CWRAI3 c2
--WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_CWRAI3 t
--			WHERE c2.workID = t.workID 
--			AND c2.rightstypecode = t.rightstypecode
--			--AND c2.formatCode = t.formatCode
--			AND c2.mediaCode = t.mediaCode
--			AND c2.forsaleind != t.forsaleind
--			AND (c2.countryCode = t.countryCode 
--				OR (c2.countryCode = 0
--				AND t.countryCode != 0))
--			AND (c2.languageCode = t.languageCode
--				OR (c2.languageCode = 0
--				AND t.languageCode != 0))
--			AND (c2.formatCode = t.formatCode 
--				OR (c2.formatCode = 0
--				AND t.formatCode != 0)))

UPDATE c2
SET c2.conflicting = 1
FROM fbt_rightsCalculus_CWRAI3 c2
WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_CWRAI3 t
			WHERE c2.workID = t.workID 
			AND c2.rightstypecode = t.rightstypecode
			--AND c2.formatCode = t.formatCode
			AND c2.mediaCode = t.mediaCode
			AND c2.forsaleind != t.forsaleind
			AND (c2.countryCode = t.countryCode 
				OR (t.countryCode = 0
				AND c2.countryCode != 0))
			AND (c2.languageCode = t.languageCode
				OR (t.languageCode = 0
				AND c2.languageCode != 0))
			AND (c2.formatCode = t.formatCode 
				OR (t.formatCode = 0
				AND c2.formatCode != 0)))




--load um
INSERT INTO CoreWorkRightsAvailableInternal 
(
	workProjectKey, 
	rightsType, 
	mediaCode, 
	formatCode, 
	languageCode, 
	countryCode, 
	effectiveDate, 
	expirationDate, 
	lastUserID, 
	lastMaintDate,
	exclusiveInd
)
SELECT
	ins.workID,
	ins.rightsTypeCode,
	ins.mediaCode,
	ins.formatCode,
	ins.languageCode,
	ins.countryCode,
	ins.effectiveDate,
	ins.expirationDate,
	'QSIDBA' AS lastUserID,
	GETDATE() AS lastMaintDate,
	ins.currentexclusiveind
FROM	
	fbt_rightsCalculus_CWRAI3 ins
WHERE
	ins.conflicting = 0
AND ins.forsaleind = 1

INSERT INTO CoreWorkRightsInternalConflicting 
(
	workProjectKey, 
	rightsType, 
	mediaCode, 
	formatCode, 
	languageCode, 
	countryCode, 
	effectiveDate, 
	expirationDate, 
	lastUserID, 
	lastMaintDate
)
SELECT
	ins.workID,
	ins.rightsTypeCode,
	ins.mediaCode,
	ins.formatCode,
	ins.languageCode,
	ins.countryCode,
	ins.effectiveDate,
	ins.expirationDate,
	'QSIDBA' AS lastUserID,
	GETDATE() AS lastMaintDate
FROM	
	fbt_rightsCalculus_CWRAI3 ins
WHERE
	ins.conflicting = 1
--AND ins.forsaleind = 1



IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWRAI3insupd')
DROP TABLE fbt_rightsCalculus_CWRAI3insupd

SELECT
	ins.workID,
	ins.rightsTypeCode,
	ins.mediaCode,
	ins.formatCode,
	ins.languageCode,
	ins.countryCode,
	ins.effectiveDate,
	ins.expirationDate
INTO
	fbt_rightsCalculus_CWRAI3insupd
FROM	
	fbt_rightsCalculus_CWRAI3 ins
WHERE
	ins.conflicting = 0
AND ins.forsaleind = 0


UPDATE 
	crna
SET
	crna.lastUserID = 'QSIDBA',
	crna.lastMaintDate = getdate(),
	crna.effectiveDate = CASE WHEN ct.effectiveDate IS NOT NULL AND ct.effectiveDate > crna.effectiveDate THEN ct.effectiveDate ELSE crna.effectiveDate END, --change effective date only if it pushes it out
	crna.expirationDate = CASE WHEN ct.expirationDate IS NOT NULL AND ct.expirationDate < crna.expirationDate THEN ct.expirationDate ELSE crna.expirationDate END --change expiration date only if it's earlier
FROM 
	CoreWorkRightsNotAvailableInternal crna
INNER JOIN fbt_rightsCalculus_CWRAI3insupd ct
	ON crna.workProjectKey = ct.workID
	AND crna.rightsType = ct.rightsTypeCode
	AND ISNULL(crna.mediaCode,0) = ISNULL(ct.mediaCode,0)
	AND crna.formatCode = ct.formatCode
	AND crna.languageCode = ct.languageCode
	AND crna.countryCode = ct.countryCode

INSERT INTO CoreWorkRightsNotAvailableInternal
	(workProjectKey, rightsType, mediaCode, formatCode, languageCode, countryCode, effectiveDate, expirationDate, lastUserID, lastMaintDate)
SELECT 
	ct.workId,ct.rightsTypeCode,ct.mediaCode,ct.formatCode,ct.languageCode,ct.countryCode,ct.effectiveDate,ct.expirationDate,'QSIDBA',getdate()
FROM 
	fbt_rightsCalculus_CWRAI3insupd ct
WHERE NOT EXISTS(SELECT 1 FROM CoreWorkRightsNotAvailableInternal crna
					WHERE crna.workProjectKey = ct.workID
					AND crna.rightsType = ct.rightsTypeCode
					AND ISNULL(crna.mediaCode,0) = ISNULL(ct.mediaCode,0)
					AND crna.formatCode = ct.formatCode
					AND crna.languageCode = ct.languageCode
					AND crna.countryCode = ct.countryCode)

Print 'Block 2 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
					Section: Load CoreWorkRightsSoldSubrights / CoreWorkRightsAvailableSubrights
						Rules->
							RightsPermission is not excluded from contract
							rightsimpactCode = 2
							taqProjectStatus = client default 85
						IF exclusive > CoreWorkRightsSoldSubrights
						ELSE -> CoreWorkRightsAvailableSubrights
***************************************************************************************************************/
--Explode out countries / language for SR if there is another contract for the work
Print 'Exploding out rights for sub rights'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
INSERT INTO fbt_rightsCalculus_insupd(workId,contractId,rightsKey,rightsTypeCode,rightsImpactCode,taqprojectstatuscode,rightspermissioncode,
									subrightssalecode,languageCode,mediaCode,FormatCode,currentexclusiveind,effectiveDate,expirationDate,
									forSaleInd,exclusivesubrightsoldind,nonexclusivesubrightsoldind,includeForSubrightsSelection,countryCode)
SELECT
	ins.workId,ins.contractId,ins.rightsKey,ins.rightsTypeCode,ins.rightsImpactCode,ins.taqprojectstatuscode,ins.rightspermissioncode,
	ins.subrightssalecode,ins.languageCode,ins.mediaCode,ins.FormatCode,ins.currentexclusiveind,ins.effectiveDate,ins.expirationDate,
	ins.forSaleInd,ins.exclusivesubrightsoldind,ins.nonexclusivesubrightsoldind,ins.includeForSubrightsSelection,cj.datacode
FROM
	fbt_rightsCalculus_insupd ins
CROSS JOIN (SELECT gen.dataCode FROM gentables gen WHERE gen.tableid = 114 AND gen.deletestatus = 'N' ) cj
WHERE
	ins.countryCode = 0
AND EXISTS(SELECT 1 FROM fbt_rightsCalculus_insupd t
			WHERE ins.workID = t.workID
			AND ins.contractID != t.contractID
			AND t.countryCode != 0)

INSERT INTO fbt_rightsCalculus_insupd(workId,contractId,rightsKey,rightsTypeCode,rightsImpactCode,taqprojectstatuscode,rightspermissioncode,
									subrightssalecode,mediaCode,FormatCode,currentexclusiveind,effectiveDate,expirationDate,
									forSaleInd,exclusivesubrightsoldind,nonexclusivesubrightsoldind,includeForSubrightsSelection,countryCode,languageCode)
SELECT
	ins.workId,ins.contractId,ins.rightsKey,ins.rightsTypeCode,ins.rightsImpactCode,ins.taqprojectstatuscode,ins.rightspermissioncode,
	ins.subrightssalecode,ins.mediaCode,ins.FormatCode,ins.currentexclusiveind,ins.effectiveDate,ins.expirationDate,
	ins.forSaleInd,ins.exclusivesubrightsoldind,ins.nonexclusivesubrightsoldind,ins.includeForSubrightsSelection,ins.countryCode,g.datacode
FROM
	fbt_rightsCalculus_insupd ins
CROSS JOIN(SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 318 AND gen.deleteStatus = 'N') g
WHERE
	ins.languageCode = 0
AND EXISTS(SELECT 1 FROM fbt_rightsCalculus_insupd t
			WHERE ins.workID = t.workID
			AND ins.contractID != t.contractID
			AND t.languageCode != 0)
Print 'Done Exploding out rights for sub rights'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
--Remove the Zero rows

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_insupdexpl')
DROP TABLE fbt_rightsCalculus_insupdexpl

SELECT ins.* INTO fbt_rightsCalculus_insupdexpl
FROM fbt_rightsCalculus_insupd ins
WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_insupd t
			WHERE ins.workID = t.workID 
			AND ins.contractID = t.contractID
			AND ((ins.countryCode = 0 AND t.countryCode != 0)
				OR (ins.languageCode = 0 AND t.languageCode != 0)))
AND (ins.countryCode = 0 OR ins.languageCode = 0)
Print 'created table without zeroes done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')	

DELETE ins 
FROM fbt_rightsCalculus_insupd ins
WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_insupd t
			WHERE ins.workID = t.workID 
			AND ins.contractID = t.contractID
			AND ((ins.countryCode = 0 AND t.countryCode != 0)
				OR (ins.languageCode = 0 AND t.languageCode != 0)))
AND (ins.countryCode = 0 OR ins.languageCode = 0)
Print 'Delete of zeroes done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')		
--We likely just created way more than 100% growth in our table so the statistics will be way out of wack
--UPDATE STATISTICS fbt_rightsCalculus_insupd

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSRAI1')
DROP TABLE fbt_rightsCalculus_CWSRAI1

SELECT
	ot.*
INTO
	fbt_rightsCalculus_CWSRAI1
FROM
	fbt_rightsCalculus_insupd ot
WHERE
	ot.rightsImpactCode = 2
AND ot.taqProjectStatusCode = @clientDefaultValue
AND ot.rightsPermissionCode IN (SELECT gen.datacode FROM gentables gen WHERE gen.tableID = 463 AND (gen.gen1ind = 0 OR gen.gen1ind IS NULL))
AND ot.includeForSubrightsSelection = 1
AND ISNULL(ot.forsaleind,0) = 1

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSRAI2')
DROP TABLE fbt_rightsCalculus_CWSRAI2


SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	MAX(ot.forsaleind) AS forsaleind,
	ISNULL(ot.currentexclusiveind,0) AS exclusiveind,
	ISNULL(MAX(ot.nonexclusivesubrightsoldind),0) AS nonexclusivesubrightsoldind
INTO
	fbt_rightsCalculus_CWSRAI2
FROM
	fbt_rightsCalculus_CWSRAI1 ot
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languageCode,ISNULL(ot.currentexclusiveind,0)

INSERT INTO CoreWorkRightsSoldSubrights
(
	workProjectKey,
	rightsType,
	mediaCode,
	formatCode,
	languageCode,
	countryCode,
	effectiveDate,
	expirationDate,
	lastUserID,
	lastMaintDate
)
SELECT	
	cws.workID,
	cws.rightstypecode,
	cws.mediaCode,
	cws.formatCode,
	cws.languageCode,
	cws.countryCode,
	cws.effectiveDate,
	cws.expirationDate,
	'QSIDBA' AS lastUserID,
	GETDATE() AS lastMaintDate
FROM
	fbt_rightsCalculus_CWSRAI2 cws
WHERE
	ISNULL(cws.exclusiveind,0) = 1
	
INSERT INTO CoreWorkRightsAvailableSubrights
(
	workProjectKey,
	rightsType,
	mediaCode,
	formatCode,
	languageCode,
	countryCode,
	effectiveDate,
	expirationDate,
	lastUserID,
	lastMaintDate,
	nonExclusiveSoldInd
)
SELECT	
	cws.workID,
	cws.rightstypecode,
	cws.mediaCode,
	cws.formatCode,
	cws.languageCode,
	cws.countryCode,
	cws.effectiveDate,
	cws.expirationDate,
	'QSIDBA' AS lastUserID,
	GETDATE() AS lastMaintDate,
	1 AS nonexclusivesubrightsoldind
FROM
	fbt_rightsCalculus_CWSRAI2 cws
WHERE
	ISNULL(cws.exclusiveind,0) != 1

Print 'Block 3 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
					Section: Load CoreWorkRightsSoldSubrights / CoreWorkRightsAvailableSubrights
						Rules->
							UpdateWithSubrightsInd = 1 (true)
							RightsPermission is not excluded from contract
							subrightsSalesCode is not keep
							rightsimpactCode = 1
							taqProjectStatus = client default 85
						IF exclusive > CoreWorkRightsSoldSubrights
						ELSE -> CoreWorkRightsAvailableSubrights
***************************************************************************************************************/


IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR2AI1')
DROP TABLE fbt_rightsCalculus_CWSR2AI1

SELECT
	ot.*
INTO
	fbt_rightsCalculus_CWSR2AI1
FROM
	fbt_rightsCalculus_insupd ot
WHERE
	ISNULL(ot.subrightssalecode,0) != @keepNotForSale
AND ot.rightsImpactCode = 1
AND ot.taqProjectStatusCode = @clientDefaultValue
AND ot.rightsPermissionCode IN (SELECT gen.datacode FROM gentables gen WHERE gen.tableID = 463 AND (gen.gen1ind = 0 OR gen.gen1ind IS NULL))
AND ot.updatewithsubrightsind = 1
AND ot.includeForSubrightsSelection = 1

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR2AI2_sold')
DROP TABLE fbt_rightsCalculus_CWSR2AI2_sold


SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	MAX(ot.forsaleind) AS forsaleind,
	MAX(ot.currentexclusiveind) AS currentexclusiveind,
	ISNULL(MAX(ot.nonexclusivesubrightsoldind),0) AS nonexclusivesubrightsoldind
INTO
	fbt_rightsCalculus_CWSR2AI2_sold
FROM
	fbt_rightsCalculus_CWSR2AI1 ot
WHERE
	ISNULL(ot.currentexclusiveind,0) = 1
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languageCode


IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR2AI2_Notsold')
DROP TABLE fbt_rightsCalculus_CWSR2AI2_Notsold


SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	MAX(ot.forsaleind) AS forsaleind,
	MAX(ot.currentexclusiveind) AS currentexclusiveind,
	ISNULL(MAX(ot.nonexclusivesubrightsoldind),0) AS nonexclusivesubrightsoldind
INTO
	fbt_rightsCalculus_CWSR2AI2_Notsold
FROM
	fbt_rightsCalculus_CWSR2AI1 ot
WHERE
	ISNULL(ot.currentexclusiveind,0) != 1
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languageCode

create unique index idx1 on fbt_rightsCalculus_CWSR2AI2_Notsold (workID,rightsTypeCode,mediaCode,formatCode,countryCode,languageCode) INCLUDE(effectiveDate,expirationDate,nonexclusivesubrightsoldind)
create unique index idx1 on fbt_rightsCalculus_CWSR2AI2_sold (workID,rightsTypeCode,mediaCode,formatCode,countryCode,languageCode) INCLUDE(effectiveDate,expirationDate,nonexclusivesubrightsoldind)



UPDATE 
	dest 
SET 
	dest.lastUserID = 'QSIDBA',
	dest.lastMaintDate = getdate(),
	dest.effectiveDate = CASE WHEN src.effectiveDate IS NOT NULL AND src.effectiveDate > dest.effectiveDate THEN src.effectiveDate ELSE dest.effectiveDate END, --change effective date only if it pushes it out
	dest.expirationDate = CASE WHEN src.expirationDate IS NOT NULL AND src.expirationDate < dest.expirationDate THEN src.expirationDate ELSE dest.expirationDate END --change expiration date only if it's earlier
FROM 
	CoreWorkRightsSoldSubrights dest 
INNER JOIN fbt_rightsCalculus_CWSR2AI2_sold src
	ON 	src.workID = dest.workProjectKey
	AND src.rightsTypeCode = dest.rightsType
	AND src.mediaCode = dest.mediaCode
	AND src.formatCode = dest.formatCode
	AND src.countryCode = dest.countryCode
	AND src.languageCode = dest.languageCode

INSERT INTO CoreWorkRightsSoldSubrights
	(workProjectKey, rightsType, mediaCode, formatCode, languageCode, countryCode, effectiveDate, expirationDate, lastUserID, lastMaintDate)
SELECT 
	src.workID, src.rightstypecode, src.mediaCode, src.formatCode, src.languageCode, src.countryCode, src.effectiveDate, src.expirationDate, 'QSIDBA', GETDATE()
FROM 
	fbt_rightsCalculus_CWSR2AI2_sold src
WHERE NOT EXISTS(SELECT 1 FROM CoreWorkRightsSoldSubrights dest
					WHERE src.workID = dest.workProjectKey
					AND src.rightsTypeCode = dest.rightsType
					AND src.mediaCode = dest.mediaCode
					AND src.formatCode = dest.formatCode
					AND src.countryCode = dest.countryCode
					AND src.languageCode = dest.languageCode)

	
UPDATE 
	dest
SET 
	dest.nonExclusiveSoldInd = src.nonexclusivesubrightsoldind,
	dest.lastUserID = 'QSIDBA',
	dest.lastMaintDate = getdate(),
	dest.effectiveDate = CASE WHEN src.effectiveDate IS NOT NULL AND src.effectiveDate > dest.effectiveDate THEN src.effectiveDate ELSE dest.effectiveDate END, --change effective date only if it pushes it out
	dest.expirationDate = CASE WHEN src.expirationDate IS NOT NULL AND src.expirationDate < dest.expirationDate THEN src.expirationDate ELSE dest.expirationDate END --change expiration date only if it's earlier
FROM 
	CoreWorkRightsAvailableSubrights dest
INNER JOIN fbt_rightsCalculus_CWSR2AI2_Notsold src
	ON 	src.workID = dest.workProjectKey
	AND src.rightsTypeCode = dest.rightsType
	AND src.mediaCode = dest.mediaCode
	AND src.formatCode = dest.formatCode
	AND src.countryCode = dest.countryCode
	AND src.languageCode = dest.languageCode

	
INSERT INTO CoreWorkRightsAvailableSubrights
	(workProjectKey, rightsType, mediaCode, formatCode, languageCode, countryCode, effectiveDate, expirationDate, lastUserID, lastMaintDate, nonExclusiveSoldInd)
SELECT 
	src.workID, src.rightstypecode, src.mediaCode, src.formatCode, src.languageCode, src.countryCode, src.effectiveDate, src.expirationDate, 'QSIDBA', GETDATE(), src.nonexclusivesubrightsoldind
FROM 
	fbt_rightsCalculus_CWSR2AI2_Notsold src
WHERE NOT EXISTS (SELECT 1 FROM CoreWorkRightsAvailableSubrights dest 
					WHERE src.workID = dest.workProjectKey
					AND src.rightsTypeCode = dest.rightsType
					AND src.mediaCode = dest.mediaCode
					AND src.formatCode = dest.formatCode
					AND src.countryCode = dest.countryCode
					AND src.languageCode = dest.languageCode)


Print 'Block 4 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
					Section: Load CoreWorkRightsSoldSubrights
						Rules->
							UpdateWithSubrightsInd != 1 (not true)
							RightsPermission is not excluded from contract
							subrightsSalesCode is not keep
							rightsimpactCode = 1 (granted to publisher)
							taqProjectStatus = client default 85
						IF exclusive > CoreWorkRightsSoldSubrights
						ELSE -> CoreWorkRightsAvailableSubrights
***************************************************************************************************************/

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR3AI1')
DROP TABLE fbt_rightsCalculus_CWSR3AI1

SELECT
	ot.*
INTO
	fbt_rightsCalculus_CWSR3AI1
FROM
	fbt_rightsCalculus_insupd ot
WHERE
	ISNULL(ot.subrightssalecode,0) != @keepNotForSale
AND ot.rightsImpactCode = 1
AND ot.taqProjectStatusCode = @clientDefaultValue
AND ot.rightsPermissionCode IN (SELECT gen.datacode FROM gentables gen WHERE gen.tableID = 463 AND (gen.gen1ind = 0 OR gen.gen1ind IS NULL))
AND ISNULL(ot.updatewithsubrightsind,0) != 1
AND ot.includeForSubrightsSelection = 1

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR3AI2_sold')
DROP TABLE fbt_rightsCalculus_CWSR3AI2_sold

SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	MAX(ot.forsaleind) AS forsaleind,
	MAX(ot.currentexclusiveind) AS currentexclusiveind,
	ISNULL(MAX(ot.nonexclusivesubrightsoldind),0) AS nonexclusivesubrightsoldind
INTO
	fbt_rightsCalculus_CWSR3AI2_sold
FROM
	fbt_rightsCalculus_CWSR3AI1 ot
WHERE
	ISNULL(ot.forsaleind,0) = 0
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languageCode

--create covering index for update/insert
create unique index idx1 on fbt_rightsCalculus_CWSR3AI2_sold (workID,rightsTypeCode,mediaCode,formatCode,countryCode,languageCode) INCLUDE(effectiveDate,expirationDate,nonexclusivesubrightsoldind)

UPDATE 
	dest 
SET
	dest.lastUserID = 'QSIDBA',
	dest.lastMaintDate = getdate(),
	dest.effectiveDate = CASE WHEN src.effectiveDate IS NOT NULL AND src.effectiveDate > dest.effectiveDate THEN src.effectiveDate ELSE dest.effectiveDate END, --change effective date only if it pushes it out
	dest.expirationDate = CASE WHEN src.expirationDate IS NOT NULL AND src.expirationDate < dest.expirationDate THEN src.expirationDate ELSE dest.expirationDate END --change expiration date only if it's earlier
FROM	
	CoreWorkRightsSoldSubrights dest 
INNER JOIN fbt_rightsCalculus_CWSR3AI2_sold src
	ON 	src.workID = dest.workProjectKey
	AND src.rightsTypeCode = dest.rightsType
	AND src.mediaCode = dest.mediaCode
	AND src.formatCode = dest.formatCode
	AND src.countryCode = dest.countryCode
	AND src.languageCode = dest.languageCode
	
INSERT INTO CoreWorkRightsSoldSubrights
	(workProjectKey, rightsType, mediaCode, formatCode, languageCode, countryCode, effectiveDate, expirationDate, lastUserID, lastMaintDate)
SELECT 
	src.workID, src.rightstypecode, src.mediaCode, src.formatCode, src.languageCode, src.countryCode,  src.effectiveDate, src.expirationDate, 'QSIDBA', GETDATE()
FROM
	fbt_rightsCalculus_CWSR3AI2_sold src
WHERE NOT EXISTS(SELECT 1 FROM CoreWorkRightsSoldSubrights dest
				WHERE src.workID = dest.workProjectKey
					AND src.rightsTypeCode = dest.rightsType
					AND src.mediaCode = dest.mediaCode
					AND src.formatCode = dest.formatCode
					AND src.countryCode = dest.countryCode
					AND src.languageCode = dest.languageCode)
					
	
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR3AI2_Notsold')
DROP TABLE fbt_rightsCalculus_CWSR3AI2_Notsold

SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	MAX(ot.forsaleind) AS forsaleind,
	MAX(ot.currentexclusiveind) AS currentexclusiveind,
	ISNULL(MAX(ot.nonexclusivesubrightsoldind),0) AS nonexclusivesubrightsoldind
INTO
	fbt_rightsCalculus_CWSR3AI2_Notsold
FROM
	fbt_rightsCalculus_CWSR3AI1 ot
WHERE 1=1
	--ISNULL(ot.currentexclusiveind,0) != 1
AND ISNULL(ot.forsaleind,0) = 1
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languageCode

--create covering index for update/insert
create unique index idx1 on fbt_rightsCalculus_CWSR3AI2_Notsold (workID,rightsTypeCode,mediaCode,formatCode,countryCode,languageCode) INCLUDE(effectiveDate,expirationDate,nonexclusivesubrightsoldind)
--create statistics effsdates ON fbt_rightsCalculus_CWSR3AI2_Notsold(effectiveDate) with sample 10 percent
--create statistics expsdates ON fbt_rightsCalculus_CWSR3AI2_Notsold(expirationDate) with sample 10 percent

UPDATE 
	dest 
SET
	dest.nonExclusiveSoldInd = src.nonexclusivesubrightsoldind,
	dest.lastUserID = 'QSIDBA',
	dest.lastMaintDate = getdate(),
	dest.effectiveDate = CASE WHEN src.effectiveDate IS NOT NULL AND src.effectiveDate > dest.effectiveDate THEN src.effectiveDate ELSE dest.effectiveDate END, --change effective date only if it pushes it out
	dest.expirationDate = CASE WHEN src.expirationDate IS NOT NULL AND src.expirationDate < dest.expirationDate THEN src.expirationDate ELSE dest.expirationDate END --change expiration date only if it's earlier
FROM 
	CoreWorkRightsAvailableSubrights dest
INNER JOIN fbt_rightsCalculus_CWSR3AI2_Notsold src
	ON	src.workID = dest.workProjectKey
	AND src.rightsTypeCode = dest.rightsType
	AND src.mediaCode = dest.mediaCode
	AND src.formatCode = dest.formatCode
	AND src.countryCode = dest.countryCode
	AND src.languageCode = dest.languageCode


INSERT INTO CoreWorkRightsAvailableSubrights 
	(workProjectKey, nonExclusiveSoldInd, rightsType, mediaCode, formatCode, languageCode, countryCode, effectiveDate, expirationDate, lastUserID, lastMaintDate)
SELECT 
	src.workID, src.nonexclusivesubrightsoldind, src.rightstypecode, src.mediaCode, src.formatCode, src.languageCode, src.countryCode,  src.effectiveDate, src.expirationDate, 'QSIDBA', GETDATE()
FROM 
	fbt_rightsCalculus_CWSR3AI2_Notsold src
LEFT JOIN CoreWorkRightsAvailableSubrights dest
				ON src.workID = dest.workProjectKey
				AND src.rightsTypeCode = dest.rightsType
				AND src.mediaCode = dest.mediaCode
				AND src.formatCode = dest.formatCode
				AND src.countryCode = dest.countryCode
				AND src.languageCode = dest.languageCode
WHERE dest.workProjectKey IS NULL

Print 'Block 5 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
--Remove any available rights that may have been sold on a different contract
--update statistics fbt_rightsCalculus_insupd
DELETE avail 
FROM CoreWorkRightsAvailableSubrights avail
INNER JOIN CoreWorkRightsSoldSubrights sold
	ON avail.workProjectKey = sold.workProjectKey
	AND avail.rightsType = sold.rightsType
	AND avail.mediaCode = sold.mediaCode
	AND avail.formatCode = sold.formatCode
	AND avail.countryCode = sold.countryCode
	AND avail.languageCode = sold.languageCode
WHERE EXISTS(SELECT 1 FROM fbt_rightsCalculus_insupd ins
			WHERE avail.workProjectKey = ins.workID)
OPTION(RECOMPILE)
Print 'Block 6 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
					Section: PendingKeys -> CoreWorkRightsAvailableSubrights / CoreWorkRightsSoldSubrights


						Rules->
							RightsPermission is not excluded from contract
							subrightsSalesCode is not keep
							rightsimpactCode = 2 
							taqProjectStatus = pending
						IF exclusive > CoreWorkRightsSoldSubrights
						ELSE -> CoreWorkRightsAvailableSubrights
***************************************************************************************************************/
--To determine the pending contract keys, you would find all contracts for that work where there is a 
--taqprojectrights row with rightspermissioncode is "Not excluded from contract" (SELECT datacode FROM gentables WHERE tableid = 463 AND (gen1ind =  0 OR  gen1ind IS NULL)) 
--for all contracts for this work where taqproject.rightsimpactcode = 2 and the taqprojectstatus =  pending 
-- SEE Section 6.2 for more info on pending (contracts are pending - any contract that is not active (the active status is identified in a client default) and has inactive/cancelled set to false will be considered pending) 

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR3AI1_pending1')
DROP TABLE fbt_rightsCalculus_CWSR3AI1_pending1

SELECT
	ot.*
INTO
	fbt_rightsCalculus_CWSR3AI1_pending1
FROM
	fbt_rightsCalculus_insupd ot
WHERE
	1=1
AND ot.rightsImpactCode = 2
AND ISNULL(ot.taqprojectstatuscode,0) != @clientDefaultValue
AND ot.rightsPermissionCode IN (SELECT gen.datacode FROM gentables gen WHERE gen.tableid = 463 AND (gen.gen1ind =  0 OR  gen.gen1ind IS NULL))



IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.tables 
			WHERE table_name = 'fbt_rightsCalculus_CWSR3AI1_pending2')
DROP TABLE fbt_rightsCalculus_CWSR3AI1_pending2

SELECT
	ot.workId,
	ot.rightsTypeCode,
	ot.mediaCode,
	ot.formatCode,
	ot.countryCode,
	ot.languageCode,
	MAX(ot.effectiveDate) AS effectiveDate,
	MIN(ot.expirationDate) AS expirationDate,
	MAX(ot.forsaleind) AS forsaleind,
	ISNULL(MAX(ot.currentexclusiveind),0) AS currentexclusiveind,
	ot.contractID
INTO
	fbt_rightsCalculus_CWSR3AI1_pending2
FROM
	fbt_rightsCalculus_CWSR3AI1_pending1 ot
GROUP BY ot.workID, ot.rightsTypeCode, ot.mediaCode, ot.formatCode, ot.countryCode, ot.languageCode,ot.contractID


--CoreWorkRightsSubrightsPending
INSERT INTO CoreWorkRightsSubrightsPending
(
	workProjectKey,
	contractKey,
	rightsType,
	mediaCode,
	formatCode,
	languageCode,
	countryCode,
	exclusiveInd,
	lastUserID,
	lastMaintDate
)
SELECT
	cwras.workId,
	cwras.contractID,
	cwras.rightsTypeCode,
	cwras.mediaCode,
	cwras.formatCode,
	cwras.languageCode,
	cwras.countryCode,
	cwras.currentexclusiveind,
	'QSIDBA', 
	GETDATE()
FROM
	fbt_rightsCalculus_CWSR3AI1_pending2 cwras
Print 'Block 7 done'
--print format(getdate(), 'yyyy-MM-dd HH:mm:ss.fff')
/***************************************************************************************************************
					Section: PendingKeys -> Cleanup!
***************************************************************************************************************/
IF @i_workID IS NOT NULL
BEGIN
	PRINT 'Finished removing process log entry workID: ' + CAST(@i_workID AS VARCHAR(50))
	DELETE CoreWorkRightsProcessLog WHERE workProjectKey = @i_workID
END
END
GO

GRANT EXEC ON qcontract_reloadTerritoryRights TO PUBLIC
GO