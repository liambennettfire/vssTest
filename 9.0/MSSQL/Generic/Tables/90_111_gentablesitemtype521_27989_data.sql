DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT
  
BEGIN
  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 521 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 521 AND gentablesitemtype.datacode = g.datacode)

  -- Purchase Orders project types:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 41 -- 'purchase orders'
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'component'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'finished good'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'whole book purchase'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'composition'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'miscellaneous'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 42 -- 'proforma po report'
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND qsicode = 5 -- 'proforma po report'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 43 -- 'final po report'
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND qsicode = 6 -- 'final po report'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
    
END
go
