DECLARE
  @v_datacode INT,
  @v_sortorder INT,
  @v_work_itemtype INT,
  @v_work_usageclass INT,
  @v_newkey INT

BEGIN
  SELECT @v_work_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 9
  
  SELECT @v_work_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 28
      
  DECLARE cur_sendcodes CURSOR FOR
    SELECT datacode, sortorder
    FROM gentables
    WHERE tableid = 581 
    
  OPEN cur_sendcodes
  
  FETCH NEXT FROM cur_sendcodes INTO @v_datacode,@v_sortorder

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate,sortorder)
    VALUES
      (@v_newkey, 581, @v_datacode, @v_work_itemtype, @v_work_usageclass, 'QSIDBA', getdate(),@v_sortorder)
      
    FETCH NEXT FROM cur_sendcodes INTO @v_datacode,@v_sortorder
  END

  CLOSE cur_sendcodes 
  DEALLOCATE cur_sendcodes 
      
END
go