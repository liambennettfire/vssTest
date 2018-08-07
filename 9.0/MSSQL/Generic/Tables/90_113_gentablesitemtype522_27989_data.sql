DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT
  
BEGIN
  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 522 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 522 AND gentablesitemtype.datacode = g.datacode)

  -- Purchase Order statuses:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 41  --Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 4  -- Pending
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END

   
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 6 -- Proforma Created
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 7 --'proforma sent'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 8 -- 'final created'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END

  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 9 -- 'final sent'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END

  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 10 -- 'void'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 11  -- 'amended'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
 
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 12 --'cancelled before sending'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 43  --Final PO Report
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 13 -- 'sent to vendor'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
END
go
