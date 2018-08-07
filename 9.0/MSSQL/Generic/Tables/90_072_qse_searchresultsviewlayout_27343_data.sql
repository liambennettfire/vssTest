DECLARE
  @v_resultsviewkey INT
  
BEGIN
  SELECT @v_resultsviewkey = resultsviewkey 
  FROM qse_searchresultsview 
  WHERE searchtypecode = 25 AND userkey = -1 AND defaultind = 1
  
  UPDATE qse_searchresultsviewlayout
  SET columnorder = columnorder + 1
  WHERE resultsviewkey = @v_resultsviewkey

  INSERT INTO qse_searchresultsviewlayout
    (resultsviewkey, columnnumber, columnorder, lastuserid, lastmaintdate)
  SELECT
    @v_resultsviewkey, columnnumber, 1, 'INITDATA', GETDATE()
  FROM qse_searchresultscolumns
  WHERE searchtypecode = 25 AND columnname = 'templateind'
END
go
