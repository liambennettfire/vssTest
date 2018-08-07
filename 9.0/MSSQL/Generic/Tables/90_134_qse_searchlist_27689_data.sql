/*** Update usageclasscode for each Project list ***/
/* NOTE: If list contains multiple Usage Classes, usageclasscode on qse_searchlist will be 0 */
DECLARE
   @v_listkey INT,
   @v_itemtype INT,   
   @v_usageclass INT,
   @v_count INT
   
 SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44
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
  (83,
  -1,
  30,
  1,
  'Current Working List',
  'QSIDBA',
  getdate(),
  1,
  @v_itemtype,
  @v_usageclass,
  1,
  0)
go

DECLARE
   @v_listkey INT,
   @v_itemtype INT,   
   @v_usageclass INT,
   @v_count INT
   
 SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44
 
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
  defaultonpopupsind,
  autofindind)
VALUES
  (84,
  -1,
  30,
  2,
  'BASIC Specification Template Search Criteria',
  'QSIDBA',
  getdate(),
  1,
  1,
  @v_itemtype,
  @v_usageclass,
  1,
  0,
  1,
  1)
go

DECLARE
   @v_listkey INT,
   @v_itemtype INT,   
   @v_usageclass INT,
   @v_count INT
   
 SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44

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
  (85,
  -1,
  30,
  4,
  'Temp Search Results',
  'QSIDBA',
  getdate(),
  0,
  0,
  @v_itemtype,
  @v_usageclass,
  1,
  0)
go

DECLARE
   @v_listkey INT,
   @v_itemtype INT,   
   @v_usageclass INT,
   @v_count INT
   
 SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 44
 
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
  (86,
  -1,
  30,
  16,
  'Recent Specification Templates',
  'QSIDBA',
  getdate(),
  @v_itemtype,
  @v_usageclass,
  1,
  0)
go