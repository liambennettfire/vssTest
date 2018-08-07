if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductAssociationItem') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductAssociationItem
GO

CREATE PROCEDURE dbo.WK_getProductAssociationItem
@bookkey int,
@associationtype varchar(100)
AS
/*

dbo.WK_getProductAssociationItem 583305, 'com.lww.pace.domain.relationship.FreeAncillaryAssociation'

dbo.WK_getProductAssociationItem 909270, 'com.lww.pace.domain.relationship.PackageAssociation'

Select * FROM WK_ORA.WKDBA.PRODUCT_ASSOCIATION_ITEM

Select bookkey, Count(*) FROM associatedtitles
where associationtypecode in (9)
GROUP BY bookkey
HAVING Count(*) > 3
--ORDER BY bookkey, associationtypecode

Select parentbookkey, Count(*)
FROM bookfamily
GROUP BY parentbookkey
HAVING COunt(*) > 5

Select * FROM bookfamily where parentbookkey = 566187

SElect * FROM book
where bookkey = 566187

Select [dbo].[rpt_get_misc_value](566187, 2, 'long')
79677

Select * FROM WK_ORA.WKDBA.PRODUCT_ASSOCIATION
WHERE COMMON_PRODUCT_ID = 79677 AND TYPE = 'com.lww.pace.domain.relationship.PackageAssociation'

Select * FROM WK_ORA.WKDBA.PRODUCT_ASSOCIATION_ITEM
WHERE PRODUCT_ASSOCIATION_ID = 73122

566187	567387
566187	569396
566187	582120

Select * FROM bookfamily 
ORDER BY parentbookkey, sortorder


Select MAX(PRODUCT_ASSOCIATION_ITEM_ID) FROM WK_ORA.WKDBA.PRODUCT_ASSOCIATION_ITEM

*/
BEGIN

DECLARE @ass_id int
SET @ass_id = 0

If @associationtype = 'com.lww.pace.domain.relationship.UpsellAssociation' 
	SET @ass_id = 5

If @associationtype = 'com.lww.pace.domain.relationship.AncillaryAssociation' 
	SET @ass_id = 6

If @associationtype = 'com.lww.pace.domain.relationship.FreeAncillaryAssociation' 
	SET @ass_id = 7

If @associationtype = 'com.lww.pace.domain.relationship.PackageAssociation' 
	SET @ass_id = 9


SELECT 
(CASE WHEN associationtypecode = 5 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.ProductAssociationItem'
WHEN (associationtypecode = 6 OR associationtypecode= 7) and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.AncillaryAssociationItem'
WHEN associationtypecode = 9 and associationtypesubcode = 1 THEN 'com.lww.pace.domain.relationship.ProductAssociationItem'
END) as [ancillaryTypeField],
dbo.rpt_get_formats_of_work	(associatetitlebookkey, 17, '|') as associatedItemNumbersField,
itemkey as [idField],
sortorder as [sequenceField]	
FROM associatedtitles_wk
WHERE bookkey = @bookkey and 
associationtypecode = @ass_id
ORDER BY sortorder



/*

SELECT 
(CASE WHEN associationtypecode = 5 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.ProductAssociationItem'
WHEN (associationtypecode = 6 OR associationtypecode= 7) and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.AncillaryAssociationItem'
WHEN associationtypecode = 9 and associationtypesubcode = 1 THEN 'com.lww.pace.domain.relationship.ProductAssociationItem'
END) as [ancillaryTypeField],
dbo.rpt_get_formats_of_work	(associatetitlebookkey, 17, '|') as associatedItemNumbersField,
(Cast(bookkey as varchar(20)) + Cast(@ass_id as varchar(2)) + Cast(sortorder as varchar(20))) as [idField],
sortorder as [sequenceField]	
FROM associatedtitles
WHERE bookkey = @bookkey and 
associationtypecode = @ass_id
ORDER BY sortorder

*/


END




