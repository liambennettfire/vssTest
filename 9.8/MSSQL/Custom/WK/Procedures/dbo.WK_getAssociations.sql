if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getAssociations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_getAssociations
GO
CREATE PROCEDURE dbo.WK_getAssociations
@bookkey int
/*
This stored procedure returns associations for a title
We need to mimic the same behavior in PACE

The following are converted into AssociatedTitles table

com.lww.pace.domain.relationship.AncillaryAssociation
com.lww.pace.domain.relationship.UpsellAssociation
com.lww.pace.domain.relationship.FreeAncillaryAssociation

This one is converted as a package so we need to use bookfamily table

com.lww.pace.domain.relationship.PackageAssociation


ASSOCIATION TYPES
com.lww.pace.domain.relationship.PackageAssociation
com.lww.pace.domain.relationship.AncillaryAssociation
com.lww.pace.domain.relationship.UpsellAssociation
com.lww.pace.domain.relationship.FreeAncillaryAssociation


--***************************************************************
ANSILLARY TYPES

Select Distinct Type FROM WK_ORA.wkdba.PRODUCT_ASSOCIATION_ITEM
com.lww.pace.domain.relationship.AncillaryAssociationItem
com.lww.pace.domain.relationship.ProductAssociationItem

Select DISTINCT TYPE FROM WK_ORA.wkdba.PRODUCT_ASSOCIATION
WHERE PRODUCT_ASSOCIATION_ID IN (
Select PRODUCT_ASSOCIATION_ID FROM  WK_ORA.wkdba.PRODUCT_ASSOCIATION_ITEM
WHERE TYPE = 'com.lww.pace.domain.relationship.AncillaryAssociationItem')

RULE 1: IF ASSOCIATION TYPE IS
com.lww.pace.domain.relationship.AncillaryAssociation
com.lww.pace.domain.relationship.FreeAncillaryAssociation
THEN USE ANSILLARY TYPE 
com.lww.pace.domain.relationship.AncillaryAssociationItem

RULE 2 : IF ASSOCIATION TYPE IS
com.lww.pace.domain.relationship.PackageAssociation
com.lww.pace.domain.relationship.UpsellAssociation
THEN USE ANSILLARY TYPE 
com.lww.pace.domain.relationship.ProductAssociationItem


AS PER SENTHIL's EMAIL, associatedItemNumbers corresponds to formats of work in TMM:
select c.standard_number_without_dashes
from WK_ORA.wkdba.product_association_item a 
JOIN WK_ORA.wkdba.product_association b
ON a.product_association_id = b.product_association_id
JOIN WK_ORA.wkdba.product c
ON a.common_product_id = c.common_product_id
where product_association_item_id = 15685

Calling procedure should loop throuh each record
For each associationtypecode, an Association object needs to be created
For each row of the associationtypecode, an AssociationItem should be created and added to the Association object

Association[] assoc = new Association[1]; //

assoc[0].id;
assoc[0].items;
assoc[0].type;

AssociationItem[] ai = new AssociationItem[1];
ai[0].ancillaryType;
ai[0].associatedItemNumbers;
ai[0].id;
ai[0].sequence;



*/

AS
BEGIN

CREATE TABLE #tmp(
		[association_id] [int] NOT NULL,
		[associationtypecode] [int] NOT NULL,
		[type] [varchar] (100)NOT NULL,
		[ancillarytype] [varchar](100) NOT NULL,
		[associatedItemNumbers] [varchar](50) NOT NULL,
		[associationitem_id] [varchar](80) NOT NULL,
		[sequence] int NOT NULL
	)

INSERT INTO #tmp
Select
(Cast(bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) as [association_id],
associationtypecode,
(CASE WHEN associationtypecode = 5 THEN 'com.lww.pace.domain.relationship.UpsellAssociation'
	        WHEN associationtypecode = 6 THEN 'com.lww.pace.domain.relationship.AncillaryAssociation'
			WHEN associationtypecode = 7 THEN 'com.lww.pace.domain.relationship.FreeAncillaryAssociation'
		END) as [type],

(CASE WHEN associationtypecode = 5 THEN 'com.lww.pace.domain.relationship.ProductAssociationItem'
	        WHEN associationtypecode = 6 OR associationtypecode= 7 THEN 'com.lww.pace.domain.relationship.AncillaryAssociationItem'
			WHEN associationtypecode = 7 THEN 'com.lww.pace.domain.relationship.FreeAncillaryAssociation'
		END) as [ancillaryType],
--(Case WHEN dbo.rpt_get_isbn(associatetitlebookkey, 17) = '' OR dbo.rpt_get_isbn(associatetitlebookkey, 17) IS NULL THEN dbo.rpt_get_isbn(associatetitlebookkey, 15)
--							 ELSE dbo.rpt_get_isbn(associatetitlebookkey, 17) END) as associatedItemNumbers,
 		dbo.rpt_get_formats_of_work	(associatetitlebookkey, 17, ';') as associatedItemNumbers,
 (Cast(bookkey as varchar(20)) + '-' + Cast(associationtypecode as varchar(20)) + '-' + Cast(associationtypesubcode as varchar(20)) + '-' + Cast(associatetitlebookkey as varchar(20)) + '-' + Cast(sortorder as varchar(20))) as [associationitem_id],
sortorder as [sequence]	

FROM associatedtitles
WHERE bookkey = @bookkey and 
associationtypecode in (5,6,7)
--and (Case WHEN dbo.rpt_get_isbn(associatetitlebookkey, 17) = '' OR dbo.rpt_get_isbn(associatetitlebookkey, 17) IS NULL THEN dbo.rpt_get_isbn(associatetitlebookkey, 15)
--							 ELSE dbo.rpt_get_isbn(associatetitlebookkey, 17) END) <> ''
--ORDER BY associationtypecode, sortorder

IF EXISTS(Select * FROM bookfamily where parentbookkey = @bookkey and relationcode = 20001)
	BEGIN
		INSERT INTO #tmp
		
		Select
		(Cast(parentbookkey as varchar(20)) + '-' + Cast(childbookkey as varchar(20))) as [association_id],
		9999 as associationtypecode, --assigned a dummy association type code for packages
		'com.lww.pace.domain.relationship.PackageAssociation' as [type],
		'com.lww.pace.domain.relationship.ProductAssociationItem' as [ancillarytype],
--		(Case WHEN dbo.rpt_get_isbn(childbookkey, 17) = '' OR dbo.rpt_get_isbn(childbookkey, 17) IS NULL THEN dbo.rpt_get_isbn(childbookkey, 15)
--		ELSE dbo.rpt_get_isbn(childbookkey, 17) END) as associatedItemNumber, 
		dbo.rpt_get_formats_of_work	(childbookkey, 17, ';') as associatedItemNumbers,
		(Cast(parentbookkey as varchar(20)) + '-' + Cast(childbookkey as varchar(20)) + 'D') as [associationitem_id],
		sortorder as [sequence]
		FROM bookfamily
		where parentbookkey = @bookkey 
		and relationcode = 20001
--		and (Case WHEN dbo.rpt_get_isbn(childbookkey, 17) = '' OR dbo.rpt_get_isbn(childbookkey, 17) IS NULL THEN dbo.rpt_get_isbn(childbookkey, 15)
--		ELSE dbo.rpt_get_isbn(childbookkey, 17) END) <> ''
	END

Select * FROM #tmp
ORDER BY associationtypecode, sequence
DROP TABLE #tmp

END
