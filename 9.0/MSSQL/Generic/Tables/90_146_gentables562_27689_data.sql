DECLARE
  @v_max_code INT,
  @v_max_sortorder INT,  
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 562
  
  SELECT @v_max_sortorder = MAX(sortorder)
  FROM gentables
  WHERE tableid = 562  
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  IF @v_max_sortorder IS NULL
    SET @v_max_sortorder = 0
        
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 562 AND LOWER(datadesc) = 'n/a'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    SET @v_max_sortorder = @v_max_sortorder + 1    
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, 
      lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (562, @v_max_code, 'N/A', 'N', @v_max_sortorder, 'PLStage', 'N/A', 
      'QSIDBA', getdate(), 0, 0, 0, 0)
  END    
END
go
  