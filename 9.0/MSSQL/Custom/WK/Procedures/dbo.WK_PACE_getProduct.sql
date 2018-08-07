if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getProduct') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getProduct
GO
CREATE PROCEDURE [dbo].[WK_PACE_getProduct]
AS
/*

EXEC dbo.WK_LWW_getProduct


*/
BEGIN  

SELECT 
--b.bookkey as intproductid,
dbo.WK_getProductId(b.bookkey) as intproductid,
dbo.WK_get_itemnumber_withdashes(b.bookkey) as strproductisbn,
LOWER(b.title) as strproducttitlesearch,    --      LOWER (cp.title) strproducttitlesearch,
SUBSTRING(b.title, 1, 250) as strproducttitle, --          SUBSTR (cp.title, 1, 250) strproducttitle,
LOWER(REPLACE((Case WHEN dbo.rpt_get_isbn(b.bookkey, 16) = '' OR dbo.rpt_get_isbn(b.bookkey, 16) IS NULL 
THEN (Select itemnumber from isbn i where i.bookkey = b.bookkey)
ELSE dbo.rpt_get_isbn(b.bookkey, 16) END), '-','')) as strproductisbnsearch, 
(CASE dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',2)          
		 WHEN 'book' THEN 'Book'
         WHEN 'journal' THEN 'Journal'
         WHEN 'looseleaf' THEN 'Looseleaf'
         WHEN 'newsletter' THEN 'Newsletter'
         WHEN 'onlineService' THEN 'Online Service'
         WHEN 'PDACD' THEN 'PDA CD-ROM'
         WHEN 'slides' THEN 'Slides'
         WHEN 'software' THEN 'Software'
         WHEN 'CD' THEN 'Software'
         WHEN 'video' THEN 'VHS'
         WHEN 'DVD' THEN 'DVD'
         WHEN 'PDA' THEN 'PDA'
         WHEN 'audiotape' THEN 'Audio Tape'
         WHEN 'composite' THEN 'Package'
         WHEN 'labManual' THEN 'Lab Manual'
         WHEN 'laserdisc' THEN 'Laser Disk'
         WHEN 'newsletter' THEN 'Newsletter'
         WHEN 'cardDeck' THEN 'Card Deck'
         WHEN 'foldingPocketChart' THEN 'Folding Pocket Chart'
         WHEN 'chart' THEN 'Chart'
         WHEN 'gifts' THEN 'Gift'
         WHEN 'models' THEN 'Model'
         WHEN 'standsDisplays' THEN 'Stand/Display'
         WHEN 'seasonal' THEN 'Seasonal'
         WHEN 'journalSingleIssue' THEN 'Journal Single Issue'
		 ELSE dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',2) END)
as strproducttype,
(CASE [dbo].[rpt_get_subgentables_field](312, bd.mediatypecode, bd.mediatypesubcode, '2')
	WHEN 'CD' THEN 'CD-ROM'
    WHEN 'CDMac' THEN 'CD-ROM for Macintosh'
    WHEN 'CDWin' THEN 'CD-ROM for Windows'
    WHEN 'CDWinMac' THEN 'CD-ROM for Windows and Macintosh'
    WHEN 'PALVideo' THEN 'PAL Video'
    WHEN 'VHSVideo' THEN 'VHS Video'
    WHEN 'Composite' THEN 'Package'
    WHEN 'video' THEN 'Video'
    WHEN 'web' THEN 'Online Deliverable'
    WHEN 'prepack' THEN 'Package'
    WHEN NULL THEN 'Print'        
	WHEN '' THEN 'Print'
	ELSE [dbo].[rpt_get_subgentables_field](312, bd.mediatypecode, bd.mediatypesubcode, '2')
--	ELSE dbo.WK_getBindingMediaType(b.bookkey, 'M', ',')
	END) as strproductmediatype,
(CASE WHEN dbo.WK_getSubTitles(b.bookkey, 1) IS NULL THEN ''
	 ELSE SUBSTRING(dbo.WK_getSubTitles(b.bookkey, 1), 1, 250) END) AS strproductsubtitle,
(CASE WHEN [dbo].[rpt_get_best_pub_date](b.bookkey, 1) = '' THEN NULL
     ELSE [dbo].[rpt_get_best_pub_date](b.bookkey, 1) END) as dtproductpublicationdate,
(CASE WHEN dbo.WK_getSubTitles(b.bookkey, 2) IS NULL OR dbo.WK_getSubTitles(b.bookkey, 2) = ''  THEN ''
      ELSE SUBSTRING(dbo.WK_getSubTitles(b.bookkey, 2), 1, 250) END) as strproductsubtitle2,
(Case WHEN [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) IS NULL OR [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) = ''
	 THEN LOWER(dbo.rpt_get_isbn(b.bookkey, 16)) + ' ' + LOWER(dbo.rpt_get_title(b.bookkey, 'F')) + ' ' + LOWER([dbo].[rpt_get_book_comment](b.bookkey, 3, 7, 3))
     ELSE LOWER(dbo.rpt_get_isbn(b.bookkey, 16)) + ' ' + LOWER(dbo.rpt_get_title(b.bookkey, 'F')) + ' ' + LOWER([dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3))
	 END) as strproductabstractsearch,
NULL as strproductinventorystatus, -- p.inventory_status strproductinventorystatus,
(Case WHEN [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) IS NULL OR [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) = ''
	 THEN REPLACE([dbo].[rpt_get_book_comment](b.bookkey, 3, 7, 3), '"', '///Thirty-Fourth')
     ELSE REPLACE([dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3), '"', '///Thirty-Fourth')
	 END) AS clbproductabstract,
bd.volumenumber as intproductvolume, -- SUBSTR (p.volume, 1, 2) intproductvolume,
(CASE WHEN [dbo].[rpt_get_best_page_count](b.bookkey, 1) IS NULL OR [dbo].[rpt_get_best_page_count](b.bookkey, 1) = '' OR [dbo].[rpt_get_best_page_count](b.bookkey, 1) = 0 THEN NULL
     ELSE [dbo].[rpt_get_best_page_count](b.bookkey, 1) END) AS intproductpagecount,
[dbo].[rpt_get_trim_size](b.bookkey, 1, 'B') as strproducttrimsize, --p.width || ' x ' || p.height strproducttrimsize,
--(CASE dbo.WK_getBindingMediaType(b.bookkey, 'B', ',')
  (CASE [dbo].[rpt_get_subgentables_field](312, bd.mediatypecode, bd.mediatypesubcode, '1')
				 WHEN NULL THEN '' 
				 WHEN 'hard' THEN 'Hardbound'
                 WHEN 'soft' THEN 'Softbound'
                 WHEN 'flexible' THEN 'Flexible Binding'
                 WHEN 'comb' THEN 'Combbound'
                 WHEN 'spiral' THEN 'Spiralbound'
                 WHEN 'spiralGatefold' THEN 'Spiralbound with Gatefold'
                 WHEN 'perfect' THEN 'Perfectbound'
                 WHEN 'looseleafPages' THEN 'Looseleaf Pages'
                 WHEN 'looseleafBinder' THEN 'Looseleaf with Binder'
                 WHEN 'threeRingBinder' THEN 'Three Ring Binder'
                 WHEN 'cardDeck' THEN 'Card Deck'
                 WHEN 'cardDeckRings' THEN 'Card Deck with Hinge Metal Rings'
                 WHEN 'laminated' THEN 'Laminated'
                 WHEN 'plasticStyrene' THEN 'Plastic Styrene'
                 WHEN 'shrinkWrappedIndiv' THEN 'Shrink Wrapped Invidual'
                 WHEN 'shrinkWrappedLaminated' THEN 'Shrink Wrapped Laminated'
                 WHEN 'shrinkWrappedTabs' THEN 'Shrink Wrapped Tabs'
				 ELSE [dbo].[rpt_get_subgentables_field](312, bd.mediatypecode, bd.mediatypesubcode, '1') END)
--				 ELSE dbo.WK_getBindingMediaType(b.bookkey, 'B', ',') END)
as strproductbindingtype,
'ps.MEDIA_FORMAT' strproductformattype, 
0 AS intproductversion,
(CASE WHEN bd.editionnumber IS NOT NULL and bd.editionnumber <> '' AND bd.editionnumber > 1 and bd.editionnumber < 101 THEN dbo.rpt_get_gentables_field(557, bd.editionnumber, '1')
ELSE bd.editiondescription END) as strproductedition,
NULL strproductcomboinclusion, 
[dbo].[rpt_get_misc_value](b.bookkey, 25, 'long') as  strproductpublishingfrequency,
NULL dtproductcopyrightyear, 
NULL strproductcontactfax, 
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 41, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 41, 'long') END) as strproductcontactinfo,

