delete from qse_searchtableinfo
where searchitemcode = 15
go
-- for purchase orders start with same data as projects
INSERT INTO qse_searchtableinfo (searchitemcode,tablename,jointoresultstablefrom,
  jointoresultstablewhere,tablekey1column,tablekey2column)
SELECT 15,tablename,jointoresultstablefrom,jointoresultstablewhere,tablekey1column,tablekey2column
  FROM qse_searchtableinfo
 WHERE searchitemcode = 3
go


INSERT INTO qse_searchtableinfo
  (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere)
SELECT
  datacode, 'taqproductnumbers', 'taqproductnumbers', 'coreprojectinfo.projectkey = taqproductnumbers.taqprojectkey AND taqproductnumbers.productidcode = (SELECT datacode FROM gentables WHERE tableid=594 AND qsicode=7)'
FROM gentables
WHERE tableid = 550 AND qsicode = 15
go






