IF NOT EXISTS (SELECT 1 FROM gentables WHERE tableid=441 AND datacode=12)
INSERT INTO gentables
  (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
VALUES
  (441, 12, 'Multi-level Drop-Down', 'N', 12, 'DATATYPE', 'Multilevel DD', 'QSIDBA', getdate(), 0, 0, 0, 0)

IF EXISTS (SELECT 1 FROM qse_searchcriteria WHERE searchcriteriakey = 328 AND description='Eloquence Customer') -- check for first implementation
BEGIN
  DELETE FROM qse_searchcriteria WHERE searchcriteriakey IN (326,327,328)
  DELETE FROM qse_searchcriteriadetail WHERE parentcriteriakey IN (326,327,328)
  DELETE FROM qse_searchotherdropdown WHERE searchcriteriakey IN (326,327,328)
  DELETE FROM qse_searchtypecriteria WHERE searchcriteriakey IN (326,327,328)
END
  
INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, allowmultiplerowsind, parentcriteriaind)
VALUES
  (326, 'ASSETS APPROVED UNDISTRIBUTED', 0, 1, 1, 1)

INSERT INTO qse_searchcriteria
  (searchcriteriakey, description, datatypecode, defaultoperator, gentableid, allowmultiplerowsind, allowrangeind, 
  allowbestind, stripdashesind, detailcriteriaind, parentcriteriaind, useshortdescind, allowmultiplevaluesind)
VALUES
  (327, 'Partner/Asset Type', 12, 1, NULL, 0, 0, 
  0, 0, 1, 0, 0, 0)

INSERT INTO qse_searchcriteriadetail
  (parentcriteriakey, detailcriteriakey, sortorder)
VALUES
  (326, 327, 1)

INSERT INTO qse_searchotherdropdown
  (searchcriteriakey, dropdownlevel, sourcetable, datacolumn, displaycolumn, sortstring, useorgfilterind)
VALUES
  (327, 1, 'cscustomerpartnerasset', 'customerkey', 'customername', 'customername ASC', 0)
INSERT INTO qse_searchotherdropdown
  (searchcriteriakey, dropdownlevel, sourcetable, datacolumn, displaycolumn, sortstring, useorgfilterind)
VALUES
  (327, 2, 'cscustomerpartnerasset', 'partnercontactkey', 'partnername', 'partnername ASC', 0)
INSERT INTO qse_searchotherdropdown
  (searchcriteriakey, dropdownlevel, sourcetable, datacolumn, displaycolumn, sortstring, useorgfilterind)
VALUES
  (327, 3, 'cscustomerpartnerasset', 'assettypecode', 'assettypename', 'assettypename ASC', 0)

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey)
VALUES
  (6, 326)

INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname, subgencolumnname, subgen2columnname)
VALUES
  (6, 327, 'EODundistributedapprovedassets', 'customerkey', 'partnercontactkey', 'taqelementtypecode')
