if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductMiscFields') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductMiscFields
GO

CREATE PROCEDURE [dbo].[WK_getProductMiscFields]
@bookkey int
AS
BEGIN

Select 
[dbo].[rpt_get_bookcontact_name_by_role_min](b.bookkey, 18, 'D') as AcquisitionEditorNameField,
NULL as advStockStatusField,
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') as advStockStatusCodeField,
(CASE WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'OD' THEN 1
ELSE [dbo].[rpt_get_carton_qty](b.bookkey, 1) END)  as boxQuantityField,
--bd.copyrightyear as copyrightYearField,
[dbo].[rpt_get_misc_value](b.bookkey, 44, 'long') as copyrightYearField,
NULL as demoItemNumberField,
--dbo.rpt_get_edition(b.bookkey, 'D') as editionNumberField,
(Case WHEN bd.editionnumber IS NULL or bd.editionnumber = '' OR bd.editionnumber = 0 THEN NULL 
ELSE bd.editionnumber END) as editionNumberField,
bd.editiondescription as editionTypeField, 
NULL as editorField, --SUBSTRING(bd.fullauthordisplayname, 1, 30) as editorField,
--(Case WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'ED' AND 
--[dbo].[rpt_get_best_pub_date](b.bookkey, 1) <> '' 
--AND DateDiff(month, getdate(), [dbo].[rpt_get_best_pub_date](b.bookkey, 1)) <= 14
--THEN [dbo].[rpt_get_best_pub_date](b.bookkey, 1)
(Case WHEN dbo.WK_isPrePub(@bookkey) = 'Y' THEN [dbo].[rpt_get_best_pub_date](b.bookkey, 1)
ELSE NULL END) as estShipDateField, --Pub Date if it is a prepublication
--dbo.rpt_get_author_first(b.bookkey, 0, 'L') as firstAuthorNameField,
(CASE WHEN dbo.rpt_get_author_first(b.bookkey, 0, 'L') IS NULL or 
dbo.rpt_get_author_first(b.bookkey, 0, 'L') = '' THEN NULL
ELSE UPPER(dbo.rpt_get_author_first(b.bookkey, 0, 'L')) END) as firstAuthorNameField,
--bd.nextisbn as futureItemNumberField,
(Select TOP 1 isbn from associatedtitles WHERE bookkey = bd.bookkey and associationtypecode = 4 and associationtypesubcode = 4 ORDER BY sortorder) as futureItemNumberField,
(Case WHEN [dbo].[rpt_get_misc_value](b.bookkey, 20, 'long') = 'Yes'  THEN 1
     ELSE 0 END) as isDemoField,
(Case WHEN [dbo].[rpt_get_misc_value](b.bookkey, 21, 'long') = 'Yes'  THEN 1
     ELSE 0 END) as isPreviewField,
(Case WHEN [dbo].[rpt_get_misc_value](b.bookkey, 23, 'long') = 'Yes'  THEN 1
     ELSE 0 END) as isSampleField,
NULL as issuesPerYearField,

[dbo].[rpt_get_misc_value](b.bookkey, 25, 'long') as pubFrequencyField,
[dbo].[rpt_get_misc_value](b.bookkey, 6, 'long') as itemCategoryField,
[dbo].[rpt_get_misc_value](b.bookkey, 9, 'long') as itemMessageField,
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 17) = '' OR dbo.rpt_get_isbn(b.bookkey, 17) IS NULL THEN (Select itemnumber from isbn where bookkey = @bookkey)
	     ELSE dbo.rpt_get_isbn(b.bookkey, 17) END) as itemnumberField,

--(Case WHEN [dbo].[rpt_get_role_multiple](b.bookkey, 43, 'C', '/', '') <> '' 
--AND [dbo].[rpt_get_role_multiple](b.bookkey, 44, 'C', '/', '(rep)') <> '' THEN 
--[dbo].[rpt_get_role_multiple](b.bookkey, 43, 'C', '/', '') + ' / ' +  [dbo].[rpt_get_role_multiple](b.bookkey, 44, 'C', '/', '(rep)')
--     WHEN [dbo].[rpt_get_role_multiple](b.bookkey, 43, 'C', '/', '') = '' 
--AND [dbo].[rpt_get_role_multiple](b.bookkey, 44, 'C', '/', '(rep)') <> '' THEN 
--[dbo].[rpt_get_role_multiple](b.bookkey, 44, 'C', '/', '(rep)')
--WHEN [dbo].[rpt_get_role_multiple](b.bookkey, 43, 'C', '/', '') <> '' 
--AND [dbo].[rpt_get_role_multiple](b.bookkey, 44, 'C', '/', '(rep)') = '' THEN 
--[dbo].[rpt_get_role_multiple](b.bookkey, 43, 'C', '/', '')
--ELSE '' END) as marketerField,
[dbo].[rpt_get_bookcontact_name_by_role_min](b.bookkey, 43, 'D') as marketerField,
NULL as marketingManagerField, --[dbo].[rpt_get_misc_value](b.bookkey, 26, 'long') as marketingManagerField,
NULL as nextIssueDateField,
--bd.preveditionisbn as previousItemNumberField,
(Select TOP 1 isbn from associatedtitles WHERE bookkey = bd.bookkey and associationtypecode = 4 and associationtypesubcode = 3 ORDER BY sortorder) as previousItemNumberField,
NULL as priceRestrictionField,
--dbo.rpt_get_author_first(b.bookkey, 0, 'L') as primaryAuthorLastNameField,
(CASE WHEN dbo.rpt_get_author_first(b.bookkey, 0, 'L') IS NULL or 
dbo.rpt_get_author_first(b.bookkey, 0, 'L') = '' THEN NULL
ELSE UPPER(dbo.rpt_get_author_first(b.bookkey, 0, 'L')) END) as primaryAuthorLastNameField,
null as productTypeField,
--(Select TOP 1 categorysub2code FROM booksubjectcategory where categorytableid = 412 and bookkey = @bookkey ORDER BY sortorder) as productCodeField,
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 13, 'long') IS NULL or [dbo].[rpt_get_misc_value](b.bookkey, 13, 'long') = '' THEN NULL
ELSE UPPER([dbo].[rpt_get_misc_value](b.bookkey, 13, 'long')) END) as productCodeField,
NULL as productFormatField,
[dbo].[rpt_get_best_pub_date](b.bookkey, 1) as pubDateField,
[dbo].[rpt_get_misc_value](b.bookkey, 25, 'long') as pubFrequencyField,
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') as pubStatusField,
[dbo].[rpt_get_group_level_4](b.bookkey, 'F') as publisherField,
[dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') as quantityInStockField,
[dbo].[rpt_get_misc_value](b.bookkey, 8, 'long') as quantityReordersField,
dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',1) as searchTypeField,
dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',2) as subTypeField,
[dbo].[rpt_get_misc_value](b.bookkey, 11, 'long') as tableCountField,
[dbo].[rpt_get_misc_value](b.bookkey, 10, 'long') as totalIllustrationCountField,
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 27, 'long') IS NOT NULL THEN [dbo].[rpt_get_misc_value](b.bookkey, 27, 'long')
WHEN bd.volumenumber is not null or bd.volumenumber <> '' THEN Cast(bd.volumenumber as varchar(512))
ELSE NULL END) as volumeField,
(CASE WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'OD' THEN 'Y'
ELSE 'N' END) as printonDemandField
FROM book b
join bookdetail bd
on b.bookkey = bd.bookkey
WHERE b.bookkey = @bookkey

END




