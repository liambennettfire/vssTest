INSERT INTO qse_searchtableinfo (searchitemcode,tablename,jointoresultstablefrom,
  jointoresultstablewhere,tablekey1column,tablekey2column)
SELECT 14,tablename,jointoresultstablefrom,jointoresultstablewhere,tablekey1column,tablekey2column
  FROM qse_searchtableinfo
 WHERE searchitemcode = 3
go