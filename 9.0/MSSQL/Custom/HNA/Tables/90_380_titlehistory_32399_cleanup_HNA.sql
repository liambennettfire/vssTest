DECLARE @v_mediatypecode INT,
		@v_mediatypesubcode INT,
		@v_bookkey	INT,
		@v_printingkey	INT,
		@v_currentstringvalue	VARCHAR(255),
		@v_desc		VARCHAR(255),
		@v_columnkey	INT,
		@v_id_num	INT

BEGIN
	DECLARE titlehistory_cur CURSOR FOR
		SELECT bookkey,printingkey,currentstringvalue,columnkey,id_num
		  FROM titlehistory
		 WHERE fielddesc = 'media' AND isnumeric(currentstringvalue)=1


	OPEN titlehistory_cur
	
	FETCH titlehistory_cur INTO @v_bookkey,@v_printingkey,@v_currentstringvalue,@v_columnkey,@v_id_num
	
	WHILE @@fetch_status = 0
	BEGIN
		SELECT @v_mediatypecode = CONVERT(INT,@v_currentstringvalue)
		
		SET @v_desc = ''
		
		SET  @v_desc = ltrim(rtrim(dbo.get_gentables_desc(312,convert(int,@v_mediatypecode),'long'))) 
		
		print @v_mediatypecode
		print @v_desc
		
		IF @v_desc IS NOT NULL AND @v_desc <> '' BEGIN 
			UPDATE titlehistory
			   SET currentstringvalue = @v_desc
			 WHERE bookkey = @v_bookkey
			   AND printingkey = @v_printingkey
			   AND columnkey = @v_columnkey
			   AND id_num = @v_id_num
	    END

		FETCH titlehistory_cur INTO @v_bookkey,@v_printingkey,@v_currentstringvalue,@v_columnkey,@v_id_num
	END
	
	CLOSE titlehistory_cur 
	DEALLOCATE titlehistory_cur
END
go

DECLARE @v_mediatypecode INT,
		@v_mediatypesubcode INT,
		@v_bookkey	INT,
		@v_printingkey	INT,
		@v_currentstringvalue	VARCHAR(255),
		@v_desc		VARCHAR(255),
		@v_columnkey	INT,
		@v_id_num	INT

BEGIN
	DECLARE titlehistory_cur CURSOR FOR
		SELECT bookkey,printingkey,currentstringvalue,columnkey,id_num
		  FROM titlehistory
		 WHERE fielddesc = 'format' AND isnumeric(currentstringvalue)=1


	OPEN titlehistory_cur
	
	FETCH titlehistory_cur INTO @v_bookkey,@v_printingkey,@v_currentstringvalue,@v_columnkey,@v_id_num
	
	WHILE @@fetch_status = 0
	BEGIN
	    SELECT @v_mediatypecode = mediatypecode FROM bookdetail WHERE bookkey = @v_bookkey
	    
		SELECT @v_mediatypesubcode = CONVERT(INT,@v_currentstringvalue)
		
		SET @v_desc = ''
		
		SET  @v_desc = ltrim(rtrim(dbo.get_subgentables_desc(312, @v_mediatypecode, @v_mediatypesubcode, 'long')))
		
		print @v_mediatypecode
		print @v_mediatypesubcode
		print @v_desc
		
		IF @v_desc IS NOT NULL AND @v_desc <> '' BEGIN 
		
			UPDATE titlehistory
			   SET currentstringvalue = @v_desc
			 WHERE bookkey = @v_bookkey
			   AND printingkey = @v_printingkey
			   AND columnkey = @v_columnkey
			   AND id_num = @v_id_num
	    END

		FETCH titlehistory_cur INTO @v_bookkey,@v_printingkey,@v_currentstringvalue,@v_columnkey,@v_id_num
	END
	
	CLOSE titlehistory_cur 
	DEALLOCATE titlehistory_cur
END
go