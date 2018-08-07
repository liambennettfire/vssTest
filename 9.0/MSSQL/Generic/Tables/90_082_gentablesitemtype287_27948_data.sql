DECLARE 
	@v_itemtypecode_printing INT,
	@v_itemtypecode_title INT,
    @v_usageclasscode_title INT,
	@v_datacode_assettype INT,
	@v_newkey INT
	
	SELECT @v_itemtypecode_printing = datacode FROM gentables where tableid = 550 and qsicode = 14
    SELECT @v_itemtypecode_title = datacode, @v_usageclasscode_title = datasubcode FROM subgentables where tableid = 550 and qsicode = 26
    
	  DECLARE printing_gentablesitemtype_cur CURSOR FOR
		SELECT DISTINCT datacode from gentablesitemtype where tableid = 287 and itemtypecode = @v_itemtypecode_title AND itemtypesubcode IN (0, @v_usageclasscode_title)  
		AND datacode NOT IN (SELECT DISTINCT datacode from gentablesitemtype where tableid = 287 and itemtypecode = @v_itemtypecode_printing)
	  OPEN printing_gentablesitemtype_cur

	  FETCH NEXT FROM printing_gentablesitemtype_cur INTO @v_datacode_assettype

	  WHILE (@@FETCH_STATUS = 0) 
	  BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

		  INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
		  VALUES
			(@v_newkey, 287, @v_datacode_assettype, 0, @v_itemtypecode_printing, 0, 'QSIDBA', getdate())
        
		FETCH NEXT FROM printing_gentablesitemtype_cur INTO @v_datacode_assettype
	  END

	  CLOSE printing_gentablesitemtype_cur 
	  DEALLOCATE printing_gentablesitemtype_cur