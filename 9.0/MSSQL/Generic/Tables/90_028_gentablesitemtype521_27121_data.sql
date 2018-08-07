DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT
  
BEGIN
  -- delete orphans
  DELETE FROM gentablesitemtype
  WHERE tableid = 522 AND 
    NOT EXISTS (SELECT * FROM gentables g
                WHERE g.tableid = 522 AND gentablesitemtype.datacode = g.datacode)


  -- Printing project statuses:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = 14  -- Printing
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 3 -- Active
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 14, @v_usageclass, 'QSIDBA', getdate())
    END
  END

   
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND qsicode = 2 -- Cancelled
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 522, @v_datacode, 14, @v_usageclass, 'QSIDBA', getdate())
    END
  END

  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 522 AND LOWER(datadesc) = 'inactive'
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 522 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 522, @v_datacode, 14, @v_usageclass, 'QSIDBA', getdate(), 2)
    END
  END
END
go
