DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_datacode	INT,
  @v_newkey	INT
  
BEGIN
  -- Creation Date
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'creation date'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind)
    VALUES
      (@v_max_code, 'Creation Date', 0, 0, 'Creation Date', 'Creation',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1)
  END
  ELSE BEGIN
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LOWER(description) = 'creation date'
  END
  
  --filter 'Create Date' for Purchase Orders
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, 0, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Sent
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'final po date'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind)
    VALUES
      (@v_max_code, 'Final PO Sent', 0, 0, 'Final PO Sent', 'Final PO',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1)
  END
  ELSE BEGIN
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LOWER(description) = 'final po date'
  END
  
  --filter 'Final PO Sent' for Purchase Orders/Purchase Order
  SELECT @v_datacode = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 AND qsicode = 41  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = 15 AND
      itemtypesubcode = @v_datacode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, 15, @v_datacode, 'QSIDBA', getdate())
    END
  END
  
  -- PO Date
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'po date'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind)
    VALUES
      (@v_max_code, 'PO Date', 0, 0, 'PO Date', 'PO Date',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1)
  END
  ELSE BEGIN
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LOWER(description) = 'po date'
  END
  
  --'PO Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
  -- Proforma PO Report
  SELECT @v_datacode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND datacode = 15 AND qsicode = 42  --Proforma PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = 15 AND
      itemtypesubcode = @v_datacode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, 15, @v_datacode, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Report
  SELECT @v_datacode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND datacode = 15 AND qsicode = 43  --Final PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = 15 AND
      itemtypesubcode = @v_datacode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, 15, @v_datacode, 'QSIDBA', getdate())
    END
  END
    
END
go
  