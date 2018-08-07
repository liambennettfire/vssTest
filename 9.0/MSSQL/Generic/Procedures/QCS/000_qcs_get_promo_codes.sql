IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_promo_codes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_promo_codes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Derek Kurth
-- Create date: May 2015
-- Description:	Get all promo codes for a given promo taqprojectkey.
-- =============================================
CREATE PROCEDURE [dbo].[qcs_get_promo_codes] @promokey INT
AS
BEGIN

	DECLARE @maxAmtMisckey INT;
	DECLARE @maxUseMisckey INT;
	DECLARE @discountPercentMisckey INT;
	DECLARE @discountAmountMisckey INT;
	
	EXEC @maxAmtMisckey = qutl_get_misckey 27, null, null -- get the misckey that goes with qsicode 27, for MaxDiscountAmount
	EXEC @maxUseMisckey = qutl_get_misckey 22, null, null -- for MaxTimesAllowed
	EXEC @discountPercentMisckey = qutl_get_misckey 24, null, null -- for DiscountPercent
	EXEC @discountAmountMisckey = qutl_get_misckey 23, null, null -- for DiscountAmount

	SELECT
		p.taqprojectkey AS ReferenceId
		,(CASE WHEN (SELECT eloquencefieldtag FROM gentables WHERE tableid = 594 AND datacode = pn.productidcode) = 'CLD_PC_PROMO_CODE_ID' THEN pn.productnumber ELSE null END) AS Code
		,p.taqprojecttitle AS Description
		,g2.eloquencefieldtag AS PromoCodeType
		,(SELECT t.activedate FROM taqprojecttask t JOIN datetype dt ON t.datetypecode = dt.datetypecode WHERE t.taqprojectkey = p.taqprojectkey AND eloquencefieldtag = 'CLD_PC_EFF_DT') AS EffectiveDate
		,(SELECT t.activedate FROM taqprojecttask t JOIN datetype dt ON t.datetypecode = dt.datetypecode WHERE t.taqprojectkey = p.taqprojectkey AND eloquencefieldtag = 'CLD_PC_EXP_DT') AS ExpirationDate
		,m.floatvalue AS MaxDiscountAmount
		,m2.floatvalue AS MaxTimesAllowed
		,m3.floatvalue AS DiscountPercent
		,m4.floatvalue AS DiscountAmount
		,(CASE WHEN (SELECT eloquencefieldtag FROM gentables WHERE tableid = 522 AND datacode = g.datacode) = 'CLD_PC_ACTIVE' THEN 0 ELSE 1 end) AS Inactive
	from 
		subgentables sg
		JOIN taqproject p ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode
		LEFT OUTER JOIN taqprojectmisc m ON m.taqprojectkey = p.taqprojectkey AND m.misckey = @maxAmtMisckey
		LEFT OUTER JOIN taqprojectmisc m2 ON m2.taqprojectkey = p.taqprojectkey AND m2.misckey = @maxUseMisckey
		LEFT OUTER JOIN taqprojectmisc m3 ON m3.taqprojectkey = p.taqprojectkey AND m3.misckey = @discountPercentMisckey
		LEFT OUTER JOIN taqprojectmisc m4 ON m4.taqprojectkey = p.taqprojectkey AND m4.misckey = @discountAmountMisckey
		JOIN gentables g ON g.datacode = p.taqprojectstatuscode
		JOIN taqproductnumbers pn ON p.taqprojectkey = pn.taqprojectkey
		JOIN projectrelationshipview rel ON p.taqprojectkey = rel.relatedprojectkey
		JOIN gentables g2 ON g2.datacode = p.taqprojecttype
	WHERE
		g.tableid = 550
		AND sg.eloquencefieldtag = 'CLD_PC_PROMOCODE'
		AND rel.relationshipcode in (SELECT datacode FROM gentables WHERE tableid = 582 AND eloquencefieldtag = 'CLD_PC_PROMO_CODE_REL')
		AND g2.tableid = 521
		AND rel.taqprojectkey = @promokey
END
GO
GRANT EXEC ON qcs_get_promo_codes TO PUBLIC
GO