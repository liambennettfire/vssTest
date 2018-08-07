if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqversionspecitems_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqversionspecitems_view]
GO

/***********************************************************************************************************************
**  Change History
************************************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  09/22/17  Colman    46478 - Custom Description Spec Items not displaying
**  10/02/17  Colman    47456 - Calculated itemdetail specs not displaying
**  11/20/17  Colman    48469 - No spec items appear when qsiadmin userkey != 0
************************************************************************************************************************/

CREATE VIEW [dbo].[taqversionspecitems_view] AS
-- WITH cte_taqprojectculturecode_view
-- AS (
-- SELECT 
  -- t.taqProjectKey,
  -- COALESCE(t.culturecode,q.culturecode,cd.clientDefaultValue,gen.dataCode,-1) AS cultureCode
-- FROM dbo.taqProject t
-- CROSS JOIN dbo.qsiusers q
-- CROSS JOIN dbo.clientdefaults cd
-- CROSS JOIN dbo.gentables gen
-- WHERE q.userKey = 0
-- AND cd.clientdefaultid = 78
-- AND gen.tableid = 670
-- AND gen.qsicode = 1
-- )
SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, 
  v.relatedprojectkey, v.relatedstagecode, v.relatedversionkey, v.relatedformatkey, v.relatedcategorykey, v.firstprtg_taqversionformatyearkey,
  c.itemcategorycode, c.speccategorydescription, i.taqversionspecitemkey, 
  i.itemcode, s.qsicode itemcode_qsicode,
  sub.datadesc AS itemdesc,  
  a.usefunctionforitemdetailind,
  CASE a.usefunctionforitemdetailind
    WHEN 1 THEN (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.itemdetailcode 
  END itemdetailcode,
  CASE a.usefunctionforitemdetailind
  WHEN 1 THEN
    CASE (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
      WHEN NULL THEN NULL
      WHEN 0 THEN NULL
      ELSE CASE
      WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) > 0 THEN 
        (SELECT g.datadesc FROM gentables g, subgentables t 
        WHERE t.tableid = 616 AND t.datacode = c.itemcategorycode AND t.datasubcode = i.itemcode AND g.tableid = t.numericdesc1 AND g.datacode = (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode)))
      ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode AND datasub2code = (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode)))
      END
    END
  ELSE
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
    END
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
  END [description],
  i.description2,
  a.usefunctionfordecimalind,
  CASE WHEN a.usefunctionfordecimalind = 1 THEN 0 ELSE i.decimalvalue END decimalvalue,
  a.usefunctionforuomind, 
  CASE WHEN a.usefunctionforuomind = 1 THEN 0 ELSE i.unitofmeasurecode END unitofmeasurecode,
  gen2.datadesc unitofmeasuredesc,
  i.validforprtgscode, 
  gen.datadesc  validforprtgsdesc,
  c.lastuserid, c.lastmaintdate, c.sortorder,
  p.culturecode
FROM taqversionspeccategory c
  JOIN taqproject p ON p.taqprojectkey = c.taqprojectkey
  JOIN taqversionrelatedcomponents_view v ON v.taqprojectkey = c.taqprojectkey AND v.taqversionspecategorykey = c.taqversionspecategorykey
  LEFT OUTER JOIN taqversionspecitems i ON c.taqversionspecategorykey = i.taqversionspecategorykey
  JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode 
  JOIN subgentables s ON s.tableid= 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode
  -- JOIN cte_taqprojectculturecode_view ct ON a.culturecode = ct.cultureCode AND v.taqprojectkey = ct.taqprojectkey
  LEFT JOIN subgentables sub ON sub.tableid = 616 AND sub.datacode = c.itemcategorycode AND sub.datasubcode = i.itemcode
  LEFT JOIN gentables gen ON gen.datacode = i.validforprtgscode AND gen.tableid = 623
  LEFT JOIN gentables gen2 ON gen2.datacode = i.unitofmeasurecode AND gen2.tableid = 613
WHERE c.relatedspeccategorykey = 0
OR c.relatedspeccategorykey IS NULL
UNION
SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, 
  v.relatedprojectkey, v.relatedstagecode, v.relatedversionkey, v.relatedformatkey, v.relatedcategorykey, v.firstprtg_taqversionformatyearkey,
  c.itemcategorycode, c2.speccategorydescription, i.taqversionspecitemkey, 
  i.itemcode, s.qsicode itemcode_qsicode,
  s.datadesc AS itemdesc, 
  a.usefunctionforitemdetailind,
  CASE a.usefunctionforitemdetailind
    WHEN 1 THEN (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
    ELSE i.itemdetailcode 
  END itemdetailcode,
  CASE a.usefunctionforitemdetailind
  WHEN 1 THEN
    CASE (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode))
      WHEN NULL THEN NULL
      WHEN 0 THEN NULL
      ELSE CASE
      WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) > 0 THEN 
        (SELECT g.datadesc FROM gentables g, subgentables t 
        WHERE t.tableid = 616 AND t.datacode = c.itemcategorycode AND t.datasubcode = i.itemcode AND g.tableid = t.numericdesc1 AND g.datacode = (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode)))
      ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode AND datasub2code = (dbo.get_itemdetailcode(v.firstprtg_taqversionformatyearkey, s.qsicode)))
      END
    END
  ELSE
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
    END
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
  END [description],
  i.description2,
  a.usefunctionfordecimalind,
  CASE WHEN a.usefunctionfordecimalind = 1 THEN 0 ELSE i.decimalvalue END decimalvalue,
  a.usefunctionforuomind, 
  CASE WHEN a.usefunctionforuomind = 1 THEN 0 ELSE i.unitofmeasurecode END unitofmeasurecode,
  gen2.datadesc unitofmeasuredesc,
  i.validforprtgscode, 
  gen.datadesc  validforprtgsdesc,
  c.lastuserid, c.lastmaintdate, c2.sortorder,
  p.culturecode
FROM taqversionspeccategory c
  JOIN taqproject p ON p.taqprojectkey = c.taqprojectkey
  JOIN taqversionspeccategory c2 ON c2.taqversionspecategorykey = c.relatedspeccategorykey
  JOIN taqversionspecitems i ON i.taqversionspecategorykey = c.relatedspeccategorykey
  JOIN taqversionrelatedcomponents_view v ON v.taqprojectkey = c.taqprojectkey AND v.taqversionspecategorykey = c.taqversionspecategorykey
  JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode
  -- JOIN cte_taqprojectculturecode_view ct ON a.culturecode = ct.cultureCode AND v.taqprojectkey = ct.taqprojectkey
  JOIN subgentables s ON s.tableid= 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode
  LEFT JOIN gentables gen ON gen.datacode = i.validforprtgscode AND gen.tableid = 623
  LEFT JOIN gentables gen2 ON gen2.datacode = i.unitofmeasurecode AND gen2.tableid = 613
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[taqprojectprinting_view]  TO [public]
GO