DECLARE
  @v_datacode INT,
  @v_datasubcode  INT,
  @v_qsicode  INT,
  @v_relateddatacode  INT,
  @v_sortorder INT,
  @v_work_itemtype INT,
  @v_work_usageclass INT,
  @v_newkey INT

BEGIN
  SELECT @v_work_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 9  -- Works

  SELECT @v_work_usageclass = 0 
     
        
  DECLARE cur_sendcodes CURSOR FOR
    SELECT datacode, datasubcode, qsicode
    FROM subgentables
    WHERE tableid = 616 
    
  OPEN cur_sendcodes
  
  FETCH NEXT FROM cur_sendcodes INTO @v_datacode, @v_datasubcode, @v_qsicode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    IF @v_qsicode = 1 BEGIN
      SET @v_relateddatacode = 3
    END
    ELSE BEGIN
      SET @v_relateddatacode = 1
    END

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode,datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate,relateddatacode)
    VALUES
      (@v_newkey, 616, @v_datacode,@v_datasubcode,  @v_work_itemtype, @v_work_usageclass, 'QSIDBA', getdate(),@v_relateddatacode)
      
    FETCH NEXT FROM cur_sendcodes INTO @v_datacode, @v_datasubcode, @v_qsicode

  END

  CLOSE cur_sendcodes 
  DEALLOCATE cur_sendcodes 
      
END
go


DECLARE
  @v_datacode INT,
  @v_datasubcode  INT,
  @v_qsicode  INT,
  @v_relateddatacode  INT,
  @v_sortorder INT,
  @v_project_itemtype INT,
  @v_project_usageclass INT,
  @v_newkey INT

BEGIN
  SELECT @v_project_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 3 --Projects

  SELECT @v_project_usageclass = 0  
        
  DECLARE cur_sendcodes CURSOR FOR
    SELECT datacode, datasubcode, qsicode
    FROM subgentables
    WHERE tableid = 616 
    
  OPEN cur_sendcodes
  
  FETCH NEXT FROM cur_sendcodes INTO @v_datacode, @v_datasubcode, @v_qsicode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    IF @v_qsicode = 1 BEGIN
      SET @v_relateddatacode = 3
    END
    ELSE BEGIN
      SET @v_relateddatacode = 1
    END

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, relateddatacode)
    VALUES
      (@v_newkey, 616, @v_datacode,@v_datasubcode,  @v_project_itemtype, @v_project_usageclass, 'QSIDBA', getdate(),@v_relateddatacode)
      
    FETCH NEXT FROM cur_sendcodes INTO @v_datacode, @v_datasubcode, @v_qsicode
  END

  CLOSE cur_sendcodes 
  DEALLOCATE cur_sendcodes 
      
END
go

