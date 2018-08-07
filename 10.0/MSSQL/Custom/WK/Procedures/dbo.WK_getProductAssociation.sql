if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductAssociation') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductAssociation
GO

CREATE PROCEDURE dbo.WK_getProductAssociation
@bookkey int
AS
/*
dbo.WK_getProductAssociation 566208
566187


Select * FROM associatedtitles
where associationtypecode in ( 5,6,7,9 )
ORDER BY bookkey, associationtypecode

Select * FROM bookfamily where parentbookkey = 566187

dbo.WK_getProductAssociation 566187

SElect * FROM book
where bookkey = 566187

Select * FROM WK_ORA.WKDBA.PRODUCT_ASSOCIATION



*/
BEGIN

Select
Distinct
(Cast(bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) as [idField],
(CASE WHEN associationtypecode = 5 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.UpsellAssociation'
	        WHEN associationtypecode = 6 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.AncillaryAssociation'
			WHEN associationtypecode = 7 and associationtypesubcode = 0 THEN 'com.lww.pace.domain.relationship.FreeAncillaryAssociation'
			WHEN associationtypecode = 9 and associationtypesubcode = 1 THEN 'com.lww.pace.domain.relationship.PackageAssociation'
		END) as [typeField]

FROM associatedtitles
WHERE bookkey = @bookkey and 
(
(associationtypecode = 5 and associationtypesubcode = 0)
OR
(associationtypecode = 6 and associationtypesubcode = 0)
OR
(associationtypecode = 7 and associationtypesubcode = 0)
OR
(associationtypecode = 9 and associationtypesubcode = 1)
)

END


/* BELOW WAS THE IMPLEMENTATION PRIOR TO NEW RELEASE,
SETS ARE NOW IN ASSOCIATEDTITLES TABLE















CREATE TABLE #tmp(
		[idField] [int] NOT NULL,
		[typeField] [varchar] (100) NOT NULL
	)

INSERT INTO #tmp
Select
Distinct
(Cast(bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) as [idField],
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN (Cast(@bookkey as varchar(20)) + Cast(associationtypecode as varchar(20)))
--ELSE ( 
--CASE associationtypecode
--WHEN 5 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.relationship.UpsellAssociation') THEN (Select TOP 1 PRODUCT_ASSOCIATION_ID FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.relationship.UpsellAssociation' ORDER BY PRODUCT_ASSOCIATION_ID DESC) ELSE (Cast(@bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) END)
--WHEN 6 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.relationship.AncillaryAssociation') THEN (Select TOP 1 PRODUCT_ASSOCIATION_ID FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.relationship.AncillaryAssociation' ORDER BY PRODUCT_ASSOCIATION_ID DESC) ELSE (Cast(@bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) END)
--WHEN 7 THEN (CASE WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.relationship.FreeAncillaryAssociation') THEN (Select TOP 1 PRODUCT_ASSOCIATION_ID FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE ='com.lww.pace.domain.relationship.FreeAncillaryAssociation' ORDER BY PRODUCT_ASSOCIATION_ID DESC) ELSE (Cast(@bookkey as varchar(20)) + Cast(associationtypecode as varchar(20))) END)
--END)
--END) as [idField],

--associationtypecode,
(CASE WHEN associationtypecode = 5 THEN 'com.lww.pace.domain.relationship.UpsellAssociation'
	        WHEN associationtypecode = 6 THEN 'com.lww.pace.domain.relationship.AncillaryAssociation'
			WHEN associationtypecode = 7 THEN 'com.lww.pace.domain.relationship.FreeAncillaryAssociation'
		END) as [typeField]

FROM associatedtitles
WHERE bookkey = @bookkey and 
associationtypecode in (5,6,7)
--and (Case WHEN dbo.rpt_get_isbn(associatetitlebookkey, 17) = '' OR dbo.rpt_get_isbn(associatetitlebookkey, 17) IS NULL THEN dbo.rpt_get_isbn(associatetitlebookkey, 15)
--							 ELSE dbo.rpt_get_isbn(associatetitlebookkey, 17) END) <> ''
--ORDER BY associationtypecode, sortorder

IF EXISTS(Select * FROM bookfamily where parentbookkey = @bookkey and relationcode = 20001 )
	BEGIN
		INSERT INTO #tmp
		Select Distinct
		--integer overflow can't use the primary key
--		99 as associationtypecode, --assigned a dummy association type code for packages
--		(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN (Cast(parentbookkey as varchar(20)) + '999')
--		WHEN EXISTS(Select * FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE = 'com.lww.pace.domain.relationship.PackageAssociation') THEN (Select TOP 1 PRODUCT_ASSOCIATION_ID FROM dbo.WK_PRODUCT_ASSOCIATION WHERE COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and TYPE = 'com.lww.pace.domain.relationship.PackageAssociation' ORDER BY PRODUCT_ASSOCIATION_ID DESC) 
--       ELSE (Cast(parentbookkey as varchar(20)) + '99') END)
--		 as [idField],
		(Cast(parentbookkey as varchar(20)) + '0') as [idField],
		'com.lww.pace.domain.relationship.PackageAssociation' as [typeField]
		FROM bookfamily
		where parentbookkey = @bookkey 
		and relationcode = 20001
--		and (Case WHEN dbo.rpt_get_isbn(childbookkey, 17) = '' OR dbo.rpt_get_isbn(childbookkey, 17) IS NULL THEN dbo.rpt_get_isbn(childbookkey, 15)
--		ELSE dbo.rpt_get_isbn(childbookkey, 17) END) <> ''
	END

Select * FROM #tmp
DROP TABLE #tmp
END




*/