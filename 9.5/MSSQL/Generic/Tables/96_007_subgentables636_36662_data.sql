-- Add data for dynamic title/taq classification control
-- NB: numericdesc1 is column number, sort order is overriden by the sort order in gentablesitemtype if the latter is not null

DECLARE @v_count INT, @v_datacode INT

-- Title classification control
SET @v_datacode = 14
--SELECT @v_count = COUNT(*) FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode

--IF @v_count = 0 BEGIN
  --Column 1
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 1, 'Territory', 'Territory', 1, 1, 'N', 'SECCNFG', 'Territory', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 2, 'Exclusivity', 'Exclusivity', 2, 1, 'N', 'SECCNFG', 'Exclusivity', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 3, 'CanadianRestriction', 'Supply To Region', 3, 1, 'N', 'CanadianRestriction', 'Subtitle', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 4, 'Discount', 'Discount', 4, 1, 'N', 'SECCNFG', 'Discount', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 5, 'Restrictions', 'Restrictions', 5, 1, 'N', 'SECCNFG', 'Restrictions', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 6, 'CopyrightYear', 'Copyright Year', 6, 1, 'N', 'SECCNFG', 'CopyrightYear', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)
  
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 7, 'TitleType', 'Type', 7, 1, 'N', 'SECCNFG', 'TitleType', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 8, 'Returns', 'Returns', 8, 1, 'N', 'SECCNFG', 'Returns', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 2
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 9, 'PublishToWeb', 'Publish To Web', 1, 2, 'N', 'SECCNFG', 'PublishToWeb', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 10, 'AgeRange', 'Age Range', 2, 2, 'N', 'SECCNFG', 'AgeRange', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 11, 'GradeRange', 'Grade Range', 3, 2, 'N', 'SECCNFG', 'GradeRange', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 12, 'Language', 'Language', 4, 2, 'N', 'SECCNFG', 'Language', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 13, 'LegacyTerritories', 'Legacy Territories', 5, 2, 'N', 'SECCNFG', 'LegacyTerritories', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 14, 'Origin', 'Origin', 6, 2, 'N', 'SECCNFG', 'Origin', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 15, 'Audience', 'Audience', 7, 2, 'N', 'SECCNFG', 'Audience', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 16, 'ProposedTerritory', 'Proposed Territory', 0, 2, 'N', 'SECCNFG', 'ProposedTerritory', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)
-- END

-- TAQ Project Classification control
SET @v_datacode = 15
--SELECT @v_count = COUNT(*) FROM subgentables WHERE tableid = 636 AND datacode = @v_datacode

--IF @v_count = 0 BEGIN
  --Column 1
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 1, 'ProposedTerritory', 'Proposed Territory', 0, 1, 'N', 'SECCNFG', 'ProposedTerritory', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 2, 'CanadianRestriction', 'Supply To Region', 2, 1, 'N', 'CanadianRestriction', 'Subtitle', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 3, 'Restrictions', 'Restrictions', 3, 1, 'N', 'SECCNFG', 'Restrictions', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 4, 'CopyrightYear', 'Copyright Year', 4, 1, 'N', 'SECCNFG', 'CopyrightYear', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)
  
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 5, 'TitleType', 'Type', 5, 1, 'N', 'SECCNFG', 'TitleType', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 6, 'Returns', 'Returns', 6, 1, 'N', 'SECCNFG', 'Returns', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  --Column 2
  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 7, 'AgeRange', 'Age Range', 1, 2, 'N', 'SECCNFG', 'AgeRange', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 8, 'GradeRange', 'Grade Range', 2, 2, 'N', 'SECCNFG', 'GradeRange', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 9, 'Language', 'Language', 3, 2, 'N', 'SECCNFG', 'Language', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 10, 'Origin', 'Origin', 4, 2, 'N', 'SECCNFG', 'Origin', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

  INSERT INTO subgentables
  (tableid, datacode, datasubcode, datadesc, alternatedesc1, sortorder, numericdesc1, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate, subgen1ind, subgen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, subgen3ind, subgen4ind)
  VALUES
  (636, @v_datacode, 11, 'Audience', 'Audience', 5, 2, 'N', 'SECCNFG', 'Audience', 'QSIDBA', GETDATE(), 0, 0, 0, 0, 1, 0, 0, 0)

-- END