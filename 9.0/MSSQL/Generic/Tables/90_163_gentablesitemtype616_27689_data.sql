DECLARE 
	@v_itemtypecode_PLTemplate INT,
	@v_itemtypesubcode_PLTemplate INT,	
	@v_itemtypecode_ProjectTAQ INT,
    @v_usageclasscode_ProjectTAQ INT,
	@v_datacode_SI INT,
	@v_datasubcode_SI INT,	    	
	@v_relateddatacode_SI INT,	
	@v_newkey INT
	
	SELECT @v_itemtypecode_PLTemplate = datacode, @v_itemtypesubcode_PLTemplate = datasubcode FROM subgentables where tableid = 550 and qsicode = 29
    SELECT @v_itemtypecode_ProjectTAQ = datacode, @v_usageclasscode_ProjectTAQ = datasubcode FROM subgentables where tableid = 550 and qsicode = 1
    
	  DECLARE SpecificationItems_gentablesitemtype_cur CURSOR FOR
		SELECT DISTINCT datacode, datasubcode, relateddatacode from gentablesitemtype where tableid = 616 and itemtypecode = @v_itemtypecode_ProjectTAQ AND itemtypesubcode IN (0, @v_usageclasscode_ProjectTAQ)  
		
	  OPEN SpecificationItems_gentablesitemtype_cur

	  FETCH NEXT FROM SpecificationItems_gentablesitemtype_cur INTO @v_datacode_SI, @v_datasubcode_SI, @v_relateddatacode_SI

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN	  
		  IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 616 and itemtypecode = @v_itemtypecode_PLTemplate and itemtypesubcode IN (@v_itemtypesubcode_PLTemplate, 0) and datacode = @v_datacode_SI AND datasubcode = @v_datasubcode_SI) 
		  BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

			  INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, relateddatacode)
			  VALUES
				(@v_newkey, 616, @v_datacode_SI, @v_datasubcode_SI, @v_itemtypecode_PLTemplate, @v_itemtypesubcode_PLTemplate, 'QSIDBA', getdate(), @v_relateddatacode_SI)    
		  END	         
		FETCH NEXT FROM SpecificationItems_gentablesitemtype_cur INTO @v_datacode_SI, @v_datasubcode_SI, @v_relateddatacode_SI
	  END

	  CLOSE SpecificationItems_gentablesitemtype_cur 
	  DEALLOCATE SpecificationItems_gentablesitemtype_cur