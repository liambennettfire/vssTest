DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 565
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
        
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 565 AND LOWER(datadesc) = 'active'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, 
      lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (565, @v_max_code, 'Active', 'N', 'PLStatus', 'Active', 
      'QSIDBA', getdate(), 0, 0, 0, 0)
  END    
END
go
  