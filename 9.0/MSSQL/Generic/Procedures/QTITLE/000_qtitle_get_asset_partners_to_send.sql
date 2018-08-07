if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_asset_partners_to_send') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_asset_partners_to_send
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_asset_partners_to_send
 (@i_listkey        integer,
  @i_metadata_only  tinyint,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************
**  Name: qtitle_get_asset_partners_to_send
**  Desc: This stored procedure will return a list of all asset/partner combinations
**        that need to be re-sent.
**
**  Auth: Kate
**  Date: October 26 2012
**************************************************************************************/

DECLARE
  @v_error  INT,
  @v_rowcount INT,
  @v_metadata_element VARCHAR(30)
  
BEGIN
	SELECT @v_metadata_element = CONVERT(VARCHAR,datacode)
	FROM gentables 
	WHERE tableid = 287 AND qsicode = 3

  IF @i_metadata_only = 1
  BEGIN
    SELECT DISTINCT  
      cp.distributiontype distributiontypecode,
      ep.bookkey,
      ep.partnercontactkey globalcontactkey,
      getdate() nextsenddate,
      @v_metadata_element as selectedassets
    FROM taqprojectelementpartner ep, taqprojectelement e, qse_searchresults r, book b, customerpartner cp
    WHERE ep.assetkey = e.taqelementkey AND 
      ep.bookkey = r.key1 AND
      ep.bookkey = b.bookkey AND
      ep.bookkey = e.bookkey AND
      b.elocustomerkey = cp.customerkey AND
			ep.partnercontactkey = cp.partnercontactkey AND
      r.listkey = @i_listkey AND
      ep.resendind = 1 AND
      ep.cspartnerstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 5) AND
      elementstatus = (SELECT datacode FROM gentables WHERE tableid = 593 AND qsicode = 3)
  END
  ELSE BEGIN
		SELECT DISTINCT 
			cp.distributiontype distributiontypecode,
			ep.bookkey,
			ep.partnercontactkey globalcontactkey,
			getdate() nextsenddate, ep.partnercontactkey,
			COALESCE(STUFF((SELECT DISTINCT ',' + CONVERT(VARCHAR, taqelementtypecode)
				FROM customerpartnerassets cpa2, taqprojectelementpartner ep2, taqprojectelement e2
				WHERE ep2.assetkey = e2.taqelementkey AND 
					ep2.partnercontactkey = cpa2.partnercontactkey AND
					e2.taqelementtypecode  = cpa2.assettypecode AND
					ep2.partnercontactkey = ep.partnercontactkey AND
					ep2.bookkey = e2.bookkey AND
					e2.bookkey = e.bookkey AND
					ep2.resendind = 1 AND
					ep2.cspartnerstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 5)
				FOR XML PATH('')), 1, 1, ''), '') as selectedassets --replaces qtitle_get_partner_assets_to_resend(globalcontactkey)
		INTO #tmp_asset_partners  
		FROM taqprojectelementpartner ep, taqprojectelement e, qse_searchresults r, book b, customerpartner cp
		WHERE ep.assetkey = e.taqelementkey AND 
			ep.bookkey = r.key1 AND
			ep.bookkey = b.bookkey AND
			ep.bookkey = e.bookkey AND
			b.elocustomerkey = cp.customerkey AND
			ep.partnercontactkey = cp.partnercontactkey AND
			r.listkey = @i_listkey AND
			ep.resendind = 1 AND
			ep.cspartnerstatuscode IN (SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 5) AND
			elementstatus = (SELECT datacode FROM gentables WHERE tableid = 593 AND qsicode = 3)

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Error accessing taqprojectelementpartner table.' 
		END
		
		UPDATE #tmp_asset_partners
		SET selectedassets = @v_metadata_element + ',' + selectedassets
		WHERE CHARINDEX(@v_metadata_element, COALESCE(selectedassets, '')) = 0
			AND LEN(COALESCE(selectedassets, '')) > 0
		
		UPDATE #tmp_asset_partners
		SET selectedassets = @v_metadata_element
		WHERE CHARINDEX(@v_metadata_element, COALESCE(selectedassets, '')) = 0
			AND LEN(COALESCE(selectedassets, '')) = 0

		SELECT distributiontypecode, globalcontactkey, nextsenddate, bookkey,
			selectedassets
		FROM #tmp_asset_partners
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing taqprojectelementpartner temp table.' 
  END 

   --DROP table #tmp_asset_partners
END
GO

GRANT EXEC ON qtitle_get_asset_partners_to_send TO PUBLIC
GO