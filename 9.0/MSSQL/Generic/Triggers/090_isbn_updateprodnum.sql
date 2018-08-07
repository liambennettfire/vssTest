IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.updateprodnum') AND type = 'TR')
  DROP TRIGGER dbo.updateprodnum
GO

CREATE TRIGGER updateprodnum ON isbn  
FOR UPDATE AS

  DECLARE
    @bookkey INT,
    @lastuserid VARCHAR(30),
    @linklevelcode INT,
    @prodnumlockey INT,
    @columnname VARCHAR(50),
    @alt_prodnumlockey INT,
    @alt_columnname  VARCHAR(50),   
    @old_isbn VARCHAR(50),
    @old_isbn10 VARCHAR(50),
    @old_ean  VARCHAR(50),
    @old_ean13 VARCHAR(50),
    @old_gtin VARCHAR(50),
    @old_gtin14 VARCHAR(50),
    @old_upc  VARCHAR(50),
    @old_lccn VARCHAR(50),
    @old_dsmarc VARCHAR(50),
    @old_itemnumber VARCHAR(50),
    @old_productnumber VARCHAR(50),
    @new_isbn VARCHAR(50),
    @new_isbn10 VARCHAR(50),
    @new_ean  VARCHAR(50),
    @new_ean13 VARCHAR(50),
    @new_gtin VARCHAR(50),
    @new_gtin14 VARCHAR(50),
    @new_upc  VARCHAR(50),
    @new_lccn VARCHAR(50),
    @new_dsmarc VARCHAR(50),
    @new_itemnumber VARCHAR(50),
    @new_productnumber VARCHAR(50),
    @new_altproductnumber  VARCHAR(50),    
    @count  INT,
    @rowcount  INT,
    @err_msg VARCHAR(100)

  /*** Get all current and previous values ***/
  SELECT @bookkey = i.bookkey, @lastuserid = i.lastuserid,
    @old_isbn = d.isbn, @new_isbn = i.isbn,
    @old_isbn10 = d.isbn10, @new_isbn10 = i.isbn10,
    @old_ean = d.ean, @new_ean = i.ean, 
    @old_ean13 = d.ean13, @new_ean13 = i.ean13, 
    @old_gtin = d.gtin, @new_gtin = i.gtin, 
    @old_gtin14 = d.gtin14, @new_gtin14 = i.gtin14, 
    @old_upc = d.upc, @new_upc = i.upc,
    @old_lccn = d.lccn, @new_lccn = i.lccn, 
    @old_dsmarc = d.dsmarc, @new_dsmarc = i.dsmarc, 
    @old_itemnumber = d.itemnumber, @new_itemnumber = i.itemnumber
  FROM inserted i, deleted d
  WHERE i.isbnkey = d.isbnkey
  
  /* no rows were updated - return */
  if @bookkey is null OR @bookkey <= 0 begin    
    return 
  end  

  /*** Check if this is a set ***/
  SELECT @linklevelcode = linklevelcode
  FROM book
  WHERE bookkey = @bookkey

  IF @linklevelcode = 30
    BEGIN
      SET @prodnumlockey = 2 
      SET @alt_prodnumlockey = 4
    END
  ELSE
    BEGIN
      SET @prodnumlockey = 1
      SET @alt_prodnumlockey = 3
    END

  -- Select source column name for the PRIMARY productnumber
  SELECT @columnname = UPPER(columnname)
  FROM productnumlocation
  WHERE productnumlockey = @prodnumlockey;

  SELECT @rowcount = @@rowcount
  IF @rowcount = 0 BEGIN
    SET @err_msg = 'PRODUCTNUMLOCATION.COLUMNNAME not set for primary product.' 
    PRINT @err_msg
  END
  
  SET @old_productnumber = NULL
  SET @new_productnumber = NULL
  
  IF @columnname = 'ISBN'
    BEGIN
      SET @old_productnumber = @old_isbn
      SET @new_productnumber = @new_isbn
    END
  ELSE IF @columnname = 'ISBN10'
    BEGIN
      SET @old_productnumber = @old_isbn10
      SET @new_productnumber = @new_isbn10
    END
  ELSE IF @columnname = 'EAN'
    BEGIN
      SET @old_productnumber = @old_ean
      SET @new_productnumber = @new_ean
    END
  ELSE IF @columnname = 'EAN13'
    BEGIN
      SET @old_productnumber = @old_ean13
      SET @new_productnumber = @new_ean13
    END    
  ELSE IF @columnname = 'GTIN'
    BEGIN
      SET @old_productnumber = @old_gtin
      SET @new_productnumber = @new_gtin
    END
  ELSE IF @columnname = 'GTIN14'
    BEGIN
      SET @old_productnumber = @old_gtin14
      SET @new_productnumber = @new_gtin14
    END
  ELSE IF @columnname = 'UPC'
    BEGIN
      SET @old_productnumber = @old_upc
      SET @new_productnumber = @new_upc
    END
  ELSE IF @columnname = 'LCCN'
    BEGIN
      SET @old_productnumber = @old_lccn
      SET @new_productnumber = @new_lccn
    END
  ELSE IF @columnname = 'DSMARC'
    BEGIN
      SET @old_productnumber = @old_dsmarc
      SET @new_productnumber = @new_dsmarc
    END
  ELSE IF @columnname = 'ITEMNUMBER'
    BEGIN
      SET @old_productnumber = @old_itemnumber
      SET @new_productnumber = @new_itemnumber
    END

  IF (@new_productnumber IS NULL AND @old_productnumber IS NOT NULL) OR 
     (@old_productnumber IS NULL AND @new_productnumber IS NOT NULL) OR 
     (@new_productnumber <> @old_productnumber)
  BEGIN   
    UPDATE productnumber
    SET productnumber = @new_productnumber,
        lastuserid = @lastuserid,
        lastmaintdate = getdate()
    WHERE bookkey = @bookkey AND productnumlockey = @prodnumlockey

    IF @@error != 0
    BEGIN
      ROLLBACK TRANSACTION
      SET @err_msg = 'Could not update productnumber table (trigger).'
      PRINT @err_msg
    END
  END
  
  
  -- Default secondary productnumber
  SET @new_altproductnumber = NULL
  
  -- Check if client displays secondary product (clientoptions for TMM and PROD)
  SELECT @count = COUNT(*) 
  FROM clientoptions
  WHERE optionvalue = 1 AND optionid IN (57,58)
  
  -- Select source column name for the SECONDARY productnumber
  SELECT @alt_columnname = UPPER(columnname)
  FROM productnumlocation
  WHERE productnumlockey = @alt_prodnumlockey;
  
  SELECT @rowcount = @@rowcount
  IF @rowcount = 0 AND @count > 0 BEGIN
    SET @err_msg = 'PRODUCTNUMLOCATION.COLUMNNAME not set for secondary product.' 
    PRINT @err_msg
  END   

  SET @new_altproductnumber =
  CASE @alt_columnname
    WHEN 'ISBN' THEN @new_isbn
    WHEN 'ISBN10' THEN @new_isbn10
    WHEN 'EAN' THEN @new_ean
    WHEN 'EAN13' THEN @new_ean13
    WHEN 'GTIN' THEN @new_gtin
    WHEN 'GTIN14' THEN @new_gtin14
    WHEN 'UPC' THEN @new_upc
    WHEN 'LCCN' THEN @new_lccn
    WHEN 'DSMARC' THEN @new_dsmarc
    WHEN 'ITEMNUMBER' THEN @new_itemnumber
    ELSE NULL
  END
    
    
  /*** Update ISBN, EAN, UPC and ALTPRODUCTNUMBER on coretitleinfo. ***/
  /*** The above productnumber table update takes care of PRODUCTNUMBER update on coretitleinfo. ***/
  EXECUTE CoreTitleInfo_Verify_Row @bookkey, 0, 1

  UPDATE coretitleinfo
  SET isbn = @new_isbn, isbnx = REPLACE(@new_isbn, '-', ''),
    ean = @new_ean, eanx = REPLACE(@new_ean, '-', ''),
    upc = @new_upc, upcx = REPLACE(@new_upc, '-', ''),
    itemnumber = @new_itemnumber,
    altproductnumber = @new_altproductnumber, 
    altproductnumberx = REPLACE(@new_altproductnumber, '-', '')
  WHERE bookkey = @bookkey

  IF @@error != 0
  BEGIN
    ROLLBACK TRANSACTION
    SET @err_msg = 'Could not update ISBN, EAN, UPC, ALTPRODUCTNUMBER on coretitleinfo table (trigger).'
    PRINT @err_msg
  END

GO