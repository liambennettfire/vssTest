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
  WHERE tableid = 521 AND LOWER(datadesc) = 'normal'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder)
    VALUES
      (521, @v_max_code, 'Normal', 'N', 'ProjectType', 'Normal', 'QSIDBA', getdate(), 0, 0, 1)
  END
  ELSE BEGIN
	 UPDATE gentables SET sortorder = 1   WHERE tableid = 521 AND LOWER(datadesc) = 'normal'
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'proforma po report'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode, sortorder)
    VALUES
      (521, @v_max_code, 'Proforma PO Report', 'N', 'ProjectType', 'Proforma PO Report', 'QSIDBA', getdate(), 1, 0,5, 1)
  END 
  ELSE BEGIN
	 UPDATE gentables SET sortorder = 1 WHERE tableid = 521 AND LOWER(datadesc) = 'proforma po report'
  END  
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'final po report'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode, sortorder)
    VALUES
      (521, @v_max_code, 'Final PO Report', 'N', 'ProjectType', 'Final PO Report', 'QSIDBA', getdate(), 1, 0,6, 1)
  END
  ELSE BEGIN
	 UPDATE gentables SET sortorder = 1 WHERE tableid = 521 AND LOWER(datadesc) = 'final po report'
  END 
  
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
      (521, @v_max_code, 'Converted Printing', 'Y', 'ProjectType', 'Conv. Prtg.', 'QSIDBA', getdate(), 0, 0,7)
  END    
  ELSE BEGIN
	 UPDATE gentables SET deletestatus = 'Y' WHERE tableid = 521 AND qsicode = 7
  END 
  
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 521
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'specification template'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode, sortorder)
    VALUES
      (521, @v_max_code, 'Specification Template', 'N', 'ProjectType', 'Spec Template', 'QSIDBA', getdate(), 0, 0, 8, 1)
  END
  ELSE BEGIN
	 UPDATE gentables SET sortorder = 1 WHERE tableid = 521 AND LOWER(datadesc) = 'specification template'
  END 
  
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 521
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'converted po'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode, sortorder)
    VALUES
      (521, @v_max_code, 'Converted PO', 'Y', 'ProjectType', 'Converted PO', 'QSIDBA', getdate(), 0, 0,9, 999)
  END
  ELSE BEGIN
	 UPDATE gentables SET sortorder = 999 WHERE tableid = 521 AND LOWER(datadesc) = 'converted po'
  END   
  
              
END
go