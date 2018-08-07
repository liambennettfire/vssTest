DECLARE   @v_count              int
DECLARE   @v_datacode           int
DECLARE   @v_datasubcode        int
DECLARE   @v_tableid            int
DECLARE   @v_datadesc           varchar(120)
DECLARE   @v_datadescshort      varchar(20)
DECLARE   @v_tablemnemonic      varchar(40)
DECLARE   @v_alternatedesc1     varchar(255)
DECLARE   @v_alternatedesc2     varchar(255)
DECLARE   @v_newkey             int
DECLARE   @v_numericdesc1       int
DECLARE   @v_numericdesc2       int
DECLARE   @v_itemtypecode_PurchaseOrders      int
DECLARE   @v_itemtypesubcode_PurchaseOrders   int
DECLARE   @v_itemtypesubcode_ProformaPOReport int
DECLARE   @v_itemtypesubcode_FinalPOReport    int
DECLARE   @v_qsicode            int
DECLARE   @v_deletestatus		varchar(1)
DECLARE   @indicator1		    TINYINT
DECLARE   @relateddatacode      int

BEGIN
   SELECT @v_itemtypecode_PurchaseOrders = datacode FROM gentables WHERE tableid = 550 AND qsicode = 15
   SELECT @v_itemtypesubcode_PurchaseOrders = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 41
   SELECT @v_itemtypesubcode_ProformaPOReport = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 42
   SELECT @v_itemtypesubcode_FinalPOReport = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 43
     
   UPDATE gentablesitemtype  SET relateddatacode = 0, indicator1 = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() WHERE tableid = 285

   IF EXISTS(SELECT * FROM gentables where tableid = 285 and datadesc = 'Shipping Location' AND COALESCE(qsicode, 0) <> 17) BEGIN
	  UPDATE gentables SET datadesc = 'Shipping Location (old - remove)', deletestatus = 'Y', lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	  WHERE tableid = 285 and datadesc = 'Shipping Location' AND COALESCE(qsicode, 0) <> 17
   END
   
   SET @v_tableid = 285
   SET @v_tablemnemonic = 'ROLETYPE'
   SET @v_qsicode = 15

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND LTRIM(RTRIM(LOWER(datadesc))) = 'vendor' --Vendor
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Vendor'
    SET @v_datadescshort = 'Vendor'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,NULL,null,null,@v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND LTRIM(RTRIM(LOWER(datadesc))) = 'vendor'

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END     
  
  SET @indicator1 = 1
  SET @relateddatacode = 1
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders) BEGIN
	  -- add it to gentablesitemtype for Vendor
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_PurchaseOrders, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders	
  END
  
  SET @indicator1 = 1
  SET @relateddatacode = 1
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport) BEGIN
	  -- add it to gentablesitemtype for Vendor
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_ProformaPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate()     
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport	
  END
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport) BEGIN
	  -- add it to gentablesitemtype for Vendor
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_FinalPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport	
  END  
    
        
