DECLARE 
	@v_itemtypecode_titles INT,
	@v_itemtypecode_title INT,
    @v_usageclasscode_title INT,
	@v_datacode_taskdatetype INT,
	@v_newkey INT,
	@v_relateddatacode INT,
	@v_indicator1 TINYINT,
	@v_max_code INT,
	@v_count INT
	
	SELECT @v_itemtypecode_titles = datacode FROM gentables where tableid = 550 and qsicode = 1 -- Titles
	
	SELECT @v_datacode_taskdatetype = datetypecode FROM datetype WHERE qsicode = 7 -- Publication Date
		
	SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 1 --Key date indicator
	
	IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 323 AND itemtypecode = @v_itemtypecode_titles 
		AND datacode = @v_datacode_taskdatetype AND relateddatacode = @v_relateddatacode AND indicator1 = @v_indicator1) BEGIN
    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

	  INSERT INTO gentablesitemtype
		(gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, relateddatacode, indicator1)
	  VALUES
		(@v_newkey, 323, @v_datacode_taskdatetype, 0, @v_itemtypecode_titles, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
   	END