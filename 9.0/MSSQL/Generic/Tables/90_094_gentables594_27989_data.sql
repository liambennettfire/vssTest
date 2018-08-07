DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 594
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 594 AND qsicode = 7
  
  -- Used to be dwokey but is not used so being reused for 'PO #'
  IF @v_count = 1
  BEGIN
	DELETE FROM gentables
	  WHERE tableid = 594
	   AND qsicode = 7 
  END
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 594 AND LOWER(datadesc) = 'PO #' AND qsicode = 7
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, qsicode, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (594, @v_max_code, 'PO #', 'N', 'Project/ElementIDType', 'PO #',
      'QSIDBA', getdate(), 7, 0, 0)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 594 AND LOWER(datadesc) = 'po amendment #'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, qsicode, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (594, @v_max_code, 'PO Amendment #', 'N', 'Project/ElementIDType', 'PO Amendment #',
      'QSIDBA', getdate(), 13, 0, 0)
  END  
  
END
go
