IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_promo_code_products]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_promo_code_products]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Derek Kurth
-- Create date: May 2015
-- Description:	Get all products for a given promo code taqprojectkey.
-- =============================================
CREATE PROCEDURE [dbo].[qcs_get_promo_code_products] @promocodekey INT
AS
BEGIN
	SELECT
		isbn.cloudproductid AS ProductId
		,null AS DiscountPercent -- not used yet
		,pt.decimal1 AS DiscountAmount
		,0 AS Inactive -- On the Cloud side, if either the Promo or PromoCode is Inactive, the product will be Inactive.  Otherwise, it's active.
	FROM taqprojecttitle pt
	JOIN isbn ON pt.bookkey = isbn.bookkey
	WHERE taqprojectkey = @promocodekey
END

GO

GRANT EXEC ON qcs_get_promo_code_products TO PUBLIC

GO