DECLARE
  @v_datacode INT,
  @v_newkey	INT

BEGIN

  SELECT @v_datacode = COALESCE(MAX(datacode),0) + 1
  FROM gentables
  WHERE tableid = 582

  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
  VALUES
    (582, @v_datacode, 'Printing (for Purchase Orders)', 'N', 'ProjectRelationship', 'Printing (PO)', 'QSIDBA', getdate(),
    0, 0, 1, 0, 'Printing', 25)

  SET @v_datacode = @v_datacode + 1

  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
  VALUES
    (582, @v_datacode, 'Purchase Orders (for Printings)', 'N', 'ProjectRelationship', 'PO (Printings)', 'QSIDBA', getdate(),
    0, 0, 1, 0, 'Purchase Orders', 26)

 SET @v_datacode = @v_datacode + 1

  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
  VALUES
    (582, @v_datacode, 'Purchase Orders (for PO Reports)', 'N', 'ProjectRelationship', 'PO (PO Reports)', 'QSIDBA', getdate(),
    0, 0, 1, 0, 'Purchase Orders', 27)

  SET @v_datacode = @v_datacode + 1

  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
  VALUES
    (582, @v_datacode, 'PO Report', 'N', 'ProjectRelationship', 'PO Report', 'QSIDBA', getdate(),
    0, 0, 1, 0, NULL, 28)

END
go
