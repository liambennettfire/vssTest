 /*** Disable any existing triggers on productnumber table since an update is issued ***/
/*** on productnumber table inside the coretitleinfo_load procedure ***/
ALTER TABLE productnumber DISABLE TRIGGER ALL
go

/**** Execute the coretitle load stored procedure *****/
set nocount on
go
EXEC CoreTitleInfo_Load
GO
set nocount off
go


/* Enable back all triggers on productnumber table */
ALTER TABLE productnumber ENABLE TRIGGER ALL
go


/*** This routine will update product column values on associatedtitles table ***/
/*** based on client's productnumlocation configuration. ***/
BEGIN
  DECLARE
    @v_bookkey  INT,
    @v_assoc_bookkey  INT,
    @v_assoc_product  VARCHAR(50),
    @v_assoc_productx VARCHAR(50),
    @v_assoctypecode  INT,
    @v_assoctypesubcode  INT,
    @v_error  INT,
    @v_error_desc VARCHAR(2000),
    @v_isbn10 VARCHAR(25),
    @v_isbn13 VARCHAR(25),
    @v_length INT,
    @v_linklevelcode  INT,
    @v_prodnum_set_column VARCHAR(50),
    @v_prodnum_set_table  VARCHAR(50),
    @v_prodnum_title_column VARCHAR(50),
    @v_prodnum_title_table  VARCHAR(50),
    @v_prodnum_column   VARCHAR(50),
    @v_prodnum_table    VARCHAR(50),
    @v_prodnum_value    VARCHAR(50),
    @v_prodnum_valuex   VARCHAR(50),
    @v_product_type   TINYINT,
    @v_sortorder  INT,
    @v_sqlstring  NVARCHAR(4000),
    @v_validated_product  VARCHAR(50)

  DECLARE assoctitles_cur CURSOR FOR
    SELECT associatedtitles.bookkey, associatedtitles.associatetitlebookkey, associatedtitles.associationtypecode,
        associatedtitles.associationtypesubcode, associatedtitles.sortorder, associatedtitles.isbn, book.linklevelcode
	FROM associatedtitles LEFT OUTER JOIN book ON associatedtitles.bookkey = book.bookkey 
     WHERE   associatedtitles.isbn IS NOT NULL
    ORDER BY associatedtitles.bookkey    
    
  /*** Get source table and column for the PRIMARY productnumber value for TITLES ***/
  SELECT @v_prodnum_title_table = LOWER(tablename), @v_prodnum_title_column = LOWER(columnname)
  FROM productnumlocation
  WHERE productnumlockey = 1

  /*** Get source table and column for the PRIMARY productnumber value for SETS ***/
  SELECT @v_prodnum_set_table = LOWER(tablename), @v_prodnum_set_column = LOWER(columnname)
  FROM productnumlocation
  WHERE productnumlockey = 2
  
  
  /* <<assoctitles_cur>> */
  OPEN assoctitles_cur

  FETCH NEXT FROM assoctitles_cur
  INTO @v_bookkey, @v_assoc_bookkey, @v_assoctypecode, @v_assoctypesubcode, 
      @v_sortorder, @v_assoc_product, @v_linklevelcode

  WHILE (@@FETCH_STATUS = 0)  /* assoctitles_cur LOOP */
  BEGIN  
  
    /*** Get the PRIMARY productnumber table/column setup ***/
    IF @v_linklevelcode = 30  --SETS
      BEGIN
        SET @v_prodnum_table = @v_prodnum_set_table
        SET @v_prodnum_column = @v_prodnum_set_column
      END
    ELSE  --TITLES
      BEGIN
        SET @v_prodnum_table = @v_prodnum_title_table
        SET @v_prodnum_column = @v_prodnum_title_column
      END
  
    /*** Strip out any dashes from current product value on associatedtitles table ***/
    SET @v_assoc_productx = REPLACE(@v_assoc_product, '-', '')
    
    IF @v_assoc_bookkey > 0 -- in-house title
      BEGIN
      
        /*** Build and run dynamic SQL select to get the correct product value ***/
        /*** based on productnumlocation configuration ***/
        SET @v_sqlstring = N'SELECT @p_value = ' + @v_prodnum_column + 
          ' FROM ' + @v_prodnum_table +
          ' WHERE bookkey = ' + CONVERT(VARCHAR, @v_assoc_bookkey)

        EXECUTE sp_executesql @v_sqlstring, 
          N'@p_value VARCHAR(50) OUTPUT', @v_prodnum_value OUTPUT

        SELECT @v_error = @@ERROR
        IF @v_error = 0   --execute was successful
        BEGIN
        
          /** Strip out any dashes from the correct product value for comparison **/
          /** with currrent product value on associatedtitles table **/
          SET @v_prodnum_valuex = REPLACE(@v_prodnum_value, '-', '')
          
          /** If the current product without dashes differs from the determined **/
          /** correct product without dashes, update associatedtitles **/
          IF @v_assoc_productx <> @v_prodnum_valuex OR
            (@v_assoc_product <> @v_prodnum_value AND @v_assoc_productx = @v_prodnum_valuex)
          BEGIN
          
            PRINT 'Updating productnumber from ' + @v_assoc_product + ' to ' + @v_prodnum_value + ' (bookkey=' + CONVERT(VARCHAR, @v_bookkey) + '/associatetitlebookkey=' + CONVERT(VARCHAR, @v_assoc_bookkey) + ')'

            UPDATE associatedtitles
            SET isbn = @v_prodnum_value
            WHERE bookkey = @v_bookkey AND
              associatetitlebookkey = @v_assoc_bookkey AND
              associationtypecode = @v_assoctypecode AND
              associationtypesubcode = @v_assoctypesubcode AND
              sortorder = @v_sortorder
              
          END --IF @v_assoc_productx <> @v_prodnum_valuex        
        END --IF @v_error = 0    
      END --IF @v_assoc_bookkey > 0 (in-house title)
          
    ELSE  -- other publisher's title
      BEGIN
        
        -- Check the length of current product value on associatedtitles table
        SET @v_length = LEN(@v_assoc_productx)
        
        -- For non in-house titles, validate isbn values
        IF @v_prodnum_table = 'isbn'
        BEGIN
        
          IF @v_length = 10 --assume ISBN-10 value
            SET @v_product_type = 0
          ELSE IF @v_length = 13  --assume ISBN-13 value
            SET @v_product_type = 1
          ELSE IF @v_length = 14  --assume GTIN value
            SET @v_product_type = 2
          ELSE  --assume ISBN-10 value
            SET @v_product_type = 0
            
          EXEC qean_validate_product @v_assoc_product, @v_product_type, 0, 0,
            @v_validated_product OUTPUT, @v_error OUTPUT, @v_error_desc OUTPUT
          
          IF @v_error = 0  -- existing product on associatedtitles is VALID
            BEGIN
              IF @v_product_type = 0  --current value is ISBN-10
                IF @v_prodnum_column = 'ean' OR @v_prodnum_column = 'gtin'
                  BEGIN
                    -- Generate ISBN-13 from current ISBN-10 value
                    SET @v_isbn10 = @v_validated_product
                    EXEC qean_EAN_from_ISBN @v_isbn10, @v_isbn13 OUTPUT, @v_error OUTPUT, @v_error_desc OUTPUT
                    
                    IF @v_error = 0 --successful ISBN-13 generation
                    BEGIN
                      SET @v_validated_product = @v_isbn13
                      -- For GTIN, append GTIN Prefix '0-' to the new validated product
                      IF @v_prodnum_column = 'gtin'
                        SET @v_validated_product = '0-' + @v_validated_product
                    END
                  END                    
                ELSE IF @v_prodnum_column <> 'isbn'
                  GOTO FETCH_NEXT
                  
              ELSE  --current value is ISBN-13 or GTIN
                IF @v_prodnum_column = 'isbn' --value should be ISBN-10
                  BEGIN
                    -- Generate ISBN-10 from current ISBN-13 value
                    IF @v_product_type = 2
                      SET @v_isbn13 = SUBSTRING(@v_validated_product, 3, 50)
                    ELSE
                      SET @v_isbn13 = @v_validated_product                      
                    EXEC qean_ISBN_from_EAN @v_isbn13, @v_isbn10 OUTPUT, @v_error OUTPUT, @v_error_desc OUTPUT
                    
                    IF @v_error = 0 --successful ISBN-10 generation
                    BEGIN
                      SET @v_validated_product = @v_isbn10
                    END
                  END
                ELSE IF @v_prodnum_column <> 'ean' AND @v_prodnum_column <> 'gtin'
                  GOTO FETCH_NEXT
                  
              IF @v_error = 0
              BEGIN
                IF @v_assoc_product <> @v_validated_product
                BEGIN

                  PRINT 'Updating productnumber from ' + @v_assoc_product + ' to ' + @v_validated_product + ' (bookkey=' + CONVERT(VARCHAR, @v_bookkey) + '/associatetitlebookkey=' + CONVERT(VARCHAR, @v_assoc_bookkey) + ')'

                  UPDATE associatedtitles
                  SET isbn = @v_validated_product
                  WHERE bookkey = @v_bookkey AND
                    associatetitlebookkey = @v_assoc_bookkey AND
                    associationtypecode = @v_assoctypecode AND
                    associationtypesubcode = @v_assoctypesubcode AND
                    sortorder = @v_sortorder
                END
              END
              
            END --@v_error = 0 (existing product is VALID)
          ELSE  --@v_error <> 0 (existing product on associatedtitles is INVALID - SKIP)
            BEGIN
              PRINT 'INVALID productnumber ' + @v_assoc_product + ': ' + @v_error_desc + ' (bookkey=' + CONVERT(VARCHAR, @v_bookkey) + '/associatetitlebookkey=' + CONVERT(VARCHAR, @v_assoc_bookkey) + ')'
              
              GOTO FETCH_NEXT
            END
            
        END  --@v_prodnum_table = 'isbn'        
      END --IF @v_assoc_bookkey = 0 (other publisher's title)
  
    
    FETCH_NEXT:
    FETCH NEXT FROM assoctitles_cur
    INTO @v_bookkey, @v_assoc_bookkey, @v_assoctypecode, @v_assoctypesubcode, 
        @v_sortorder, @v_assoc_product, @v_linklevelcode
  
  END  /*LOOP assoctitles_cur */

  CLOSE assoctitles_cur
  DEALLOCATE assoctitles_cur
    
END
go


/*** This routine will update Extended Search Criteria drop-down values, ***/
/*** and Title History column values based on current isbnlabels configuration. ***/
BEGIN
  DECLARE 
    @v_count	INT,
    @v_label  VARCHAR(50)

  /*** ISBN-10 ***/
  SELECT @v_count = COUNT(*)
  FROM isbnlabels WHERE LOWER(columnname) = 'isbn'
  
  IF @v_count > 0
    SELECT @v_label = UPPER(label)
    FROM isbnlabels WHERE LOWER(columnname) = 'isbn'
  ELSE
    SET @v_label = 'ISBN-10'

  UPDATE qse_searchcriteria
  SET description = @v_label
  WHERE searchcriteriakey = 97
  
  UPDATE titlehistorycolumns
  SET columndescription = @v_label
  WHERE columnkey = 43
  
  
  /*** EAN/ISBN-13 ***/
  SELECT @v_count = COUNT(*)
  FROM isbnlabels WHERE LOWER(columnname) = 'ean'
  
  IF @v_count > 0
    SELECT @v_label = UPPER(label)
    FROM isbnlabels WHERE LOWER(columnname) = 'ean'
  ELSE
    SET @v_label = 'EAN/ISBN-13'

  UPDATE qse_searchcriteria
  SET description = @v_label
  WHERE searchcriteriakey = 95
  
  UPDATE titlehistorycolumns
  SET columndescription = @v_label
  WHERE columnkey = 45
  
  
  /*** GTIN ***/
  SELECT @v_count = COUNT(*)
  FROM isbnlabels WHERE LOWER(columnname) = 'gtin'
  
  IF @v_count > 0
    SELECT @v_label = UPPER(label)
    FROM isbnlabels WHERE LOWER(columnname) = 'gtin'
  ELSE
    SET @v_label = 'GTIN'
  
  UPDATE titlehistorycolumns
  SET columndescription = @v_label
  WHERE columnkey = 143
  
  
  /*** UPC ***/
  SELECT @v_count = COUNT(*)
  FROM isbnlabels WHERE LOWER(columnname) = 'upc'
  
  IF @v_count > 0
    SELECT @v_label = UPPER(label)
    FROM isbnlabels WHERE LOWER(columnname) = 'upc'
  ELSE
    SET @v_label = 'UPC'

  UPDATE qse_searchcriteria
  SET description = @v_label
  WHERE searchcriteriakey = 96
  
  UPDATE titlehistorycolumns
  SET columndescription = @v_label
  WHERE columnkey = 44
  
  
  /*** LCCN ***/
  SELECT @v_count = COUNT(*)
  FROM isbnlabels WHERE LOWER(columnname) = 'lccn'
  
  IF @v_count > 0
    SELECT @v_label = UPPER(label)
    FROM isbnlabels WHERE LOWER(columnname) = 'lccn'
  ELSE
    SET @v_label = 'LCCN'
  
  UPDATE titlehistorycolumns
  SET columndescription = @v_label
  WHERE columnkey = 46
  
  
  /*** Item # ***/
  SELECT @v_count = COUNT(*)
  FROM isbnlabels WHERE LOWER(columnname) = 'itemnumber'
  
  IF @v_count > 0
    SELECT @v_label = UPPER(label)
    FROM isbnlabels WHERE LOWER(columnname) = 'itemnumber'
  ELSE
    SET @v_label = 'Item Number'

  UPDATE qse_searchcriteria
  SET description = @v_label
  WHERE searchcriteriakey = 121
    
END
go 

 
