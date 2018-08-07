DECLARE
  @v_count  INT,
  @v_itemtypecode  INT,
  @v_configobjectkey_ProjectDetails  INT,
  @v_configobjectkey  INT
           
BEGIN  		 
     SELECT TOP(1) @v_configobjectkey_ProjectDetails = configobjectkey
     FROM qsiconfigobjects
     WHERE LOWER(configobjectid) = LOWER('ProjectDetails')	
     
	 -- Printing Details	 
	 SELECT @v_itemtypecode = datacode
	 FROM gentables
	 WHERE tableid = 550 AND qsicode = 14
	 
     SELECT TOP(1) @v_configobjectkey = configobjectkey
     FROM qsiconfigobjects
     WHERE LOWER(configobjectid) = LOWER('shPrintingDetails')	 
     
     IF EXISTS(SELECT * FROM miscitemsection WHERE configobjectkey = @v_configobjectkey_ProjectDetails AND itemtypecode = @v_itemtypecode) BEGIN
		 UPDATE miscitemsection 
		 SET configobjectkey = @v_configobjectkey
		 WHERE configobjectkey = @v_configobjectkey_ProjectDetails
		 AND itemtypecode = @v_itemtypecode
     END
     
	 -- Purchase Order Details	 
	 SELECT @v_itemtypecode = datacode
	 FROM gentables
	 WHERE tableid = 550 AND qsicode = 15
	 
     SELECT TOP(1) @v_configobjectkey = configobjectkey
     FROM qsiconfigobjects
     WHERE LOWER(configobjectid) = LOWER('shPurchaseOrderDetails')	 
     
     IF EXISTS(SELECT * FROM miscitemsection WHERE configobjectkey = @v_configobjectkey_ProjectDetails AND itemtypecode = @v_itemtypecode) BEGIN     
		 UPDATE miscitemsection 
		 SET configobjectkey = @v_configobjectkey
		 WHERE configobjectkey = @v_configobjectkey_ProjectDetails
		 AND itemtypecode = @v_itemtypecode
     END
     
	 -- Scale Details	 
	 SELECT @v_itemtypecode = datacode
	 FROM gentables
	 WHERE tableid = 550 AND qsicode = 11
	 
     SELECT TOP(1) @v_configobjectkey = configobjectkey
     FROM qsiconfigobjects
     WHERE LOWER(configobjectid) = LOWER('shScaleDetails')	 
     
     IF EXISTS(SELECT * FROM miscitemsection WHERE configobjectkey = @v_configobjectkey_ProjectDetails AND itemtypecode = @v_itemtypecode) BEGIN     
		 UPDATE miscitemsection 
		 SET configobjectkey = @v_configobjectkey
		 WHERE configobjectkey = @v_configobjectkey_ProjectDetails
		 AND itemtypecode = @v_itemtypecode     
     END
	 
	 -- Work Details	 
	 SELECT @v_itemtypecode = datacode
	 FROM gentables
	 WHERE tableid = 550 AND qsicode = 9
	 
     SELECT TOP(1) @v_configobjectkey = configobjectkey
     FROM qsiconfigobjects
     WHERE LOWER(configobjectid) = LOWER('shWorkDetails')	 
     
     IF EXISTS(SELECT * FROM miscitemsection WHERE configobjectkey = @v_configobjectkey_ProjectDetails AND itemtypecode = @v_itemtypecode) BEGIN     
		 UPDATE miscitemsection 
		 SET configobjectkey = @v_configobjectkey
		 WHERE configobjectkey = @v_configobjectkey_ProjectDetails
		 AND itemtypecode = @v_itemtypecode  
     END  	 
     
	 -- Contract Details	 
	 SELECT @v_itemtypecode = datacode
	 FROM gentables
	 WHERE tableid = 550 AND qsicode = 10
	 
     SELECT TOP(1) @v_configobjectkey = configobjectkey
     FROM qsiconfigobjects
     WHERE LOWER(configobjectid) = LOWER('shContractDetails')	 
     
     IF EXISTS(SELECT * FROM miscitemsection WHERE configobjectkey = @v_configobjectkey_ProjectDetails AND itemtypecode = @v_itemtypecode) BEGIN     
		 UPDATE miscitemsection 
		 SET configobjectkey = @v_configobjectkey
		 WHERE configobjectkey = @v_configobjectkey_ProjectDetails
		 AND itemtypecode = @v_itemtypecode  
     END  	      
	 
END
go  