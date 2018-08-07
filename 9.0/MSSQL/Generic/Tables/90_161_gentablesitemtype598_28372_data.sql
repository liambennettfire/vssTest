DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtypecode INT,
  @v_usageclass INT
  
BEGIN
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 25 -- Production Specification  
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 598 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, text1)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 'Copy the Specifications')
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 8 -- Tasks
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 598 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate())
    END
  END 
  
  

  -- P&L Templates project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 29  -- P&L Templates
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 16 -- P&L First Stage Version
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 598 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, text1)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 'Copy the P&L Version')
    END
  END

  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 8 -- Tasks
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 598 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate())
    END
  END   
  
END
go
