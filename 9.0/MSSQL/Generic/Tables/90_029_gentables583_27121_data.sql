DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 583
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND qsicode = 31 -- Printings (on Titles)
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, qsicode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder,
      alternatedesc1, alternatedesc2)
    VALUES
      (583, @v_max_code, 'Printings (on Titles)', 'N', 'WebRelationshipTab', 31, 'Printings',
      'QSIDBA', getdate(), 1, 0, NULL, 'Printings', '~/PageControls/ProjectRelationships/ProjectsTitle.ascx')
  END
END
go
