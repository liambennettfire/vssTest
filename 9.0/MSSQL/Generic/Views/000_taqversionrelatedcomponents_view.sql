IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[taqversionrelatedcomponents_view]'))
  DROP VIEW [dbo].[taqversionrelatedcomponents_view]
GO

CREATE VIEW [dbo].[taqversionrelatedcomponents_view] AS
SELECT c.taqprojectkey,
  CASE (SELECT taqprojectstatuscode FROM taqproject WHERE taqprojectkey = c.taqprojectkey)
    WHEN (SELECT datacode FROM gentables WHERE tableid = 522 AND qsicode = 10) THEN 0
    ELSE 1
  END activeind,
  c.taqversionformatkey,
  c.taqversionspecategorykey,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqprojectkey
    ELSE (SELECT taqprojectkey FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedprojectkey,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqversionformatkey
    ELSE (SELECT taqversionformatkey FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedformatkey,  
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqversionspecategorykey
    ELSE c.relatedspeccategorykey
  END relatedcategorykey,
  c.sortorder AS sortorder
FROM taqversionspeccategory c

GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqversionrelatedcomponents_view]  TO [public]
GO
