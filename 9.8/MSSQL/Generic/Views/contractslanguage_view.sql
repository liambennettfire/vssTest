if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[contractslanguage_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[contractslanguage_view]
GO

CREATE VIEW dbo.contractslanguage_view AS
SELECT r.rightslanguagetypecode, r.taqprojectkey, r.rightskey, l.languagecode
FROM taqprojectrights r, taqprojectrightslanguage l
WHERE r.rightskey = l.rightskey AND 
  r.rightslanguagetypecode = 3
UNION
SELECT r.rightslanguagetypecode, r.taqprojectkey, r.rightskey, g.datacode
FROM taqprojectrights r, gentables g
WHERE r.rightslanguagetypecode = 2 AND 
  g.tableid = 318 AND
  NOT EXISTS (SELECT * FROM taqprojectrightslanguage l 
              WHERE l.languagecode = g.datacode AND l.rightskey = r.rightskey)
UNION
SELECT r.rightslanguagetypecode, r.taqprojectkey, r.rightskey, g.datacode
FROM taqprojectrights r, gentables g
WHERE r.rightslanguagetypecode = 1 AND 
  g.tableid = 318 

go

GRANT SELECT ON contractslanguage_view TO PUBLIC
go


