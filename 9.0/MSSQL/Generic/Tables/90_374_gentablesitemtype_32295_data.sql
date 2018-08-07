DECLARE 
	@v_itemtypecode_PLTemplate INT,
	@v_itemtypesubcode_PLTemplate INT,	
	@v_itemtypecode_ProjectTAQ INT,
    @v_usageclasscode_ProjectTAQ INT,
	@v_datacode INT,		
	@v_newkey INT
	
	SELECT @v_itemtypecode_PLTemplate = datacode, @v_itemtypesubcode_PLTemplate = datasubcode FROM subgentables where tableid = 550 and qsicode = 29
    
	  DECLARE ReleaseStrategy_gentables_cur CURSOR FOR
		SELECT DISTINCT datacode from gentables where tableid = 567 
	  OPEN ReleaseStrategy_gentables_cur

	  FETCH NEXT FROM ReleaseStrategy_gentables_cur INTO @v_datacode

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN	  
		  IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 567 and itemtypecode = @v_itemtypecode_PLTemplate and itemtypesubcode IN (@v_itemtypesubcode_PLTemplate, 0) and datacode = @v_datacode) 
		  BEGIN	  
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

			INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
			VALUES
				(@v_newkey, 567, @v_datacode, 0, 0, @v_itemtypecode_PLTemplate, @v_itemtypesubcode_PLTemplate, 0, 'QSIDBA', getdate())			
		  END			        
		FETCH NEXT FROM ReleaseStrategy_gentables_cur INTO @v_datacode
	  END

	  CLOSE ReleaseStrategy_gentables_cur 
	  DEALLOCATE ReleaseStrategy_gentables_cur
	  
	  
	  
	  
	  DECLARE PLType_gentables_cur CURSOR FOR
		SELECT DISTINCT datacode from gentables where tableid = 566 
	  OPEN PLType_gentables_cur

	  FETCH NEXT FROM PLType_gentables_cur INTO @v_datacode

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN	  
		  IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 566 and itemtypecode = @v_itemtypecode_PLTemplate and itemtypesubcode IN (@v_itemtypesubcode_PLTemplate, 0) and datacode = @v_datacode) 
		  BEGIN	  
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

			INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
			VALUES
				(@v_newkey, 566, @v_datacode, 0, 0, @v_itemtypecode_PLTemplate, @v_itemtypesubcode_PLTemplate, 0, 'QSIDBA', getdate())			
		  END			        
		FETCH NEXT FROM PLType_gentables_cur INTO @v_datacode
	  END

	  CLOSE PLType_gentables_cur 
	  DEALLOCATE PLType_gentables_cur
	  
	  
	  DECLARE ProjectStatus_gentables_cur CURSOR FOR
		SELECT DISTINCT datacode from gentables where tableid = 522 
	  OPEN ProjectStatus_gentables_cur

	  FETCH NEXT FROM ProjectStatus_gentables_cur INTO @v_datacode

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN	  
		  IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 522 and itemtypecode = @v_itemtypecode_PLTemplate and itemtypesubcode IN (@v_itemtypesubcode_PLTemplate, 0) and datacode = @v_datacode) 
		  BEGIN	  
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

			INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
			VALUES
				(@v_newkey, 522, @v_datacode, 0, 0, @v_itemtypecode_PLTemplate, @v_itemtypesubcode_PLTemplate, 0, 'QSIDBA', getdate())			
		  END			        
		FETCH NEXT FROM ProjectStatus_gentables_cur INTO @v_datacode
	  END

	  CLOSE ProjectStatus_gentables_cur 
	  DEALLOCATE ProjectStatus_gentables_cur

	 