(CASE [dbo].[rpt_get_misc_value](b.bookkey, 36, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 36, 'long') END) as strmedialength, --p.media_length strproductmedialength,

(CASE [dbo].[rpt_get_misc_value](b.bookkey, 37, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 37, 'long') END)  as strvolumesettype,

(Select TOP 1 dbo.rpt_get_sub2gentables_field(bsc.categorytableid, bsc.categorycode, bsc.categorysubcode, bsc.categorysub2code, 'S') 
from booksubjectcategory bsc where bsc.bookkey = b.bookkey and bsc.categorytableid = 412 
and categorysub2code IS NOT NULL AND categorysub2code <> 0
ORDER BY bsc.sortorder) as strsaccode,

(Select TOP 1 dbo.rpt_get_subgentables_field(bsc.categorytableid, bsc.categorycode, bsc.categorysubcode, 'S') 
from booksubjectcategory bsc where bsc.bookkey = b.bookkey and bsc.categorytableid = 412 
and categorysub2code IS NOT NULL AND categorysub2code <> 0
ORDER BY bsc.sortorder) as strsacsum,

(CASE bd.languagecode2 
   WHEN NULL THEN ''
   WHEN '' THEN ''
   ELSE [dbo].[rpt_get_gentables_field] (318, bd.languagecode2, 'D') end) as STRORIGINALLANGUAGE,

