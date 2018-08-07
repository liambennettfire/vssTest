IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[csmediaformatcode]') AND type in (N'V'))
DROP VIEW [dbo].[csmediaformatcode]
GO

CREATE VIEW [csmediaformatcode] AS
    SELECT 
        g.eloquencefieldtag AS mediatag,
        g.datacode AS mediacode,
        s.eloquencefieldtag AS formattag,
        s.datasubcode AS formatcode
    FROM gentables g, subgentables s 
    WHERE 
        g.tableid=312 AND
        s.tableid=312 AND
        g.datacode=s.datacode AND
        g.eloquencefieldtag IS NOT NULL AND
        s.eloquencefieldtag IS NOT NULL
GO

GRANT  SELECT  ON [dbo].[csmediaformatcode]  TO [public]
GO
