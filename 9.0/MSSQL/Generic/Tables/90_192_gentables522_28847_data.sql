DECLARE
  @v_max_code INT,
  @v_count  INT
  

BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'void' and qsicode = 10) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'void'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode,gen2ind)
      VALUES
        (522, @v_max_code, 'Void', 'N', 'ProjectStatus', NULL, 'Void',
        'QSIDBA', getdate(), 1, 0, 10,1)
    END
  END
  ELSE BEGIN
	UPDATE gentables
	   SET gen2ind = 1,
	       lastuserid = 'QSIDBA',
	       lastmaintdate = getdate()
	 WHERE tableid = 522
	   AND LOWER(datadesc) = 'void'
	   AND qsicode = 10
  END
  
  
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'amended' and qsicode = 11) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'amended'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode,gen2ind)
      VALUES
        (522, @v_max_code, 'Amended', 'N', 'ProjectStatus', NULL, 'Amended',
        'QSIDBA', getdate(), 1, 0, 11,1)
    END
  END
  ELSE BEGIN
	UPDATE gentables
	   SET gen2ind = 1,
	       lastuserid = 'QSIDBA',
	       lastmaintdate = getdate()
	 WHERE tableid = 522
	   AND LOWER(datadesc) = 'amended'
	   AND qsicode = 11
  END
  
  
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'sent to vendor' and qsicode = 12) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'sent to vendor'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode,gen2ind)
      VALUES
        (522, @v_max_code, 'Sent to Vendor', 'N', 'ProjectStatus', NULL, 'Sent to Vendor',
        'QSIDBA', getdate(), 1, 0, 12,1)
    END
  END
  ELSE BEGIN
	UPDATE gentables
	   SET gen2ind = 1,
	       lastuserid = 'QSIDBA',
	       lastmaintdate = getdate()
	 WHERE tableid = 522
	   AND LOWER(datadesc) = 'sent to vendor'
	   AND qsicode = 12
  END

END
go


DECLARE
  @v_max_code INT,
  @v_count  INT
  

BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'amended' and qsicode = 11) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'amended'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode,gen2ind)
      VALUES
        (522, @v_max_code, 'Amended', 'N', 'ProjectStatus', NULL, 'Amended',
        'QSIDBA', getdate(), 1, 0, 11,1)
    END
  END
  ELSE BEGIN
	UPDATE gentables
	   SET gen2ind = 1,
	       lastuserid = 'QSIDBA',
	       lastmaintdate = getdate()
	 WHERE tableid = 522
	   AND LOWER(datadesc) = 'amended'
	   AND qsicode = 11
  END

END
go

DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'sent to vendor' and qsicode = 13) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'sent to vendor'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode,gen2ind)
      VALUES
        (522, @v_max_code, 'Sent to Vendor', 'N', 'ProjectStatus', NULL, 'Sent to Vendor',
        'QSIDBA', getdate(), 1, 0, 13,1)
    END
  END
  ELSE BEGIN
	UPDATE gentables
	   SET gen2ind = 1,
	       lastuserid = 'QSIDBA',
	       lastmaintdate = getdate()
	 WHERE tableid = 522
	   AND LOWER(datadesc) = 'sent to vendor'
	   AND qsicode = 13
  END

END
go