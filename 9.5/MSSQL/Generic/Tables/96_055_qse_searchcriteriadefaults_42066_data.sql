DECLARE
  @v_listkey INT,
  @v_sequence INT
  
BEGIN
  SELECT @v_listkey = listkey
  FROM qse_searchlist 
  WHERE userkey = -1 AND searchtypecode = 29 AND listtypecode = 2
  
  SELECT @v_sequence = MAX(sequence) + 1
  FROM qse_searchcriteriadefaults
  WHERE listkey = @v_listkey
  
  INSERT INTO qse_searchcriteriadefaults
    (listkey, sequence, subsequence, searchcriteriakey, defaultoperator, operatordesc, numericvalue, subgennumericvalue, logicaloperator)
  VALUES
    (@v_listkey, @v_sequence, 1, 120, 1, '= ', NULL, 1, 1)
END
go