-- Shipping Location   
   SET @v_tableid = 285
   SET @v_tablemnemonic = 'ROLETYPE'
   SET @v_qsicode = 17

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND qsicode = 17 --Shipping Location
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Shipping Location'
    SET @v_datadescshort = 'Shipping Location'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,NULL,null,null,@v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
  
    SET @v_datadesc = 'Shipping Location'
    SET @v_datadescshort = 'Shipping Location'
      
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND qsicode = 17 

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 1, datadesc = @v_datadesc, datadescshort = @v_datadescshort, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END      
    
    
  SET @indicator1 = 0
  SET @relateddatacode = 2
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders) BEGIN
	  -- add it to gentablesitemtype for Shipping Location
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_PurchaseOrders, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders	
  END
  
  SET @indicator1 = 0
  SET @relateddatacode = 2
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport) BEGIN
	  -- add it to gentablesitemtype for Shipping Location
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_ProformaPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport	
  END    
    
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport) BEGIN
	  -- add it to gentablesitemtype for Shipping Location
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_FinalPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport	
  END  
      
  -- Shipping Location (Rarely Used)   
   SET @v_tableid = 285
   SET @v_tablemnemonic = 'ROLETYPE'
   SET @v_qsicode = 18

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND LTRIM(RTRIM(LOWER(datadesc))) = 'shipping location (rarely used)' --Shipping Location (Rarely Used)
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Shipping Location (Rarely Used)'
    SET @v_datadescshort = 'Ship Loc (Rarely Use'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,1,0,NULL,null,null,@v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND LTRIM(RTRIM(LOWER(datadesc))) = 'shipping location (rarely used)'

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END      
    
    
  SET @indicator1 = 0
  SET @relateddatacode = 2
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders) BEGIN
	  -- add it to gentablesitemtype for Shipping Location (Rarely Used)
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_PurchaseOrders, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders	
  END
  
  SET @indicator1 = 0
  SET @relateddatacode = 2
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport) BEGIN
	  -- add it to gentablesitemtype for Shipping Location (Rarely Used)
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_ProformaPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport	
  END    
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport) BEGIN
	  -- add it to gentablesitemtype for Shipping Location (Rarely Used)
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_FinalPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport	
  END    
    
  -- Foreign Vendor
   SET @v_tableid = 285
   SET @v_tablemnemonic = 'ROLETYPE'
   SET @v_qsicode = 19   

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND LTRIM(RTRIM(LOWER(datadesc))) = 'foreign vendor' --Foreign Vendor
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Foreign Vendor'
    SET @v_datadescshort = 'Foreign Vendor'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,0,0,NULL,null,null, @v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND LTRIM(RTRIM(LOWER(datadesc))) = 'foreign vendor'

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END      
    
    
  SET @indicator1 = 1
  SET @relateddatacode = 3
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders) BEGIN
	  -- add it to gentablesitemtype for Foreign Vendor
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_PurchaseOrders, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders	
  END
  
  SET @indicator1 = 1
  SET @relateddatacode = 3
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport) BEGIN
	  -- add it to gentablesitemtype for Foreign Vendor
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_ProformaPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport	
  END    
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport) BEGIN
	  -- add it to gentablesitemtype for Foreign Vendor
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_FinalPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport	
  END      
  
  
  -- Forwarding Agent
   SET @v_tableid = 285
   SET @v_tablemnemonic = 'ROLETYPE'
   SET @v_qsicode = 20      

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND LTRIM(RTRIM(LOWER(datadesc))) = 'forwarding agent' --Forwarding Agent
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Forwarding Agent'
    SET @v_datadescshort = 'Forwarding Agent'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,0,0,NULL,null,null, @v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND LTRIM(RTRIM(LOWER(datadesc))) = 'forwarding agent'

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END      
    
    
  SET @indicator1 = 1
  SET @relateddatacode = 3
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders) BEGIN
	  -- add it to gentablesitemtype for Forwarding Agent
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_PurchaseOrders, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders	
  END
  
  SET @indicator1 = 1
  SET @relateddatacode = 3
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport) BEGIN
	  -- add it to gentablesitemtype for Forwarding Agent
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_ProformaPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport	
  END    
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport) BEGIN
	  -- add it to gentablesitemtype for Forwarding Agent
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_FinalPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport	
  END        
  
  
  -- Packager
   SET @v_tableid = 285
   SET @v_tablemnemonic = 'ROLETYPE'
   SET @v_qsicode = 21    

   SELECT @v_datacode = max(datacode)
   FROM gentables
   WHERE tableid = @v_tableid

   IF @v_datacode = 0 BEGIN
   SET @v_datacode = 1
   END
   ELSE BEGIN
   SET @v_datacode = @v_datacode + 1
   END
     
	
   SELECT @v_count = count(*)
    FROM gentables
   WHERE tableid = @v_tableid
     AND LTRIM(RTRIM(LOWER(datadesc))) = 'packager' --Packager
     
  IF @v_count = 0 BEGIN	  
    SET @v_datadesc = 'Packager'
    SET @v_datadescshort = 'Packager'
        
    INSERT INTO gentables 
      (tableid,datacode,datadesc,deletestatus,applid,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,
       numericdesc1,numericdesc2,bisacdatacode,gen1ind,gen2ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,
       eloquencefieldtag,alternatedesc1,alternatedesc2,qsicode)
    VALUES (@v_tableid,@v_datacode,@v_datadesc,'N',NULL,NULL,@v_tablemnemonic,NULL,@v_datadescshort,'QSIDBA',getdate(),
      NULL,NULL,NULL,NULL,NULL,0,0,0,0,NULL,null,null, @v_qsicode)
  END
  ELSE IF @v_count = 1 BEGIN
     SELECT @v_datacode = datacode
       FROM gentables
      WHERE tableid = @v_tableid
        AND LTRIM(RTRIM(LOWER(datadesc))) = 'packager'

      UPDATE gentables
	     SET qsicode = @v_qsicode, lockbyqsiind = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate()
	   WHERE tableid = @v_tableid
		 AND datacode = @v_datacode 
  END      
    
    
  SET @indicator1 = 1
  SET @relateddatacode = 0
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders) BEGIN
	  -- add it to gentablesitemtype for Forwarding Agent
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_PurchaseOrders, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_PurchaseOrders	
  END
  
  SET @indicator1 = 1
  SET @relateddatacode = 0
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport) BEGIN
	  -- add it to gentablesitemtype for Forwarding Agent
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_ProformaPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_ProformaPOReport	
  END    
  
  IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport) BEGIN
	  -- add it to gentablesitemtype for Forwarding Agent
		 EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	
		 INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, 
			 itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate, sortorder, indicator1, relateddatacode)
		 VALUES
			(@v_newkey, @v_tableid, @v_datacode, 0, 0, @v_itemtypecode_PurchaseOrders, @v_itemtypesubcode_FinalPOReport, 0, 'QSIDBA', getdate(), null, @indicator1, @relateddatacode)  
  END
  ELSE BEGIN
	 UPDATE gentablesitemtype SET indicator1 = @indicator1, relateddatacode = @relateddatacode, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
	 WHERE tableid=285 and datacode = @v_datacode and itemtypecode = @v_itemtypecode_PurchaseOrders and itemtypesubcode = @v_itemtypesubcode_FinalPOReport	
  END        
    
    
END
go