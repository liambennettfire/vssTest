IF EXISTS (SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID(N'[dbo].[lw_edh_generate_product_xml]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[lw_edh_generate_product_xml]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[lw_edh_generate_product_xml] (@i_bookkey int, @x_payload XML OUTPUT)
as
/** Revision History  **/
/** Created by BDT 2015-07-09  ***/

/** SP delivers the EDH XML payload for a given bookkey */

--select * from isbn where itemnumber = '005588856'

--declare @i_bookkey int
--declare @x_payload xml
--set @i_bookkey = 8515757

exec lw_edh_misc_fields_pivot

DECLARE @sqlquery NVARCHAR(MAX)

SELECT
	@sqlquery = 'ALTER view [dbo].[SWAG_LR_EDH]
AS

/* ALTER THIS VIEW IN sp lw_edh_generate_product_xml */

Select  
nullif(ISNULL(i.ean13,''''),'''') as ean13,
nullif(ISNULL(i.gtin14,''''),'''') as gtin14,
nullif(ISNULL(i.isbn10,''''),'''') as isbn10,
nullif(i.upc,'''') as upc,
nullif(isnull(i.itemnumber,''''),'''') as lifewayItemNumber,
CASE WHEN 
ISNULL(dbo.rpt_get_title(c.bookkey, ''P''),'''') = '''' THEN NULL ELSE
dbo.rpt_get_title(c.bookkey, ''P'') END
 as titlePrefix,
dbo.rpt_get_title(c.bookkey, ''T'') as titleWithoutPrefix,
dbo.rpt_get_title(c.bookkey, ''F'') as title,
dbo.rpt_get_short_title(c.bookkey) as shortTitle,
nullif(isnull(dbo.rpt_bhp_get_title(c.bookkey,''X''),''''),'''') as translatedTitle,
CASE WHEN ISNULL(dbo.rpt_get_misc_value(c.bookkey,287,''long''),'''') <> '''' THEN dbo.rpt_get_misc_value(c.bookkey,287,''long'')
ELSE
UPPER(convert(varchar(150),LEFT(dbo.rpt_bhp_get_title(c.bookkey,''O''),150) collate Cyrillic_General_CI_AI))
END as oracleLongDescrip,
CASE WHEN ISNULL(c.subtitle,'''') = '''' THEN NULL ELSE
dbo.rpt_get_sub_title(c.bookkey) END as subtitle,
s.*,
isnull(dbo.rpt_get_page_count(c.bookkey,1,''E''),''0'') as pageCountEstimate,
nullif(dbo.rpt_get_page_count(c.bookkey,1,''A''),'''') as pageCountActual,
nullif(dbo.rpt_get_carton_qty(c.bookkey,1),'''') as cartonQuantity,
NullIf(left(dbo.rpt_get_uom(c.bookkey, ''T'', ''S''),2),'''') as lengthUOM,
NullIf(dbo.[rpt_lr_get_trim_properties_with_decimals](c.bookkey,1,''E'',''H'',3),'''') as lengthEstimate,
NullIf(dbo.[rpt_lr_get_trim_properties_with_decimals](c.bookkey,1,''A'',''H'',3),'''') as lengthActual,
NullIf(left(dbo.rpt_get_uom(c.bookkey, ''T'', ''S''),2),'''') as widthUOM,
NullIf(dbo.[rpt_lr_get_trim_properties_with_decimals](c.bookkey,1,''E'',''W'',3),'''') as widthEstimate,
NullIf(dbo.[rpt_lr_get_trim_properties_with_decimals](c.bookkey,1,''A'',''W'',3),'''') as widthActual,
NullIf(left(dbo.rpt_get_uom(c.bookkey, ''S'', ''S''),2),'''') as depthUOM,
NullIf(dbo.[rpt_lr_get_trim_properties_with_decimals](c.bookkey,1,''A'',''D'',3),'''') as depthActual,
NullIf(left(dbo.rpt_get_uom(c.bookkey, ''B'', ''S''),2),'''') as weightUOM,
NullIf(dbo.rpt_get_bookweight(c.bookkey,1),'''') as weightActual,
nullif(dbo.rpt_bhp_get_age_range_detail(c.bookkey,''H''),'''') as audienceAgeMaximum,
nullif(dbo.rpt_bhp_get_age_range_detail(c.bookkey,''L''),'''') as audienceAgeMinimum,
nullif(dbo.rpt_bhp_get_grade_range_detail(c.bookkey,''H''),'''') as audienceGradeMaximum,
nullif(dbo.rpt_bhp_get_grade_range_detail(c.bookkey,''L''),'''') as audienceGradeMinimum,
nullif(dbo.rpt_lr_get_cogs_acct(c.bookkey),'''') as accountingCOGSAcct,
nullif(dbo.rpt_lr_get_sales_acct(c.bookkey),'''') as accountingSalesAcct

from coretitleinfo c join isbn i on c.bookkey = i.bookkey
left outer join swag_misc_fields_pivot s on c.bookkey = s.pimKey'

EXECUTE sp_executesql @sqlquery

SELECT
	@x_payload = (SELECT
		t.*,
		(SELECT
			xr.crossReference
		FROM SWAG_misc_fields_pivot_xr xr
		WHERE t.pimKey = xr.pimKey
		FOR XML PATH (''), TYPE),
		--s.*,
		--Series
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.seriescode = sggv.datacode
			AND sggv.tableid = 327
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('series'), TYPE),

		--Edition
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.editioncode = sggv.datacode
			AND sggv.tableid = 200
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('editionType'), TYPE),

		--Edition Number
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.editioncode = sggv.datacode
			AND sggv.tableid = 557
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('editionNumber'), TYPE),

		--Additional Edition Information
		(SELECT
			editiondescription
		FROM bookdetail p
		WHERE t.pimKey = p.bookkey)
		AS additionalEditionDescription,

		--BISAC Status
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.bisacstatuscode = sggv.datacode
			AND sggv.tableid = 314
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('bisacStatus'), TYPE),

		--Product Availability
		(SELECT
			CAST(p.bisacstatuscode AS VARCHAR(5)) + '-' + CAST(p.prodavailability AS VARCHAR(5)) AS pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2
		FROM bookdetail p
		JOIN SWAG_get_subgentables_view sggv
			ON p.prodavailability = sggv.datasubcode
			AND sggv.tableid = 314
			AND p.bisacstatuscode = sggv.datacode
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('productAvailability'), TYPE),

		--Internal Title Status
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.bisacstatuscode = sggv.datacode
			AND sggv.tableid = 149
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('internalTitleStatus'), TYPE),

		--Organization
		(SELECT
			o.orgentrykey AS pimID,
			o.orgentrydesc AS valueDescription,
			o.orgentryshortdesc AS valueDescriptionShort,
			o.altdesc1 AS alternatedesc1,
			o.altdesc2 AS alternatedesc2

		FROM bookorgentry bo
		JOIN orgentry o
			ON o.orgentrykey = bo.orgentrykey
			AND bo.orglevelkey = 1
		WHERE t.pimKey = bo.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('organization'), TYPE),

		--Publisher
		(SELECT
			o.orgentrykey AS pimID,
			o.orgentrydesc AS valueDescription,
			o.orgentryshortdesc AS valueDescriptionShort,
			o.altdesc1 AS alternatedesc1,
			o.altdesc2 AS alternatedesc2

		FROM bookorgentry bo
		JOIN orgentry o
			ON o.orgentrykey = bo.orgentrykey
			AND bo.orglevelkey = 2
		WHERE t.pimKey = bo.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('publisher'), TYPE),

		--Imprint
		(SELECT
			o.orgentrykey AS pimID,
			o.orgentrydesc AS valueDescription,
			o.orgentryshortdesc AS valueDescriptionShort,
			o.altdesc1 AS alternatedesc1,
			o.altdesc2 AS alternatedesc2

		FROM bookorgentry bo
		JOIN orgentry o
			ON o.orgentrykey = bo.orgentrykey
			AND bo.orglevelkey = 3
		WHERE t.pimKey = bo.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('imprint'), TYPE),

		--Season Est
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM printing p
		JOIN SWAG_get_gentables_view sggv
			ON p.estseasonkey = sggv.datacode
			AND sggv.tableid = 329
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('seasonEst'), TYPE),

		--Season Act
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternateDesc1,
			sggv.alternateDesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM printing p
		JOIN SWAG_get_gentables_view sggv
			ON p.seasonkey = sggv.datacode
			AND sggv.tableid = 329
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('seasonAct'), TYPE),


		--Discount
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.discountcode = sggv.datacode
			AND sggv.tableid = 459
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('discountGroup'), TYPE),

		--Price
		(SELECT
			bp.pricekey AS pimID,
			gt.alternatedesc2 AS priceType,
			gt.externalcode AS priceList,
			CASE
				WHEN bp.activeind = 1 THEN 'true'
				ELSE 'false'
			END AS isActive,
			gt2.externalcode AS currency,
			CONVERT(VARCHAR(50), CONVERT(MONEY, bp.budgetprice, 2)) AS priceBudget,
			CONVERT(VARCHAR(50), CONVERT(MONEY, bp.finalprice, 2)) AS priceFinal,
			CONVERT(VARCHAR(50), CONVERT(MONEY, NULLIF(CASE
				WHEN ISNULL(bp.finalprice, 0) <> 0 THEN bp.finalprice
				ELSE NULLIF(bp.budgetprice, 0)
			END, 0), 0)) AS priceBest,
			dbo.lw_Date_CentralTimeOffset(bp.effectivedate) AS effectivedate,
			dbo.lw_Date_CentralTimeOffset(bp.expirationdate) AS expirationdate

		FROM bookprice bp
		JOIN gentables gt
			ON bp.pricetypecode = gt.datacode
			AND gt.tableid = 306
		JOIN gentables gt2
			ON bp.currencytypecode = gt2.datacode
			AND gt2.tableid = 122 --and bp.pricetypecode = 8
		WHERE bp.bookkey = t.pimKey
		AND (bp.activeind = 1 --or bp.effectivedate > (select effectivedate from bookprice where activeind = 1 and bookkey = bp.bookkey)
		OR bp.effectivedate > GETDATE())

		FOR XML PATH ('price'), TYPE),

		--select * from bookprice

		--select * from bookprice bp
		--WHERE (bp.activeind = 1 or bp.effectivedate > (select effectivedate from bookprice where activeind = 1 and bookkey = bp.bookkey))
		--and bp.bookkey = 22159572

		--select * from gentables where tableid=306
		--update gentables set externalcode='Standard' where tableid=306 and datacode=8


		--Return
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.returncode = sggv.datacode
			AND sggv.tableid = 319
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('returnable'), TYPE),

		--Return Restrictions
		(SELECT
			sggv.pimID,
			sggv.valueDescription,
			sggv.valueDescriptionShort,
			sggv.externalCode1,
			sggv.externalCode2,
			sggv.externalCode3,
			sggv.alternatedesc1,
			sggv.alternatedesc2,
			sggv.numericdesc1,
			sggv.numericdesc2,
			sggv.genText1,
			sggv.genText2,
			sggv.genText3,
			sggv.genText4
		FROM bookdetail p
		JOIN SWAG_get_gentables_view sggv
			ON p.restrictioncode = sggv.datacode
			AND sggv.tableid = 320
		WHERE t.pimKey = p.bookkey
		FOR XML PATH ('pimAttrValueData'), ROOT ('returnRestrictions'), TYPE),

		--Media
		(SELECT
			'mediaFormat' AS name,
			--nullif(dbo.rpt_bhp_get_product_form_and_detail_codes(book.bookkey,'1'),'') as form,
			--nullif(dbo.rpt_bhp_get_product_form_and_detail_codes(book.bookkey,'2'),'') as formDetail,
			--nullif(dbo.rpt_bhp_get_product_form_and_detail_codes(book.bookkey,'3'),'') as formDetail,
			--nullif(dbo.rpt_bhp_get_product_form_and_detail_codes(book.bookkey,'4'),'') as formDetail,
			--nullif(dbo.rpt_bhp_get_product_form_and_detail_codes(book.bookkey,'5'),'') as formDetail,
			--nullif(dbo.rpt_bhp_get_product_form_and_detail_codes(book.bookkey,'6'),'') as formDetail,		
			(SELECT
				'1' AS level,
				(SELECT
					sggv.pimID,
					sggv.valueDescription,
					sggv.valueDescriptionShort,
					sggv.externalCode1,
					sggv.externalCode2,
					sggv.externalCode3,
					sggv.alternatedesc1,
					sggv.alternatedesc2,
					sggv.numericdesc1,
					sggv.numericdesc2,
					sggv.genText1,
					sggv.genText2,
					sggv.genText3,
					sggv.genText4
				--from bookdetail p join SWAG_get_gentables_view sggv on p.mediatypecode = sggv.datacode and sggv.tableid = 312
				--where t.pimkey = p.bookkey
				FOR XML PATH ('pimAttrValueData'), TYPE)

			FROM bookdetail p
			JOIN SWAG_get_gentables_view sggv
				ON p.mediatypecode = sggv.datacode
				AND sggv.tableid = 312
			WHERE t.pimKey = p.bookkey

			FOR XML PATH ('value'), TYPE),

			--Format
			(SELECT
				'2' AS level,
				(SELECT
					pimID AS pimID,
					sggv.valueDescription,
					sggv.valueDescriptionShort,
					sggv.externalCode1,
					sggv.alternatedesc1,
					sggv.alternatedesc2,
					sggv.numericdesc1,
					sggv.numericdesc2,
					sggv.genText1,
					sggv.genText2
				--from bookdetail p join SWAG_get_subgentables_view sggv 
				--on p.mediatypesubcode = sggv.datasubcode and sggv.tableid = 312 and p.mediatypecode = sggv.datacode
				--where t.pimkey = p.bookkey
				FOR XML PATH ('pimAttrValueData'), TYPE)

			FROM bookdetail p
			JOIN SWAG_get_subgentables_view sggv
				ON p.mediatypesubcode = sggv.datasubcode
				AND sggv.tableid = 312
				AND p.mediatypecode = sggv.datacode
			WHERE t.pimKey = p.bookkey

			FOR XML PATH ('value'), TYPE)

		FOR XML PATH ('taxonomy'), TYPE),

		--Dates where ExternalID is not null or blank
		(SELECT
			dt.externalcode AS name,
			CASE
				WHEN tpt.actualind = 1 THEN 'true'
				ELSE 'false'
			END AS isActual,
			dbo.lw_Date_CentralTimeOffset(tpt.activedate) AS activedate,
			dbo.lw_Date_CentralTimeOffset(tpt.reviseddate) AS reviseddate,
			dbo.lw_Date_CentralTimeOffset(tpt.originaldate) AS originaldate

		FROM taqprojecttask tpt
		JOIN datetype dt
			ON tpt.datetypecode = dt.datetypecode
		WHERE tpt.bookkey = t.pimKey
		AND dt.datetypecode <> 445
		AND ISNULL(dt.externalcode, '') <> ''
		FOR XML PATH ('taskDate'), TYPE),

		--Language
		(SELECT
			dbo.rpt_lr_edh_get_language_xml(t.pimKey, '1')),
		(SELECT
			dbo.rpt_lr_edh_get_language_xml(t.pimKey, '2')),
		--(
		--	select 
		--	case when isnull(bd.languagecode,0) <> 0 then '1' else '' end as sequence,
		--	(select 
		--	sggv.pimID,
		--	sggv.valueDescription,
		--	sggv.valueDescriptionShort,
		--	sggv.externalCode1,
		--	sggv.externalCode2,
		--	sggv.externalCode3,
		--	sggv.alternateDesc1,
		--	sggv.alternateDesc2,
		--	sggv.numericDesc1,
		--	sggv.numericDesc2,
		--	sggv.genText1,
		--	sggv.genText2,
		--	sggv.genText3,
		--	sggv.genText4
		--	from SWAG_get_gentables_view sggv
		--	where bd.languagecode = sggv.datacode and sggv.tableid = 318
		--	FOR XML PATH ('pimAttrValueData'), TYPE)


		--from bookdetail bd where t.pimkey = bd.bookkey
		--FOR XML PATH ('language'), TYPE),

		----Language 2
		--(
		--select 
		--	case when isnull(bd.languagecode,0) <> 0 then '2' else '' end as sequence,
		--	(select 
		--	sggv.pimID,
		--	sggv.valueDescription,
		--	sggv.valueDescriptionShort,
		--	sggv.externalCode1,
		--	sggv.externalCode2,
		--	sggv.externalCode3,
		--	sggv.alternateDesc1,
		--	sggv.alternateDesc2,
		--	sggv.numericDesc1,
		--	sggv.numericDesc2,
		--	sggv.genText1,
		--	sggv.genText2,
		--	sggv.genText3,
		--	sggv.genText4
		--	from SWAG_get_gentables_view sggv
		--	where bd.languagecode2 = sggv.datacode and sggv.tableid = 318
		--	FOR XML PATH ('pimAttrValueData'), TYPE)


		--from bookdetail bd where t.pimkey = bd.bookkey
		--FOR XML PATH ('language'), TYPE),

		--Contributors
		(SELECT
			bcv.sortorder AS sequence,
			CASE
				WHEN bcv.primaryind = 'Y' THEN 'true'
				ELSE 'false'
			END AS isPrimary,
			(SELECT
				scv.*,
				(SELECT
					cm.externalcode AS name,
					datadesc AS type,
					NULLIF(contactmethodvalue, '') AS value
				FROM globalcontactmethod g
				JOIN (SELECT
					*
				FROM subgentables
				WHERE tableid = 517) cm
					ON datacode = contactmethodcode
					AND datasubcode = contactmethodsubcode
				WHERE LEFT(cm.externalcode, 2) = 'xr'
				AND globalcontactkey = bcv.contributorkey
				FOR XML PATH ('crossReference'), TYPE)
			FROM SWAG_Contact_View scv
			WHERE bcv.contributorkey = scv.pimID
			FOR XML PATH ('party'), TYPE),
			(SELECT
				sggv.pimID,
				sggv.valueDescription,
				sggv.valueDescriptionShort,
				sggv.externalCode1,
				sggv.externalCode2,
				sggv.externalCode3,
				sggv.alternatedesc1,
				sggv.alternatedesc2,
				sggv.numericdesc1,
				sggv.numericdesc2,
				sggv.genText1,
				sggv.genText2,
				sggv.genText3,
				sggv.genText4
			FROM SWAG_get_gentables_view sggv
			WHERE bcv.roletypecode = sggv.datacode
			AND sggv.tableid = 134
			FOR XML PATH ('pimAttrValueData'), ROOT ('role'), TYPE)



		FROM rpt_bhp_bookcontributor_view bcv
		WHERE t.pimKey = bcv.bookkey
		ORDER BY bcv.sortorder
		FOR XML PATH ('contributor'), TYPE),

		--Participants
		(SELECT
			bpv.sortorder AS sequence,
			CASE
				WHEN bpv.keyind = 1 THEN 'true'
				ELSE 'false'
			END AS isKey,
			(SELECT
				scv.*,
				(SELECT
					cm.externalcode AS name,
					datadesc AS type,
					NULLIF(contactmethodvalue, '') AS value
				FROM globalcontactmethod g
				JOIN (SELECT
					*
				FROM subgentables
				WHERE tableid = 517) cm
					ON datacode = contactmethodcode
					AND datasubcode = contactmethodsubcode
				WHERE LEFT(cm.externalcode, 2) = 'xr'
				AND globalcontactkey = bpv.globalcontactkey
				FOR XML PATH ('crossReference'), TYPE)

			FROM SWAG_Contact_View scv
			WHERE bpv.globalcontactkey = scv.pimID
			FOR XML PATH ('party'), TYPE),
			(SELECT (SELECT
					sggv.pimID,
					sggv.valueDescription,
					sggv.valueDescriptionShort,
					sggv.externalCode1,
					sggv.externalCode2,
					sggv.externalCode3,
					sggv.alternatedesc1,
					sggv.alternatedesc2,
					sggv.numericdesc1,
					sggv.numericdesc2,
					sggv.genText1,
					sggv.genText2,
					sggv.genText3,
					sggv.genText4
				FROM SWAG_get_gentables_view sggv
				WHERE bcr.rolecode = sggv.datacode
				AND sggv.tableid = 285
				FOR XML PATH ('pimAttrValueData'), TYPE)
			FROM bookcontactrole bcr
			WHERE bcr.bookcontactkey = bpv.bookcontactkey
			ORDER BY bpv.sortorder
			FOR XML PATH ('role'), TYPE)




		FROM bookcontact bpv
		WHERE t.pimKey = bpv.bookkey
		ORDER BY bpv.sortorder
		FOR XML PATH ('participant'), TYPE),

		/*
		--Old Code for Misc Items
				--Misc Items where ExternalID is not null or blank
				(
				select 
					ltrim(rtrim(smf.miscname)),
					(SELECT 
					CASE 
					WHEN smf.misctype = 5 THEN --Gentables
					--CAST (
						(select 
						sgsv.pimId, 
						sgsv.valueDescription as valueDescription, 
						sgsv.valueDescriptionShort as valueDescriptionShort,
						sgsv.externalCode1 as externalCode1, 
						sgsv.alternateDesc1 as alternateDesc1, 
						sgsv.alternateDesc2 as alternateDesc2, 
						cast(sgsv.numericDesc1 as varchar(255)),
						cast(sgsv.numericDesc2 as varchar(255)), 
						sgsv.genText1, 
						sgsv.genText2 
						from swag_get_subgentables_view sgsv
						where smf.datacode = sgsv.datacode and bm.longvalue = sgsv.datasubcode and sgsv.tableid = 525
						FOR XML PATH ('pimAttrValueData'), TYPE) 
					--as varchar(max))
					
					WHEN smf.misctype = 3 THEN --Text
					CAST (isnull(bm.textvalue,'')
					as xml)
					
					WHEN smf.misctype = 4 THEN --Checkbox
					CAST (case when isnull(bm.longvalue,0) = 1 then 'true' else 'false' end
					as xml)	
							
					WHEN smf.misctype = 1 THEN --Numeric
					CAST (isnull(cast(bm.longvalue as varchar(255)),'')
					as xml)	
					
					WHEN smf.misctype = 2 THEN --Float
					CAST (isnull(cast(bm.floatvalue as varchar(255)),'')
					as xml)	
							
					ELSE cast('' as XML) END
					
					--select * from bookmiscitems
					--select * from bookmisc
					
					)
					--+
					--'</'+ltrim(rtrim(smf.miscname))+'>'
						
					FROM SWAG_misc_fields smf join bookmisc bm on bm.misckey = smf.misckey
					WHERE bm.bookkey = t.pimkey
					FOR XML PATH (''), TYPE),
		*/

		--BISAC Subject Categories
		(SELECT
			bisac.sortorder AS sequence,

			--BISAC SubCategory
			(SELECT
				CAST(bisac.bisaccategorycode AS VARCHAR(5)) + '-' + CAST(bisac.bisaccategorysubcode AS VARCHAR(5)) AS pimID,
				sgv.valueDescription + '/' + sggv.valueDescription AS valueDescription,
				sggv.valueDescriptionShort,
				sggv.externalCode1,
				sggv.alternatedesc1,
				sggv.alternatedesc2,
				sggv.numericdesc1,
				sggv.numericdesc2,
				sggv.bisacdatacode,
				sggv.genText1,
				sggv.genText2
			FROM SWAG_get_gentables_view sgv
			JOIN SWAG_get_subgentables_view sggv
				ON sgv.datacode = sggv.datacode
				AND sgv.tableid = sggv.tableid
			WHERE bisac.bisaccategorysubcode = sggv.datasubcode
			AND sggv.tableid = 339
			AND bisac.bisaccategorycode = sggv.datacode
			AND t.pimKey = bisac.bookkey
			FOR XML PATH ('pimAttrValueData'), ROOT ('value'), TYPE)

		FROM gentablesdesc gtd
		JOIN bookbisaccategory bisac
			ON gtd.tableid = 339
		WHERE bisac.bookkey = t.pimKey
		ORDER BY bisac.sortorder
		FOR XML PATH ('bisacSubject'), TYPE),

		--Categories
		(SELECT
			gtd.tabledesclong AS name,
			bsc.sortorder AS sequence,
			(SELECT
				CASE
					WHEN ISNULL(bsc.categorycode, 0) <> 0 THEN '1'
					ELSE NULL
				END AS level,
				(SELECT
					sggv.pimID,
					sggv.valueDescription,
					sggv.valueDescriptionShort,
					sggv.externalCode1,
					sggv.externalCode2,
					sggv.externalCode3,
					sggv.alternatedesc1,
					sggv.alternatedesc2,
					sggv.numericdesc1,
					sggv.numericdesc2,
					sggv.genText1,
					sggv.genText2,
					sggv.genText3,
					sggv.genText4
				FROM SWAG_get_gentables_view sggv
				WHERE bsc.categorycode = sggv.datacode
				AND sggv.tableid = bsc.categorytableid
				AND t.pimKey = bsc.bookkey
				FOR XML PATH ('pimAttrValueData'), TYPE)
			FOR XML PATH ('value'), TYPE),


			--SubCategory
			(SELECT
				CASE
					WHEN ISNULL(bsc.categorysubcode, 0) <> 0 THEN '2'
					ELSE NULL
				END AS level,
				(SELECT
					CAST(bsc.categorysubcode AS VARCHAR(5)) AS pimID,
					sggv.valueDescription,
					sggv.valueDescriptionShort,
					sggv.externalCode1,
					sggv.alternatedesc1,
					sggv.alternatedesc2,
					sggv.numericdesc1,
					sggv.numericdesc2,
					sggv.genText1,
					sggv.genText2
				FOR XML PATH ('pimAttrValueData'), TYPE)
			FROM SWAG_get_subgentables_view sggv
			WHERE bsc.categorysubcode = sggv.datasubcode
			AND sggv.tableid = bsc.categorytableid
			AND bsc.categorycode = sggv.datacode
			AND t.pimKey = bsc.bookkey
			FOR XML PATH ('value'), TYPE),

			--Sub2Category
			(SELECT
				CASE
					WHEN ISNULL(bsc.categorysub2code, 0) <> 0 THEN '3'
					ELSE NULL
				END AS level,
				(SELECT
					CAST(bsc.categorysub2code AS VARCHAR(5)) AS pimID,
					sggv.valueDescription,
					sggv.valueDescriptionShort,
					sggv.externalCode1,
					sggv.alternatedesc1,
					sggv.alternatedesc2,
					sggv.numericdesc1,
					sggv.numericdesc2,
					sggv.genText1,
					sggv.genText2
				FOR XML PATH ('pimAttrValueData'), TYPE)
			FROM SWAG_get_sub2gentables_view sggv
			WHERE bsc.categorysub2code = sggv.datasub2code
			AND sggv.tableid = bsc.categorytableid
			AND bsc.categorycode = sggv.datacode
			AND bsc.categorysubcode = sggv.datasubcode
			AND t.pimKey = bsc.bookkey
			FOR XML PATH ('value'), TYPE)

		FROM gentablesdesc gtd
		JOIN booksubjectcategory bsc
			ON gtd.tableid = bsc.categorytableid
		WHERE bsc.bookkey = t.pimKey
		FOR XML PATH ('taxonomy'), TYPE),

		--Book Comments where ExternalID is not null or blank
		(SELECT
			CAST(
			'<' + LTRIM(RTRIM(bkcmt.externalcode)) + '><![CDATA[' + ISNULL( REPLACE(  CAST(bc.commenthtmllite AS NVARCHAR(MAX) ), ':','/:')  , '') + ']]></' + LTRIM(RTRIM(bkcmt.externalcode)) + '>' AS XML)
		FROM subgentables bkcmt
		JOIN bookcomments bc
			ON bkcmt.datacode = bc.commenttypecode
			AND bkcmt.datasubcode = bc.commenttypesubcode
		WHERE bc.bookkey = t.pimKey
		AND bkcmt.tableid = 284
		AND ISNULL(bkcmt.externalcode, '') <> ''
		FOR XML PATH (''), TYPE)


	FROM SWAG_LR_EDH t
	--left outer join SWAG_misc_fields_pivot_xr xr on t.pimKey = xr.pimkey
	WHERE t.pimKey = book.bookkey
	FOR XML PATH ('product'), TYPE)


FROM book
--join SWAG_misc_fields_pivot s on book.bookkey = s.pimKey
WHERE standardind = 'N'
AND bookkey = @i_bookkey

AND bookkey IN (SELECT
	bookkey
FROM bookmisc bm
JOIN bookmiscitems bmi
	ON bm.misckey = bmi.misckey
	AND bmi.externalid = 'sendToOracleStatus'
JOIN subgentables s
	ON bmi.datacode = s.datacode
	AND s.tableid = 525
	AND bm.longvalue = s.datasubcode
	AND s.externalcode = 'A')

--select @x_payload
GO