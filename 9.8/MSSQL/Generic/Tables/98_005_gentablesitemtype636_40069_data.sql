DECLARE
  @v_qsicode INT,
  @v_newkey INT,
  @v_count INT,
  @v_sortorder INT,
  @v_po_itemtypecode INT,
  @v_po_itemtypesubcode INT,
  @v_xpo_itemtypesubcode INT,
  @v_pbr_sectiondatacode INT,
  @v_pbr_productsubcode INT

-- PO Item Type
SELECT @v_po_itemtypecode = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 15

-- Express PO Summary class
SELECT @v_xpo_itemtypesubcode = datasubcode
FROM subgentables
WHERE tableid = 550 AND qsicode = 51

SET @v_pbr_sectiondatacode = 6  -- Participant By Role 1
SET @v_pbr_productsubcode = 15  -- PO Section (Product)

-- For each PBR section
WHILE (@v_pbr_sectiondatacode < 9)
BEGIN
  -- For each PO usage class
  DECLARE poclass_cursor CURSOR FOR
  SELECT datasubcode FROM subgentables WHERE tableid = 550 AND datacode = @v_po_itemtypecode
  OPEN poclass_cursor
  FETCH poclass_cursor INTO @v_po_itemtypesubcode

  WHILE (@@FETCH_STATUS = 0)
  BEGIN	
    SELECT @v_count = COUNT(*) 
    FROM gentablesitemtype 
    WHERE tableid = 636 AND itemtypecode = @v_po_itemtypecode AND itemtypesubcode = @v_po_itemtypesubcode AND datacode = @v_pbr_sectiondatacode AND datasubcode = @v_pbr_productsubcode

    IF @v_count = 0 BEGIN
      SET @v_sortorder = 0
      
      -- If this is Participant By Role 2 for Express PO class
      IF @v_po_itemtypesubcode = @v_xpo_itemtypesubcode AND @v_pbr_sectiondatacode = 7 
      BEGIN
        -- Insert Product column as sortorder 3 and increment the remaining existing columns
        SET @v_sortorder = 3
        UPDATE gentablesitemtype 
        SET sortorder = sortorder + 1 
        WHERE sortorder >= @v_sortorder AND tableid = 636 AND itemtypecode = @v_po_itemtypecode AND itemtypesubcode = @v_po_itemtypesubcode AND datacode = @v_pbr_sectiondatacode
      END
        
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 636, @v_pbr_sectiondatacode, @v_pbr_productsubcode, @v_po_itemtypecode, @v_po_itemtypesubcode, @v_sortorder, 'QSIDBA', getdate())
    END
    FETCH poclass_cursor INTO @v_po_itemtypesubcode
  END
  
  CLOSE poclass_cursor
  DEALLOCATE poclass_cursor
  
  SET @v_pbr_sectiondatacode = @v_pbr_sectiondatacode + 1
END

GO