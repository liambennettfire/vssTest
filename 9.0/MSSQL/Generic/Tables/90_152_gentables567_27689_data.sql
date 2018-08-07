DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 567 
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
        
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 567 AND LOWER(datadesc) = 'n/a'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1   
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, 
      lastuserid, lastmaintdate, gen1ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, eloquencefieldtag, qsicode)
    VALUES
      (567, @v_max_code, 'N/A', 'N', @v_max_code, 'ReleaseStrategy', 'N/A', 
      'QSIDBA', getdate(), 1, 0, 0, 1, 0, 'N/A', 1)
  END    
END
go
  