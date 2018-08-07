IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EODundistributedapprovedassets]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[EODundistributedapprovedassets]
GO

CREATE VIEW [dbo].[EODundistributedapprovedassets] AS
SELECT DISTINCT te.bookkey, te.taqelementtypecode, te.elementstatus, bd.csapprovalcode, b.elocustomerkey AS customerkey, a.partnercontactkey
FROM taqprojectelement te
JOIN book b ON b.bookkey = te.bookkey
JOIN bookdetail bd ON bd.bookkey = te.bookkey 
JOIN customerpartnerassets a ON b.elocustomerkey = a.customerkey
LEFT OUTER JOIN taqprojectelementpartner tpe ON tpe.assetkey = te.taqelementkey AND tpe.cspartnerstatuscode = 1
LEFT OUTER JOIN taqprojectelementpartner tpe2 ON tpe2.assetkey = te.taqelementkey AND tpe2.cspartnerstatuscode <> 1
WHERE
  te.elementstatus IN (
    SELECT datacode FROM gentables WHERE tableid = 593 AND qsicode = 3 -- -- ElementStatus - Approved
  ) 
  AND (
    te.cspartnerstatuscode IN (
      SELECT datacode FROM gentables WHERE tableid = 639 AND qsicode = 1) -- -- CSTitleAssetStatus - Not Distributed
    OR tpe.assetkey IS NOT NULL 
    OR tpe2.assetkey IS NULL
  )

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT SELECT, UPDATE, INSERT, DELETE ON [dbo].[EODundistributedapprovedassets]  TO [public]
GO

