if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[taqversionspecitems_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[taqversionspecitems_view]
GO


CREATE VIEW [dbo].[taqversionspecitems_view] AS
SELECT i.taqversionspecategorykey,i.relatedspeccategorykey,i.taqprojectkey, i.plstagecode, i.taqversionkey, i.taqversionformatkey,
  i.itemcategorycode, i.speccategorydescription,
  t.decimalvalue, 
  t.unitofmeasurecode, (SELECT datadesc FROM gentables WHERE tableid = 613 AND datacode = t.unitofmeasurecode) unitofmeasuredesc,
  t.itemcode, (SELECT datadesc FROM subgentables WHERE tableid = 616 AND datacode = i.itemcategorycode AND datasubcode = t.itemcode) itemdesc,
  t.itemdetailcode, 
  CASE t.itemdetailcode
    WHEN NULL THEN NULL
    WHEN 0 THEN NULL
    ELSE 
      CASE
        WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = i.itemcategorycode AND datasubcode = t.itemcode) > 0 THEN 
          CASE
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode =                               i.itemcategorycode AND datasubcode = t.itemcode)) = 'gentables' THEN
              (SELECT g.datadesc FROM gentables g, subgentables s 
                 WHERE s.tableid = 616 AND s.datacode = i.itemcategorycode AND s.datasubcode = t.itemcode AND g.tableid = s.numericdesc1 AND g.datacode =                      t.itemdetailcode)
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode =                               i.itemcategorycode AND datasubcode = t.itemcode)) = 'ink' THEN
              (SELECT g.inkdesc FROM ink g, subgentables s 
                 WHERE s.tableid = 616 AND s.datacode = i.itemcategorycode AND s.datasubcode = t.itemcode AND g.inkkey =  t.itemdetailcode)

	 END
        ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = i.itemcategorycode AND datasubcode = t.itemcode AND datasub2code = t.itemdetailcode)
      END
  END itemdetaildesc,
  t.quantity, t.description,t.description2, 
  t.validforprtgscode,(SELECT datadesc FROM gentables WHERE tableid = 623 AND datacode = t.validforprtgscode) validforprtgsdesc,
  i.lastuserid, i.lastmaintdate,i.sortorder,t.taqversionspecitemkey
FROM taqversionspeccategory i
LEFT OUTER JOIN taqversionspecitems t ON i.taqversionspecategorykey = t.taqversionspecategorykey 
and (i.relatedspeccategorykey is NULL or i.relatedspeccategorykey = 0)
UNION
SELECT i.taqversionspecategorykey,i.relatedspeccategorykey,i.taqprojectkey, i.plstagecode, i.taqversionkey, i.taqversionformatkey,
  i.itemcategorycode, i2.speccategorydescription,
  t.decimalvalue, 
  t.unitofmeasurecode, (SELECT datadesc FROM gentables WHERE tableid = 613 AND datacode = t.unitofmeasurecode) unitofmeasuredesc,
  t.itemcode, (SELECT datadesc FROM subgentables WHERE tableid = 616 AND datacode = i.itemcategorycode AND datasubcode = t.itemcode) itemdesc,
  t.itemdetailcode, 
  CASE t.itemdetailcode
    WHEN NULL THEN NULL
    WHEN 0 THEN NULL
    ELSE 
      CASE
        WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = i.itemcategorycode AND datasubcode = t.itemcode) > 0 THEN 
          CASE
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode =                               i.itemcategorycode AND datasubcode = t.itemcode)) = 'gentables' THEN
              (SELECT g.datadesc FROM gentables g, subgentables s 
                 WHERE s.tableid = 616 AND s.datacode = i.itemcategorycode AND s.datasubcode = t.itemcode AND g.tableid = s.numericdesc1 AND g.datacode =                      t.itemdetailcode)
            WHEN (SELECT location FROM gentablesdesc WHERE tableid = (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode =                               i.itemcategorycode AND datasubcode = t.itemcode)) = 'ink' THEN
              (SELECT g.inkdesc FROM ink g, subgentables s 
                 WHERE s.tableid = 616 AND s.datacode = i.itemcategorycode AND s.datasubcode = t.itemcode AND g.inkkey =  t.itemdetailcode)

	 END
        ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = i.itemcategorycode AND datasubcode = t.itemcode AND datasub2code = t.itemdetailcode)
      END
  END itemdetaildesc,
  t.quantity, t.description, t.description2,
  t.validforprtgscode,(SELECT datadesc FROM gentables WHERE tableid = 623 AND datacode = t.validforprtgscode) validforprtgsdesc,
  i.lastuserid, i.lastmaintdate,i2.sortorder,t.taqversionspecitemkey
FROM taqversionspeccategory i, taqversionspecitems t, taqversionspeccategory i2
WHERE i2.taqversionspecategorykey = t.taqversionspecategorykey and (i.relatedspeccategorykey is not NULL or i.relatedspeccategorykey <> 0) and i.relatedspeccategorykey = i2.taqversionspecategorykey

GO


