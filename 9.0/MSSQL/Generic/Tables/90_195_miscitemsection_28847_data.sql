DECLARE 
	@v_misckey INT,
	@v_configobjectkey INT,
	@v_itemtypecode INT,
	@v_usageclasscode INT
	
	
BEGIN
 --   --- Report Specification Detail Type on Project Details for Proforma PO Report classes and Final PO Report Classes
	SELECT @v_misckey = misckey 
	  FROM bookmiscitems
	 WHERE lower(miscname) = 'report specification detail type'
	
	SELECT @v_configobjectkey = configobjectkey
	  FROM qsiconfigobjects
	 WHERE configobjectid = 'ProjectDetails'
	
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 15
        
    SELECT @v_usageclasscode = datasubcode
      FROM subgentables
     WHERE tableid = 550
       AND datacode = @v_itemtypecode
       AND qsicode = 42   -- Proforma PO report
       
    INSERT INTO miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
		VALUES (@v_misckey,@v_configobjectkey,@v_usageclasscode,@v_itemtypecode,1,1,1,'QSIDBA',getdate())
		
		
    SELECT @v_usageclasscode = datasubcode
      FROM subgentables
     WHERE tableid = 550
       AND datacode = @v_itemtypecode
       AND qsicode = 43   -- Final PO report
       
       
    INSERT INTO miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
		VALUES (@v_misckey,@v_configobjectkey,@v_usageclasscode,@v_itemtypecode,1,2,1,'QSIDBA',getdate())
		
		
    --- Vendor ID on Vendor and Shipping Information section on Contact Summary
	SELECT @v_misckey = misckey 
	  FROM bookmiscitems
	 WHERE lower(miscname) = 'vendor id'
	
	SELECT @v_configobjectkey = configobjectkey
	  FROM qsiconfigobjects
	 WHERE configobjectid = 'VendorandShippingInformation'
	
    SELECT @v_itemtypecode = datacode
      FROM gentables
     WHERE tableid = 550
       AND qsicode = 2 -- Contacts
        
    INSERT INTO miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
		VALUES (@v_misckey,@v_configobjectkey,0,@v_itemtypecode,1,1,1,'QSIDBA',getdate())
	
	-- Net Days on Vendor and Shipping Information section on Contact Summary	
	SELECT @v_misckey = misckey 
	  FROM bookmiscitems
	 WHERE lower(miscname) = 'net days'	
	 
	 
	INSERT INTO miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
		VALUES (@v_misckey,@v_configobjectkey,0,@v_itemtypecode,2,1,1,'QSIDBA',getdate())
		
			
    -- FOB on Vendor and Shipping Information section on Contact Summary	
	SELECT @v_misckey = misckey 
	  FROM bookmiscitems
	 WHERE lower(miscname) = 'fob'	
	 
	 
	INSERT INTO miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
		VALUES (@v_misckey,@v_configobjectkey,0,@v_itemtypecode,3,1,1,'QSIDBA',getdate())
    

END
go

