DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_datacode INT,  
  @v_datasubcode	INT,
  @v_newkey	INT,
  @v_qsicode INT
  
BEGIN

 -- PO Date
  SELECT @v_max_code = MAX(datetypecode)
  FROM datetype
  WHERE datetypecode < 20000
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM datetype
  WHERE LOWER(description) = 'po voided'
  
  SET @v_qsicode = 30
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO datetype
      (datetypecode, description, printkeydependent, changetitlestatusind, datelabel, datelabelshort,
      tableid, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, activeind, contractind,
      sortorder, showintaqind,
      taqtotmmind, taqkeyind,showallsectionsind, milestoneind, qsicode)
    VALUES
      (@v_max_code, 'PO Voided', 0, 0, 'PO Voided', 'PO Voided',
      323, 'QSIDBA', getdate(), 0, 0, 1, 0, 
      0, 1,
      0,1,0,1, @v_qsicode)
  END
  ELSE BEGIN
    UPDATE datetype 
    SET qsicode = @v_qsicode, activeind = 1, contractind = 0, showintaqind = 1, taqkeyind = 1, milestoneind = 1
    WHERE LTRIM(RTRIM(LOWER(description))) =  'po voided'
      
	SELECT @v_max_code = datetypecode
      FROM datetype
     WHERE LTRIM(RTRIM(LOWER(description))) = 'po voided'
  END
  
  
  
  --'PO Date' for Purchase Orders/Proforma PO Reports and Purchase Orders/Final PO Reports
  -- Proforma PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
  
  -- Final PO Report
  SELECT @v_datacode = datacode, @v_datasubcode = datasubcode
    FROM subgentables
  WHERE tableid = 550 AND qsicode = 43  --Final PO Report
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323 AND 
      itemtypecode = @v_datacode AND
      itemtypesubcode = @v_datasubcode AND
      datacode = @v_max_code
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 323, @v_max_code, @v_datacode, @v_datasubcode, 'QSIDBA', getdate())
    END
  END
 END 
 go
  