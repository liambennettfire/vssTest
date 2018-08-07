DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtypecode INT,
  @v_usageclass INT
  
BEGIN

  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 285 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 285 AND gentablesitemtype.datacode = g.datacode)

  -- Printing Item Type code:
  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 14  --Printing
  
  -- Title Request roles:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = @v_itemtypecode
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 285 AND LOWER(datadesc) = 'production manager'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 285 AND 
      itemtypecode = @v_itemtypecode AND 
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 285, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate())
    END
  END  
  
END
go
