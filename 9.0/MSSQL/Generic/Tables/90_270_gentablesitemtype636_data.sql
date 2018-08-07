DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_itemsubtype  INT,
  @v_newkey	INT,
  @v_prtg_itemtype	INT
  
BEGIN  
  -- Loop through all existing configurations and add the row for the newly added Component List - Quantity
  -- (set to invisible for all but Printings)
  DECLARE cur CURSOR FOR
    SELECT DISTINCT itemtypecode, itemtypesubcode 
    FROM gentablesitemtype 
    WHERE tableid = 636 AND datacode = 4
			
  OPEN cur
		
  FETCH NEXT FROM cur INTO @v_itemtype, @v_itemsubtype
		
  WHILE @@FETCH_STATUS = 0
  BEGIN

    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 636 AND datacode = 4 AND datasubcode = 15 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_itemsubtype

    IF @v_count = 0
    BEGIN    
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO gentablesitemtype
        (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder)
      VALUES
        (@v_newkey, 636, 4, 15, @v_itemtype, @v_itemsubtype, 'QSIDBA', GETDATE(), 0) 
    END   
			
    FETCH NEXT FROM cur INTO  @v_itemtype, @v_itemsubtype
  END
		
  CLOSE cur
  DEALLOCATE cur      
      
  SELECT @v_prtg_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 14	--Printing
  
  UPDATE gentablesitemtype
  SET sortorder = 1
  WHERE tableid = 636 AND datacode = 4 AND datasubcode = 15 AND itemtypecode = @v_prtg_itemtype  
  
END
go
