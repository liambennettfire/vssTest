DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_datacode	INT,
  @v_newkey	INT,
  @v_qsicode INT,
  @v_relateddatacode INT,
  @v_indicator1 TINYINT
  
BEGIN
  -- Cover Due
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'cover due'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    SET @v_qsicode = 25
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind,qsicode)
    VALUES
      (@v_max_code, 'Cover Due', 0, 0, 'Cover Due', 'Cover Due',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,0,0,1,@v_qsicode)
  END
  ELSE BEGIN
    UPDATE datetype 
    SET activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1,qsicode = @v_qsicode
    WHERE LTRIM(RTRIM(LOWER(description))) =  'cover due'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'cover due'
  END
  
  --filter 'Cover Date' for Purchase Orders
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 0 --Not Key date indicator
	
	
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      datacode = @v_max_code AND
      relateddatacode = @v_relateddatacode AND
      indicator1 = @v_indicator1
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate,relateddatacode, indicator1)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
    END
  END
  
  -- Jacket Due
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'jacket due'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    SET @v_qsicode = 26
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind,qsicode)
    VALUES
      (@v_max_code, 'Jacket Due', 0, 0, 'Jacket Due', 'Jacket Due',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,0,0,1,@v_qsicode)
  END
  ELSE BEGIN
	UPDATE datetype 
    SET activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1,qsicode = @v_qsicode
    WHERE LTRIM(RTRIM(LOWER(description))) =  'jacket due'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'jacket due'
  END
  
  --filter 'Jacket Due' for Purchase Orders
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 0 --Not Key date indicator
	
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      datacode = @v_max_code AND
      relateddatacode = @v_relateddatacode AND
      indicator1 = @v_indicator1
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate,relateddatacode, indicator1)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
    END
  END
  
  -- Misc Due
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'misc due'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    SET @v_qsicode = 27
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind,qsicode)
    VALUES
      (@v_max_code, 'Misc Due', 0, 0, 'Misc Due', 'Misc Due',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,0,0,1,@v_qsicode)
  END
  ELSE BEGIN
	UPDATE datetype 
    SET activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1,qsicode = @v_qsicode
    WHERE LTRIM(RTRIM(LOWER(description))) =  'misc due'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'misc due'
  END
  
  --filter 'Misc Due' for Purchase Orders
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_relateddatacode = datacode FROM gentables WHERE tableid = 580 AND datadesc = 'Only 1 Task Allowed'
	
	SET @v_indicator1 = 0 --Not Key date indicator
	
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      datacode = @v_max_code AND
      relateddatacode = @v_relateddatacode AND
      indicator1 = @v_indicator1
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate,relateddatacode, indicator1)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, 0, 'QSIDBA', getdate(), @v_relateddatacode, @v_indicator1)
    END
  END
    
END
go
  