IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
			WHERE TABLE_NAME = 'quarto_rpt_contractComment_view')
DROP VIEW quarto_rpt_contractComment_view
GO

CREATE VIEW [dbo].[quarto_rpt_contractComment_view]
AS
/*
Case 42354: Create a view for Quarto contract comments
Replaces these placeholders with the real values:
	@customername (displayname for contact with role of 'Customer')
	@customeraddress (primary address for contact with role of 'Customer')
	@addendumcreatedate   (Contract Signed for current contract)
	@licensorname  (displayname for contact with role of 'Licensor')
	@licensoraddress (primary address for contact with role of 'Licensor')
	@booktitle  (will return 1st Work title even if thjere are more than 1)
	@mastercreatedate  (Contract Signed for related master contract)

Where the comment type is Addendum - Top Section (add more when Quarto knows what comment types will be used for boiler plate language)
*/
WITH CTE_createDate
AS
(
	SELECT min (activedate) AS createDate,taqProjectKey
	FROM taqprojecttask 
	WHERE datetypecode = (select datetypecode from datetype where qsicode in (5))
	GROUP BY taqProjectKey
),
CTE_primaryAddress
AS
(
	SELECT 
		globalcontactKey,
		ISNULL(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(
			ISNULL(gca.address1,'') + ' ' + ISNULL(gca.address2,'') + ' ' + ISNULL(gca.address3,'') +' ' + ISNULL(gca.city,'') + ', ' +
				ISNULL(st.dataDesc,'') + ', ' + ISNULL(gca.zipCode,'') + ', ' + ISNULL(cn.dataDesc,'') 
				,' ,',',')
				,'  ',' ')
				,',,',',')
				,',,',','))),'')
				AS fullAddress
	FROM
		globalcontactaddress gca
	LEFT JOIN gentables cn
		ON gca.countrycode = cn.dataCode 
		AND cn.tableID = 114
	LEFT JOIN gentables st
		ON gca.stateCode = st.dataCode 
		AND cn.tableID = 160
	WHERE 
		gca.primaryind = 1
),
CTE_contactsLinked --using CTE so I can reuse it
AS
(
	SELECT 
		conr.taqProjectKey, gen.dataDesc, gen.dataCode,gc.displayname, gc.globalcontactkey,conr.primaryInd,con.keyind,
		ROW_NUMBER() OVER(PARTITION BY conr.taqProjectKey, conr.roleCode 
					ORDER BY CASE WHEN ISNULL(conr.primaryInd,0) = 1 THEN 1 ELSE 2 END ASC,
							 CASE WHEN ISNULL(con.keyind,0) = 1 THEN 1 ELSE 2 END ASC, con.sortOrder ASC) rnk
	FROM taqprojectcontactrole conr
	INNER JOIN gentables gen
		ON conr.rolecode = gen.dataCode
		AND gen.tableID = 285
		AND gen.datadesc IN ('Licensee','Client','Customer','Licensor')
	INNER JOIN taqprojectcontact con
		ON conr.taqprojectcontactkey = con.taqprojectcontactkey
	INNER JOIN globalContact gc
		ON con.globalcontactkey = gc.globalcontactkey
	WHERE conr.activeind = 1
)
SELECT 
	t.taqprojectkey,
	--REPLACE( --@licenseename
	--REPLACE( --@licenseeaddress
	REPLACE( --@masterCreateDate
	REPLACE( --@customeraddress
	REPLACE( --@addendumcreatedate
	REPLACE( --@customername
	REPLACE( --@booktitle
	REPLACE( --@licensorname
	REPLACE( --@licensoraddress
		CAST(commenthtml AS VARCHAR(MAX)),'@customername',ISNULL(gc.DisplayName,''))
		,'@addendumcreatedate',ISNULL(CAST(cd.createDate AS varchar(50)),'1900-01-01'))
		,'@customeraddress',
			ISNULL(CASE WHEN RIGHT(RTRIM(pca.fullAddress),1) = ',' THEN SUBSTRING(RTRIM(pca.fullAddress),1,LEN(RTRIM(pca.fullAddress))-1)	
			   ELSE pca.fullAddress
				END,'') )--Trailing commas
		,'@booktitle',ISNULL(ti.taqprojecttitle,''))
		,'@licensorname',ISNULL(gcl.displayname,''))
		,'@licensoraddress',
			ISNULL(CASE WHEN RIGHT(RTRIM(pcal.fullAddress),1) = ',' THEN SUBSTRING(RTRIM(pcal.fullAddress),1,LEN(RTRIM(pcal.fullAddress))-1)	
			   ELSE pcal.fullAddress
				END,'') )--Trailing commas
		,'@mastercreatedate',ISNULL(CAST(mastCD.createDate AS varchar(50)),'1900-01-01'))
		--,'@licenseename',ISNULL(gcli.displayname,''))
		--,'@licenseeaddress',
		--	ISNULL(CASE WHEN RIGHT(RTRIM(pcali.fullAddress),1) = ',' THEN SUBSTRING(RTRIM(pcali.fullAddress),1,LEN(RTRIM(pcali.fullAddress))-1)	
		--	   ELSE pcali.fullAddress
		--		END,'') )--Trailing commas
		AS commentText
