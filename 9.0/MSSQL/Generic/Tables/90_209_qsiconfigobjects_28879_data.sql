DECLARE
  @v_count  INT,
  @v_objectkey  INT,
  @v_itemtype INT,
  @v_newdetailkey INT,
  @v_usageclass INT,
  @v_qsiwindowviewkey INT,
  @v_windowid	INT,  
  @v_usageclass_ProformatPOReport INT,
  @v_usageclass_FinalPOReport INT,
  @v_configobjectkey INT     
  
BEGIN  
  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'posummary'  
  
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode 
      FROM subgentables WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders 
      
  SELECT @v_usageclass_ProformatPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 42   -- Purchase Orders / Proforma PO Report
	
  SELECT @v_usageclass_FinalPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 43   -- Purchase Orders / Final PO Report 
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
  
    SELECT TOP(1) @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects
	WHERE lower(configobjectid) = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid     
    
	DECLARE cur CURSOR FOR   ---- Proforma PO Report
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  exec get_next_key 'qsidba', @v_newdetailkey output
					    
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, position)
		  VALUES
			(@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'Tasks and Participants', 1, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	    
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur  		  

		DECLARE cur CURSOR FOR    ---- Final PO Report
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  exec get_next_key 'qsidba', @v_newdetailkey output
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, position)
		  VALUES
			(@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'Tasks and Participants', 1, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur      
  END 
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
    SELECT TOP(1) @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects
	WHERE lower(configobjectid) = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid  
	  
    DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
				    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'Tasks', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	    
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  		  

    DECLARE cur CURSOR FOR    ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'Tasks', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur       
  END    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
    SELECT TOP(1) @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects
	WHERE lower(configobjectid) = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid  
	
   DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
				    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'Additional Participants', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	    
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  		  

    DECLARE cur CURSOR FOR    ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'Additional Participants', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur   	  
  END       
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
    SELECT TOP(1) @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects
	WHERE lower(configobjectid) = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid 

    DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
				    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'Details and Costs', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)	    
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  		  

    DECLARE cur CURSOR FOR    ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'Details and Costs', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur      	
  END  
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
    SELECT TOP(1) @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects
	WHERE lower(configobjectid) = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid 
	
    DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
				    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'PO Details', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)	    
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  		  

    DECLARE cur CURSOR FOR    ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'PO Details', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur     	
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
    SELECT TOP(1) @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects
	WHERE lower(configobjectid) = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	 
    DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
				    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'PO Special Instructions', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 4)	    
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  		  

    DECLARE cur CURSOR FOR    ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'PO Special Instructions', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 4)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur    	
  END	  	  	  
END
go



DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_newkey	INT,
  @v_objectkey  INT,
  @v_qsiwindowviewkey INT,					
  @v_windowid	INT,
  @v_itemtype INT,  
  @v_usageclass INT,  
  @v_usageclass_ProformatPOReport INT,
  @v_usageclass_FinalPOReport INT 
     
BEGIN

  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'posummary'
  
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 41   -- Purchase Orders / Purchase Orders 
	
  SELECT @v_usageclass_ProformatPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 42   -- Purchase Orders / Proforma PO Report
	
  SELECT @v_usageclass_FinalPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 43   -- Purchase Orders / Final PO Report  

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProdSpecs' AND windowid = @v_windowid
  
  IF @v_count = 0
  BEGIN  
    EXEC dbo.get_next_key 'FBT', @v_max_key OUT  
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    VALUES
      (@v_max_key, @v_windowid, 'shProdSpecs', 'Specifications', 'Specifications',
      'QSIDBA', getdate(), 1, 0, 15, 0, 5, 3, @v_max_key, '~/PageControls/PurchaseOrders/Sections/Summary/POProductionSpecification.ascx')		
  
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = 15 AND usageclasscode = 1
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey, @v_max_key, 1, 'Specifications', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 2, 5)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
    
    DECLARE cur CURSOR FOR ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = 15 AND usageclasscode = 2
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey, @v_max_key, 2, 'Specifications', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 2, 0)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur    
    
    DECLARE cur CURSOR FOR ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = 15 AND usageclasscode = 3
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey, @v_max_key, 3, 'Specifications', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 2, 0)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur     
  END
  ELSE BEGIN 
	UPDATE qsiconfigobjects SET position = 5, defaultvisibleind = 1 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 5, visibleind = 1, labeldesc = 'Specifications'
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	SELECT @v_count = count(*)    ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 0, visibleind = 0
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  
	
	SELECT @v_count = count(*)    ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 0, visibleind = 0
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END   
  END
END
go
  