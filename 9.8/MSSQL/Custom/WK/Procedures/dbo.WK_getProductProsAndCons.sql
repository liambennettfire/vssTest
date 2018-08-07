if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductProsAndCons') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductProsAndCons
GO
CREATE PROCEDURE dbo.WK_getProductProsAndCons
@bookkey int,
@associatetitlebookkey int,
@sortorder int
AS
BEGIN

/*

Select * FROM WK_ORA.WKDBA.PROS_AND_CONS
WHERE COMPETITION_ID = 93264

Select * FROM WK_ORA.WKDBA.COMPETITION
WHERE COMPETITION_ID = 93264

Select * FROM WK_ORA.WKDBA.COMMON_PRODUCT
WHERE COMMON_PRODUCT_ID = 72927
Type:
com.lww.pace.domain.marketing.CompetitionCon
com.lww.pace.domain.marketing.CompetitionPro

dbo.WK_getProductProsAndCons 923044, 0, 1

Select *
FROM associatedtitles
WHERE associationtypecode = 1
and bookkey = 923044

Select * FROM qsicomments where commentkey in (1125205, 1122977)

Commenttypecode = 10, commenttypesubcode =1 PROS
Commenttypecode = 10, commenttypesubcode = 2, CONS

competitorsField	Competition[]	
	domesticPriceField	CSIDouble
	editionNumberField	CSIString
	idField	CSIString
	leadPersonField	CSIString
	pageCountField	CSIInt
	proAndConField	ProAndCon[]
		competitionIdField
		idField
		sequenceField
		textField
		typeField


*/

CREATE TABLE #tmp(
competitionIdField int,
idField int,
sequenceField int,
textField varchar(max) NULL,
typeField varchar(255) NULL
)

Insert into #tmp
Select
--(Cast(at.bookkey as varchar(20)) + Cast(at.associationtypecode as varchar(20)) + Cast(at.sortorder as varchar(20))) as competitionIdField,
(Cast(at.bookkey as varchar(20)) + Cast(at.sortorder as varchar(20))) as competitionIdField,
at.Commentkey1 as idField,
at.sortorder as sequenceField,
Cast(qc1.commenttext as varchar(max)) as textField,
'com.lww.pace.domain.marketing.CompetitionPro' as typeField
FROM associatedtitles at
join qsicomments qc1
on at.Commentkey1 = qc1.commentkey
WHERE at.bookkey = @bookkey 
and at.associatetitlebookkey = @associatetitlebookkey
and at.sortorder = @sortorder 
and associationtypecode = 1 and associationtypesubcode = 0 
and qc1.commenttypecode = 6 and qc1.commenttypesubcode = 1
UNION
Select
--(Cast(at.bookkey as varchar(20)) + Cast(at.associationtypecode as varchar(20)) + Cast(at.sortorder as varchar(20))) as competitionIdField,
(Cast(at.bookkey as varchar(20)) +  Cast(at.sortorder as varchar(20))) as competitionIdField,
at.Commentkey2 as idField,
at.sortorder as sequenceField,
Cast(qc2.commenttext as varchar(max)) as textField,
'com.lww.pace.domain.marketing.CompetitionCon' as typeField
FROM associatedtitles at
join qsicomments qc2
on at.Commentkey2 = qc2.commentkey
WHERE at.bookkey = @bookkey 
and at.associatetitlebookkey = @associatetitlebookkey
and at.sortorder = @sortorder 
and associationtypecode = 1 and associationtypesubcode = 0 
and qc2.commenttypecode = 6 and qc2.commenttypesubcode = 2


Select * FROM #tmp
ORDER BY sequenceField

DROP TABLE #tmp

END
