UPDATE subgentables
SET lockbyqsiind = 1
WHERE tableid = 636
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 1, 'Apply Spec Template button', 'N', 0, 'SECCNFG', 'Apply Template btn', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 2, 'Versions button', 'N', 0, 'SECCNFG', 'Versions btn', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 3, 'Scale Verification button', 'N', 0, 'SECCNFG', 'Scale Ver btn', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 4, 'Total # of Characters', 'N', 0, 'SECCNFG', '# of Characters', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 5, 'Total # of Words', 'N', 0, 'SECCNFG', '# of Words', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 6, 'Manuscript Pages', 'N', 0, 'SECCNFG', 'Manuscript Pages', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 7, 'Specifications For Format dropdown', 'N', 0, 'SECCNFG', 'Specifications For', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 8, 'Printing Number dropdown', 'N', 0, 'SECCNFG', 'Printing Number', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 9, 'Media/Format Edit dropdowns', 'N', 0, 'SECCNFG', 'Media/Format Edit', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 10, 'Component List – Whole Grid', 'N', 0, 'SECCNFG', 'Component–Whole Grid', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 11, 'Component List – Component Process', 'N', 0, 'SECCNFG', 'Component–Comp Proc', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 12, 'Component List – Scale Type', 'N', 0, 'SECCNFG', 'Component–Scale Type', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go

INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (636, 4, 13, 'Component List – Vendor', 'N', 0, 'SECCNFG', 'Component–Vendor', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
go
