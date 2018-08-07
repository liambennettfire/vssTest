IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.insertprodnum') AND type = 'TR')
  DROP TRIGGER dbo.insertprodnum
GO

CREATE TRIGGER insertprodnum ON isbn  
FOR INSERT AS 

  DECLARE 
    @bookkey INT, 
    @isbn VARCHAR(50),
    @isbn10 VARCHAR(50),
    @ean  VARCHAR(50),
    @ean13 VARCHAR(50),
    @gtin VARCHAR(50),
    @gtin14 VARCHAR(50),
    @upc  VARCHAR(50),
    @lccn VARCHAR(50),
    @dsmarc VARCHAR(50),
    @itemnumber VARCHAR(50),    
    @lastuserid VARCHAR(30), 
    @linklevelcode INT,
    @prodnumlockey INT,
    @columnname VARCHAR(50),
    @productnumber VARCHAR(50),
    @alt_prodnumlockey INT,    
    @alt_columnname  VARCHAR(50),
    @alt_productnumber  VARCHAR(50),
    @count  INT,
    @rowcount  INT,
    @err_msg VARCHAR(100)

  /*** Get all current values ***/
  SELECT @bookkey = i.bookkey, @lastuserid = i.lastuserid,
    @isbn = i.isbn, @isbn10 = i.isbn10, @ean = i.ean, @ean13 = i.ean13,
    @gtin = i.gtin, @gtin14 = i.gtin14, @upc = i.upc,
    @lccn = i.lccn, @dsmarc = i.dsmarc, @itemnumber = i.itemnumber   
  FROM inserted i

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
  WHERE productnumlockey = @prodnumlockey

  SELECT @rowcount = @@rowcount
  IF @rowcount = 0 BEGIN
    SET @err_msg = 'PRODUCTNUMLOCATION.COLUMNNAME not set for primary product.' 
    PRINT @err_msg
  END
  
  SET @productnumber =
  CASE @columnname
    WHEN 'ISBN' THEN @isbn
    WHEN 'ISBN10' THEN @isbn10
    WHEN 'EAN' THEN @ean
    WHEN 'EAN13' THEN @ean13
    WHEN 'GTIN' THEN @gtin
    WHEN 'GTIN14' THEN @gtin14
    WHEN 'UPC' THEN @upc
    WHEN 'LCCN' THEN @lccn
    WHEN 'DSMARC' THEN @dsmarc
    WHEN 'ITEMNUMBER' THEN @itemnumber
    ELSE NULL
  END
  
  INSERT INTO productnumber 
    (bookkey, productnumlockey, productnumber, lastuserid, lastmaintdate)
  VALUES 
    (@bookkey, @prodnumlockey, @productnumber, @lastuserid, getdate())

  IF @@error != 0
  BEGIN
    ROLLBACK TRANSACTION
    SET @err_msg = 'Could not insert into productnumber table (trigger).'
    PRINT @err_msg
  END


  -- Default secondary productnumber to NULL
  SET @alt_productnumber = NULL
  
  -- Check if client displays secondary product (clientoptions for TMM and PROD)
  SELECT @count = COUNT(*) 
  FROM clientoptions
  WHERE optionvalue = 1 AND optionid IN (57,58)
  
  -- Select source column name for the SECONDARY productnumber
  SELECT @alt_columnname = UPPER(columnname)
  FROM productnumlocation
  WHERE productnumlockey = @alt_prodnumlockey
  
  SELECT @rowcount = @@rowcount
  IF @rowcount = 0 AND @count > 0 BEGIN
    SET @err_msg = 'PRODUCTNUMLOCATION.COLUMNNAME not set for secondary product.' 
    PRINT @err_msg
  END 
  
  SET @alt_productnumber =
  CASE @alt_columnname
    WHEN 'ISBN' THEN @isbn
    WHEN 'ISBN10' THEN @isbn10
    WHEN 'EAN' THEN @ean
    WHEN 'EAN13' THEN @ean13
    WHEN 'GTIN' THEN @gtin
    WHEN 'GTIN14' THEN @gtin14
    WHEN 'UPC' THEN @upc
    WHEN 'LCCN' THEN @lccn
    WHEN 'DSMARC' THEN @dsmarc
    WHEN 'ITEMNUMBER' THEN @itemnumber
    ELSE NULL
  END
  

  /*** Update ISBN, EAN, UPC and ALTPRODUCTNUMBER on coretitleinfo. ***/
  /*** The above insert into productnumber table takes care of PRODUCTNUMBER update on coretitleinfo. ***/
  EXECUTE CoreTitleInfo_Verify_Row @bookkey, 0, 1

  UPDATE coretitleinfo
  SET isbn = @isbn, isbnx = REPLACE(@isbn, '-', ''),
    ean = @ean, eanx = REPLACE(@ean, '-', ''),
    upc = @upc, upcx = REPLACE(@upc, '-', ''),
    itemnumber = @itemnumber,
    altproductnumber = @alt_productnumber, 
    altproductnumberx = REPLACE(@alt_productnumber, '-', '')
  WHERE bookkey = @bookkey

  IF @@error != 0
  BEGIN
    ROLLBACK TRANSACTION
    SET @err_msg = 'Could not update ISBN, EAN, UPC, ALTPRODUCTNUMBER on coretitleinfo table (trigger).'
    PRINT @err_msg
  END

GO