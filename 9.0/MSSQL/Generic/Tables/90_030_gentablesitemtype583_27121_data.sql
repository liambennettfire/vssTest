DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_itemtypecode INT  
  
BEGIN

  -- Printing relationship tabs:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 14 --- Printing
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 1   --Projects
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, 14, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 31   --Printing (on Titles)
  
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 26--Titles
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate())
    END
  END
END
go