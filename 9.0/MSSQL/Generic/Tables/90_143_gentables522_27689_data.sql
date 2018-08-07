DECLARE
  @v_max_code INT,
  @v_count  INT
  

BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'pending' and qsicode = 4) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'pending'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode)
      VALUES
        (522, @v_max_code, 'Pending', 'N', 'ProjectStatus', NULL, 'Pending',
        'QSIDBA', getdate(), 1, 0, 4)
    END
  END

END
go


DECLARE
  @v_max_code INT,
  @v_count  INT
  

BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'active' and qsicode = 3) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'active'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode)
      VALUES
        (522, @v_max_code, 'Active', 'N', 'ProjectStatus', NULL, 'Active',
        'QSIDBA', getdate(), 1, 0, 3)
    END
  END

END
go

DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'cancelled' and qsicode = 2) BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'cancelled'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode)
      VALUES
        (522, @v_max_code, 'Cancelled', 'N', 'ProjectStatus', NULL, 'Cancelled',
        'QSIDBA', getdate(), 1, 0, 2)
    END
  END

END
go