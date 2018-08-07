if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProductRelationship') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProductRelationship
GO

CREATE PROCEDURE dbo.WK_LWW_getProductRelationship
--@bookkey int
AS

/*

dbo.WK_LWW_getProductRelationship

(SELECT   mp.product_id intproductid,
                           rp.product_id intproductrelationshipid,
                           rp.product_id intmainproductid,
                           SUBSTR
                              (pa.association_name,
                               1,
                               40
                              ) strproductrelationshiptitle,
                           SUBSTR (pa.TYPE, 34,
                                   20) strproductrelationshiptype
                      FROM product rp,
                           product mp,
                           product_association_item pai,
                           product_association pa
                     WHERE rp.common_product_id = pai.common_product_id
                       AND rp.publication_status NOT IN ('OP', 'TR', 'CA')
                       AND pai.product_association_id =
                                                     pa.product_association_id
                       AND mp.common_product_id = pa.common_product_id
                       AND pa.common_product_id(+) = p.common_product_id
                       AND ROWNUM < 16
                  ORDER BY pai.display_sequence
                 ) AS relationshiplist
		) productrelationship,

Select Top 100 * FROM WK_ORA.wkdba.PRODUCT
WHERE PRODUCT_ID = 2360

Select * FROM WK_ORA.WKDBA.COMMON_PRODUCT
WHERE COMMON_PRODUCT_ID = 67233

Select Top 100 * FROM WK_ORA.wkdba.PRODUCT_ASSOCIATION
WHERE COMMON_PRODUCT_ID = 67233


Select * FROM WK_ORA.wkdba.PRODUCT_ASSOCIATION
WHERE ASSOCIATION_NAME IS NOT NULL

Select Top 100 * FROM WK_ORA.wkdba.product_association_item
WHERE PRODUCT_ASSOCIATION_ID = 588



Select * FROM WK_ORA.WKDBA.PRODUCT
WHERE PRODUCT_ID = 2325





*/

BEGIN

Select
--dbo.WK_getProductId(bookkey) as intproductid,
--dbo.WK_getProductId(associatetitlebookkey) as intproductrelationshipid,
--dbo.WK_getProductId(associatetitlebookkey) as intmainproductid,
bookkey as intproductid,
associatetitlebookkey as intproductrelationshipid,
associatetitlebookkey as intmainproductid,
NULL as strproductrelationshiptitle,
Substring((CASE WHEN associationtypecode = 5 and associationtypesubcode = 0 THEN 'UpsellAssociation'
	        WHEN associationtypecode = 6 and associationtypesubcode = 0 THEN 'AncillaryAssociation'
			WHEN associationtypecode = 7 and associationtypesubcode = 0 THEN 'FreeAncillaryAssociation'
			WHEN associationtypecode = 9 and associationtypesubcode = 1 THEN 'PackageAssociation'
		END), 1, 20) as strproductrelationshiptype,
sortorder

FROM associatedtitles
WHERE (
(associationtypecode = 5 and associationtypesubcode = 0)
OR
(associationtypecode = 6 and associationtypesubcode = 0)
OR
(associationtypecode = 7 and associationtypesubcode = 0)
OR
(associationtypecode = 9 and associationtypesubcode = 1)
)
and dbo.WK_IsEligibleforLWW(bookkey) = 'Y'
--and dbo.WK_getProductId(bookkey) = 2360
--and sortorder < 16
--ORDER BY dbo.WK_getProductId(bookkey), (CASE WHEN associationtypecode = 5 THEN 'UpsellAssociation'
ORDER BY bookkey, SUBSTRING((CASE WHEN associationtypecode = 5 and associationtypesubcode = 0 THEN 'UpsellAssociation'
	        WHEN associationtypecode = 6 and associationtypesubcode = 0 THEN 'AncillaryAssociation'
			WHEN associationtypecode = 7 and associationtypesubcode = 0 THEN 'FreeAncillaryAssociation'
			WHEN associationtypecode = 9 and associationtypesubcode = 1 THEN 'PackageAssociation'
		END), 1, 20), sortorder


END


/* BELOW WAS THE IMPLEMENTATION WHEN SETS WERE IN BOOKFAMILY TABLE **********************



CREATE TABLE #tmp(
		intproductid int,
		intproductrelationshipid int,
		intmainproductid int,
		strproductrelationshiptitle varchar(40),
		strproductrelationshiptype varchar(40),
		sortorder int
	)

--Select * FROM associatedtitles

INSERT INTO #tmp
Select
--dbo.WK_getProductId(bookkey) as intproductid,
--dbo.WK_getProductId(associatetitlebookkey) as intproductrelationshipid,
--dbo.WK_getProductId(associatetitlebookkey) as intmainproductid,
bookkey as intproductid,
associatetitlebookkey as intproductrelationshipid,
associatetitlebookkey as intmainproductid,
NULL as strproductrelationshiptitle,
(CASE WHEN associationtypecode = 5 THEN 'UpsellAssociation'
	        WHEN associationtypecode = 6 THEN 'AncillaryAssociation'
			WHEN associationtypecode = 7 THEN 'FreeAncillaryAssociation'
		END) as strproductrelationshiptype,
sortorder

FROM associatedtitles
WHERE associationtypecode in (5,6,7)
and dbo.WK_IsEligibleforLWW(bookkey) = 'Y'
--and dbo.WK_getProductId(bookkey) = 2360
--and sortorder < 16
--ORDER BY dbo.WK_getProductId(bookkey), (CASE WHEN associationtypecode = 5 THEN 'UpsellAssociation'
ORDER BY bookkey, (CASE WHEN associationtypecode = 5 THEN 'UpsellAssociation'
	        WHEN associationtypecode = 6 THEN 'AncillaryAssociation'
			WHEN associationtypecode = 7 THEN 'FreeAncillaryAssociation'
		END), sortorder

--Select * FROM bookfamily

INSERT INTO #tmp
Select
--dbo.WK_getProductId(parentbookkey) as intproductid,
--dbo.WK_getProductId(childbookkey) as intproductrelationshipid,
--dbo.WK_getProductId(childbookkey) as intmainproductid,
parentbookkey as intproductid,
childbookkey as intproductrelationshipid,
childbookkey as intmainproductid,
NULL as strproductrelationshiptitle,
'PackageAssociation' as strproductrelationshiptype,
sortorder
FROM bookfamily
where dbo.WK_IsEligibleforLWW(parentbookkey) = 'Y'
and relationcode = 20001
ORDER BY  parentbookkey, sortorder --dbo.WK_getProductId(parentbookkey), sortorder

Select intproductid, intproductrelationshipid, intmainproductid, NULL, strproductrelationshiptype 
FROM #tmp
ORDER BY intproductid, strproductrelationshiptype, sortorder

DROP TABLE #tmp

END

*/