if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getProduct') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getProduct
GO
CREATE PROCEDURE [dbo].[WK_LWW_getProduct]
AS
/*

EXEC dbo.WK_LWW_getProduct


*/
BEGIN

SELECT 
--(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 1, 'long') IS NULL 
--OR [dbo].[rpt_get_misc_value](b.bookkey, 1, 'long') = '' THEN b.bookkey
--ELSE [dbo].[rpt_get_misc_value](b.bookkey, 1, 'long') END) as intproductid, --p.product_id intproductid, 
b.bookkey as intproductid,
(Case WHEN dbo.rpt_get_isbn(b.bookkey, 16) = '' OR dbo.rpt_get_isbn(b.bookkey, 16) IS NULL 
THEN (Select itemnumber from isbn i where i.bookkey = b.bookkey)
ELSE dbo.rpt_get_isbn(b.bookkey, 16) END) as strproductisbn, -- p.standard_number strproductisbn,
LOWER(b.title) as strproducttitlesearch,    --      LOWER (cp.title) strproducttitlesearch,
SUBSTRING(b.title, 1, 250) as strproducttitle, --          SUBSTR (cp.title, 1, 250) strproducttitle,

LOWER(REPLACE((Case WHEN dbo.rpt_get_isbn(b.bookkey, 16) = '' OR dbo.rpt_get_isbn(b.bookkey, 16) IS NULL 
THEN (Select itemnumber from isbn i where i.bookkey = b.bookkey)
ELSE dbo.rpt_get_isbn(b.bookkey, 16) END), '-','')) as strproductisbnsearch, --LOWER (REPLACE (p.standard_number, '-', '')) strproductisbnsearch,
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
--DECODE (p.product_sub_type,
--                  'book', 'Book',
--                  'journal', 'Journal',
--                  'looseleaf', 'Looseleaf',
--                  'newsletter', 'Newsletter',
--                  'onlineService', 'Online Service',
--                  'PDACD', 'PDA CD-ROM',
--                  'slides', 'Slides',
--                  'software', 'Software',
--                  'CD', 'Software',
--                  'video', 'VHS',
--                  'DVD', 'DVD',
--                  'PDA', 'PDA',
--                  'audiotape', 'Audio Tape',
--                  'composite', 'Package',
--                  'labManual', 'Lab Manual',
--                  'laserdisc', 'Laser Disk',
--                  'newsletter', 'Newsletter',
--                  'cardDeck', 'Card Deck',
--                  'foldingPocketChart', 'Folding Pocket Chart',
--                  'chart', 'Chart',
--                  'gifts', 'Gift',
--                  'models', 'Model',
--                  'standsDisplays', 'Stand/Display',
--                  'seasonal', 'Seasonal',
--                  'journalSingleIssue', 'Journal Single Issue',
--                  p.product_sub_type
--                 ) AS strproducttype,
--(CASE dbo.WK_getBindingMediaType(b.bookkey, 'M', ',')
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
--          DECODE (p.media_type,
--                  'CD', 'CD-ROM',
--                  'CDMac', 'CD-ROM for Macintosh',
--                  'CDWin', 'CD-ROM for Windows',
--                  'CDWinMac', 'CD-ROM for Windows and Macintosh',
--                  'PALVideo', 'PAL Video',
--                  'VHSVideo', 'VHS Video',
--                  'Composite', 'Package',
--                  'video', 'Video',
--                  'web', 'Online Deliverable',
--                  NULL, 'Print',
--                  p.media_type
--                 ) AS strproductmediatype,
(CASE WHEN dbo.WK_getSubTitles(b.bookkey, 1) IS NULL THEN ''
	 ELSE SUBSTRING(dbo.WK_getSubTitles(b.bookkey, 1), 1, 250) END) AS strproductsubtitle,
--          DECODE (cp.subtitle1,
--                  NULL, ' ',
--                  SUBSTR (cp.subtitle1, 1, 250)
--                 ) AS strproductsubtitle,
(CASE WHEN [dbo].[rpt_get_best_pub_date](b.bookkey, 1) = '' THEN NULL
     ELSE [dbo].[rpt_get_best_pub_date](b.bookkey, 1) END) as dtproductpublicationdate,
--          TRUNC (p.publication_date) dtproductpublicationdate,
(CASE WHEN dbo.WK_getSubTitles(b.bookkey, 2) IS NULL OR dbo.WK_getSubTitles(b.bookkey, 2) = ''  THEN ''
      ELSE SUBSTRING(dbo.WK_getSubTitles(b.bookkey, 2), 1, 250) END) as strproductsubtitle2,
--(CASE WHEN dbo.WK_getSubTitles(b.bookkey, 2) IS NOT NULL AND dbo.WK_getSubTitles(b.bookkey, 2) <> '' 
--           AND standard_number_description IS NOT NULL AND standard_number_description <> '' THEN 
--		SUBSTRING(dbo.WK_getSubTitles(b.bookkey, 2), 1, 250) + ', ' + standard_number_description
--      WHEN standard_number_description IS NULL OR standard_number_description = '' THEN SUBSTRING(dbo.WK_getSubTitles(b.bookkey, 2), 1, 250)
--      WHEN dbo.WK_getSubTitles(b.bookkey, 2) IS NULL OR dbo.WK_getSubTitles(b.bookkey, 2) = '' THEN standard_number_description
--	  ELSE '' END) as strproductsubtitle2,
--		DECODE
--               (cp.subtitle2,
--                NULL, p.standard_number_description,
--                ' ', p.standard_number_description,
--                DECODE (p.standard_number_description,
--                        NULL, SUBSTR (cp.subtitle2, 1, 250),
--                           SUBSTR (cp.subtitle2, 1, 250)
--                        || ', '
--                        || p.standard_number_description
--                       )
--               ) AS strproductsubtitle2,
(Case WHEN [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) IS NULL OR [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) = ''
	 THEN LOWER(dbo.rpt_get_isbn(b.bookkey, 16)) + ' ' + LOWER(dbo.rpt_get_title(b.bookkey, 'F')) + ' ' + LOWER([dbo].[rpt_get_book_comment](b.bookkey, 3, 7, 3))
     ELSE LOWER(dbo.rpt_get_isbn(b.bookkey, 16)) + ' ' + LOWER(dbo.rpt_get_title(b.bookkey, 'F')) + ' ' + LOWER([dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3))
	 END) as strproductabstractsearch,

--          DECODE
--             (d.html_long_description,
--              NULL, LOWER (REPLACE (p.standard_number, '-', ''))
--               || ' '
--               || LOWER (cp.title)
--               || ' '
--               || LOWER (cleanolstext (d.short_description)),
--                 LOWER (REPLACE (p.standard_number, '-', ''))
--              || ' '
--              || LOWER (cp.title)
--              || ' '
--              || LOWER (cleanolstext (d.html_long_description))
--             ) AS strproductabstractsearch,
NULL as strproductinventorystatus, -- p.inventory_status strproductinventorystatus,
(Case WHEN [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) IS NULL OR [dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3) = ''
	 THEN REPLACE([dbo].[rpt_get_book_comment](b.bookkey, 3, 7, 3), '"', '///Thirty-Fourth')
     ELSE REPLACE([dbo].[rpt_get_book_comment](b.bookkey, 3, 8, 3), '"', '///Thirty-Fourth')
	 END) AS clbproductabstract,
--
--          DECODE (d.html_long_description,
--                  NULL, REPLACE (d.short_description, '"', '///Thirty-Fourth'),
--                  REPLACE (d.html_long_description, '"', '///Thirty-Fourth')
--                 ) AS clbproductabstract,
bd.volumenumber as intproductvolume, -- SUBSTR (p.volume, 1, 2) intproductvolume,
(CASE WHEN [dbo].[rpt_get_best_page_count](b.bookkey, 1) IS NULL OR [dbo].[rpt_get_best_page_count](b.bookkey, 1) = '' OR [dbo].[rpt_get_best_page_count](b.bookkey, 1) = 0 THEN NULL
     ELSE [dbo].[rpt_get_best_page_count](b.bookkey, 1) END) AS intproductpagecount,
--          DECODE (p.page_count,
--                  0, NULL,
--                  p.page_count
--                 ) AS intproductpagecount,
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 10, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 10, 'long') END) as intproducttableilluscount,
--
--          DECODE (cp.total_illustration_count,
--                  0, NULL,
--                  cp.total_illustration_count
--                 ) AS intproducttableilluscount,
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 31, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 31, 'long') END) as intproductfourcolorilluscount, --cp.four_color_count intproductfourcolorilluscount,
          
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 32, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 32, 'long') END) as intproducttwocolorilluscount, --cp.two_color_count intproducttwocolorilluscount,
          
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 33, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 33, 'long') END) as intproductanimlength,

