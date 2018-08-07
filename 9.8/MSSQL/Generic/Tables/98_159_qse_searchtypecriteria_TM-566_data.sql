UPDATE qse_searchtypecriteria
SET tablename = 'bookproductdetail#'
WHERE searchtypecode = 6
  AND searchcriteriakey = 308

IF NOT EXISTS (
    SELECT 1
    FROM qse_searchtableinfo
    WHERE tablename = 'bookproductdetail#'
    )
  INSERT INTO qse_searchtableinfo (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere, tablekey1column, tablekey2column)
  VALUES (1, 'bookproductdetail#', 'bookproductdetail bookproductdetail#', 'coretitleinfo.bookkey = bookproductdetail#.bookkey', NULL, NULL)
