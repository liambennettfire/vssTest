if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_specitems_by_printingview') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_specitems_by_printingview
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION [dbo].[qproject_get_specitems_by_printingview](@i_taqversionformatyearkey int)

/***********************************************************************************************************************
**  Name: qproject_get_specitems_by_printingview
**  Desc: Takes the output of qproject_get_specitems_by_printing and generates calculated values.
**
**  Auth: Alan Katzen
**  Date: 14 June 2013
************************************************************************************************************************
**  Change History
************************************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  06/21/16  Kate      Fixes for related specs - see case 29764.
**  10/02/17  Colman    47456 - Calculated itemdetail specs not displaying
**  11/14/17  Colman    47625
************************************************************************************************************************/

RETURNS @specitemsbyprinting TABLE(
  taqversionformatyearkey INT,
  printingnumber INT,
  yearcode INT,
  taqprojectkey INT,
  plstagecode INT,
  taqversionkey INT,
  taqprojectformatkey INT,
  taqversionspecategorykey INT,
  relatedspeccategorykey INT,
  itemcategorycode	INT,
  itemcategory_qsicode INT,
  speccategorydescription VARCHAR(255),
  scaleprojecttype	INT,
  scaleprojectdesc	VARCHAR(40),
  vendorcontactkey	INT,
  vendordisplayname	VARCHAR(255),
  taqversionspecitemkey	INT,
  itemcode	INT,
  itemcode_qsicode INT,
  itemdesc		VARCHAR(120),
  usefunctionforqtyind	TINYINT,
  quan  INT,
  usefunctionfordescind TINYINT,
  [description] VARCHAR(2000),
  usefunctionforitemdetailind	TINYINT,
  itemdetailcode INT,
  itemdetaildesc VARCHAR(120),
  usefunctionfordecimalind		TINYINT,
  [decimal]  NUMERIC(15,4),
  usefunctionforuomind		TINYINT,
  unitofmeasurecode INT,
  uomdesc VARCHAR(120),
  validforprtscode		INT,
  validforprtsdesc		VARCHAR(40)		
	)

AS
BEGIN
  INSERT INTO @specitemsbyprinting
    (taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
    taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
    scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
    taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
    usefunctionforqtyind, quan,
    usefunctionfordescind, [description],
    usefunctionforitemdetailind, itemdetailcode, itemdetaildesc,
    usefunctionfordecimalind, [decimal],
    usefunctionforuomind, unitofmeasurecode, uomdesc,
    validforprtscode, validforprtsdesc)
  SELECT DISTINCT s.taqversionformatyearkey, s.printingnumber, s.yearcode, s.taqprojectkey, s.plstagecode, s.taqversionkey, s.taqprojectformatkey,
    s.taqversionspecategorykey, s.relatedspeccategorykey, s.itemcategorycode, s.itemcategory_qsicode, s.speccategorydescription,
    s.scaleprojecttype, s.scaleprojectdesc, s.vendorcontactkey, s.vendordisplayname,
    s.taqversionspecitemkey, s.itemcode, s.itemcode_qsicode, s.itemdesc,
    s.usefunctionforqtyind,
    CASE s.usefunctionforqtyind
      WHEN 1 THEN (dbo.get_quantity(s.taqversionformatyearkey, s.itemcode_qsicode))
      ELSE s.quantity 
    END,
    s.usefunctionfordescind,
    CASE s.usefunctionfordescind
      WHEN 1 THEN (dbo.get_description(s.taqversionformatyearkey, s.itemcode_qsicode))
      ELSE s.[description]
    END,
    s.usefunctionforitemdetailind,
    CASE s.usefunctionforitemdetailind
      WHEN 1 THEN (dbo.get_itemdetailcode(s.taqversionformatyearkey, s.itemcode_qsicode))
      ELSE s.itemdetailcode 
    END itemdetailcode,
    CASE s.usefunctionforitemdetailind
		WHEN 1 then
			CASE (dbo.get_itemdetailcode(s.taqversionformatyearkey, s.itemcode_qsicode))
				WHEN NULL THEN NULL
				WHEN 0 THEN NULL
				ELSE CASE
				WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = s.itemcategorycode AND datasubcode = s.itemcode) > 0 THEN 
					(SELECT g.datadesc FROM gentables g, subgentables t 
					WHERE t.tableid = 616 AND t.datacode = s.itemcategorycode AND t.datasubcode = s.itemcode AND g.tableid = t.numericdesc1 AND g.datacode = (dbo.get_itemdetailcode(s.taqversionformatyearkey, s.itemcode_qsicode)))
				ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = s.itemcategorycode AND datasubcode = s.itemcode AND datasub2code = (dbo.get_itemdetailcode(s.taqversionformatyearkey, s.itemcode_qsicode)))
				END
			END
		ELSE
			CASE s.itemdetailcode
				WHEN NULL THEN NULL
				WHEN 0 THEN NULL
				ELSE CASE
				WHEN (SELECT numericdesc1 FROM subgentables WHERE tableid = 616 AND datacode = s.itemcategorycode AND datasubcode = s.itemcode) > 0 THEN 
					(SELECT g.datadesc FROM gentables g, subgentables t 
					WHERE t.tableid = 616 AND t.datacode = s.itemcategorycode AND t.datasubcode = s.itemcode AND g.tableid = t.numericdesc1 AND g.datacode = s.itemdetailcode)
				ELSE (SELECT datadesc FROM sub2gentables WHERE tableid = 616 AND datacode = s.itemcategorycode AND datasubcode = s.itemcode AND datasub2code = s.itemdetailcode)
				END
			END
		END itemdetaildesc,
    s.usefunctionfordecimalind,
    CASE s.usefunctionfordecimalind
      WHEN 1 THEN (dbo.get_decimalvalue(s.taqversionformatyearkey, s.itemcode_qsicode))
      ELSE s.decimalvalue 
    END,
    s.usefunctionforuomind,
    CASE s.usefunctionforuomind
      WHEN 1 THEN (dbo.get_uomcode(s.taqversionformatyearkey, s.itemcode_qsicode))
      ELSE s.unitofmeasurecode 
    END,
    CASE unitofmeasurecode
      WHEN NULL THEN NULL
      WHEN 0 THEN NULL
      ELSE (SELECT g.datadesc FROM gentables g WHERE tableid = 613 AND datacode = s.unitofmeasurecode) 
    END uomdesc,
    s.validforprtscode, s.validforprtsdesc
  FROM qproject_get_specitems_by_printing(@i_taqversionformatyearkey) s

  RETURN
END