INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (586, 1, 1, 'From Production Unit Cost', 'N', 'PLCalcType', 'From Prod Unit Cost', 'FIREBRAND', GETDATE(), 0, 0, 1, 0)
go
  
INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (586, 1, 2, 'From Component Unit Cost', 'N', 'PLCalcType', 'From Comp Unit Cost', 'FIREBRAND', GETDATE(), 0, 0, 1, 0)
  
INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (586, 2, 1, 'From Total Cost', 'N', 'PLCalcType', 'From Total Cost', 'FIREBRAND', GETDATE(), 0, 0, 1, 0)
go
