/*** Insert default lists for Printing Searches ***/
INSERT INTO qse_searchlist 
  (listkey,
  userkey,
  searchtypecode,
  listtypecode,
  listdesc,
  lastuserid,
  lastmaintdate,
  defaultind,
  searchitemcode,
  usageclasscode,
  firebrandlockind,
  resultswithnoorgsind)
VALUES
  (75,
  -1,
  28,
  1,
  'Current Working List',
  'QSIDBA',
  getdate(),
  1,
  14,
  0,
  1,
  0)
go

INSERT INTO qse_searchlist 
  (listkey,
  userkey,
  searchtypecode,
  listtypecode,
  listdesc,
  lastuserid,
  lastmaintdate,
  saveascriteriaind,
  defaultind,
  searchitemcode,
  usageclasscode,
  firebrandlockind,
  resultswithnoorgsind,
  defaultonpopupsind)
VALUES
  (76,
  -1,
  28,
  2,
  'BASIC Printing Search Criteria',
  'QSIDBA',
  getdate(),
  1,
  1,
  14,
  0,
  1,
  0,
  1)
go

INSERT INTO qse_searchlist 
  (listkey,
  userkey,
  searchtypecode,
  listtypecode,
  listdesc,
  lastuserid,
  lastmaintdate,
  saveascriteriaind,
  defaultind,
  searchitemcode,
  usageclasscode,
  firebrandlockind,
  resultswithnoorgsind)
VALUES
  (77,
  -1,
  28,
  4,
  'Temp Search Results',
  'QSIDBA',
  getdate(),
  0,
  0,
  14,
  0,
  1,
  0)
go

INSERT INTO qse_searchlist 
  (listkey,
  userkey,
  searchtypecode,
  listtypecode,
  listdesc,
  lastuserid,
  lastmaintdate,
  searchitemcode,
  usageclasscode,
  firebrandlockind,
  resultswithnoorgsind)
VALUES
  (78,
  -1,
  28,
  14,
  'Recent Printings',
  'QSIDBA',
  getdate(),
  14,
  0,
  1,
  0)
go