/***********************************************************************************************
Case 4256 - ISBN Prefix validation - 11/09/06 - KW
This SQL is provided to validate existing ISBN Prefixes (subgentables 138).
It can be run at any given time to make sure that all existing ISBN Prefixes are VALID.
A message for each ISBN Prefix record is written into isbnprefixvalidation table.
***********************************************************************************************/

/* NOTE: If duplicate ISBN Prefixes exist, this SQL will make sure that only one
isbnprefixcode (datasubcode) remains active for the given duplicate description (and EAN Prefix).
All other isbnprefixcodes are INACTIVATED and timestamped with lastuserid = QSI_DUP. */

BEGIN
  DECLARE
    @v_active_datasubcode INT,
    @v_count  INT,
    @v_datacode INT,
    @v_datasubcode  INT,
    @v_datadesc VARCHAR(120),
    @v_eanprefix      VARCHAR(40),
    @v_eanprefixcode  INT,
    @v_isbnprefix     VARCHAR(120),
    @v_isbnprefixcode INT,    
    @v_pubprefix_length INT,
    @v_qsi_dup      VARCHAR(30),
    @v_error_code   INT,
    @v_error_desc   VARCHAR(2000)
        
  /**********************************************************************/
  /*** This part cleans up duplicate ISBN Prefixes (subgentables 138) ***/
  /**********************************************************************/
  DECLARE dups_cur CURSOR FOR
    SELECT datacode, datadesc
    FROM subgentables
    WHERE tableid = 138 
    GROUP BY datacode, datadesc HAVING COUNT(DISTINCT datasubcode) > 1          
  
  -- Loop through all duplicate ISBN Prefix records    
  OPEN dups_cur

  FETCH NEXT FROM dups_cur INTO @v_datacode, @v_datadesc

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN
    
    -- Inactivate all duplicate prefixes to start with
    UPDATE subgentables
    SET deletestatus = 'Y', lastuserid = 'QSI_DUP', lastmaintdate = getdate()
    WHERE tableid = 138 AND 
        datacode = @v_datacode AND 
        datadesc = @v_datadesc
        
    SET @v_count = 1
    
    DECLARE prefixcode_cur CURSOR FOR
      SELECT datasubcode
      FROM subgentables
      WHERE tableid = 138 AND 
          datacode = @v_datacode AND
          datadesc = @v_datadesc
      ORDER BY lastmaintdate, datasubcode        
    
    -- Loop through all distinct isbnprefixcodes (datasubcodes) w/duplicate description
    OPEN prefixcode_cur

    FETCH NEXT FROM prefixcode_cur INTO @v_datasubcode

    WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
    BEGIN
    
      -- Activate the first isbnprefixcode (datasubcode)
      IF @v_count = 1
        BEGIN
          SET @v_active_datasubcode = @v_datasubcode
          
          UPDATE subgentables
          SET deletestatus = 'N', lastuserid = 'QSIDBA', lastmaintdate = getdate()
          WHERE tableid = 138 AND 
              datacode = @v_datacode AND 
              datasubcode = @v_datasubcode
        END      
      ELSE
        -- For subsequent isbnprefixcodes, update isbn, isbnnumbers and reuseisbns
        -- to the only active isbnprefixcode (first activated row above)
        BEGIN
          UPDATE isbn
          SET isbnprefixcode = @v_active_datasubcode
          WHERE eanprefixcode = @v_datacode AND isbnprefixcode = @v_datasubcode
        
          UPDATE isbnnumbers
          SET isbnprefixcode = @v_active_datasubcode
          WHERE eanprefixcode = @v_datacode AND isbnprefixcode = @v_datasubcode

          UPDATE reuseisbns
          SET isbnsubprefixcode = @v_active_datasubcode
          WHERE isbnprefixcode = @v_datacode AND isbnsubprefixcode = @v_datasubcode          
        END
      
      -- Accumulate count
      SET @v_count = @v_count + 1
      
      FETCH NEXT FROM prefixcode_cur INTO @v_datasubcode

    END	/* prefixcode_cur LOOP */
    
    CLOSE prefixcode_cur 
    DEALLOCATE prefixcode_cur
    
         
    FETCH NEXT FROM dups_cur INTO @v_datacode, @v_datadesc

  END	/* dups_cur LOOP */
  
  CLOSE dups_cur 
  DEALLOCATE dups_cur


  /************************************************************/
  /*** This part validates ISBN Prefixes (subgentables 138) ***/
  /************************************************************/        
  DECLARE prefix_cur CURSOR FOR    
    SELECT s.datacode, s.datasubcode, s.datadesc, g.datadesc, s.lastuserid
    FROM subgentables s, gentables g
    WHERE s.tableid = 138 AND 
      s.tableid = g.tableid AND 
      s.datacode = g.datacode
    ORDER BY s.datacode, s.datadesc
    
  -- Remove previous validation rows from isbnprefixvalidation table
  DELETE FROM isbnprefixvalidation
      
  OPEN prefix_cur

  FETCH NEXT FROM prefix_cur
  INTO @v_eanprefixcode, @v_isbnprefixcode, @v_isbnprefix, @v_eanprefix, @v_qsi_dup

  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN
  
    SET @v_pubprefix_length = 0
    
    -- Non-existing eanprefixcode will return NULL EAN Prefix - set to '?'
    IF @v_eanprefix IS NULL
      SET @v_eanprefix = '?'

    -- Call ISBN Prefix validation procedure
    EXEC qean_isbnprefix_isvalid @v_isbnprefix, @v_eanprefix, @v_pubprefix_length OUTPUT,
      @v_error_code OUTPUT, @v_error_desc OUTPUT

    INSERT INTO isbnprefixvalidation
      (tableid,
      datacode,
      datasubcode,
      eanprefix,
      isbnprefix,
      isvalid,
      message,
      pubprefixlength,
      validationdate)
    VALUES
      (138,
      @v_eanprefixcode,
      @v_isbnprefixcode,
      @v_eanprefix,
      @v_isbnprefix,
      CASE
        WHEN @v_error_code = 0 THEN 1
        ELSE 0
      END,
      CASE
        WHEN @v_qsi_dup = 'QSI_DUP' THEN '*** DUPLICATE ISBN Prefix - inactivated by QSI ***'
        WHEN @v_error_code = 0 THEN 'VALID'
        ELSE REPLACE(@v_error_desc, '<newline>', ':  ')
      END,
      @v_pubprefix_length,
      getdate())
      

    FETCH NEXT FROM prefix_cur
    INTO @v_eanprefixcode, @v_isbnprefixcode, @v_isbnprefix, @v_eanprefix, @v_qsi_dup

  END	/* prefix_cur LOOP */
  
  CLOSE prefix_cur 
  DEALLOCATE prefix_cur

END
go
