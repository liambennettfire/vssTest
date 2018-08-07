DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 522
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 4
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Pending', 'N', 'ProjectStatus', NULL, 'Pending',
      'QSIDBA', getdate(), 0, 0,4,1)
  END
  ELSE BEGIN
	UPDATE gentables
	   SET sortorder = 1
	 WHERE tableid = 522
	   AND qsicode = 4
  END
   
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 6  
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Proforma Created', 'N', 'ProjectStatus', 'Proforma Created',
      'QSIDBA', getdate(), 0, 0,6,6)
  END
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 7
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Proforma Sent', 'N', 'ProjectStatus', null, 'Proforma Sent',
      'QSIDBA', getdate(), 0, 0,7,7)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 8
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Final Created', 'N', 'ProjectStatus', null, 'Final Created',
      'QSIDBA', getdate(), 0, 0,8,4)
  END
    
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 9
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Final Sent', 'N', 'ProjectStatus', null, 'Final Sent',
      'QSIDBA', getdate(), 0, 0,9,5)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 10
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Void', 'N', 'ProjectStatus', null, 'Void',
      'QSIDBA', getdate(), 0, 0,10,9)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 11
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Amended', 'N', 'ProjectStatus', null, 'Amended',
      'QSIDBA', getdate(), 0, 0,11,2)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 12
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Cancelled Before Sending', 'N', 'ProjectStatus', null, 'Cancelled',
      'QSIDBA', getdate(), 0, 0,12,3)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 522 AND qsicode = 13
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode,sortorder)
    VALUES
      (522, @v_max_code, 'Sent to Vendor', 'N', 'ProjectStatus', null, 'Sent to Vendor',
      'QSIDBA', getdate(), 0, 0,13,8)
  END

END
go