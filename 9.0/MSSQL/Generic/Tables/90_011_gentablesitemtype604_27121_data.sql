DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_itemtype INT
  
BEGIN

  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 604 AND LOWER(datadesc) = 'printing'

  IF @v_datacode > 0
  BEGIN
    -- Printing 
    SELECT @v_itemtype = datacode
      FROM gentables 
     WHERE tableid = 550
       AND qsicode = 14

	  SELECT @v_usageclass = datasubcode
	  FROM subgentables
	  WHERE tableid = 550 AND datacode = @v_itemtype
    
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 604 AND 
      itemtypecode = 3 AND 
      itemtypesubcode = @v_usageclass AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 604, @v_datacode, @v_itemtype, @v_usageclass, 'QSIDBA', getdate())
    END
  
    
     -- Titles
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 604 AND 
      itemtypecode = 1 AND 
      itemtypesubcode = 0 AND
      datacode = @v_datacode 
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 604, @v_datacode, 1, 0, 'QSIDBA', getdate())
    END
  END

END
go
