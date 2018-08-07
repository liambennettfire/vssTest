IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[assettype_view]'))
DROP VIEW [dbo].[assettype_view]
GO
CREATE VIEW [dbo].[assettype_view]
AS
SELECT
	datacode AS code, 
	datadesc AS name, 
	datadescshort AS shortname, 
	qsicode, 
	eloquencefieldtag AS tag
FROM
	gentables
WHERE
	tableid = 287 AND
	gen1ind = 1 AND
	deletestatus != 'Y' AND
	eloquencefieldtag IS NOT NULL
GO

GRANT  SELECT  ON [dbo].[assettype_view]  TO [public]
GO
