UPDATE gentables 
SET sortorder = datacode
WHERE tableid IN (565,566,567)
go

UPDATE gentables
SET tablemnemonic = 'PLStatus'
WHERE tableid = 565 AND tablemnemonic <> 'PLStatus'
go
