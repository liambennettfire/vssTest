DECLARE
  @v_count  INT,
  @v_datacode INT,
  @v_newkey INT,
  @v_usageclass INT,
  @v_usageclass_Proforma_PO_Report INT,
  @v_usageclass_Final_PO_Report INT,
  @v_itemtypecode INT  
  
BEGIN
  
  -- Printings tab item type filtered to appear on PO Reports
  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode  = 15 -- Purchase Orders
  
  SELECT @v_datacode = datacode
  FROM gentables
  WHERE tableid = 583 AND qsicode = 36   --Printings (on PO Reports)
  
  SELECT @v_usageclass_Proforma_PO_Report = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 42  --Proforma PO Report
  
  SELECT @v_usageclass_Final_PO_Report = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND qsicode = 43  --Final PO Report   
    
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = @v_itemtypecode AND
      itemtypesubcode = @v_usageclass_Proforma_PO_Report AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, @v_itemtypecode, @v_usageclass_Proforma_PO_Report, 'QSIDBA', getdate())
    END
  END
  
  IF @v_datacode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 583 AND 
      itemtypecode = @v_itemtypecode AND
      itemtypesubcode = @v_usageclass_Final_PO_Report AND
      datacode = @v_datacode
      
    IF @v_count = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
      
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_newkey, 583, @v_datacode, @v_itemtypecode, @v_usageclass_Final_PO_Report, 'QSIDBA', getdate())
    END
  END  
END
go  