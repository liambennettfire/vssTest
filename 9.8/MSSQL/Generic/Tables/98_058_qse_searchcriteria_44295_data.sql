-- Criteria for WEB Journal Search Results Update

IF NOT EXISTS (SELECT 1 FROM qse_searchtypecriteria WHERE searchtypecode = 31 AND searchcriteriakey = 71)
  INSERT INTO qse_searchtypecriteria
    (searchtypecode, searchcriteriakey, tablename, columnname)
  VALUES
    (31, 71, 'taqproject', 'taqprojectstatuscode')
  
IF NOT EXISTS (SELECT 1 FROM qse_searchtypecriteria WHERE searchtypecode = 31 AND searchcriteriakey = 73)
  INSERT INTO qse_searchtypecriteria
    (searchtypecode, searchcriteriakey, tablename, columnname)
  VALUES
    (31, 73, 'taqproject', 'taqprojecttype')
  
IF NOT EXISTS (SELECT 1 FROM qse_searchtypecriteria WHERE searchtypecode = 31 AND searchcriteriakey = 86)
  INSERT INTO qse_searchtypecriteria
    (searchtypecode, searchcriteriakey)
  VALUES
    (31, 86)
  
IF NOT EXISTS (SELECT 1 FROM qse_searchtypecriteria WHERE searchtypecode = 31 AND searchcriteriakey = 87)
  INSERT INTO qse_searchtypecriteria
    (searchtypecode, searchcriteriakey, tablename, columnname)
  VALUES
    (31, 87, 'taqprojecttask', 'activedate')

IF NOT EXISTS (SELECT 1 FROM qse_searchtypecriteria WHERE searchtypecode = 31 AND searchcriteriakey = 88)
  INSERT INTO qse_searchtypecriteria
    (searchtypecode, searchcriteriakey, tablename, columnname)
  VALUES
    (31, 88, 'taqprojecttask', 'datetypecode')
    
DECLARE @v_newkey INT

IF NOT EXISTS (SELECT 1 FROM qse_searchlist WHERE searchtypecode = 31 AND userkey = -2)
BEGIN
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey out

  INSERT INTO qse_searchlist
    (listkey, userkey, searchtypecode, listtypecode, listdesc, saveascriteriaind, defaultind, lastuserid, lastmaintdate, 
    autofindind, hidecriteriaind, hideorgfilterind, searchitemcode, createddate, createdbyuserid, privateind, usageclasscode, 
    includeorglevelsind, firebrandlockind, resultswithnoorgsind, resultsviewkey, defaultonpopupsind)
  VALUES
    (@v_newkey, -2, 31, 4, 'Journal Search Results Update Criteria', 1, 0, 'QSIDBA', getdate(), 
    0, 0, 0, 3, getdate(), 'QSIDBA', 0, 0, 
    0, 0, 0, NULL, 0)
END    