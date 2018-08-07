IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_assets_skip_resend]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[qcs_get_assets_skip_resend]
GO

CREATE FUNCTION [dbo].[qcs_get_assets_skip_resend](@listkey int = NULL, @userKey int, @bookKey int, @allWorksForTitle bit = 0)
RETURNS @AssetsToSkipResend TABLE (
  BookKey int,
  PartnerKey int,
  AssetTypeCode  int)
AS
BEGIN

  DECLARE @v_ListSearchType INT;
  SELECT @v_ListSearchType = searchtypecode FROM qse_searchlist WHERE listkey = @listkey
  
  IF @v_ListSearchType = 26 --CS/EOD Outbox (resend)
    INSERT INTO @AssetsToSkipResend
      SELECT ep.bookkey, ep.partnercontactkey, e.taqelementtypecode
      FROM dbo.qcs_get_booklist(@listkey, @userKey, @bookKey, @allWorksForTitle) AS b 
        JOIN taqprojectelementpartner ep ON ep.bookkey = b.bookkey
        JOIN taqprojectelement e ON ep.assetkey = e.taqelementkey
      WHERE ep.resendind = 0
         OR (ep.resendind = 1 and ep.cspartnerstatuscode = 4)
   ELSE
    INSERT INTO @AssetsToSkipResend
    SELECT 0, 0, 0  

	RETURN
END
GO

GRANT SELECT ON dbo.qcs_get_assets_skip_resend TO PUBLIC
GO