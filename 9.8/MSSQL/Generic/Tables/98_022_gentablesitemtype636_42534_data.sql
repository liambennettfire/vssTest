DECLARE
	@v_itemtypecode INT,
	@v_usageclasscode INT,
	@v_configobjectkey INT,
	@v_configdetailkey INT,
	@v_count INT,
	@v_count1 INT,
	@v_datacode INT,
    @v_datasubcode INT,
    @v_datasubcode_POSection INT,
	@v_tableid INT,
    @v_error_code  INT,
    @v_error_desc varchar(2000),
    @v_defaultvisibleind INT 
	
  SET @v_tableid = 636	
  SET @v_datasubcode_POSection = 15
  
  DECLARE crGentablesItemType CURSOR FOR
  SELECT datacode, datasubcode, itemtypecode, itemtypesubcode 
  FROM gentablesitemtype
  WHERE tableid = 636 AND datacode IN (6,7,8) AND datasubcode = 8
  
  OPEN crGentablesItemType 

  FETCH NEXT FROM crGentablesItemType INTO @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclasscode

  WHILE (@@FETCH_STATUS <> -1) BEGIN
  
	IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid =  @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode_POSection AND itemtypecode = @v_itemtypecode AND itemtypesubcode = @v_usageclasscode) BEGIN
		exec qutl_insert_gentablesitemtype  @v_tableid, @v_datacode,@v_datasubcode_POSection, 0, @v_itemtypecode, @v_usageclasscode,@v_error_code OUTPUT,@v_error_desc OUTPUT
		print 'errorcode = ' + CAST(@v_error_code AS varchar)
		print 'error message =' + @v_error_desc			
			
		IF EXISTS (SELECT * FROM gentablesitemtype WHERE tableid =  @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode_POSection AND itemtypecode = @v_itemtypecode AND itemtypesubcode = @v_usageclasscode)
		BEGIN
			UPDATE gentablesitemtype 
			SET sortorder = 0 
			WHERE tableid =  @v_tableid AND 
					datacode = @v_datacode AND 
					datasubcode = @v_datasubcode_POSection AND 
					itemtypecode = @v_itemtypecode  AND
					itemtypesubcode = @v_usageclasscode
		END
			
	END	
		  
    
	FETCH NEXT FROM crGentablesItemType INTO @v_datacode, @v_datasubcode, @v_itemtypecode, @v_usageclasscode
  END /* WHILE FETCHING */

  CLOSE crGentablesItemType 
  DEALLOCATE crGentablesItemType  