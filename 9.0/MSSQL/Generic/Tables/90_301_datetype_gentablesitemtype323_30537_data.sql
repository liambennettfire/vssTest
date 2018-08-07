UPDATE  datetype SET qsicode = 28 
WHERE LOWER(description) = 'po date'

GO

DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_datacode INT,  
  @v_datasubcode	INT,
  @v_newkey	INT
  
BEGIN

  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
 -- Amended Date    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'amended date'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
    VALUES
      (@v_max_code, 'Amended Date', 0, 0, 'Amended Date', 'Amended',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1, 29)
  END
  ELSE BEGIN
    UPDATE datetype 
    SET qsicode = 29, activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1
    WHERE LTRIM(RTRIM(LOWER(description))) =  'amended date'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'amended date'
  END
  
  --'Ammended Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
  -- Proforma PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  --Final PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
            
 -- Sent to Vendor
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'Sent to Vendor'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
    VALUES
      (@v_max_code, 'Sent to Vendor', 0, 0, 'Sent to Vendor', 'Sent to Ve',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1, 31)
  END
  ELSE BEGIN
    UPDATE datetype 
    SET qsicode = 31, activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1
    WHERE LTRIM(RTRIM(LOWER(description))) =  'Sent to Vendor'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'Sent to Vendor'
  END
  
  --'PO Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
  
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 41  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
    
  -- Proforma PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  --Final PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
  
 -- Cancelled
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'cancelled'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
    VALUES
      (@v_max_code, 'Cancelled', 0, 0, 'Cancelled', 'Cancelled',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1, 32)
  END
  ELSE BEGIN
    UPDATE datetype 
    SET qsicode = 32, activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1
    WHERE LTRIM(RTRIM(LOWER(description))) =  'Cancelled'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'Cancelled'
  END
  
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 41  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END  
  
  -- PO Date
  SELECT @v_max_code = datetypecode
  FROM datetype 
  WHERE qsicode = 28
  
  --'PO Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
  -- Proforma PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  --Final PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END  
  
  
    -- Create Date
  SELECT @v_max_code = datetypecode
  FROM datetype 
  WHERE qsicode = 17
  
  --'Create Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
  
  -- Purchase Orders
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 41  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END 
    
  -- Proforma PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  --Final PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END  
    
 ---- PO Voided
 -- SELECT @v_max_code = MAX(datetypecode)
 -- FROM datetype
 -- WHERE datetypecode < 20000
  
 -- IF @v_max_code IS NULL
 --   SET @v_max_code = 0
    
 -- SELECT @v_count = COUNT(*)
 -- FROM datetype
 -- WHERE LOWER(description) = 'po voided'
  
 -- IF @v_count = 0
 -- BEGIN
 --   SET @v_max_code = @v_max_code + 1
    
 --   INSERT INTO datetype
 --     (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
 --     tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
 --     sortorder, showintaqind,
 --     taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
 --   VALUES
 --     (@v_max_code, 'PO Voided', 0, 0, 'PO Voided', 'PO Voided',
 --     323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
 --     0, 1,
 --     0,1,0,1, 30)
 -- END
 -- ELSE BEGIN
 --   UPDATE datetype 
 --   SET qsicode = 30, activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1
 --   WHERE LTRIM(RTRIM(LOWER(description))) =  'po voided'
      
	--SELECT @v_max_code = datetypecode
 --     FROM datetype
 --    WHERE LTRIM(RTRIM(LOWER(description))) = 'po voided'
 -- END
  
 -- -- Proforma PO Report
 -- SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
 --   FROM subgentables
 -- WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
 -- IF @v_datacode > 0
 -- BEGIN
 --   SELECT @v_count = COUNT(*)
 --   FROM gentablesitemtype
 --   WHERE tableid = 323 AND 
 --     itemtypecode = @v_datacode AND
 --     itemtypesubcode = @v_datasubcode AND
 --     datacode = @v_max_code
      
 --   IF @v_count = 0
 --   BEGIN
 --     EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
 --     INSERT INTO gentablesitemtype
 --       (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
 --     VALUES
 --       (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
 --   END
 -- END
  
 -- -- Final PO Report
 -- SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
 --   FROM subgentables
 -- WHERE tableid = 550 AND qsicode = 43  --Final PO Report
  
 -- IF @v_datacode > 0
 -- BEGIN
 --   SELECT @v_count = COUNT(*)
 --   FROM gentablesitemtype
 --   WHERE tableid = 323 AND 
 --     itemtypecode = @v_datacode AND
 --     itemtypesubcode = @v_datasubcode AND
 --     datacode = @v_max_code
      
 --   IF @v_count = 0
 --   BEGIN
 --     EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
 --     INSERT INTO gentablesitemtype
 --       (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
 --     VALUES
 --       (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
 --   END
 -- END          
END
go