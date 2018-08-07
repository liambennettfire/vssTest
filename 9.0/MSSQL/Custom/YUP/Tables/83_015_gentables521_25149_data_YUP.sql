DECLARE
  @v_datacode INT,
  @v_newkey	INT

BEGIN
  SELECT @v_datacode = COALESCE(MAX(datacode),0) + 1
  FROM gentables
  WHERE tableid = 521

  INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, 
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (521, @v_datacode, 'UK Currency P&L', 'N', 'ProjectType', 'UK Currency P&L', 'QSIDBA', getdate(), 0, 0, 0, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
  SELECT
    @v_newkey, 521, @v_datacode, 0, datacode, datasubcode, 'QSIDBA', getdate()
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 39

END
go
