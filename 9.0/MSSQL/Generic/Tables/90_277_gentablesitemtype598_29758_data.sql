DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtypecode INT,
  @v_usageclass INT
  
BEGIN

  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 5 -- Comments
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 598 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, text1)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 'Copy Comments from the linked project if any exists and then add any additional Comments from the Copy From Project')
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 8 -- Tasks
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 598 AND 
      itemtypecode = @v_itemtypecode AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, text1)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 'Copy Tasks from the linked project if any exists and then add any additional Tasks from the Copy From Project')
    END
  END  
  
END
go
