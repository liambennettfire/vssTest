DECLARE
  @v_colnum INT
  
BEGIN
  UPDATE qse_searchresultscolumns
  SET defaultsortorder = defaultsortorder + 1, websortorder = websortorder + 1
  WHERE searchtypecode = 25 AND defaultsortorder > 0
  
  SELECT @v_colnum = MAX(columnnumber) + 1
  FROM qse_searchresultscolumns
  WHERE searchtypecode = 25
  
  INSERT INTO qse_searchresultscolumns
    (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign)
  SELECT
    25, datacode, 0, @v_colnum, 'Template', 'Template', 'coreprojectinfo', 'templateind', 1, 0, 1, 1, 'center'
  FROM gentables
  WHERE tableid = 550 AND qsicode = 10
  
END
go
