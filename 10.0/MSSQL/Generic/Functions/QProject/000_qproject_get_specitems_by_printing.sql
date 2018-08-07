if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qproject_get_specitems_by_printing') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qproject_get_specitems_by_printing
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION [dbo].[qproject_get_specitems_by_printing](@i_taqversionformatyearkey int)

/***********************************************************************************************************************
**  Name: qproject_get_specitems_by_printing
**  Desc: Note that this does not return calculated values. 
**        qproject_get_specitems_by_printingview takes the output of this function and generates calculated values.
**
**  Auth: Kusum Basra
**  Date: 27 March 2012
************************************************************************************************************************
**  Change History
************************************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   -------------------------------------------
**  06/21/16  Kate      Fixes for related specs - see case 29764.
**  11/14/17  Colman    47625
**  02/01/18  Colman    48235
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
  itemcategory_qsicode  INT,
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
  usefunctionfordescind TINYINT,
  usefunctionforitemdetailind	TINYINT,
  usefunctionfordecimalind		TINYINT,
  usefunctionforuomind		TINYINT,
  validforprtscode		INT,
  validforprtsdesc		VARCHAR(40),
  itemdetailcode INT,
  description VARCHAR(2000),
  quantity  INT,
  decimalvalue  NUMERIC(15,4),
  unitofmeasurecode INT	
  )

AS
BEGIN
  DECLARE
  @v_taqversionformatyearkey	integer,
  @v_printingnumber	integer,
  @v_yearcode	integer,
  @v_taqprojectkey	integer,
  @v_plstagecode	integer,
  @v_taqversionkey	integer,
  @v_taqprojectformatkey	integer,
  @v_taqversionspecategorykey	integer,
  @v_relatedspeccategorykey	integer,
  @v_itemcategorycode	integer,
  @v_ignoreitemcategorycode integer,
  @v_itemcategorycode_qsicode integer,
  @v_speccategorydescription	VARCHAR(255), 
  @v_scaleprojecttype	integer,
  @v_scaleprojectdesc	varchar(255),
  @v_vendorcontactkey	integer,
  @v_vendordisplayname	varchar(255),
  @v_taqversionspecitemkey	integer, 
  @v_itemcode integer,
  @v_itemcode_qsicode integer,
  @v_itemdesc	varchar(120),
  @v_unitofmeasurecode	integer,
  @v_validforprtgscode integer,
  @v_validforprtsdesc	VARCHAR(40),
  @v_itemdetailcode	integer,
  @v_usefunctionforitemdetailind TINYINT,
  @v_usefunctionforqtyind	TINYINT,
  @v_usefunctionfordescind       TINYINT,
  @v_usefunctionfordecimalind	TINYINT,
  @v_usefunctionforuomind      TINYINT,
  @v_culturecode INT,
  @v_description VARCHAR(4000),
  @v_quantity INT,
  @v_decimalvalue NUMERIC(15,4),
  @v_itemtype INT,
  @v_summarycode INT
  
  DECLARE @tbl_related_summary TABLE
  (
    taqprojectkey INT,
    plstagecode INT,
    taqversionkey INT,
    taqversionformatkey INT,
    taqversionspecategorykey INT, 
    relatedspeccategorykey INT, 
    itemcategorycode INT, 
    speccategorydescription VARCHAR(255), 
    scaleprojecttype INT, 
    vendorcontactkey INT
  )
      
  IF @i_taqversionformatyearkey > 0
    DECLARE taqversionformatyear_cur CURSOR fast_forward FOR
      SELECT y.taqversionformatyearkey, y.printingnumber, y.yearcode, y.taqprojectkey, y.plstagecode, y.taqversionkey, y.taqprojectformatkey, p.searchitemcode
      FROM taqversionformatyear y
        JOIN taqproject p ON p.taqprojectkey = y.taqprojectkey
      WHERE printingnumber > 0 AND taqversionformatyearkey = @i_taqversionformatyearkey
  ELSE
    DECLARE taqversionformatyear_cur CURSOR fast_forward FOR
      SELECT y.taqversionformatyearkey, y.printingnumber, y.yearcode, y.taqprojectkey, y.plstagecode, y.taqversionkey, y.taqprojectformatkey, p.searchitemcode
      FROM taqversionformatyear y
        JOIN taqproject p ON p.taqprojectkey = y.taqprojectkey
      WHERE printingnumber > 0
		  
  OPEN taqversionformatyear_cur
		
  FETCH from taqversionformatyear_cur 
  INTO @v_taqversionformatyearkey, @v_printingnumber, @v_yearcode, @v_taqprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey, @v_itemtype

  WHILE @@fetch_status = 0
  BEGIN

    -- Get project culture
    SELECT @v_culturecode = projectculturecode FROM dbo.get_culture(0, @v_taqprojectkey, 0)
    SET @v_ignoreitemcategorycode = 0

    IF @v_itemtype = 15 -- Purchase Order
    BEGIN
      SELECT @v_summarycode = datacode FROM gentables WHERE tableid = 616 AND qsicode = 1
      SET @v_ignoreitemcategorycode = @v_summarycode
      
      IF EXISTS (SELECT 1
        FROM taqversionspeccategory
        WHERE taqprojectkey = @v_taqprojectkey
          AND plstagecode = @v_plstagecode
          AND taqversionkey = @v_taqversionkey
          AND taqversionformatkey = @v_taqprojectformatkey
          AND itemcategorycode = @v_summarycode
          AND relatedspeccategorykey IS NOT NULL
      ) 
      BEGIN
        -- Return related Summary component on the PO if one exists (there should never be a non-related summary so we ignore it if there is.)
        INSERT INTO @tbl_related_summary
          SELECT taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, relatedspeccategorykey AS taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, speccategorydescription, 
            scaleprojecttype, vendorcontactkey
        FROM taqversionspeccategory
        WHERE taqprojectkey = @v_taqprojectkey
          AND plstagecode = @v_plstagecode
          AND taqversionkey = @v_taqversionkey
          AND taqversionformatkey = @v_taqprojectformatkey
          AND itemcategorycode = @v_summarycode
          AND relatedspeccategorykey IS NOT NULL
      END 
      ELSE 
      BEGIN
        -- If there is no related Summary component on the PO see if we can find one on a related printing (there should never be a non-related summary so we ignore it if there is.)
        INSERT INTO @tbl_related_summary
          SELECT taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, taqversionspecategorykey, taqversionspecategorykey AS relatedspeccategorykey, itemcategorycode, speccategorydescription, 
            scaleprojecttype, vendorcontactkey
          FROM taqversionspeccategory
          WHERE taqprojectkey = (
            SELECT TOP 1 prv.relatedprojectkey
            FROM projectrelationshipview prv
              LEFT OUTER JOIN taqversionformatrelatedproject vfrp ON vfrp.relatedprojectkey = prv.relatedprojectkey
            WHERE prv.taqprojectkey = @v_taqprojectkey 
              AND prv.relationshipcode = (SELECT datacode FROM gentables WHERE tableid=582 AND qsicode=25) -- Printing (for Purchase Orders)
            ORDER BY vfrp.editioncostpercent DESC
          )
          AND itemcategorycode = @v_summarycode
      END
    END

    -- Get all specs: 
    -- first part of the union are specs sitting directly on the project, 
    -- second part are specs on related project, 
    -- third is summary specs from a related printing
    DECLARE taqversionspeccategory_cur CURSOR FOR       
      SELECT taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, taqversionspecategorykey, taqversionspecategorykey, 
             itemcategorycode, speccategorydescription, scaleprojecttype, vendorcontactkey
      FROM taqversionspeccategory
      WHERE taqprojectkey = @v_taqprojectkey
        AND plstagecode = @v_plstagecode
        AND taqversionkey = @v_taqversionkey
        AND taqversionformatkey = @v_taqprojectformatkey
        AND itemcategorycode <> @v_ignoreitemcategorycode
        AND ISNULL(relatedspeccategorykey,0) = 0 
      UNION
      SELECT c.taqprojectkey, c.plstagecode, c.taqversionkey, c.taqversionformatkey, c.taqversionspecategorykey, c.relatedspeccategorykey, c2.itemcategorycode, c2.speccategorydescription, 
             c2.scaleprojecttype, c2.vendorcontactkey
      FROM taqversionspeccategory c
        JOIN taqversionspeccategory c2 ON c2.taqversionspecategorykey = c.relatedspeccategorykey
      WHERE c.taqprojectkey = @v_taqprojectkey
        AND c.plstagecode = @v_plstagecode
        AND c.taqversionkey = @v_taqversionkey
        AND c.taqversionformatkey = @v_taqprojectformatkey
        AND c.itemcategorycode <> @v_ignoreitemcategorycode
        AND c.relatedspeccategorykey > 0
      UNION
      SELECT taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, speccategorydescription, 
             scaleprojecttype, vendorcontactkey
      FROM @tbl_related_summary

    OPEN taqversionspeccategory_cur

    FETCH taqversionspeccategory_cur
      INTO @v_taqprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey, @v_taqversionspecategorykey, @v_relatedspeccategorykey, 
        @v_itemcategorycode, @v_speccategorydescription, @v_scaleprojecttype, @v_vendorcontactkey

    WHILE @@fetch_status = 0
    BEGIN

      IF @v_printingnumber = 1
        DECLARE taqversionspecitems_cur CURSOR fast_forward FOR
          SELECT taqversionspecitemkey, itemcode, unitofmeasurecode, validforprtgscode, 
            itemdetailcode, description, quantity, decimalvalue, unitofmeasurecode
          FROM taqversionspecitems
          WHERE taqversionspecategorykey = @v_relatedspeccategorykey
          AND COALESCE(validforprtgscode,3) in (1,3) --Valid for 1st and all printings
      ELSE
        DECLARE taqversionspecitems_cur CURSOR fast_forward FOR
          SELECT taqversionspecitemkey, itemcode, unitofmeasurecode, validforprtgscode, 
            itemdetailcode, description, quantity, decimalvalue, unitofmeasurecode
          FROM taqversionspecitems
          WHERE taqversionspecategorykey = @v_relatedspeccategorykey
            AND COALESCE(validforprtgscode,3) in (2,3)  --Valid for all but 1st printing and all printings
    		
      OPEN taqversionspecitems_cur
    		
      FETCH from taqversionspecitems_cur 
      INTO @v_taqversionspecitemkey, @v_itemcode, @v_unitofmeasurecode, @v_validforprtgscode, 
        @v_itemdetailcode, @v_description, @v_quantity, @v_decimalvalue, @v_unitofmeasurecode

      -- If there are no spec items for a summary component, add one anyway
      IF @v_itemcategorycode = @v_summarycode AND @@FETCH_STATUS <> 0
        INSERT INTO @specitemsbyprinting
          (taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
          taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
          scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
          taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
          usefunctionforqtyind, usefunctionfordescind, usefunctionforitemdetailind, usefunctionfordecimalind, usefunctionforuomind,
          validforprtscode, validforprtsdesc, description, quantity, decimalvalue, unitofmeasurecode, itemdetailcode)
        VALUES
          (@v_taqversionformatyearkey, @v_printingnumber, @v_yearcode, @v_taqprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey,
          @v_taqversionspecategorykey, @v_relatedspeccategorykey, @v_itemcategorycode, @v_itemcategorycode_qsicode, @v_speccategorydescription,
          @v_scaleprojecttype, @v_scaleprojectdesc, @v_vendorcontactkey, @v_vendordisplayname,
          NULL, 0, 0, NULL, 0, 0, 0, 0, 0, 3, NULL, NULL, 0, 0, 0, 0)

      WHILE @@fetch_status = 0
      BEGIN

        IF @v_scaleprojecttype IS NOT NULL AND @v_scaleprojecttype <> 0
          SELECT @v_scaleprojectdesc = datadesc 
          FROM gentables 
          WHERE tableid = 521 AND datacode = @v_scaleprojecttype
        ELSE
          SELECT @v_scaleprojectdesc = NULL

        SET @v_itemdesc = NULL
        SET @v_itemcode_qsicode = NULL
        SET @v_itemcategorycode_qsicode = NULL
        IF @v_itemcategorycode IS NOT NULL AND @v_itemcategorycode <> 0
        BEGIN
          SELECT @v_itemcategorycode_qsicode = qsicode
          FROM gentables
          WHERE tableid = 616 AND datacode = @v_itemcategorycode

          IF @v_itemcode IS NOT NULL AND @v_itemcode <> 0
            SELECT @v_itemdesc = datadesc, @v_itemcode_qsicode = qsicode
            FROM subgentables
            WHERE tableid = 616 AND datacode = @v_itemcategorycode AND datasubcode = @v_itemcode
        END

        IF @v_vendorcontactkey IS NOT NULL AND @v_vendorcontactkey <> 0
          SELECT @v_vendordisplayname = displayname
          FROM globalcontact
          WHERE globalcontactkey = @v_vendorcontactkey
        ELSE
          SELECT @v_vendordisplayname = NULL
    	
        SELECT @v_usefunctionforitemdetailind = usefunctionforitemdetailind, @v_usefunctionforqtyind = usefunctionforqtyind, 
          @v_usefunctionfordescind = usefunctionfordescind, @v_usefunctionfordecimalind = usefunctionfordecimalind, 
          @v_usefunctionforuomind = usefunctionforuomind
        FROM taqspecadmin
        WHERE itemcategorycode = @v_itemcategorycode
          AND itemcode = @v_itemcode
          AND culturecode = @v_culturecode

        IF @v_validforprtgscode > 0
          SELECT @v_validforprtsdesc = datadesc FROM gentables where tableid = 623 AND datacode = @v_validforprtgscode
        ELSE
          SET @v_validforprtsdesc = NULL

        INSERT INTO @specitemsbyprinting
          (taqversionformatyearkey, printingnumber, yearcode, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
          taqversionspecategorykey, relatedspeccategorykey, itemcategorycode, itemcategory_qsicode, speccategorydescription,
          scaleprojecttype, scaleprojectdesc, vendorcontactkey, vendordisplayname,
          taqversionspecitemkey, itemcode, itemcode_qsicode, itemdesc,
          usefunctionforqtyind, usefunctionfordescind, usefunctionforitemdetailind, usefunctionfordecimalind, usefunctionforuomind,
          validforprtscode, validforprtsdesc, description, quantity, decimalvalue, unitofmeasurecode, itemdetailcode)
        VALUES
          (@v_taqversionformatyearkey, @v_printingnumber, @v_yearcode, @v_taqprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey,
          @v_taqversionspecategorykey, @v_relatedspeccategorykey, @v_itemcategorycode, @v_itemcategorycode_qsicode, @v_speccategorydescription,
          @v_scaleprojecttype, @v_scaleprojectdesc, @v_vendorcontactkey, @v_vendordisplayname,
          @v_taqversionspecitemkey, @v_itemcode, @v_itemcode_qsicode, @v_itemdesc,
          @v_usefunctionforqtyind, @v_usefunctionfordescind, @v_usefunctionforitemdetailind, @v_usefunctionfordecimalind, @v_usefunctionforuomind,
          @v_validforprtgscode, @v_validforprtsdesc, @v_description, @v_quantity, @v_decimalvalue, @v_unitofmeasurecode, @v_itemdetailcode)

        FETCH from taqversionspecitems_cur 
        INTO @v_taqversionspecitemkey, @v_itemcode, @v_unitofmeasurecode, @v_validforprtgscode, 
          @v_itemdetailcode, @v_description, @v_quantity, @v_decimalvalue, @v_unitofmeasurecode
      END  --taqversionspecitems_cur

      CLOSE taqversionspecitems_cur
      DEALLOCATE taqversionspecitems_cur 

      FETCH taqversionspeccategory_cur
      INTO @v_taqprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey, @v_taqversionspecategorykey, @v_relatedspeccategorykey, 
        @v_itemcategorycode, @v_speccategorydescription, @v_scaleprojecttype, @v_vendorcontactkey
    END --taqversionspeccategory_cur

    CLOSE taqversionspeccategory_cur
    DEALLOCATE taqversionspeccategory_cur

    FETCH from taqversionformatyear_cur 
    INTO @v_taqversionformatyearkey, @v_printingnumber, @v_yearcode, @v_taqprojectkey, @v_plstagecode, @v_taqversionkey, @v_taqprojectformatkey, @v_itemtype
  END  --taqversionformatyear_cur
	  
  CLOSE taqversionformatyear_cur
  DEALLOCATE taqversionformatyear_cur

	RETURN
END
