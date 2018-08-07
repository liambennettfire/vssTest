DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 605 --Title Role
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 605 AND LOWER(datadesc) = 'printing title'
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind,qsicode)
    VALUES
      (605, @v_max_code, 'Printing Title', 'N', 'TitleRole', 'Printing Title',
      'QSIDBA', getdate(), 0, 0,7)
  END
  
END
go