[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') as STRPUBLICATIONSTATUS,
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 10, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') END) as INTQUANTITYAVAILABLE,


(Select TOP 1 dbo.rpt_get_sub2gentables_field(bsc.categorytableid, bsc.categorycode, bsc.categorysubcode, bsc.categorysub2code, 'E') 
from booksubjectcategory bsc where bsc.bookkey = b.bookkey and bsc.categorytableid = 412 
and categorysub2code IS NOT NULL AND categorysub2code <> 0
ORDER BY bsc.sortorder) as PRODUCT_TRACKING_CODE_ID,
dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',1) as PRODUCT_SEARCH_TYPE,
dbo.qweb_get_BookSubjects(b.bookkey, 5,0,'E',2) as PRODUCT_SUB_TYPE,
dbo.rpt_get_date(b.bookkey, 1, 487, 'B') as PROMOTIONAL_DATE,
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 28, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 28, 'long') END) as VOLUME_YEAR,
NULL as STANDARD_NUMBER_DESCRIPTION,  --3/16 Per Angela, not used and was not converted to TMM. 
[dbo].[rpt_get_misc_value](b.bookkey, 5, 'long') as ADVANTAGE_PUB_CODE,
[dbo].[rpt_get_misc_value](b.bookkey, 6, 'long') as ADVANTAGE_ITEM_NUM, --Assuming Senthil meant item category by item_num
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 4, '') IS NULL OR [dbo].[rpt_get_misc_value](b.bookkey, 4, '') = '' THEN NULL
ELSE UPPER([dbo].[rpt_get_misc_value](b.bookkey, 4, '')) END) as ADVANTAGE_SHORT_TITLE,
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 3, '') IS NULL OR [dbo].[rpt_get_misc_value](b.bookkey, 3, '') = '' THEN NULL
ELSE UPPER([dbo].[rpt_get_misc_value](b.bookkey, 3, '')) END) as ADVANTAGE_FULL_TITLE ,
NULL as DISPLAY_SEQUENCE, 
NULL as PERSON_ADDED,
b.creationdate as DATE_ADDED,
b.lastuserid as PERSON_MODIFIED,
b.lastmaintdate as DATE_MODIFIED,
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 13, 'long') IS NULL or [dbo].[rpt_get_misc_value](b.bookkey, 13, 'long') = '' THEN NULL
ELSE UPPER([dbo].[rpt_get_misc_value](b.bookkey, 13, 'long')) END) as PROD_CODE,
(CASE WHEN [dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') = 'OD' THEN 1
ELSE [dbo].[rpt_get_carton_qty](b.bookkey, 1) END)  as CARTON_QTY,
[dbo].[rpt_get_misc_value](b.bookkey, 8, 'long') as REORDER_QTY,
dbo.rpt_get_isbn(b.bookkey, 13) as STANDARD_NUMBER10,
[dbo].[rpt_get_language](b.bookkey, 'D') as LANGUAGE

from book b
join bookdetail bd
on b.bookkey = bd.bookkey
WHERE dbo.WK_get_itemnumber_withdashes(b.bookkey) <> ''
END

