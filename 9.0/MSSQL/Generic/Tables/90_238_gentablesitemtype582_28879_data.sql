DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_itemtype INT
  
BEGIN

  --Printing (for PO Reports)
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 582 AND qsicode = 29

  IF @v_datacode > 0
  BEGIN
      
    -- Purchase Order item type
    SELECT @v_itemtype = datacode
      FROM gentables 
     WHERE tableid = 550
       AND qsicode = 15

   -- Proforma PO Report Class
     SELECT @v_usageclass = datasubcode
       FROM subgentables
       WHERE tableid = 550 AND qsicode = 42
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 582, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END

   -- Final PO Report Class
    SELECT @v_usageclass = datasubcode
     FROM subgentables
     WHERE tableid = 550 AND qsicode = 43
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 582, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END
    
  -- PO Reports(for Printings)
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 582 AND qsicode = 30

  IF @v_datacode > 0
  BEGIN
      
    -- Purchase Order item type
    SELECT @v_itemtype = datacode
      FROM gentables 
     WHERE tableid = 550
       AND qsicode = 15

   -- Proforma PO Report Class
     SELECT @v_usageclass = datasubcode
       FROM subgentables
       WHERE tableid = 550 AND qsicode = 42
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 582, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END

   -- Final PO Report Class
    SELECT @v_usageclass = datasubcode
     FROM subgentables
     WHERE tableid = 550 AND qsicode = 43
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 582 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 582, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END
 
END
go
