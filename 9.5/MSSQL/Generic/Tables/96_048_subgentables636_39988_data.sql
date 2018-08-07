-- Printings (PrintingDetailByClassView/Edit.ascx)
-----------------------------------------------------------------
-- numericdesc1 is column number, sort order is overriden by the sort order in gentablesitemtype if the latter is not null
DECLARE @v_count INT, @v_datacode INT

SET @v_datacode = 13

--Column 1
INSERT INTO subgentables
(tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
VALUES
(636, @v_datacode, 20, 'Printing', 'Printing', 3, 1, 'N', 'SECCNFG', 'Printing', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

--Column 2
INSERT INTO subgentables
(tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
VALUES
(636, @v_datacode, 19, 'Title', 'Title', 2, 2, 'N', 'SECCNFG', 'PrintingTitle', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

