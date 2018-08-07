DECLARE
	@v_datacode_Contract INT,
	@v_error_code  integer,
    @v_error_desc varchar(2000)  
	
	SELECT @v_datacode_Contract =  dbo.qutl_get_gentables_datacode(550, 10, NULL)
	
	IF @v_datacode_Contract > 0 BEGIN
	    IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 114 AND itemtypecode = @v_datacode_Contract) BEGIN
			EXEC qutl_insert_gentablesitemtype  114, 0, 0, 0, @v_datacode_Contract, 0, @v_error_code OUTPUT, @v_error_desc OUTPUT, 0, NULL, NULL  
		END
		
		IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 157 AND itemtypecode = @v_datacode_Contract) BEGIN	
			EXEC qutl_insert_gentablesitemtype  157, 0, 0, 0, @v_datacode_Contract, 0, @v_error_code OUTPUT, @v_error_desc OUTPUT, 0, NULL, NULL  
	    END
	    
	    IF NOT EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 318 AND itemtypecode = @v_datacode_Contract) BEGIN	
			EXEC qutl_insert_gentablesitemtype  318, 0, 0, 0, @v_datacode_Contract, 0, @v_error_code OUTPUT, @v_error_desc OUTPUT, 0, NULL, NULL  
	    END
   END  
 
 GO