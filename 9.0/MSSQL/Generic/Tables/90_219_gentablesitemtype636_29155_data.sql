DECLARE
  @v_count  INT,
  @v_datacode_ParticipantsByRole1 INT,
  @v_datacode_ParticipantsByRole2 INT,
  @v_datacode_ParticipantsByRole3 INT,
  @v_datasubcode INT,
  @v_usageclass_ParticipantsByRole1 INT,  
  @v_usageclass_ParticipantsByRole2 INT,
  @v_usageclass_ParticipantsByRole3 INT,     
  @v_newkey INT,
  @v_itemtypecode INT
  
BEGIN

  SET @v_datacode_ParticipantsByRole1 = 6
  SET @v_datacode_ParticipantsByRole2 = 7
  SET @v_datacode_ParticipantsByRole3 = 8 

  SELECT @v_itemtypecode = datacode, @v_usageclass_ParticipantsByRole1 = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders
  
  SELECT  @v_usageclass_ParticipantsByRole2 = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  -- Proforma PO Report
  
  SELECT @v_usageclass_ParticipantsByRole3 = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  -- Final PO Report
 
 -- Participants by Role 1 & Participants by Role 2 & Participants by Role 3  
  SET @v_datasubcode = 1 -- Role
  
  ------------------------------- Purchase Orders - Participants by Role 1 
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 1 
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END       
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END    
    
  ------------------------------- Purchase Orders - Participants by Role 2 
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END     
    
  ------------------------------- Proforma PO Report - Participants by Role 2 
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Final PO Report - Participants by Role 2
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END           
  
  ------------------------------- Purchase Orders - Participants by Role 3 
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END     
    
  ------------------------------- Proforma PO Report - Participants by Role 3 
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END   
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END         
   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
  SET @v_datasubcode = 2 -- Key
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END
  
  ------------------------------- Proforma PO Report - Participants by Role 1    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END       
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END       
    
  ------------------------------- Purchase Orders - Participants by Role 2
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END    
  ------------------------------- Proforma PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END
  
  ------------------------------- Final PO Report - Participants by Role 2
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END           
  
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END    
  ------------------------------- Proforma PO Report - Participants by Role 3    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END  
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 2, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 2, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END        
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 3 -- Sort
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Proforma PO Report - Participants by Role 1  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END       
  
  
  ------------------------------- Purchase Orders - Participants by Role 2
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END 
    
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END 
    
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END     
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END        
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 4 -- Name
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END      

  ------------------------------- Purchase Orders - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END 
  ------------------------------- Proforma PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Final PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END        
  
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*) 
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*) 
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END     
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*) 
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 3, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 3, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END          
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 5 -- Address
  
------------------------------- Purchase Orders - Participants by Role 1  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
    
------------------------------- Proforma PO Report - Participants by Role 1  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
------------------------------- Final PO Report - Participants by Role 1  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
     
------------------------------- Purchase Orders - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 5, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END           
------------------------------- Proforma PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 5, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END       
  
------------------------------- Final PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 5, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END   
    
------------------------------- Purchase Orders - Participants by Role 3  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END  
  
------------------------------- Proforma PO Report - Participants by Role 3  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END        
    
------------------------------- Final PO Report - Participants by Role 3  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 4, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 6 -- Contact Relationship
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn',sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
		itemtypecode = @v_itemtypecode AND 
		itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
		datacode = @v_datacode_ParticipantsByRole1 AND
		datasubcode = @v_datasubcode	 
  END
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn',sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
		itemtypecode = @v_itemtypecode AND 
		itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
		datacode = @v_datacode_ParticipantsByRole1 AND
		datasubcode = @v_datasubcode	 
  END
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn',sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
		itemtypecode = @v_itemtypecode AND 
		itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
		datacode = @v_datacode_ParticipantsByRole1 AND
		datasubcode = @v_datasubcode	 
  END
        
------------------------------- Purchase Orders - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn', sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode 
  END  
          
------------------------------- Proforma PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn', sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode 
  END      
  
------------------------------- Final PO Report - Participants by Role 2    
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn', sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode 
  END  
    
------------------------------- Purchase Orders - Participants by Role 3  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn', sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END   
  
------------------------------- Proforma PO Report - Participants by Role 3  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn', sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END   
        
------------------------------- Final PO Report - Participants by Role 3  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 5, 'Attn')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Attn', sortorder = 5, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END          
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 7 -- Qty
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END   
    
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END       
    
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END     
    
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END        
  
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
      
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 8 -- Email
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 11, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 11, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END    
  
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 11, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 11, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 11, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 11, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END          
  
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
      
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 6, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 6, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END          
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------       
  SET @v_datasubcode = 9 -- Phone
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 7, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 7, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 7, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END     
  
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END     
  
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 7, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 7, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
  
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 7, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END        
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 10 -- Indicator
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END      
    
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 7, 'Components to be Sold')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Components to be Sold', sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
    
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 7, 'Components to be Sold')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Components to be Sold', sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END         
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 7, 'Components to be Sold')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Components to be Sold', sortorder = 7, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
    
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
    
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END      
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 11 -- Date
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
       
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 8, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 8, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
         
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 8, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 8, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 8, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 8, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
    
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END   
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END         
    
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END     
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 12 -- Ship Method
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END       
  
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 9, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 9, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
    
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 9, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 9, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END       

  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 9, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 9, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END  
    
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END     
      
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 13 -- Notes
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode 
  END  
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode 
  END 
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode 
  END     
    
  ------------------------------- Purchase Orders - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 10, 'Instructions')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Instructions', sortorder = 10, lastuserid = 'QSIDBA', lastmaintdate = getdate()   
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode 
  END 
    
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 10, 'Instructions')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Instructions', sortorder = 10, lastuserid = 'QSIDBA', lastmaintdate = getdate()   
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode 
  END      
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 10, 'Instructions')
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = 'Instructions', sortorder = 10, lastuserid = 'QSIDBA', lastmaintdate = getdate()   
	WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode 
  END 
    
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
    
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
  SET @v_datasubcode = 14 -- Add button
  
  ------------------------------- Purchase Orders - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Proforma PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END  
  
  ------------------------------- Final PO Report - Participants by Role 1
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole1, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole1 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END     
  
  ------------------------------- Proforma PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END      
  
  ------------------------------- Final PO Report - Participants by Role 2  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole2, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 1, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole2 AND
	datasubcode = @v_datasubcode
  END   
    
  ------------------------------- Purchase Orders - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole1, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole1 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END 
  
  ------------------------------- Proforma PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole2, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole2 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END       
    
  ------------------------------- Final PO Report - Participants by Role 3
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
	  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
    INSERT INTO gentablesitemtype
  	(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
    VALUES
  	(@v_newkey, 636, @v_datacode_ParticipantsByRole3, @v_datasubcode,  @v_itemtypecode, @v_usageclass_ParticipantsByRole3, 'QSIDBA', getdate(), 0, NULL)
  END
  ELSE BEGIN
	UPDATE gentablesitemtype SET text1 = NULL, sortorder = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE tableid = 636 AND 
	itemtypecode = @v_itemtypecode AND 
	itemtypesubcode = @v_usageclass_ParticipantsByRole3 AND
	datacode = @v_datacode_ParticipantsByRole3 AND
	datasubcode = @v_datasubcode
  END        
  
END
go
