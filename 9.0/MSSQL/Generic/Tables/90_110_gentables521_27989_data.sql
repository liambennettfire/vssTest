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
  WHERE tableid = 521 AND LOWER(datadesc) = 'component'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (521, @v_max_code, 'Component', 'N', 'ProjectType', 'Component', 'QSIDBA', getdate(), 0, 0)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'finished good'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (521, @v_max_code, 'Finished Good', 'N', 'ProjectType', 'Finished Good', 'QSIDBA', getdate(), 0, 0)
  END  
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'whole book purchase'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (521, @v_max_code, 'Whole Book Purchase', 'N', 'ProjectType', 'Whole Book', 'QSIDBA', getdate(), 0, 0)
  END  
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'composition'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (521, @v_max_code, 'Composition', 'N', 'ProjectType', 'Composition', 'QSIDBA', getdate(), 0, 0)
  END 
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'miscellaneous'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
    VALUES
      (521, @v_max_code, 'Miscellaneous', 'N', 'ProjectType', 'Miscellaneous', 'QSIDBA', getdate(), 0, 0)
  END 
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'proforma po report'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode)
    VALUES
      (521, @v_max_code, 'Proforma PO Report', 'N', 'ProjectType', 'Proforma PO Report', 'QSIDBA', getdate(), 1, 0,5)
  END 
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 521 AND LOWER(datadesc) = 'final po report'
  
  IF @v_count = 0
  BEGIN        
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode)
    VALUES
      (521, @v_max_code, 'Final PO Report', 'N', 'ProjectType', 'Final PO Report', 'QSIDBA', getdate(), 1, 0,6)
  END 
END
go
