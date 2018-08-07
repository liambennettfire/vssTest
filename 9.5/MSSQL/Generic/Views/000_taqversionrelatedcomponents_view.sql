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
  c.plstagecode,
  c.taqversionkey,  
  c.taqversionspecategorykey,
  c.finishedgoodind,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqprojectkey
    ELSE (SELECT taqprojectkey FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedprojectkey,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqversionformatkey
    ELSE (SELECT taqversionformatkey FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedformatkey,  
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.plstagecode
    ELSE (SELECT plstagecode FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedstagecode,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqversionkey
    ELSE (SELECT taqversionkey FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedversionkey,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.taqversionspecategorykey
    ELSE c.relatedspeccategorykey
  END relatedcategorykey,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN c.finishedgoodind
    ELSE (SELECT finishedgoodind FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
  END relatedfinishedgoodind,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN COALESCE((SELECT TOP 1 y.taqversionformatyearkey FROM taqversionformatyear y WHERE y.taqprojectkey = c.taqprojectkey AND y.plstagecode = c.plstagecode AND y.taqversionkey = c.taqversionkey AND y.taqprojectformatkey = c.taqversionformatkey AND y.printingnumber > 0 ORDER BY y.printingnumber),0)
    ELSE COALESCE((SELECT TOP 1 y.taqversionformatyearkey FROM taqversionformatyear y, taqversionspeccategory c2 WHERE y.taqprojectkey= c2.taqprojectkey AND y.plstagecode = c2.plstagecode AND y.taqversionkey = c2.taqversionkey AND y.taqprojectformatkey = c2.taqversionformatkey AND c2.taqversionspecategorykey = c.relatedspeccategorykey AND y.printingnumber > 0 ORDER BY y.printingnumber),0)
  END firstprtg_taqversionformatyearkey, --first encountered printingnumber for the project/format/version, not necessarily printingnumber=1
  c.sortorder AS sortorder
FROM taqversionspeccategory c

GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqversionrelatedcomponents_view]  TO [public]
GO


