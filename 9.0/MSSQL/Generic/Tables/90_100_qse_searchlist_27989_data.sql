/*** Insert default lists for Purchase Order Searches ***/
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
  (79,
  -1,
  29,
  1,
  'Current Working List',
  'QSIDBA',
  getdate(),
  1,
  15,
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
  (80,
  -1,
  29,
  2,
  'BASIC PO Search Criteria',
  'QSIDBA',
  getdate(),
  1,
  1,
  15,
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
  (81,
  -1,
  29,
  4,
  'Temp Search Results',
  'QSIDBA',
  getdate(),
  0,
  0,
  15,
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
  (82,
  -1,
  29,
  15,
  'Recent Purchase Orders',
  'QSIDBA',
  getdate(),
  15,
  0,
  1,
  0)
go