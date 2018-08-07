DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtypecode INT,  
  @v_usageclass INT
  
BEGIN
  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 562 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 562 AND gentablesitemtype.datacode = g.datacode)


  -- Specification Template project statuses:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44  -- Specification Template
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 562 AND LOWER(datadesc) = 'n/a'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 562 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 562, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1)
    END
  END
END
go
