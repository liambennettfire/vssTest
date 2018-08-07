UPDATE gentables
SET gen2ind = 0
WHERE tableid = 582
go

UPDATE gentables
SET gen2ind = 1
WHERE tableid = 582 AND qsicode = 25	--Printing (for Purchase Orders)
go
