-- Title Acquisition (ProjectDetailView/Edit.ascx)
-- numericdesc1 is column number, sort order is overriden by the sort order in gentablesitemtype if the latter is not null
DECLARE @v_count INT, @v_datacode INT

SET @v_datacode = 12
--SELECT @v_count = COUNT(*) FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode

--IF @v_count = 0 BEGIN
  --Column 1
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 1, 'Prefix', 'Prefix', 1, 1, 'N', 'SECCNFG', 'Prefix', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 2, 'Title', 'Title', 2, 1, 'N', 'SECCNFG', 'Title', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 3, 'Subtitle', 'Subtitle', 3, 1, 'N', 'SECCNFG', 'Subtitle', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 4, 'Status', 'Status', 4, 1, 'N', 'SECCNFG', 'Status', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 5, 'DivisionImprint', 'DivisionImprint', 5, 1, 'N', 'SECCNFG', 'DivisionImprint', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 2
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 6, 'Class', 'Class', 1, 2, 'N', 'SECCNFG', 'Class', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 7, 'Edition', 'Edition', 2, 2, 'N', 'SECCNFG', 'Edition', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 8, 'Series', 'Series', 3, 2, 'N', 'SECCNFG', 'Series', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 3
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 9, 'Type', 'Type', 1, 3, 'N', 'SECCNFG', 'Type', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 10, 'Prod 1', 'Prod 1', 2, 3, 'N', 'SECCNFG', 'Prod 1', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 11, 'Prod 2', 'Prod 2', 3, 3, 'N', 'SECCNFG', 'Prod 2', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 12, 'Misc 1', 'Misc 1', 4, 3, 'N', 'SECCNFG', 'Misc 1', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 13, 'Misc 2', 'Misc 2', 5, 3, 'N', 'SECCNFG', 'Misc 2', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 4
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 14, 'Template', 'Template', 1, 4, 'N', 'SECCNFG', 'Template', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 15, 'Owner', 'Owner', 2, 4, 'N', 'SECCNFG', 'Owner', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 16, 'CreateWork', 'Create Work', 3, 4, 'N', 'SECCNFG', 'CreateWork', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 17, 'WorkClass', 'Work Class', 4, 4, 'N', 'SECCNFG', 'WorkClass', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 18, 'CreateFrom', 'Create From', 5, 4, 'N', 'SECCNFG', 'CreateFrom', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)
--END

-- All Other Project classes (ProjectDetailByClassView/Edit.ascx)
-----------------------------------------------------------------

SET @v_datacode = 13
--SELECT @v_count = COUNT(*) FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode

--IF @v_count = 0 BEGIN
  --Column 1
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 1, 'Name', 'Name', 1, 1, 'N', 'SECCNFG', 'Name', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 2, 'Status', 'Status', 2, 1, 'N', 'SECCNFG', 'Status', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 3, 'Type', 'Type', 3, 1, 'N', 'SECCNFG', 'Type', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 4, 'DivisionImprint', 'DivisionImprint', 4, 1, 'N', 'SECCNFG', 'DivisionImprint', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 5, 'Imprint', 'Imprint', 5, 1, 'N', 'SECCNFG', 'Imprint', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 2

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 6, 'Auto Generate Name', 'Auto Generate Name', 1, 2, 'N', 'SECCNFG', 'Auto Generate Name', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 3

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 7, 'Misc 1', 'Misc 1', 1, 3, 'N', 'SECCNFG', 'Misc 1', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 8, 'Misc 2', 'Misc 2', 2, 3, 'N', 'SECCNFG', 'Misc 2', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 9, 'Misc 3', 'Misc 3', 3, 3, 'N', 'SECCNFG', 'Misc 3', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 10, 'Misc 4', 'Misc 4', 4, 3, 'N', 'SECCNFG', 'Misc 4', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 11, 'Misc 5', 'Misc 5', 5, 3, 'N', 'SECCNFG', 'Misc 5', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 4

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 12, 'Template', 'Template', 1, 4, 'N', 'SECCNFG', 'Template', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 13, 'Class', 'Class', 2, 4, 'N', 'SECCNFG', 'Class', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 14, 'Series', 'Series', 3, 4, 'N', 'SECCNFG', 'Series', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 15, 'Owner', 'Owner', 4, 4, 'N', 'SECCNFG', 'Owner', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 16, 'Prod 1', 'Prod 1', 5, 4, 'N', 'SECCNFG', 'Prod 1', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 17, 'Prod 2', 'Prod 2', 6, 4, 'N', 'SECCNFG', 'Prod 2', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)
-- END
