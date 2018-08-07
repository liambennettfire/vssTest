DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtype INT,  
  @v_usageclass INT,  
  @v_usageclass_ProformaPO INT,
  @v_usageclass_FinalPO INT
  
BEGIN
  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 522 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 522 AND gentablesitemtype.datacode = g.datacode)

  -- Purchase Order statuses:
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 41  --Purchase Orders
  
  SELECT @v_usageclass_ProformaPO = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  --Proforma Report
  
  SELECT @v_usageclass_FinalPO = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  --Final Report  
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 14 -- 'Amended; PO Report Pending'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END  
    
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 6 -- 'Proforma Pending'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END    
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 7 -- 'Proforma Sent to Vendor'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END    
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 8 -- 'Final Pending'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END    
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 9 -- 'Final Sent to Vendor'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  END   
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 12 -- 'Cancelled before Sending'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass_ProformaPO AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_ProformaPO, 'QSIDBA', getdate())
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass_FinalPO AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_FinalPO, 'QSIDBA', getdate())
    END        
  END  
  
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 11 -- 'Amended'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode IN (@v_usageclass, 0) AND
      datacode = @v_datacode
      
    IF @v_count > 0
    BEGIN
	   DELETE FROM gentablesitemtype
	   WHERE tableid = 522 AND 
		 itemtypecode = @v_itemtype AND 
		 itemtypesubcode IN (@v_usageclass, 0) AND
		  datacode = @v_datacode
    END      
        
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass_ProformaPO AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_ProformaPO, 'QSIDBA', getdate())
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass_FinalPO AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_FinalPO, 'QSIDBA', getdate())
    END   
  END     
  
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 13 -- 'Sent to Vendor'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode IN (@v_usageclass, 0) AND
      datacode = @v_datacode
      
    IF @v_count > 0
    BEGIN
	   DELETE FROM gentablesitemtype
	   WHERE tableid = 522 AND 
		 itemtypecode = @v_itemtype AND 
		 itemtypesubcode IN (@v_usageclass, 0) AND
		  datacode = @v_datacode
    END 
      
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass_ProformaPO AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_ProformaPO, 'QSIDBA', getdate())
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = @v_itemtype AND 
      itemtypesubcode = @v_usageclass_FinalPO AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_FinalPO, 'QSIDBA', getdate())
    END   
  END   
  
  --SELECT @v_datacode = datacode
  --FROM gentables
  --WHERE tableid = 522 AND qsicode = 10 -- 'Void'
  
  --IF @v_datacode > 0
  --BEGIN
  --  SELECT @v_count = COUNT(*)
  --  FROM gentablesitemtype
  --  WHERE tableid = 522 AND 
  --    itemtypecode = @v_itemtype AND 
  --    itemtypesubcode = @v_usageclass AND
  --    datacode = @v_datacode
      
  --  IF @v_count = 0
  --  BEGIN
  --    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
  --    INSERT INTO gentablesitemtype
  --      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
  --    VALUES
  --      (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
  --  END  
  
  --  SELECT @v_count = COUNT(*)
  --  FROM gentablesitemtype
  --  WHERE tableid = 522 AND 
  --    itemtypecode = @v_itemtype AND 
  --    itemtypesubcode = @v_usageclass_ProformaPO AND
  --    datacode = @v_datacode
      
  --  IF @v_count = 0
  --  BEGIN
  --    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
  --    INSERT INTO gentablesitemtype
  --      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
  --    VALUES
  --      (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_ProformaPO, 'QSIDBA', getdate())
  --  END
    
  --  SELECT @v_count = COUNT(*)
  --  FROM gentablesitemtype
  --  WHERE tableid = 522 AND 
  --    itemtypecode = @v_itemtype AND 
  --    itemtypesubcode = @v_usageclass_FinalPO AND
  --    datacode = @v_datacode
      
  --  IF @v_count = 0
  --  BEGIN
  --    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
  --    INSERT INTO gentablesitemtype
  --      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
  --    VALUES
  --      (@v_newkey, 522, @v_datacode, @v_itemtype, @v_usageclass_FinalPO, 'QSIDBA', getdate())
  --  END   
  --END    
  
END
go
  