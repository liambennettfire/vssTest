DECLARE 
	@v_itemtypecode_PLTemplate INT,
	@v_itemtypesubcode_PLTemplate INT,	
	@v_itemtypecode_ProjectTAQ INT,
    @v_usageclasscode_ProjectTAQ INT,
	@v_datacode_WSC INT,
	@v_datasubcode_WSC INT,	    
	@v_datasub2code_WSC INT,
	@v_defaultind_WSC INT,	
	@v_sortorder_WSC INT,		
	@v_newkey INT
	
	SELECT @v_itemtypecode_PLTemplate = datacode, @v_itemtypesubcode_PLTemplate = datasubcode FROM subgentables where tableid = 550 and qsicode = 29
    SELECT @v_itemtypecode_ProjectTAQ = datacode, @v_usageclasscode_ProjectTAQ = datasubcode FROM subgentables where tableid = 550 and qsicode = 1
    
	  DECLARE WebSectionConfiguration_gentablesitemtype_cur CURSOR FOR
		SELECT DISTINCT datacode, datasubcode, datasub2code, defaultind, sortorder from gentablesitemtype where tableid = 636 and itemtypecode = @v_itemtypecode_ProjectTAQ AND itemtypesubcode IN (0, @v_usageclasscode_ProjectTAQ)  						
	  OPEN WebSectionConfiguration_gentablesitemtype_cur

	  FETCH NEXT FROM WebSectionConfiguration_gentablesitemtype_cur INTO @v_datacode_WSC, @v_datasubcode_WSC, @v_datasub2code_WSC, @v_defaultind_WSC, @v_sortorder_WSC

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN	  
		  IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 636 and itemtypecode = @v_itemtypecode_PLTemplate and itemtypesubcode IN (@v_itemtypesubcode_PLTemplate, 0) and datacode = @v_datacode_WSC AND datasubcode = @v_datasubcode_WSC) 
		  BEGIN	  
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

			INSERT INTO gentablesitemtype
				(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder)
			VALUES
				(@v_newkey, 636, @v_datacode_WSC, @v_datasubcode_WSC, @v_datasub2code_WSC, @v_itemtypecode_PLTemplate, @v_itemtypesubcode_PLTemplate, @v_defaultind_WSC, 'QSIDBA', getdate(), @v_sortorder_WSC)			
		  END			        
		FETCH NEXT FROM WebSectionConfiguration_gentablesitemtype_cur INTO @v_datacode_WSC, @v_datasubcode_WSC, @v_datasub2code_WSC, @v_defaultind_WSC, @v_sortorder_WSC
	  END

	  CLOSE WebSectionConfiguration_gentablesitemtype_cur 
	  DEALLOCATE WebSectionConfiguration_gentablesitemtype_cur