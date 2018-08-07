-- Enable Culture field on selected Project Detail sections

DECLARE
  @v_sectioncode INT,
  @v_column INT,
  @v_sortorder INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_qsicode INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_posummary_qsicode INT,
  @v_poproforma_qsicode INT,
  @v_pofinal_qsicode INT,
  @v_newkey INT

DECLARE @InsertTable TABLE
(
  datacode INT,
  datasubcode INT,
  numericdesc1 INT,
  sortorder INT,
  itemtype INT,
  usageclass INT
)

------- Non-TAQ Project detail sections ---------------------------------------------------------
SET @v_sectioncode = 13

-- PO Summary
SELECT @v_posummary_qsicode = 41
    
-- Proforma PO Report
SELECT @v_poproforma_qsicode = 42
    
-- Final PO Report
SELECT @v_pofinal_qsicode = 43
    
DECLARE cur_projecttypes CURSOR FOR
  SELECT datacode, datasubcode, qsicode
  FROM subgentables s
  WHERE 
    s.tableid = 550 
    AND s.qsicode IN (@v_posummary_qsicode, @v_poproforma_qsicode, @v_pofinal_qsicode)

OPEN cur_projecttypes

FETCH NEXT FROM cur_projecttypes INTO @v_itemtype, @v_usageclass, @v_qsicode


WHILE @@FETCH_STATUS = 0
BEGIN
  IF @v_qsicode = @v_posummary_qsicode BEGIN
    SET @v_sortorder = 2
  END
  ELSE BEGIN
    SET @v_sortorder = 3
  END
  
  INSERT INTO @InsertTable
    (datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass)
  VALUES
    (@v_sectioncode, 26, 2, @v_sortorder, @v_itemtype, @v_usageclass)

  FETCH NEXT FROM cur_projecttypes INTO @v_itemtype, @v_usageclass, @v_qsicode
END

CLOSE cur_projecttypes 
DEALLOCATE cur_projecttypes

-- Insert into gentablesitemtype

DECLARE ins_cur CURSOR FOR
SELECT datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass
FROM @InsertTable

OPEN ins_cur

FETCH ins_cur INTO
  @v_datacode, @v_datasubcode, @v_column, @v_sortorder, @v_itemtype, @v_usageclass

WHILE @@FETCH_STATUS = 0
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM gentablesitemtype
    WHERE tableid=636 
      AND datacode = @v_datacode 
      AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      AND numericdesc1 IS NOT NULL
  )
  BEGIN
    -- This item type/usage class relies on the field column (numericdesc1) defaults from subgentables
    SET @v_column = NULL
  END

  IF NOT EXISTS (
    SELECT 1 FROM gentablesitemtype 
    WHERE tableid = 636 
      AND datacode = @v_datacode AND datasubcode = @v_datasubcode 
      AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      AND sortorder <> 0
  ) 
  BEGIN
    -- Make room for the new column row if necessary
    IF EXISTS (
      SELECT 1
      FROM gentablesitemtype i
        JOIN subgentables s ON s.tableid = i.tableid and s.datacode = i.datacode and s.datasubcode = i.datasubcode
      WHERE i.tableid=636 
        AND i.datacode = @v_datacode 
        AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
        AND ((i.numericdesc1 IS NULL AND s.numericdesc1 = @v_column) OR i.numericdesc1 = @v_column)
        AND @v_sortorder <> 0 
        AND i.sortorder = @v_sortorder
    )
    BEGIN
      UPDATE gentablesitemtype SET sortorder = sortorder + 1
      WHERE gentablesitemtypekey IN (
        SELECT gentablesitemtypekey
        FROM gentablesitemtype i
          JOIN subgentables s ON s.tableid = i.tableid and s.datacode = i.datacode and s.datasubcode = i.datasubcode
        WHERE i.tableid=636 
          AND i.datacode = @v_datacode 
          AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
          AND ((i.numericdesc1 IS NULL AND s.numericdesc1 = @v_column) OR i.numericdesc1 = @v_column)
          AND i.sortorder >= @v_sortorder
      )
    END
    
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, numericdesc1, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtype, @v_usageclass, @v_sortorder, @v_column, 'QSIDBA', getdate())

    IF @@ERROR <> 0 BEGIN
      PRINT 'Insert to gentablesitemtype had an error: tableid=636, datacode=' + cast(@v_datacode AS VARCHAR) + ' datasubcode=' + cast(@v_datasubcode AS VARCHAR) 
        + ' itemtypecode=' + cast(@v_itemtype AS VARCHAR) + ' itemtypesubcode=' + cast(@v_usageclass AS VARCHAR)
      GOTO ErrorExit
    END 
  END    
  ELSE IF EXISTS (
    SELECT 1 FROM gentablesitemtype 
    WHERE tableid = 636 
      AND datacode = @v_datacode AND datasubcode = @v_datasubcode 
      AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      AND sortorder = 0
  ) 
  BEGIN
    -- If the column exists with sortorder = 0 (hidden), update it.
    UPDATE gentablesitemtype 
      SET sortorder = @v_sortorder, numericdesc1 = @v_column, lastuserid = 'QSIDBA', lastmaintdate = getdate()
    WHERE tableid = 636 
      AND datacode = @v_datacode AND datasubcode = @v_datasubcode 
      AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
      AND sortorder = 0
  END
  
  FETCH ins_cur INTO
    @v_datacode, @v_datasubcode, @v_column, @v_sortorder, @v_itemtype, @v_usageclass
END

ErrorExit:
CLOSE ins_cur
DEALLOCATE ins_cur

GO
