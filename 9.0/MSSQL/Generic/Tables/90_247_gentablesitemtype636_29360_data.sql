DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_itemsubtype  INT,
  @v_newkey	INT,
  @v_po_itemtype INT,
  @v_po_itemsubtype	INT,
  @v_prtg_itemtype	INT
  
BEGIN

  -- Set up Costs section configuration for Purchase Order/Purchase Order
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
    (@v_newkey, 636, 9, 1, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 2, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 3, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 4, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 5, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 6, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 2)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 7, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 5)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 8, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 9, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 6)  
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 10, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 11, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 12, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 8)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 13, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 0)
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 14, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 9)
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 15, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 4)    
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 16, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 7)    
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 17, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 8)  
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 18, @v_po_itemtype, @v_po_itemsubtype, 'QSIDBA', GETDATE(), 3) 
    
    
  -- Set up Costs section configuration for Printings
  SELECT @v_prtg_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 14	--Printing
         
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 1, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 2, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 3, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 4, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 5, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 6, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 2)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 7, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 5)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 8, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 9, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 6)  
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 10, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 11, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 12, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 8)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 13, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 0)
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 14, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 9)
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 15, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 4)    
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 16, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 7)    
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 17, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 8)  
    
   EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 9, 18, @v_prtg_itemtype, 0, 'QSIDBA', GETDATE(), 3) 


  -- Loop through all existing configurations and add the row for the newly added Costs
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
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 1 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 1, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 1) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 2 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 2, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 1) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 3 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 3, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 1) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 4 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 4, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 1) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 5 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 5, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 1) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 6 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 6, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 2) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 7 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 7, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 3) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 8 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 8, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 4) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 9 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 9, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 10 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 10, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 5) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 11 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 11, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 6) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 12 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 12, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 7) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 13 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 13, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 8) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 14 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 14, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 9) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 15 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 15, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 16 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 16, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 17 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 17, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 9 AND datasubcode = 18 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 9, 18, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END
			
    FETCH NEXT FROM cur INTO  @v_itemtype, @v_itemsubtype
  END
		
  CLOSE cur
  DEALLOCATE cur  

  
END
go
