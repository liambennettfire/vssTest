DECLARE @o_copygroup_datacode INT,
        @v_copygroup_datacode INT,
        @o_gentablesitemtypekey INT,
        @v_usageclass INT,
        @v_itemtype INT,
        @v_po_itemtype INT,
        @v_sortorder INT,
        @o_error_code INT,
        @o_error_desc VARCHAR(2000)

SET @o_copygroup_datacode = NULL
SET @o_error_code = 0
SET @o_error_desc = NULL

SELECT @v_po_itemtype = datacode FROM gentables WHERE tableid=550 AND qsicode=15

-- Update Production Specification data group
SELECT @v_copygroup_datacode = datacode FROM gentables WHERE tableid=598 AND qsicode=25

UPDATE gentables
SET datadesc = 'Specifications/Costs (No Comp Qtys)', alternatedesc1 = 'Copy the Production Specifications AND Costs removing all the component quantities.'
WHERE tableid = 598 AND datacode = @v_copygroup_datacode

DELETE FROM gentablesitemtype
WHERE tableid = 598 
  AND datacode = @v_copygroup_datacode
  AND itemtypecode = @v_po_itemtype

EXEC qutl_insert_gentable_value 598, 'CopyProjectDataGroups', 31, 'Specifications/Costs (Copy Qtys)', 1, 1, @o_copygroup_datacode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

IF @o_error_code = 0
BEGIN
  SELECT @v_sortorder = sortorder FROM gentables WHERE tableid = 598 AND qsicode = 25
  UPDATE gentables
  SET datacode = 31, sortorder = @v_sortorder + 1, gen1ind = 0, gen2ind = 1, datadescshort = 'Production Spec', 
  alternatedesc1 = 'Copy the Production Specifications AND Costs keeping all the component quantities.'
  WHERE tableid = 598 AND datacode = @o_copygroup_datacode

  SET @o_copygroup_datacode = 31

  -- Non-Report or Print-Run PO types
  DECLARE po_cur CURSOR FOR
  SELECT datasubcode FROM subgentables WHERE tableid = 550 AND datacode = @v_po_itemtype AND qsicode NOT IN (42, 43, 60)
  
  OPEN po_cur
  FETCH po_cur INTO @v_usageclass
  
  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    EXEC qutl_insert_gentablesitemtype 598, @o_copygroup_datacode, 0, 0, @v_po_itemtype, @v_usageclass, @o_error_code OUTPUT, @o_error_desc OUTPUT, @o_gentablesitemtypekey OUTPUT, NULL, NULL  
          
    IF @o_error_code = 0
    BEGIN
      UPDATE gentablesitemtype
      SET text1 = 'Copy the Specifications (with quantities)'
      WHERE gentablesitemtypekey = @o_gentablesitemtypekey
    END
    
    FETCH po_cur INTO @v_usageclass
  END
  
  CLOSE po_cur
  DEALLOCATE po_cur
END

IF @o_error_code <> 0
  PRINT 'ERROR: ' + @o_error_desc
