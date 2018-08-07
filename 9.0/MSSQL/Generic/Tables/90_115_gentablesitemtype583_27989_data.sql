DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_itemtypecode INT  
  
BEGIN
  
  -- Purchase Order tab item type filtered to appear on Printings
  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode  = 14 -- Printing
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 32   --Purchase Orders (on Printings)
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = @v_itemtypecode AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, @v_itemtypecode, 0, 'QSIDBA', getdate())
    END
  END
  
  -- Printings tab item type filtered to appear on Purchase Orders 
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 41 -- Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 33   --Printings (on Purchase Orders)
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = @v_itemtypecode AND 
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  -- Purchase Order tab item type filtered to appear on on PO Reports (both Proforma and Final)
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and datadesc = 'Proforma PO Report'   -- Proforma PO Report
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 34   --Purchase Orders (on PO Reports)
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and datadesc = 'Final PO Report'   -- Final PO Report
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 34   --Purchase Orders (on PO Reports)
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  -- PO Report tab item type filtered to appear on Purchase Orders/Purchase Orders class
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and datadesc = 'Purchase Orders'   -- Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 35   --PO Report
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
END
go