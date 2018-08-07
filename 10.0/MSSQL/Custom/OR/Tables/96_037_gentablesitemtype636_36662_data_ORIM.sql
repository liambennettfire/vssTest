-- Enable Proposed Territory in Classification sections

DECLARE
  @v_datacode INT,
  @v_datasubcode INT,
  @v_itemtype INT,
  @v_usageclass INT

-- Title classification control
SELECT @v_itemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 1

SET @v_usageclass = 0 -- all title usage classes

UPDATE gentablesitemtype
SET sortorder = 8
WHERE tableid = 636 AND datacode = 14 AND datasubcode = 16 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass

-- TAQ Project Classification control
SELECT @v_itemtype = datacode, @v_usageclass = datasubcode 
FROM subgentables 
WHERE tableid = 550 AND qsicode = 1

UPDATE gentablesitemtype
SET sortorder = 1
WHERE tableid = 636 AND datacode = 15 AND datasubcode = 1 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass

GO