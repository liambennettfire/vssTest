UPDATE gentables
SET lockbyqsiind = 1
WHERE tableid = 636
go

INSERT INTO gentables
  (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 'Specification', 'N', 'SECCNFG', 'Specification', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go
