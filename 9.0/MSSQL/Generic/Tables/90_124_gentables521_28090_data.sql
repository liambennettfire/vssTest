DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_usageclass INT,
  @v_newkey INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 521
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND qsicode = 7 -- Converted printing
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode)
    VALUES
      (521, @v_max_code, 'Converted Printing', 'N', 'ProjectType', 'Conv. Prtg.', 'QSIDBA', getdate(), 0, 0,7)
  END
  
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 14 and qsicode = 40 --Printing
  
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 521 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 521, @v_max_code, 14, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  
  
  
END
go
