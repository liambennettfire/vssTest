IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[taqversionrelatedcomponents_view]'))
  DROP VIEW [dbo].[taqversionrelatedcomponents_view]
GO

CREATE VIEW taqversionrelatedcomponents_view 
AS
SELECT c.taqprojectkey,
  CASE WHEN gen.datacode IS NOT NULL THEN 0 ELSE 1 END activeind,
  c.taqversionformatkey,
  c.plstagecode,
  c.taqversionkey,  
  c.taqversionspecategorykey,
  c.finishedgoodind,
  CASE WHEN NULLIF(c.relatedspeccategorykey, 0) IS NULL THEN c.taqprojectkey ELSE sc.taqprojectkey END relatedprojectkey,
  CASE WHEN NULLIF(c.relatedspeccategorykey, 0) IS NULL THEN c.taqversionformatkey ELSE sc.taqversionformatkey END relatedformatkey,
  CASE WHEN NULLIF(c.relatedspeccategorykey, 0) IS NULL THEN c.plstagecode ELSE sc.plstagecode END relatedstagecode,
  CASE WHEN NULLIF(c.relatedspeccategorykey, 0) IS NULL THEN c.taqversionkey ELSE sc.taqversionkey END relatedversionkey,
  CASE WHEN NULLIF(c.relatedspeccategorykey, 0) IS NULL THEN c.taqversionspecategorykey ELSE c.relatedspeccategorykey END relatedcategorykey,
  CASE WHEN NULLIF(c.relatedspeccategorykey, 0) IS NULL THEN c.finishedgoodind ELSE sc.finishedgoodind END relatedfinishedgoodind,
  CASE (SELECT COALESCE(c.relatedspeccategorykey, 0))
    WHEN 0 THEN COALESCE((SELECT TOP 1 y.taqversionformatyearkey FROM taqversionformatyear y WHERE y.taqprojectkey = c.taqprojectkey AND y.plstagecode = c.plstagecode AND y.taqversionkey = c.taqversionkey AND y.taqprojectformatkey = c.taqversionformatkey AND y.printingnumber > 0 ORDER BY y.printingnumber),0)
    ELSE COALESCE((SELECT TOP 1 y.taqversionformatyearkey FROM taqversionformatyear y, taqversionspeccategory c2 WHERE y.taqprojectkey= c2.taqprojectkey AND y.plstagecode = c2.plstagecode AND y.taqversionkey = c2.taqversionkey AND y.taqprojectformatkey = c2.taqversionformatkey AND c2.taqversionspecategorykey = c.relatedspeccategorykey AND y.printingnumber > 0 ORDER BY y.printingnumber),0)
  END firstprtg_taqversionformatyearkey,
  c.sortorder AS sortorder
FROM 
	taqversionspeccategory c
LEFT JOIN taqversionspeccategory sc
	ON c.relatedspeccategorykey = sc.taqversionspecategorykey
LEFT JOIN taqproject tp
	ON c.taqprojectkey = tp.taqprojectkey
LEFT JOIN gentables gen 
	ON tp.taqprojectstatuscode = gen.datacode
	AND gen.tableid = 522 
	AND gen.qsicode = 10

GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqversionrelatedcomponents_view]  TO [public]
GO


