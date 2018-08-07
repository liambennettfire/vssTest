DECLARE
  @v_datacode INT,
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
    SELECT datacode
    FROM gentables
    WHERE tableid = 567 
    
  OPEN cur_sendcodes
  
  FETCH NEXT FROM cur_sendcodes INTO @v_datacode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 567, @v_datacode, @v_work_itemtype, @v_work_usageclass, 'QSIDBA', getdate())
      
    FETCH NEXT FROM cur_sendcodes INTO @v_datacode
  END

  CLOSE cur_sendcodes 
  DEALLOCATE cur_sendcodes 
      
END
go


DECLARE
  @v_datacode INT,
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
    SELECT datacode
    FROM gentables
    WHERE tableid = 567 
      
    
  OPEN cur_sendcodes
  
  FETCH NEXT FROM cur_sendcodes INTO @v_datacode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 567, @v_datacode, @v_project_itemtype, @v_project_usageclass, 'QSIDBA', getdate())
      
    FETCH NEXT FROM cur_sendcodes INTO @v_datacode
  END

  CLOSE cur_sendcodes 
  DEALLOCATE cur_sendcodes 
      
END
go

DECLARE @v_datacode INT
DECLARE @v_tableid INT
DECLARE @v_datadesc       varchar(120)
DECLARE @v_datadescshort  varchar(20) 
DECLARE @v_tablemnemonic  varchar(40)
DECLARE @v_qsicode  INT

IF NOT EXISTS (SELECT * FROM gentables WHERE tableid = 567 AND qsicode = 1) BEGIN
  SELECT @v_datacode = COALESCE(MAX(datacode),0) + 1 FROM gentables WHERE tableid = 567

  SET @v_datadesc = 'N/A'
  SET @v_datadescshort = 'N/A'
  SET @v_tableid = 567
  SET @v_tablemnemonic = 'ReleaseStrategy'
  SET @v_qsicode = 1

  INSERT INTO gentables 
   (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
    numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
    eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
  VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
    NULL,NULL,NULL,NULL,NULL,0,0,1,0,
    NULL,NULL,NULL,@v_qsicode)

END
go


DECLARE
  @v_datacode INT,
  @v_sortorder INT,
  @v_printing_itemtype INT,
  @v_printing_usageclass INT,
  @v_newkey INT

BEGIN
  SELECT @v_printing_itemtype = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 14  -- Printing

  SELECT @v_printing_usageclass = 0  
        
  SELECT @v_datacode = datacode
    FROM gentables
    WHERE tableid = 567 
      AND qsicode = 1
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
  INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate,sortorder)
    VALUES
      (@v_newkey, 567, @v_datacode, @v_printing_itemtype, @v_printing_usageclass, 'QSIDBA', getdate(),1)
END
go