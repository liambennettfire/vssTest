IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_possible_assets]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION [dbo].[qcs_get_possible_assets]
GO

CREATE FUNCTION [dbo].[qcs_get_possible_assets](@listkey int = NULL, @userKey int, @bookKey int, @allWorksForTitle bit = 0)
RETURNS @PossibleAssets TABLE (
  BookKey int,
  PartnerKey int,
  AssetTypeCode  int)
AS
BEGIN

  DECLARE @v_ListSearchType INT;
  SELECT @v_ListSearchType = searchtypecode FROM qse_searchlist WHERE listkey = @listkey
  
  IF @v_ListSearchType = 26 --CS/EOD Outbox (resend)
    INSERT INTO @PossibleAssets
      SELECT ep.bookkey, ep.partnercontactkey, e.taqelementtypecode
      FROM dbo.qcs_get_booklist(@listkey, @userKey, @bookKey, @allWorksForTitle) AS b 
        JOIN taqprojectelementpartner ep ON ep.bookkey = b.bookkey
        JOIN taqprojectelement e ON ep.assetkey = e.taqelementkey
      WHERE ep.resendind = 1 AND
      ep.cspartnerstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 5) AND
      e.elementstatus = (SELECT datacode FROM gentables WHERE tableid = 593 AND qsicode = 3)        
   ELSE
    INSERT INTO @PossibleAssets
    SELECT 0, 0, 0  

	RETURN
END
GO

GRANT SELECT ON dbo.qcs_get_possible_assets TO PUBLIC
GO
