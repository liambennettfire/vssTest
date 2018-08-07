DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 521
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
      
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LTRIM(RTRIM(LOWER(datadesc))) = 'miscellaneous'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode)
    VALUES
      (521, @v_max_code, 'Miscellaneous', 'N', 'ProjectType', 'Miscellaneous', 'QSIDBA', getdate(), 0, 0, 10)
  END 
  ELSE BEGIN
	UPDATE gentables SET qsicode = 10 WHERE tableid = 521 AND LTRIM(RTRIM(LOWER(datadesc))) = 'miscellaneous'
  END
  
END