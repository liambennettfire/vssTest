DECLARE 
	@v_itemtypecode_printing INT,
	@v_itemtypecode_title INT,
    @v_usageclasscode_title INT,
	@v_datacode_taskdatetype INT,
	@v_newkey INT,
	@v_relateddatacode INT,
	@v_indicator1 TINYINT,
	@v_max_code INT,
	@v_count INT
	
	SELECT @v_itemtypecode_printing = datacode FROM gentables where tableid = 550 and qsicode = 14  --Printing
	
	SET @v_datacode_taskdatetype = 47 -- Warehouse Date
	
	UPDATE datetype
	   SET qsicode = 20
	 WHERE datetypecode = @v_datacode_taskdatetype
	
	SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 1 --Key date indicator
	
	IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 323 AND itemtypecode = @v_itemtypecode_printing 
		AND datacode = @v_datacode_taskdatetype AND relateddatacode = @v_relateddatacode AND indicator1 = @v_indicator1) BEGIN
    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

	  INSERT INTO gentablesitemtype
		(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, relateddatacode, indicator1)
	  VALUES
		(@v_newkey, 323, @v_datacode_taskdatetype, 0, @v_itemtypecode_printing, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
   	END
	
	
	SET @v_datacode_taskdatetype = 30  -- Bound Book date
	
	UPDATE datetype
	   SET qsicode = 21
	 WHERE datetypecode = @v_datacode_taskdatetype
	
	SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 1 --Key date indicator
	
	IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 323 AND itemtypecode = @v_itemtypecode_printing 
		AND datacode = @v_datacode_taskdatetype AND relateddatacode = @v_relateddatacode AND indicator1 = @v_indicator1) BEGIN
    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

	  INSERT INTO gentablesitemtype
		(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, relateddatacode, indicator1)
	  VALUES
		(@v_newkey, 323, @v_datacode_taskdatetype, 0, @v_itemtypecode_printing, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
    END
	
	SET @v_datacode_taskdatetype = 387  -- Production Bound Book date
	
	UPDATE datetype
	   SET qsicode = 22
	 WHERE datetypecode = @v_datacode_taskdatetype
	
	SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 1 --Key date indicator
	
	IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 323 AND itemtypecode = @v_itemtypecode_printing 
		AND datacode = @v_datacode_taskdatetype AND relateddatacode = @v_relateddatacode AND indicator1 = @v_indicator1) BEGIN
    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

	  INSERT INTO gentablesitemtype
		(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, relateddatacode, indicator1)
	  VALUES
		(@v_newkey, 323, @v_datacode_taskdatetype, 0, @v_itemtypecode_printing, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
   	END
   	
   	
   	-- Date Required
   	SELECT @v_max_code = MAX(datetypecode)
	  FROM datetype
	  WHERE datetypecode < 20000
	  
	  IF @v_max_code IS NULL
		SET @v_max_code = 0
   	
   	SELECT @v_count = COUNT(*)
	  FROM datetype
	  WHERE LOWER(description) = 'date required'
	  
	  
	IF @v_count = 0
	BEGIN
		SET @v_max_code = @v_max_code + 1
	    
		INSERT INTO datetype
		  (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
		  tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
		  sortorder, showintaqind,
		  taqtotmmind, taqkeyind,showallsectionsind, milestoneind,qsicode)
		VALUES
		  (@v_max_code, 'Date Required', 0, 0, 'Date Required', 'Required',
		  323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
		  0, 1,
		  0,1,0,1,24)
	END
	ELSE BEGIN
	    SELECT @v_datacode_taskdatetype = datetypecode FROM datetype WHERE LOWER(description) = 'date required'
	    
		UPDATE datetype
		   SET qsicode = 24
		 WHERE datetypecode = @v_datacode_taskdatetype
	END
	
	

	