DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_itemsubtype  INT,
  @v_newkey	INT,
  @v_po_itemtype INT,
  @v_po_itemsubtype	INT,
  @v_prtg_itemtype	INT
  
BEGIN

  -- Set up Specification section configuration for Purchase Order/Purchase Order
  SELECT @v_po_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15	--Purchase Order
  
  SELECT @v_po_itemsubtype = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 41	--Purchase Order
   
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 1, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 2, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 3, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 4, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 5, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 6, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 7, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 1)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 8, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 9, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)  
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 10, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 11, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 12, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 13, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  

  -- Loop through all existing configurations and add the row for the newly added Component List - Related Project
  -- (set to invisible for all but Printings)
  DECLARE cur CURSOR FOR
    SELECT DISTINCT itemtypecode, itemtypesubcode 
    FROM gentablesitemtype 
    WHERE tableid = 636 AND datacode = 4
			
  OPEN cur
		
  FETCH NEXT FROM cur INTO @v_itemtype, @v_itemsubtype
		
  WHILE @@FETCH_STATUS = 0
  BEGIN

    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 4 AND datasubcode = 14 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 4, 14, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END   
			
    FETCH NEXT FROM cur INTO  @v_itemtype, @v_itemsubtype
  END
		
  CLOSE cur
  DEALLOCATE cur  
      
      
  SELECT @v_prtg_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 14	--Printing
  
  UPDATE gentablesitemtype
  SET sortorder = 1, text1 = 'Purchase Order'
  WHERE tableid = 636 AND datacode = 4 AND datasubcode = 14 AND itemtypecode = @v_prtg_itemtype
  
END
go
