DECLARE
	@v_bookkey INT,
	@v_printingkey INT,
    @error_code INT,
    @error_desc VARCHAR(2000),
    @err_msg varchar(255)
	
    SELECT @error_code = 0
    SELECT @error_desc = ''	
	
SELECT @v_bookkey = bookkey  
FROM isbn 
WHERE ean13 =  '9780160935312'


IF @v_bookkey > 0 BEGIN
	SELECT TOP(1) @v_printingkey = printingkey 
	FROM printing 
	WHERE bookkey = @v_bookkey 
	
	EXEC deletetitle_delete_printing @v_bookkey, @v_printingkey, NULL, NULL, NULL, NULL, NULL, 
		'Case 43750', @error_code OUTPUT,@err_msg OUTPUT  
		
	 IF @error_code != 0 BEGIN
		SELECT @err_msg =  @err_msg + ' Error executing deletetitle_delete_printing proc for bookkey ' + convert(char(10),@v_bookkey) 
        PRINT @err_msg
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	 END
	 
     SELECT @error_code = 0
     SELECT @error_desc = ''		 
	 EXEC deletetitle_delete_book @v_bookkey, 'Case 43750',  @error_code OUTPUT,@error_desc OUTPUT  
	 
	 IF @error_code != 0 BEGIN
		SELECT @err_msg =  @err_msg + ' Error executing deletetitle_delete_book proc for bookkey ' + convert(char(10),@v_bookkey) 
        PRINT @err_msg
		SELECT @error_code = -1
		SELECT @error_desc = @err_msg 
		RETURN
	 END	 
	 		
END

GO