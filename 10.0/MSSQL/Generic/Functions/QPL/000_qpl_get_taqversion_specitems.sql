if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qpl_get_taqversion_specitems') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qpl_get_taqversion_specitems
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION [dbo].[qpl_get_taqversion_specitems]
(
  @i_categorykey      integer
)

/***********************************************************************************************************************
**  Name: qpl_get_taqversion_specitems
**  Desc: Function version of qproject_get_specitems_by_printingview for use when the categorykey is known.
**
**  Auth: Colman
**  Date: 11/20/2017
************************************************************************************************************************
**  Change History
************************************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
************************************************************************************************************************/

RETURNS @specitems TABLE
(
  taqprojectkey INT, 
  plstagecode INT, 
  taqversionkey INT, 
  taqversionformatkey INT, 
  taqversionspecategorykey INT, 
  relatedspeccategorykey INT, 
  relatedprojectkey INT, 
  relatedstagecode INT, 
  relatedversionkey INT, 
  relatedformatkey INT, 
  relatedcategorykey INT, 
  firstprtg_taqversionformatyearkey INT,
  itemcategorycode INT, 
  speccategorydescription VARCHAR(255), 
  taqversionspecitemkey INT, 
  itemcode INT, 
  itemcode_qsicode INT,
  itemdesc VARCHAR(120),  
  usefunctionforitemdetailind INT,
  itemdetailcode INT,
  itemdetaildesc VARCHAR(120),
  itemdetailsubcode INT, 
  itemdetailsub2code INT,
  usefunctionforqtyind INT,
  quantity INT,
  usefunctionfordescind INT,
  [description] VARCHAR(2000),
  description2 VARCHAR(2000),
  usefunctionfordecimalind INT,
  decimalvalue NUMERIC(15,4),
  usefunctionforuomind INT, 
  unitofmeasurecode INT,
  unitofmeasuredesc VARCHAR(120),
  validforprtgscode INT, 
  validforprtgsdesc VARCHAR(120),
  lastuserid VARCHAR(30), 
  lastmaintdate DATETIME, 
  sortorder INT
)

AS

BEGIN
  INSERT INTO @specitems
    (taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, taqversionspecategorykey, relatedspeccategorykey, relatedprojectkey, relatedstagecode, relatedversionkey,
    relatedformatkey, relatedcategorykey, firstprtg_taqversionformatyearkey, itemcategorycode, speccategorydescription, taqversionspecitemkey, itemcode, itemcode_qsicode,
    itemdesc, usefunctionforitemdetailind, itemdetailcode, itemdetaildesc, itemdetailsubcode, itemdetailsub2code, usefunctionforqtyind, quantity, usefunctionfordescind, [description], description2,
    usefunctionfordecimalind, decimalvalue, usefunctionforuomind, unitofmeasurecode, unitofmeasuredesc, validforprtgscode, validforprtgsdesc, lastuserid, lastmaintdate, sortorder)
  SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, 
    c.taqprojectkey relatedprojectkey, c.plstagecode relatedstagecode, c.taqversionkey relatedversionkey, c.taqversionformatkey relatedformatkey, c.relatedspeccategorykey relatedcategorykey, 
    v.firstprtg_taqversionformatyearkey,
    c.itemcategorycode, c.speccategorydescription, i.taqversionspecitemkey, 
    i.itemcode, s.qsicode itemcode_qsicode,
    sub.datadesc AS itemdesc,  
    a.usefunctionforitemdetailind,
    CASE a.usefunctionforitemdetailind
      WHEN 1 THEN (dbo.get_itemdetailcode(ISNULL(v.firstprtg_taqversionformatyearkey, 0), s.qsicode))
      ELSE i.itemdetailcode 
    END itemdetailcode,
    CASE a.usefunctionforitemdetailind
    WHEN 1 THEN
      CASE (dbo.get_itemdetailcode(ISNULL(v.firstprtg_taqversionformatyearkey, 0), s.qsicode))
        WHEN NULL THEN NULL
        WHEN 0 THEN NULL
        ELSE CASE
        WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode) > 0 THEN 
          (SELECT g.datadesc FROM gentables g, subgentables t 
          WHERE t.tableid = 616 AND t.datacode = c.itemcategorycode AND t.datasubcode = i.itemcode AND g.tableid = t.numericdesc1 AND g.datacode = (dbo.get_itemdetailcode(ISNULL(v.firstprtg_taqversionformatyearkey, 0), s.qsicode)))
        ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = c.itemcategorycode AND datasubcode = i.itemcode AND datasub2code = (dbo.get_itemdetailcode(ISNULL(v.firstprtg_taqversionformatyearkey, 0), s.qsicode)))
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
      WHEN 1 THEN (dbo.get_quantity(ISNULL(v.firstprtg_taqversionformatyearkey, 0), s.qsicode))
      ELSE i.quantity 
    END quantity,
    a.usefunctionfordescind,
    CASE a.usefunctionfordescind
      WHEN 1 THEN (dbo.get_description(ISNULL(v.firstprtg_taqversionformatyearkey, 0), s.qsicode))
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
    c.lastuserid, c.lastmaintdate, c.sortorder
  FROM taqversionspeccategory c
    LEFT OUTER JOIN taqversionspecitems i ON c.taqversionspecategorykey = i.taqversionspecategorykey
    JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode 
    JOIN subgentables s ON s.tableid= 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode
    LEFT JOIN subgentables sub ON sub.tableid = 616 AND sub.datacode = c.itemcategorycode AND sub.datasubcode = i.itemcode
    LEFT JOIN gentables gen ON gen.datacode = i.validforprtgscode AND gen.tableid = 623
    LEFT JOIN gentables gen2 ON gen2.datacode = i.unitofmeasurecode AND gen2.tableid = 613
    JOIN taqversionrelatedcomponents_view v ON v.taqprojectkey = c.taqprojectkey AND v.taqversionspecategorykey = c.taqversionspecategorykey
  WHERE c.taqversionspecategorykey = @i_categorykey 
    AND ISNULL(c.relatedspeccategorykey, 0) = 0
    
  UNION -- Items from related categories
  
  SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, 
    v.relatedprojectkey, v.relatedstagecode, v.relatedversionkey, v.relatedformatkey, v.relatedcategorykey, v.firstprtg_taqversionformatyearkey,
    c.itemcategorycode, rc.speccategorydescription, i.taqversionspecitemkey, 
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
    c.lastuserid, c.lastmaintdate, rc.sortorder
  FROM taqversionspeccategory c
    JOIN taqversionspeccategory rc ON rc.taqversionspecategorykey = c.relatedspeccategorykey
    JOIN taqversionspecitems i ON i.taqversionspecategorykey = c.relatedspeccategorykey
    JOIN taqversionrelatedcomponents_view v ON v.taqprojectkey = c.taqprojectkey AND v.taqversionspecategorykey = c.taqversionspecategorykey
    JOIN taqspecadmin a ON a.itemcategorycode = c.itemcategorycode AND a.itemcode = i.itemcode
    JOIN subgentables s ON s.tableid= 616 AND s.datacode = c.itemcategorycode AND s.datasubcode = i.itemcode
    LEFT JOIN gentables gen ON gen.datacode = i.validforprtgscode AND gen.tableid = 623
    LEFT JOIN gentables gen2 ON gen2.datacode = i.unitofmeasurecode AND gen2.tableid = 613
  WHERE c.taqversionspecategorykey = @i_categorykey 
    AND ISNULL(c.relatedspeccategorykey, 0) != 0

  RETURN
END