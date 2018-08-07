DECLARE
	@v_tableid INT,
	@v_qsicode	INT,
	@v_sortorder INT,
	@v_itemtype INT,
	@v_class INT,
	@v_datacode INT,
	@v_datasubcode INT,
	@o_error_code INT,
	@o_error_desc varchar(2000)
	
SET @v_tableid = 636
SELECT @v_sortorder = 4
SET @v_datacode = 13    -- Project Details
SET @v_datasubcode = 18  -- Season

-- Marketing Plan--
SELECT @v_itemtype = datacode, @v_class = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 10

EXEC qutl_insert_gentablesitemtype @v_tableid, @v_datacode, @v_datasubcode, 0, @v_itemtype, @v_class, @o_error_code OUTPUT, @o_error_desc OUTPUT
	
IF @o_error_code < 0 BEGIN
	SET @o_error_code = -1
	PRINT @o_error_desc
END
ELSE BEGIN
	UPDATE gentablesitemtype SET sortorder = @v_sortorder WHERE tableid = @v_tableid AND datacode = @v_datacode and datasubcode  = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
	UPDATE gentablesitemtype SET sortorder = 5 WHERE tableid = @v_tableid AND datacode = @v_datacode and datasubcode  = 15 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
END		

-- Marketing Campaign--
SELECT @v_itemtype = datacode, @v_class = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 9

EXEC qutl_insert_gentablesitemtype @v_tableid, @v_datacode, @v_datasubcode, 0, @v_itemtype, @v_class, @o_error_code OUTPUT, @o_error_desc OUTPUT
	
IF @o_error_code < 0 BEGIN
	SET @o_error_code = -1
	PRINT @o_error_desc
END		
ELSE BEGIN
	UPDATE gentablesitemtype SET sortorder = @v_sortorder WHERE tableid = @v_tableid AND datacode = @v_datacode and datasubcode  = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
    UPDATE gentablesitemtype SET sortorder = 5 WHERE tableid = @v_tableid AND datacode = @v_datacode and datasubcode  = 15 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class
END


GO