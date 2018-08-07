DECLARE  
	@o_error_code INT, 
	@o_error_desc VARCHAR(2000), 
	@o_gentablesrelationshipdetailkey INT, 
	@v_datadesc1 VARCHAR(40),
	@v_datadesc2 VARCHAR(40),
	@v_gentablesrelationshipkey	INT
	
	
	
BEGIN
	SELECT @v_gentablesrelationshipkey = gentablesrelationshipkey FROM gentablesrelationships WHERE description = 'TM Web Process Type to QSI Job Type'
	
	SELECT @v_datadesc1 = datadesc FROM gentables WHERE tableid = 669 and datadesc = 'HMH Mktg Catalog Creation' --TM Web Process Type
	SELECT @v_datadesc2 = datadesc FROM gentables WHERE tableid = 543 and datadesc = 'HMH Mktg Catalog Creation' -- Job Type
	
	EXEC qutl_insert_gentablesrelationshipdetail_value @v_gentablesrelationshipkey,@v_datadesc1,NULL,@v_datadesc2, NULL,
		NULL,NULL,NULL,NULL,1,@o_gentablesrelationshipdetailkey OUTPUT, @o_error_code OUTPUT,@o_error_desc OUTPUT
END
go
	