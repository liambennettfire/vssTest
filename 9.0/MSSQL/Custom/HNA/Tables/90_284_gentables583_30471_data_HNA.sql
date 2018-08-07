DECLARE
  @v_max_code INT,
  @v_count  INT
  
BEGIN
  --PO Reports (on Printings)
  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 583
  
  IF @v_max_code IS NULL
    SET @v_max_code = 0
    
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 583 AND LTRIM(RTRIM(LOWER(datadesc))) = 'po reports (on printings)' OR qsicode = 37 -- PO Reports (on PO Printings)
  
  IF @v_count = 0
  BEGIN
    SET @v_max_code = @v_max_code + 1
    
    INSERT INTO gentables
      (tableid, datacode, datadesc, deletestatus, tablemnemonic, qsicode, datadescshort,
      lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, sortorder,
      alternatedesc1, alternatedesc2)
    VALUES
      (583, @v_max_code, 'PO Reports (on Printings)', 'N', 'WebRelationshipTab', 37, 'PO Rtp Prtg',
      'QSIDBA', getdate(), 1, 0, NULL, 'PO Reports', '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx')
  END
  ELSE BEGIN
	UPDATE gentables SET qsicode = 37 WHERE tableid = 583 AND LTRIM(RTRIM(LOWER(datadesc))) = 'po reports (on printings)'
  END
END
go
