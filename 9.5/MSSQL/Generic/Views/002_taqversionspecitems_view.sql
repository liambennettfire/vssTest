if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqversionspecitems_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqversionspecitems_view]
GO

CREATE VIEW [dbo].[taqversionspecitems_view] AS
SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, 
  v.relatedprojectkey, v.relatedstagecode, v.relatedversionkey, v.relatedformatkey, v.relatedcategorykey, v.firstprtg_taqversionformatyearkey,
  c.itemcategorycode, c.speccategorydescription, i.taqversionspecitemkey, 
  i.itemcode, s.qsicode itemcode_qsicode,
  (SELECT datadesc FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) itemdesc,  
  a.usefunctionforitemdetailind,
  CASE a.usefunctionforitemdetailind
    WHEN 1 THEN (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.itemdetailcode 
  END itemdetailcode, 
  CASE 
    WHEN i.itemdetailcode > 0 THEN
      CASE
        WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) > 0 THEN 
          CASE
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode)) = 'gentables' THEN
              (SELECT g.datadesc FROM gentables g, subgentables s 
               WHERE s.tableid = 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode AND g.tableid = s.numericdesc1 AND g.datacode = i.itemdetailcode)
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode)) = 'ink' THEN
              (SELECT g.inkdesc FROM ink g, subgentables s 
               WHERE s.tableid = 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode AND g.inkkey =  i.itemdetailcode)
          END
        ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode AND datasub2code = i.itemdetailcode)
      END
    ELSE NULL
  END itemdetaildesc,
  i.itemdetailsubcode, i.itemdetailsub2code,
  a.usefunctionforqtyind,
  CASE a.usefunctionforqtyind
    WHEN 1 THEN (dbo.get_quantity(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.quantity 
  END quantity,
  a.usefunctionfordescind,
  CASE a.usefunctionfordescind
    WHEN 1 THEN (dbo.get_description(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.[description]
  END description, 
  i.description2,
  a.usefunctionfordecimalind,
  CASE a.usefunctionfordecimalind
    WHEN 1 THEN (dbo.get_decimalvalue(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.decimalvalue 
  END decimalvalue,
  a.usefunctionforuomind, 
  CASE a.usefunctionforuomind
    WHEN 1 THEN (dbo.get_uomcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.unitofmeasurecode 
  END unitofmeasurecode,
  (SELECT datadesc FROM gentables WHERE tableid = 613 AND datacode = i.unitofmeasurecode) unitofmeasuredesc,
  i.validforprtgscode, (SELECT datadesc FROM gentables WHERE tableid = 623 AND datacode = i.validforprtgscode) validforprtgsdesc,
  c.lastuserid, c.lastmaintdate, c.sortorder
FROM taqversionspeccategory c
	LEFT OUTER JOIN taqversionspecitems i ON c.taqversionspecategorykey = i.taqversionspecategorykey
	JOIN taqversionrelatedcomponents_view v ON v.taqprojectkey = c.taqprojectkey AND v.taqversionspecategorykey = c.taqversionspecategorykey
    JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode AND a.culturecode = (SELECT projectculturecode FROM dbo.get_culture(0,v.relatedprojectkey,0))
    JOIN subgentables s ON s.tableid= 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode
WHERE COALESCE(c.relatedspeccategorykey,0) = 0
UNION
SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, 
  v.relatedprojectkey, v.relatedstagecode, v.relatedversionkey, v.relatedformatkey, v.relatedcategorykey, v.firstprtg_taqversionformatyearkey,
  c.itemcategorycode, c2.speccategorydescription, i.taqversionspecitemkey, 
  i.itemcode, s.qsicode itemcode_qsicode,
  (SELECT datadesc FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) itemdesc,
  a.usefunctionforitemdetailind,
  CASE a.usefunctionforitemdetailind
    WHEN 1 THEN (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.itemdetailcode 
  END itemdetailcode, 
  CASE 
    WHEN i.itemdetailcode > 0 THEN
      CASE
        WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) > 0 THEN 
          CASE
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode)) = 'gentables' THEN
              (SELECT g.datadesc FROM gentables g, subgentables s 
               WHERE s.tableid = 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode AND g.tableid = s.numericdesc1 AND g.datacode = i.itemdetailcode)
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode)) = 'ink' THEN
              (SELECT g.inkdesc FROM ink g, subgentables s 
               WHERE s.tableid = 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode AND g.inkkey =  i.itemdetailcode)
          END
        ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode AND datasub2code = i.itemdetailcode)
      END
    ELSE NULL
  END itemdetaildesc,
  i.itemdetailsubcode, i.itemdetailsub2code,
  a.usefunctionforqtyind,
  CASE a.usefunctionforqtyind
    WHEN 1 THEN (dbo.get_quantity(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.quantity 
  END quantity,
  a.usefunctionfordescind,
  CASE a.usefunctionfordescind
    WHEN 1 THEN (dbo.get_description(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.[description]
  END description, 
  i.description2,
  a.usefunctionfordecimalind,
  CASE a.usefunctionfordecimalind
    WHEN 1 THEN (dbo.get_decimalvalue(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.decimalvalue 
  END decimalvalue,
  a.usefunctionforuomind, 
  CASE a.usefunctionforuomind
    WHEN 1 THEN (dbo.get_uomcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.unitofmeasurecode 
  END unitofmeasurecode,
  (SELECT datadesc FROM gentables WHERE tableid = 613 AND datacode = i.unitofmeasurecode) unitofmeasuredesc,
  i.validforprtgscode, (SELECT datadesc FROM gentables WHERE tableid = 623 AND datacode = i.validforprtgscode) validforprtgsdesc,
  c.lastuserid, c.lastmaintdate, c2.sortorder
FROM taqversionspeccategory c
  JOIN taqversionspeccategory c2 ON c2.taqversionspecategorykey = c.relatedspeccategorykey
  JOIN taqversionspecitems i ON i.taqversionspecategorykey = c.relatedspeccategorykey
  JOIN taqversionrelatedcomponents_view v ON v.taqprojectkey = c.taqprojectkey AND v.taqversionspecategorykey = c.taqversionspecategorykey
  JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode AND a.culturecode = (SELECT projectculturecode FROM dbo.get_culture(0,v.relatedprojectkey,0))
  JOIN subgentables s ON s.tableid= 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode

GO
