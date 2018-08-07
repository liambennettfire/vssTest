DECLARE
  @v_qsicode INT,
  @v_newkey INT,
  @v_count INT,
  @v_sortorder INT,
  @v_itemtypecode INT,
  @v_itemtypesubcode INT,
  @v_sectiondatacode INT,
  @v_sectionfieldcode INT,
  @v_sectioncolumn INT

-- Title Item Type
SELECT @v_itemtypecode = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 1

SET @v_itemtypesubcode = 0 -- All title usage classes

SET @v_sectiondatacode = 14  -- Title Classification
SELECT @v_sectionfieldcode = datasubcode
FROM subgentables 
WHERE tableid = 636 AND datacode = @v_sectiondatacode AND datadesc = 'Right Type'

SET @v_sectioncolumn = 2

IF NOT EXISTS (SELECT * 
  FROM gentablesitemtype 
  WHERE tableid = 636 AND itemtypecode = @v_itemtypecode AND itemtypesubcode = @v_itemtypesubcode 
    AND datacode = @v_sectiondatacode AND datasubcode = @v_sectionfieldcode)
BEGIN
  SELECT @v_sortorder = MAX(i.sortorder) + 1 
  FROM gentablesitemtype i
  JOIN subgentables s ON s.tableid=i.tableid AND s.datacode=i.datacode AND s.datasubcode=i.datasubcode AND s.numericdesc1=@v_sectioncolumn
  WHERE i.tableid=636 AND i.datacode=@v_sectiondatacode AND itemtypecode = @v_itemtypecode
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_sectiondatacode, @v_sectionfieldcode, @v_itemtypecode, @v_itemtypesubcode, NULL, @v_sortorder, 'QSIDBA', getdate())
END

GO