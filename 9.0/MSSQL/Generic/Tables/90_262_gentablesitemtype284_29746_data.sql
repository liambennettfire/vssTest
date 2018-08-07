DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_max_code INT
  
BEGIN

  SELECT @v_datacode = datacode
    FROM gentables
   WHERE tableid = 284
     AND LOWER(datadesc) = 'project'
     
  IF NOT EXISTS (SELECT * FROM subgentables WHERE tableid = 284 AND datacode = @v_datacode and LOWER(datadesc)
    = 'production notes') BEGIN
    SELECT @v_max_code = MAX(datasubcode)
    FROM subgentables
    WHERE tableid = 284
      AND datacode = @v_datacode
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM subgentables
    WHERE tableid = 284 AND datacode = @v_datacode and LOWER(datadesc) = 'production notes'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO subgentables
        (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind)
      VALUES
        (284, @v_datacode,@v_max_code, 'Production Notes', 'N', 'COMMENTT', NULL, 'Production Notes',
        'QSIDBA', getdate(), 1)
     
   END 
  END
  
  -- Printing:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 14  -- Printing
  
  SELECT @v_datasubcode = datasubcode
  FROM subgentables
  WHERE tableid = 284 AND datacode = @v_datacode AND LOWER(datadesc) = 'production notes'
  
  IF @v_datasubcode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 284 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = 0 AND
      datacode = @v_datacode AND
      datasubcode = @v_datasubcode
      
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 284, @v_datacode, @v_datasubcode, 14, 0, 'QSIDBA', getdate())
    END
  END
END
go
