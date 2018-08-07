-- Enable Proposed Territory in Classification sections

-- Title classification control
UPDATE subgentables
SET sortorder = 8
WHERE tableid = 636 AND datacode = 14 AND datasubcode = 16

-- TAQ Project Classification control
UPDATE subgentables
SET sortorder = 1
WHERE tableid = 636 AND datacode = 15 AND datasubcode = 1
