DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtypecode INT,  
  @v_usageclass INT
  
BEGIN
  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 521 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 521 AND gentablesitemtype.datacode = g.datacode)
                
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
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
    ELSE BEGIN
		UPDATE gentablesitemtype SET sortorder = 1
		WHERE tableid = 521 AND 
		  itemtypecode = 15 AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode		 
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
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
    ELSE BEGIN
		UPDATE gentablesitemtype SET sortorder = 1
		WHERE tableid = 521 AND 
		  itemtypecode = 15 AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode    
    END    
  END   
               
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 14 and qsicode = 40 --Printing
        
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND qsicode = 7 -- Converted printing      
  
  IF @v_datacode > 0
  BEGIN   
	  SELECT @v_count = COUNT(*)
	  FROM gentablesitemtype
	  WHERE tableid = 521 AND 
		itemtypecode = 14 AND 
		itemtypesubcode = @v_usageclass AND
		datacode = @v_datacode
		  
	  IF @v_count = 0
	  BEGIN
		EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
		  
		INSERT INTO gentablesitemtype
		  (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
		 VALUES
		  (@v_newkey, 521, @v_datacode, 14, @v_usageclass, 'QSIDBA', getdate(), 999)
	  END
	  ELSE BEGIN
		 UPDATE gentablesitemtype SET sortorder = 999
		 WHERE tableid = 521 AND 
			itemtypecode = 14 AND 
			itemtypesubcode = @v_usageclass AND
			datacode = @v_datacode   
	  END  	  
   END	  
  
  -- Printing:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'specification template'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 521, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
    ELSE BEGIN
		UPDATE gentablesitemtype SET sortorder = 1
		WHERE tableid = 521 AND 
		  itemtypecode = @v_itemtypecode AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode  
    END     
  END          
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 42 -- 'proforma po report'      
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND qsicode = 9 -- Converted PO 
  
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
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate(), 999)
    END
    ELSE BEGIN
		UPDATE gentablesitemtype SET sortorder = 999
		WHERE tableid = 521 AND 
		  itemtypecode = @v_itemtypecode AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode  
    END       
  END  
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and qsicode = 43 -- 'final po report'   
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 521 AND qsicode = 9 -- Converted PO 
  
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
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 521, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate(), 999)
    END
    ELSE BEGIN
		UPDATE gentablesitemtype SET sortorder = 999
		WHERE tableid = 521 AND 
		  itemtypecode = @v_itemtypecode AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode  
    END       
  END    
END
GO