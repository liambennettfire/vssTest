DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_itemtypecode INT  
  
BEGIN
  
  -- PO Reports tab item type filtered to appear on Printings
  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode  = 14 -- Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 37   --'PO Reports (on Printings)'
  
  SET @v_usageclass = 0
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = @v_itemtypecode AND
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