DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 285
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 285 AND LOWER(datadesc) = 'production manager'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, 
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (285, @v_max_code, 'Production Manager', 'N', 'ROLETYPE', 'Production Manager', 
      'QSIDBA', getdate(), 0, 0)
  END    
END
go
  