(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 34, 'long') = 'Yes' THEN 1
      ELSE 0 END) as intproductsoundlength, -- p.has_sound intproductsoundlength,

(CASE [dbo].[rpt_get_misc_value](b.bookkey, 35, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 35, 'long') END) as intproductvideolength, --p.video_length intproductvideolength,
 


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
      
--			DECODE
--                (p.binding_type,
--                 NULL, ' ',
--                 'hard', 'Hardbound',
--                 'soft', 'Softbound',
--                 'flexible', 'Flexible Binding',
--                 'comb', 'Combbound',
--                 'spiral', 'Spiralbound',
--                 'spiralGatefold', 'Spiralbound with Gatefold',
--                 'perfect', 'Perfectbound',
--                 'looseleafPages', 'Looseleaf Pages',
--                 'looseleafBinder', 'Looseleaf with Binder',
--                 'threeRingBinder', 'Three Ring Binder',
--                 'cardDeck', 'Card Deck',
--                 'cardDeckRings', 'Card Deck with Hinge Metal Rings',
--                 'laminated', 'Laminated',
--                 'plasticStyrene', 'Plastic Styrene',
--                 'shrinkWrappedIndiv', 'Shrink Wrapped Invidual',
--                 'shrinkWrappedLaminated', 'Shrink Wrapped Laminated',
--                 'shrinkWrappedTabs', 'Shrink Wrapped Tabs',
--                 p.binding_type
--                ) AS strproductbindingtype,
'ps.MEDIA_FORMAT' strproductformattype, 
0 AS intproductversion,
(CASE WHEN bd.editionnumber IS NOT NULL and bd.editionnumber <> '' AND bd.editionnumber > 1 and bd.editionnumber < 101 THEN dbo.rpt_get_gentables_field(557, bd.editionnumber, '1')
ELSE bd.editiondescription END) as strproductedition,