FROM
	taqproject t
INNER JOIN taqProjectComments tpc
	ON t.taqprojectkey = tpc.taqprojectkey
	AND tpc.commenttypecode = 6 --Project
	AND tpc.commenttypesubcode = (SELECT sub1.datasubcode FROM subgentables sub1 WHERE sub1.tableID = 284 AND sub1.dataCode = 6 AND sub1.datadesc = 'Addendum - Top Section')--Addendum - Top Section
INNER JOIN qsicomments qc
	ON tpc.commentkey = qc.commentkey
LEFT JOIN CTE_contactsLinked gcli
	ON t.taqprojectkey = gcli.taqprojectkey
	AND gcli.datadesc = 'Licensee'
	AND gcli.rnk = 1
LEFT JOIN CTE_contactsLinked gcl
	ON t.taqprojectkey = gcl.taqprojectkey
	AND gcl.datadesc = 'Licensor'
	AND gcl.rnk = 1
LEFT JOIN CTE_contactsLinked gc
	ON t.taqprojectkey = gc.taqprojectkey
	AND (gc.datadesc = 'Client' OR gc.datadesc = 'Customer')
	AND gc.rnk = 1
LEFT JOIN CTE_createDate cd
	ON t.taqprojectkey = cd.taqprojectkey
LEFT JOIN CTE_primaryAddress pca --Client Address
	ON pca.globalcontactkey = gc.globalcontactkey
LEFT JOIN CTE_primaryAddress pcal --Licensor Address
	ON pcal.globalcontactkey = gcl.globalcontactkey
LEFT JOIN CTE_primaryAddress pcali --Licensor Address
	ON pcali.globalcontactkey = gcli.globalcontactkey
LEFT JOIN projectrelationshipview prv
	ON t.taqprojectkey = prv.taqprojectkey
	AND prv.relatedprojectsearchitemcode IN (SELECT TOP 1 gen3.dataCode FROM gentables gen3 where gen3.tableID = 550 and gen3.qsicode = 9) --Work
LEFT JOIN taqProject ti
	ON ti.taqProjectKEy = prv.relatedprojectkey
LEFT JOIN projectrelationshipview mastv
	ON mastv.relatedprojectkey = t.taqprojectkey
	AND mastv.projectusageclasscode IN (SELECT TOP 1 sub2.datasubcode FROM subgentables sub2 where sub2.tableID = 550 and sub2.qsicode = 64)  --Master Contract
LEFT JOIN CTE_createDate mastCD
	ON mastCD.taqprojectkey = mastv.taqprojectkey
WHERE
	t.searchitemcode IN (SELECT gen4.dataCode FROM gentables gen4 where gen4.tableID = 550 and gen4.qsicode = 10) -- all contract types

GO

GRANT SELECT ON dbo.quarto_rpt_contractComment_view TO PUBLIC
GO

