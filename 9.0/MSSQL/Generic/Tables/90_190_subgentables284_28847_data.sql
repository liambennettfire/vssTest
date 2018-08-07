DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_count2 INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_usageclass INT,
  @v_newkey INT
  

BEGIN
  SELECT @v_datacode = datacode
    FROM gentables
   WHERE tableid = 284
     AND LOWER(datadesc) = 'project'
     

     
  IF NOT EXISTS (SELECT * FROM subgentables WHERE tableid = 284 AND datacode = @v_datacode and LOWER(datadesc)
    = 'po shipping instructions') BEGIN
    SELECT @v_max_code = MAX(datasubcode)
    FROM subgentables
    WHERE tableid = 284
      AND datacode = @v_datacode
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM subgentables
    WHERE tableid = 284 AND datacode = @v_datacode and LOWER(datadesc) = 'po shipping instructions'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO subgentables
        (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, qsicode)
      VALUES
        (284, @v_datacode,@v_max_code, 'PO Shipping Instructions', 'N', 'COMMENTT', NULL, 'PO Ship Instr.',
        'QSIDBA', getdate(), 1,2)
        
        
     -- Purchase Orders/Purchase Order itemtype filter:
	  SELECT @v_usageclass = datasubcode
	  FROM subgentables
	  WHERE tableid = 550 AND datacode = 15 and qsicode = 41  
	  
	  SELECT @v_count2 = COUNT(*)
		FROM gentablesitemtype
		WHERE tableid = 284 AND 
		  itemtypecode = 15 AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode AND
		  datasubcode = @v_max_code
	      
	  IF @v_count2 = 0
	  BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	      
		  INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
		  VALUES
			(@v_newkey, 284, @v_datacode, @v_max_code, 15, @v_usageclass, 'QSIDBA', getdate())
	  END
	END
  END
  ELSE BEGIN
    SELECT @v_datasubcode = datasubcode
      FROM subgentables
     WHERE tableid = 284
       AND datacode = @v_datacode
       AND LOWER(datadesc) = 'po shipping instructions'
  
      
	UPDATE subgentables
	   SET lockbyqsiind = 1,
	       qsicode = 2,
	       lastuserid = 'QSIDBA',
	       lastmaintdate = getdate()
	 WHERE tableid = 284
	   AND datacode = @v_datacode 
	   AND datasubcode = @v_datasubcode
	   AND LOWER(datadesc) = 'po shipping instructions'
	   
	   
	 -- Purchase Orders/Purchase Order itemtype filter:
	  SELECT @v_usageclass = datasubcode
	  FROM subgentables
	  WHERE tableid = 550 AND datacode = 15 and qsicode = 41  
	  
	 
	  SELECT @v_count2 = COUNT(*)
		FROM gentablesitemtype
		WHERE tableid = 284 AND 
		  itemtypecode = 15 AND 
		  itemtypesubcode = @v_usageclass AND
		  datacode = @v_datacode AND
		  datasubcode = @v_datasubcode
	   
	  IF @v_count2 = 0
	  BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	      
		  INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
		  VALUES
			(@v_newkey, 284, @v_datacode, @v_datasubcode, 15, @v_usageclass, 'QSIDBA', getdate())
	  END
  END

END
go