--          DECODE (cp.edition_number,
--                  2, 'Second',
--                  3, 'Third',
--                  4, 'Fourth',
--                  5, 'Fifth',
--                  6, 'Sixth',
--                  7, 'Seventh',
--                  8, 'Eighth',
--                  9, 'Ninth',
--                  10, 'Tenth',
--                  11, 'Eleventh',
--                  12, 'Twelfth',
--                  13, 'Thirteenth',
--                  14, 'Fourteenth',
--                  15, 'Fifteenth',
--                  16, 'Sixteenth',
--                  17, 'Seventeenth',
--                  18, 'Eighteenth',
--                  19, 'Nineteenth',
--                  20, 'Twentieth',
--                  21, 'Twenty-First',
--                  22, 'Twenty-Second',
--                  23, 'Twenty-Third',
--                  24, 'Twenty-Fourth',
--                  25, 'Twenty-Fifth',
--                  26, 'Twenty-Sixth',
--                  27, 'Twenty-Seventh',
--                  28, 'Twenty-Eighth',
--                  29, 'Twenty-Ninth',
--                  30, 'Thirtieth',
--                  31, 'Thirty-First',
--                  32, 'Thirty-Second',
--                  33, 'Thirty-Third',
--                  34, 'Thirty-Fourth',
--                  35, 'Thirty-Fifth',
--                  36, 'Thirty-Sixth',
--                  37, 'Thirty-Seventh',
--                  38, 'Thirty-Eighth',
--                  39, 'Thirty-Ninth',
--                  40, 'Fortieth',
--                  41, 'Forty-First',
--                  42, 'Forty-Second',
--                  43, 'Forty-Third',
--                  44, 'Forty-Fourth',
--                  45, 'Forty-Fifth',
--                  46, 'Forty-Sixth',
--                  47, 'Forty-Seventh',
--                  48, 'Forty-Eighth',
--                  49, 'Forty-Ninth',
--                  50, 'Fiftieth',
--                  51, 'Fifty-First',
--                  52, 'Fifty-Second',
--                  53, 'Fifty-Third',
--                  54, 'Fifty-Fourth',
--                  55, 'Fifty-Fifth',
--                  56, 'Fifty-Sixth',
--                  57, 'Fifty-Seventh',
--                  58, 'Fifty-Eighth',
--                  59, 'Fifty-Ninth',
--                  60, 'Sixtieth',
--                  61, 'Sixty-First',
--                  62, 'Sixty-Second',
--                  63, 'Sixty-Third',
--                  64, 'Sixty-Fourth',
--                  65, 'Sixty-Fifth',
--                  66, 'Sixty-Sixth',
--                  67, 'Sixty-Seventh',
--                  68, 'Sixty-Eighth',
--                  69, 'Sixty-Ninth',
--                  70, 'Seventieth',
--                  71, 'Seventy-First',
--                  72, 'Seventy-Second',
--                  73, 'Seventy-Third',
--                  74, 'Seventy-Fourth',
--                  75, 'Seventy-Fifth',
--                  76, 'Seventy-Sixth',
--                  77, 'Seventy-Seventh',
--                  78, 'Seventy-Eighth',
--                  79, 'Seventy-Ninth',
--                  80, 'Eightieth',
--                  81, 'Eighty-First',
--                  82, 'Eighty-Second',
--                  83, 'Eighty-Third',
--                  84, 'Eighty-Fourth',
--                  85, 'Eighty-Fifth',
--                  86, 'Eighty-Sixth',
--                  87, 'Eighty-Seventh',
--                  88, 'Eighty-Eighth',
--                  89, 'Eighty-Ninth',
--                  90, 'Ninetieth',
--                  91, 'Ninety-First',
--                  92, 'Ninety-Second',
--                  93, 'Ninety-Third',
--                  94, 'Ninety-Fourth',
--                  95, 'Ninety-Fifth',
--                  96, 'Ninety-Sixth',
--                  97, 'Ninety-Seventh',
--                  98, 'Ninety-Eighth',
--                  99, 'Ninety-Ninth',
--                  100, 'One Hundredth',
--                  cp.edition_type
--                 ) AS strproductedition,
NULL strproductcomboinclusion, 
NULL strproductweight,
          'graphic_name' strproductgraphicfilename,
          'graphic_location' strproductgraphiclink,
          NULL intproductjournalissuenumber,
          NULL intproductjournalvolumenumber, 
		  NULL strproductjournalissuetext,
