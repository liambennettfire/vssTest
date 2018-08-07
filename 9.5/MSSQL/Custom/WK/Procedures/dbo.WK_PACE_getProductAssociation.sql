if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getProductAssociation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getProductAssociation
GO
CREATE PROCEDURE dbo.WK_PACE_getProductAssociation
AS
/*

EAN	
TMM_ProductAssociationId	
Association Type

*/
BEGIN
SELECT DISTINCT
dbo.WK_get_itemnumber(bookkey) as EAN, 
(Cast(bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) as TMM_ProductAssociationId,
(CASE WHEN associationtypecode = 5 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.UpsellAssociation'
	        WHEN associationtypecode = 6 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.AncillaryAssociation'
			WHEN associationtypecode = 7 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.FreeAncillaryAssociation'
			WHEN associationtypecode = 9 and associationtypesubcode = 1 THEN 'com.lww.pace.domain.relationship.PackageAssociation'
		END) as [Association Type]

FROM associatedtitles
WHERE 
(
(associationtypecode = 5 and associationtypesubcode = 0)
OR
(associationtypecode = 6 and associationtypesubcode = 0)
OR
(associationtypecode = 7 and associationtypesubcode = 0)
OR
(associationtypecode = 9 and associationtypesubcode = 1)
)
and dbo.WK_get_itemnumber(bookkey) <> ''

END