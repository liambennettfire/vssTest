DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_itemtypecode INT,
  @v_usageclass INT,
  @v_max_sortorder INT

BEGIN

  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 1  -- Title Acquisition
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 598 AND qsicode = 28 -- Classification
  
  SELECT @v_max_sortorder = MAX(sortorder)
  FROM gentablesitemtype
  WHERE tableid = 598 AND 
    itemtypecode = @v_itemtypecode AND 
    itemtypesubcode = @v_usageclass
  
  SET @v_max_sortorder = @v_max_sortorder + 1  
  
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
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, defaultind, sortorder)
      VALUES
        (@v_newkey, 598, @v_datacode, @v_itemtypecode, @v_usageclass, 'QSIDBA', getdate(), 1, @v_max_sortorder)
    END
  END
END
go
