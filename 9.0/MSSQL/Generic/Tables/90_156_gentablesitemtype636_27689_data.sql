DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_newkey INT,
  @v_itemtypecode INT,  
  @v_usageclass INT
  
    -- Specification Template project statuses:
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 636 AND datadesc = 'Specification'  -- Specification Template
  
BEGIN

  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Apply Spec Template button'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Versions button'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Scale Verification button'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Total # of Characters'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Total # of Words'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  
    
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Manuscript Pages'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Specifications For Format dropdown'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Printing Number dropdown'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 0)
    END
  END
  
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Media/Format Edit dropdowns'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
  END
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Component List – Whole Grid'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
  END  
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Component List – Component Process'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
  END  
  
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Component List – Scale Type'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 2)
    END
  END  
  
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 636 AND datacode = @v_datacode AND datadesc = 'Component List – Vendor'
  
  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 3)
    END
  END  
  
END
go

