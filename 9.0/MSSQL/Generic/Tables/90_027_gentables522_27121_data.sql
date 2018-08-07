DECLARE
  @v_max_code INT,
  @v_count  INT
  

BEGIN
  IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 522 AND LOWER(datadesc) = 'inactive') BEGIN
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'inactive'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind)
      VALUES
        (522, @v_max_code, 'Inactive', 'N', 'ProjectStatus', 'inactive', 'Inactive',
        'QSIDBA', getdate(), 0, 0)
    END
  END

END
go