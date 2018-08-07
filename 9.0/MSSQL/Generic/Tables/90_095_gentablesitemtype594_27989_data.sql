DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT
  
BEGIN

  -- Purchase Orders/Purchase Order:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 15 and datasubcode = 1  --Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 594 AND LOWER(datadesc) = 'PO #'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 594 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 594, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 594 AND LOWER(datadesc) = 'PO Amendment #'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 594 AND 
      itemtypecode = 15 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 594, @v_datacode, 15, @v_usageclass, 'QSIDBA', getdate())
    END
  END

END
go