DECLARE
  @v_count	INT,
  @v_newkey	INT,
  @v_po_itemtype INT
  
BEGIN

  SELECT @v_po_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15	--Purchase Order
  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 562 
	AND datacode = (SELECT datacode FROM gentables WHERE tableid = 562 AND qsicode = 2)
	AND itemtypecode = @v_po_itemtype
  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, lastuserid, lastmaintdate, sortorder)
    SELECT
      @v_newkey, tableid, datacode, @v_po_itemtype, 'QSIDBA', GETDATE(), 1
    FROM gentables 
    WHERE tableid = 562 AND qsicode = 2	--N/A (P&L Stage)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 565 
	AND datacode = (SELECT datacode FROM gentables WHERE tableid = 565 AND LOWER(datadesc) = 'active')
	AND itemtypecode = @v_po_itemtype
  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, lastuserid, lastmaintdate, sortorder)
    SELECT
      @v_newkey, tableid, datacode, @v_po_itemtype, 'QSIDBA', GETDATE(), 1
    FROM gentables 
    WHERE tableid = 565 AND LOWER(datadesc) = 'active' --P&L Status
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 566 
	AND datacode = (SELECT datacode FROM gentables WHERE tableid = 566 AND qsicode = 1)
	AND itemtypecode = @v_po_itemtype
  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, lastuserid, lastmaintdate, sortorder)
    SELECT
      @v_newkey, tableid, datacode, @v_po_itemtype, 'QSIDBA', GETDATE(), 1
    FROM gentables 
    WHERE tableid = 566 and qsicode=1 --System Generated (P&L Type)
  END
  
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 567 
	AND datacode = (SELECT datacode FROM gentables WHERE tableid = 567 AND qsicode = 1)
	AND itemtypecode = @v_po_itemtype
  
  IF @v_count = 0
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, lastuserid, lastmaintdate, sortorder)
    SELECT
      @v_newkey, tableid, datacode, @v_po_itemtype, 'QSIDBA', GETDATE(), 1
    FROM gentables 
    WHERE tableid = 567 and qsicode=1 --N/A (Release Strategy)
  END  
  
END
go