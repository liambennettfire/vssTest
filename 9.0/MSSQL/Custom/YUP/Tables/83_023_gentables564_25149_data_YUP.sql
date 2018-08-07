DECLARE
  @v_datacode INT

BEGIN
  SELECT @v_datacode = COALESCE(MAX(datacode),0) + 1
  FROM gentables
  WHERE tableid = 564

  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate, 
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (564, @v_datacode, 'Final Rpt Info', 'N', 0, 'PLHeading', 'Final Rpt', 'QSIDBA', getdate(), 0, 0, 0, 0)
END
go