[dbo].[rpt_get_misc_value](b.bookkey, 25, 'long') as  strproductpublishingfrequency,   --         p.publication_frequency strproductpublishingfrequency,
          NULL dtproductcopyrightyear, 
		  NULL strproductcontactname,
          NULL strproductcontactphone, 
          NULL strproductcontactemail,
          NULL strproductcontactfax, 

(CASE [dbo].[rpt_get_misc_value](b.bookkey, 41, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 41, 'long') END) as strproductcontactinfo, --p.media_length strproductmedialength,

(CASE [dbo].[rpt_get_misc_value](b.bookkey, 36, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 36, 'long') END) as strmedialength, --p.media_length strproductmedialength,

(CASE [dbo].[rpt_get_misc_value](b.bookkey, 37, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 37, 'long') END)  as strvolumesettype, --p.volume_set_type strvolumesettype,



(Select TOP 1 dbo.rpt_get_sub2gentables_field(bsc.categorytableid, bsc.categorycode, bsc.categorysubcode, bsc.categorysub2code, 'S') 
from booksubjectcategory bsc where bsc.bookkey = b.bookkey and bsc.categorytableid = 412 
and categorysub2code IS NOT NULL AND categorysub2code <> 0
ORDER BY bsc.sortorder) as strsaccode, --p.code_value strsaccode,
          
(Select TOP 1 dbo.rpt_get_subgentables_field(bsc.categorytableid, bsc.categorycode, bsc.categorysubcode, 'S') 
from booksubjectcategory bsc where bsc.bookkey = b.bookkey and bsc.categorytableid = 412 
and categorysub2code IS NOT NULL AND categorysub2code <> 0
ORDER BY bsc.sortorder) as strsacsum, --p.sac_sum strsacsum,
(CASE bd.languagecode2 
   WHEN NULL THEN ''
   WHEN '' THEN ''
   ELSE [dbo].[rpt_get_gentables_field] (318, bd.languagecode2, 'D') end) as STRORIGINALLANGUAGE, -- p.ORIGINAL_LANGUAGE STRORIGINALLANGUAGE,
 
[dbo].[rpt_get_book_comment](b.bookkey, 3, 57, 3) as STRFEATURETEXT,
[dbo].[rpt_get_gentables_field](314, bd.bisacstatuscode, 'E') as STRPUBLICATIONSTATUS,
(CASE [dbo].[rpt_get_misc_value](b.bookkey, 10, 'long') 
      WHEN NULL THEN NULL
	  WHEN '' THEN NULL
      WHEN 0 THEN NULL
      ELSE [dbo].[rpt_get_misc_value](b.bookkey, 7, 'long') END) as INTQUANTITYAVAILABLE


from book b
join bookdetail bd
on b.bookkey = bd.bookkey
WHERE dbo.WK_IsEligibleforLWW(b.bookkey) = 'Y'


END
