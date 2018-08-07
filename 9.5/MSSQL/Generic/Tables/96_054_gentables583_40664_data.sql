DECLARE @v_maqrelcode INT,
		@v_workdatacode INT,
		@v_mworksubcode INT

SELECT @v_maqrelcode = datacode
FROM gentables
WHERE tableid = 583
  AND datadesc = 'Master Acquisition'

SELECT @v_workdatacode = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 9

SELECT @v_mworksubcode = datasubcode
FROM subgentables
WHERE datacode = @v_workdatacode
  AND qsicode = 53

PRINT @v_workdatacode
PRINT @v_mworksubcode

DELETE FROM gentablesitemtype
WHERE tableid = 583
  AND datacode = @v_maqrelcode
  AND itemtypecode = @v_workdatacode
  AND itemtypesubcode = @v_mworksubcode