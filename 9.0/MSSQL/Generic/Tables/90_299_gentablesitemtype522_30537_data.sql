DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_usageclass INT,
  @v_newkey INT,
  @v_qsicode INT,
  @v_datacode INT,  
  @v_datasubcode	INT
  
BEGIN          
    -- 'Void'
    SELECT @v_max_code = datacode
      FROM gentables
     WHERE tableid = 522
       AND LTRIM(RTRIM(LOWER(datadesc))) = 'void'
       AND qsicode = 10 
       
    
    --'PO Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
	 -- Proforma PO Report
	  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
		FROM subgentables
	  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
	  
	  IF @v_datacode > 0
	  BEGIN
		SELECT @v_count = COUNT(*)
		FROM gentablesitemtype
		WHERE tableid = 522 AND 
		  itemtypecode = @v_datacode AND
		  itemtypesubcode = @v_datasubcode AND
		  datacode = @v_max_code
	      
		IF @v_count = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	      
		  INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
		  VALUES
			(@v_newkey, 522, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
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
		WHERE tableid = 522 AND 
		  itemtypecode = @v_datacode AND
		  itemtypesubcode = @v_datasubcode AND
		  datacode = @v_max_code
	      
		IF @v_count = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	      
		  INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
		  VALUES
			(@v_newkey, 522, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
		END
	  END 	
	
END
GO