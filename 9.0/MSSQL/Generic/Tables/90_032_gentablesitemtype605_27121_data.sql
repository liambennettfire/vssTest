DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT
  
BEGIN

  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 605 AND LOWER(datadesc) = 'printing title'

  IF @v_datacode > 0
  BEGIN
    -- Printing Title
    SELECT @v_usageclass = datasubcode
    FROM subgentables
    WHERE tableid = 550 AND datacode = 14
  
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 605 AND 
      itemtypecode = 14 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 605, @v_datacode, 14, @v_usageclass, 'QSIDBA', getdate())
    END

    -- Titles
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 605 AND 
      itemtypecode = 1 AND 
      itemtypesubcode = 0 AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 605, @v_datacode, 1, 0, 'QSIDBA', getdate())
    END
  END
END
go
