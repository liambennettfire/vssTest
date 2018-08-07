IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[customerpartner_assettype_view]'))
DROP VIEW [dbo].[customerpartner_assettype_view]
GO
CREATE VIEW [dbo].[customerpartner_assettype_view]
AS
SELECT DISTINCT
  a.customerkey AS CustomerKey,
	a.partnercontactkey AS PartnerKey, 
	g.code AS Code, 
	g.name AS Name, 
	g.shortname AS ShortName, 
	g.tag AS Tag, 
	g.qsicode AS QsiCode
FROM customerpartnerassets AS a 
JOIN assettype_view AS g ON a.assettypecode = g.code

GO
GRANT  SELECT  ON [dbo].[customerpartner_assettype_view]  TO [public]
GO
