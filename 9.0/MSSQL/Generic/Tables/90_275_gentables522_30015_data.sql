DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_usageclass INT,
  @v_newkey INT
  
BEGIN

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
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode, sortorder)
      VALUES
        (522, @v_max_code, 'Pending', 'N', 'ProjectStatus', NULL, 'Pending',
        'QSIDBA', getdate(), 1, 0, 4, 1)
    END
	ELSE BEGIN
	   UPDATE gentables SET sortorder = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate() WHERE tableid = 522 AND LOWER(datadesc) = 'pending'
	END    
END
GO