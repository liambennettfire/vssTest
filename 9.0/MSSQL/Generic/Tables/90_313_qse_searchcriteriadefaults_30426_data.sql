DECLARE
  @v_listkey INT,
  @v_sequence INT
  
BEGIN
  SELECT @v_listkey = listkey
  FROM qse_searchlist 
  WHERE userkey = -1 AND searchtypecode = 28 AND listtypecode = 2
  
  SELECT @v_sequence = sequence
  FROM qse_searchcriteriadefaults
  WHERE listkey = @v_listkey AND searchcriteriakey = 157
  
  INSERT INTO qse_searchcriteriadefaults
    (listkey, sequence, subsequence, searchcriteriakey, defaultoperator, operatordesc, numericvalue, logicaloperator)
  VALUES
    (@v_listkey, @v_sequence, 6, 294, 1, '= ', 0, 1)
END
go
