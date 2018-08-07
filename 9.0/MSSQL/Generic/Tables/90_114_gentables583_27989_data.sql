DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  -- Purchase Orders (on Printings)
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 583
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 32 -- Purchase Orders (on Printings)
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, qsicode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder,
      alternatedesc1, alternatedesc2)
    VALUES
      (583, @v_max_code, 'Purchase Orders (on Printings)', 'N', 'WebRelationshipTab', 32, 'PO on Printings',
      'QSIDBA', getdate(), 1, 0, NULL, 'Purchase Orders', '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx')
  END
  
  --Printings (on Purchase Orders)
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 583
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 33 -- Printings (on Purchase Orders)
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, qsicode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder,
      alternatedesc1, alternatedesc2)
    VALUES
      (583, @v_max_code, 'Printings (on Purchase Orders)', 'N', 'WebRelationshipTab', 33, 'Printings on PO',
      'QSIDBA', getdate(), 1, 0, 2, 'Printings', '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx')
  END
  
  --Purchase Orders (on PO Reports)
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 583
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 34 -- Purchase Orders (on PO Reports)
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, qsicode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder,
      alternatedesc1, alternatedesc2)
    VALUES
      (583, @v_max_code, 'Purchase Orders (on PO Reports)', 'N', 'WebRelationshipTab', 34, 'PO on Reports',
      'QSIDBA', getdate(), 1, 0, NULL, 'Purchase Orders', '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx')
  END
  
  --Purchase Orders (on PO Reports)
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 583
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 35 -- PO Reports
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, qsicode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder,
      alternatedesc1, alternatedesc2)
    VALUES
      (583, @v_max_code, 'PO Reports', 'N', 'WebRelationshipTab', 35, 'PO Reports',
      'QSIDBA', getdate(), 1, 0, 1, 'PO Reports', '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx')
  END
END
go
