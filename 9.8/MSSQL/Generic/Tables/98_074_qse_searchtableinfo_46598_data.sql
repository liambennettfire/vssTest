-- Search table info
IF NOT EXISTS(SELECT 1 FROM qse_searchtableinfo WHERE searchitemcode = 1 AND tablename = 'EODundistributedapprovedassets') 
BEGIN
  INSERT INTO qse_searchtableinfo
    (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere, tablekey1column, tablekey2column)
  VALUES
    (1, 'EODundistributedapprovedassets', 'EODundistributedapprovedassets', 'coretitleinfo.bookkey = EODundistributedapprovedassets.bookkey', 'bookkey', NULL)
END
