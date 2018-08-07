INSERT INTO qse_searchtypecriteria
  (searchtypecode, searchcriteriakey, tablename, columnname)
SELECT
  datacode, 280, 'taqproject', 'lastmaintdate'
FROM gentables
WHERE tableid = 442 AND datacode IN (7,18,22,24,25,28)
go
