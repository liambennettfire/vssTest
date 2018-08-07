DECLARE
  @v_bookkey_book1 INT,
  @v_isbn_book1 VARCHAR(13),
  @v_isbn10_book1 VARCHAR(10),
  @v_ean_book1 VARCHAR(50),
  @v_ean13_book1 VARCHAR(13),
  @v_gtin14_book1 VARCHAR(14),
  @v_gtin_book1 VARCHAR(19),
  
  @v_bookkey_book2 INT,
  @v_isbn_book2 VARCHAR(13),
  @v_isbn10_book2 VARCHAR(10),
  @v_ean_book2 VARCHAR(50),
  @v_ean13_book2 VARCHAR(13),
  @v_gtin14_book2 VARCHAR(14),
  @v_gtin_book2 VARCHAR(19)
  
SET @v_bookkey_book1 = 0  
SET @v_isbn_book1 = NULL
SET @v_isbn10_book1 = NULL
SET @v_ean_book1 = NULL
SET @v_ean13_book1 = NULL
SET @v_gtin14_book1 = NULL
SET @v_gtin_book1 = NULL

SET @v_bookkey_book2 = 0  
SET @v_isbn_book2 = NULL
SET @v_isbn10_book2 = NULL
SET @v_ean_book2 = NULL
SET @v_ean13_book2 = NULL
SET @v_gtin14_book2 = NULL
SET @v_gtin_book2 = NULL

 select 
	@v_bookkey_book1 = bookkey,
	@v_isbn_book1 = isbn,
	@v_isbn10_book1 = isbn10, 
	@v_ean_book1 = ean, 
	@v_ean13_book1 = ean13,
	@v_gtin14_book1 = gtin14,
	@v_gtin_book1 = gtin
 from isbn where ean13 = '9781584876878'
 
 select 
	@v_bookkey_book2 = bookkey,
	@v_isbn_book2 = isbn,
	@v_isbn10_book2 = isbn10, 
	@v_ean_book2 = ean, 
	@v_ean13_book2 = ean13,
	@v_gtin14_book2 = gtin14,
	@v_gtin_book2 = gtin
 from isbn where ean13 = '9781584876922' 

IF @v_bookkey_book1 > 0 AND @v_bookkey_book2 > 0 BEGIN
	UPDATE isbn 
	SET isbn = @v_isbn_book2,
	    isbn10 = @v_isbn10_book2,
	    ean = @v_ean_book2,
	    ean13 = @v_ean13_book2,
	    gtin14 = @v_gtin14_book2,
	    gtin = @v_gtin_book2,
	    lastuserid = 'CASE 43448', 
	    lastmaintdate = GETDATE()
	WHERE bookkey = @v_bookkey_book1 
	
	UPDATE isbn 
	SET isbn = @v_isbn_book1,
	    isbn10 = @v_isbn10_book1,
	    ean = @v_ean_book1,
	    ean13 = @v_ean13_book1,
	    gtin14 = @v_gtin14_book1,
	    gtin = @v_gtin_book1,
	    lastuserid = 'CASE 43448', 
	    lastmaintdate = GETDATE()
	WHERE bookkey = @v_bookkey_book2 	
		
	EXEC CoreTitleInfo_Load @v_bookkey_book1, 0 	
	EXEC CoreTitleInfo_Load @v_bookkey_book2, 0 	
	
END
 
GO

