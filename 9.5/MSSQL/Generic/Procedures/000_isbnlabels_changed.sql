/*** This SQL should be run when changes are make to isbnlabels table. ***/
/*** It will update Extended Search Criteria drop-down values and Title History ***/
/*** column values based on isbnlabels configuration ***/
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
  
  UPDATE titlehistorycolumns
  SET columndescription = @v_label
  WHERE columnkey = 241
    
  
END
go
