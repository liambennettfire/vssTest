DECLARE
	@v_datacode INT,
	@v_itemtypecode INT,
	@v_itemtypesubcode INT,
	@o_error_code INT ,
	@o_error_desc VARCHAR(2000)	
	
SELECT @v_datacode = datacode FROM gentables WHERE tableid = 583 AND qsicode = 15
SELECT @v_itemtypecode = datacode FROM gentables WHERE tableid = 550 AND qsicode = 3

SELECT @v_itemtypesubcode = datasubcode 
FROM subgentables 
WHERE tableid = 550 AND datacode = @v_itemtypecode
AND LOWER(LTRIM(RTRIM(datadesc))) = 'third party rights'

IF @v_datacode > 0 AND @v_itemtypecode > 0 AND  @v_itemtypesubcode > 0 BEGIN
	IF EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 583 AND datacode = @v_datacode AND itemtypecode = @v_itemtypecode AND itemtypesubcode IN (0, @v_itemtypesubcode)) BEGIN
		UPDATE gentablesitemtype SET itemtypesubcode = @v_itemtypesubcode WHERE tableid = 583 AND datacode = @v_datacode AND itemtypecode = @v_itemtypecode AND itemtypesubcode IN (0, @v_itemtypesubcode)
	END
	ELSE BEGIN
		EXEC qutl_insert_gentablesitemtype 583, @v_datacode, 0,0,@v_itemtypecode, @v_itemtypesubcode,@o_error_code OUTPUT,@o_error_desc OUTPUT     
		
		IF @o_error_code < 0 BEGIN
		  SET @o_error_code = -1
		  PRINT @o_error_desc
		  RETURN
		END	 		
	END
END

