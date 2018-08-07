DECLARE
  @v_count	INT,
  @v_max_datacode INT
  
BEGIN

  UPDATE gentables
  SET tablemnemonic = (SELECT tablemnemonic FROM gentablesdesc WHERE tableid = 616)
  WHERE tableid = 616 AND tablemnemonic <> (SELECT tablemnemonic FROM gentablesdesc WHERE tableid = 616)

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 616 AND LOWER(datadesc) = 'miscellaneous'
  
  IF @v_count > 0
    UPDATE gentables 
    SET qsicode = 2, lockbyqsiind = 1
    WHERE tableid = 616 AND LOWER(datadesc) = 'miscelleneous'
  ELSE
  BEGIN
    SELECT @v_max_datacode = COALESCE(MAX(datacode),0)
    FROM gentables
    WHERE tableid = 616
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
      lockbyqsiind, lockbyeloquenceind, qsicode)
    VALUES
      (616, @v_max_datacode + 1, 'Miscellaneous', 'N', 'SPECS', 'Misc', 'QSIDBA', GETDATE(), 1, 0, 2)
  END

END
go
