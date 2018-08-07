DECLARE
  @v_count  INT,
  @v_objectkey  INT,
  @v_itemtype INT,
  @v_newkey INT,
  @v_newkey2 INT,
  @v_newdetailkey INT,
  @v_usageclass INT,
  @v_qsiwindowviewkey INT,
  @v_windowid	INT  
  --@v_usageclass_ProformatPOReport INT,
  --@v_usageclass_FinalPOReport INT     
  
     
BEGIN  
  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'posummary'  
  
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode 
      FROM subgentables WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders 
      
  --SELECT @v_usageclass_ProformatPOReport = datasubcode
	 -- FROM subgentables where tableid = 550 AND qsicode = 42   -- Purchase Orders / Proforma PO Report
	
  --SELECT @v_usageclass_FinalPOReport = datasubcode
	 -- FROM subgentables where tableid = 550 AND qsicode = 43   -- Purchase Orders / Final PO Report    

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'posummary' AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'POSummary', 'Purchase Orders Summary', 'Purchase Orders Summary',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, null, null, null, null
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPurchaseOrderDetails' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shPurchaseOrderDetails', 'Purchase Order Details', 'Purchase Order Details',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 1, 3, @v_newkey, '~/PageControls/PurchaseOrders/Sections/Summary/PODetailsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'
  END
    
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    -- combined section
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'TasksParticipants', 'Tasks/Participants', 'Tasks and Participants',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 7, 4, @v_newkey, '~/PageControls/Projects/Sections/Summary/TasksParticipants.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'
    
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_newkey, @v_usageclass, 'Tasks and Participants', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
   -- DECLARE cur CURSOR FOR   ---- Proforma PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
				    
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey, @v_usageclass_ProformatPOReport, 'Tasks and Participants', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	    
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  		  

   -- DECLARE cur CURSOR FOR    ---- Final PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
			
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey, @v_usageclass_FinalPOReport, 'Tasks and Participants', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur      

    -- individual sections
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey2 OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey2, windowid, 'KeyTasks', 'Tasks', 'Tasks',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 7, 3, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectTasksSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'
    
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_newkey2, @v_usageclass, 'Tasks', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
   -- DECLARE cur CURSOR FOR   ---- Proforma PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
				    
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey2, @v_usageclass_ProformatPOReport, 'Tasks', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	    
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  		  

   -- DECLARE cur CURSOR FOR    ---- Final PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
			
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey2, @v_usageclass_FinalPOReport, 'Tasks', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur     
    
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey2 OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey2, windowid, 'ProjectParticipants', 'Participants', 'Additional Participants',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 7, 3, @v_newkey, '~/PageControls/Projects/Sections/Summary/ParticipantsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'  
    
    
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_newkey2, @v_usageclass, 'Additional Participants', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
   -- DECLARE cur CURSOR FOR   ---- Proforma PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
				    
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey2, @v_usageclass_ProformatPOReport, 'Additional Participants', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	    
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  		  

   -- DECLARE cur CURSOR FOR    ---- Final PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
			
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey2, @v_usageclass_FinalPOReport, 'Additional Participants', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur   
  END
  ELSE BEGIN
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1, labeldesc = 'Tasks and Participants'
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	--SELECT @v_count = count(*)    ---- Proforma PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 7, visibleind = 1, labeldesc = 'Tasks and Participants'
	--	 WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END  
	
	--SELECT @v_count = count(*)    ---- Final PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 9, visibleind = 1, labeldesc = 'Tasks and Participants'
	--	 WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END    
	
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1, labeldesc = 'Tasks'
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	--SELECT @v_count = count(*)    ---- Proforma PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 7, visibleind = 1, labeldesc = 'Tasks'
	--	 WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END  
	
	--SELECT @v_count = count(*)    ---- Final PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 9, visibleind = 1, labeldesc = 'Tasks'
	--	 WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END  	
	
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1, labeldesc = 'Additional Participants'
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	--SELECT @v_count = count(*)    ---- Proforma PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 7, visibleind = 1, labeldesc = 'Additional Participants'
	--	 WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END  
	
	--SELECT @v_count = count(*)    ---- Final PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 9, visibleind = 1, labeldesc = 'Additional Participants'
	--	 WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END 	
	
  END       
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    -- combined section
    exec dbo.get_next_key 'FBT',@v_newkey out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'PODetailsCosts', 'PODetails/POCosts', 'Details and Costs',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 9, 4, @v_newkey, '~/PageControls/PurchaseOrders/Sections/Summary/PODetailsCosts.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'

    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_newkey, @v_usageclass, 'Details and Costs', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
   -- DECLARE cur CURSOR FOR   ---- Proforma PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
				    
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey, @v_usageclass_ProformatPOReport, 'Details and Costs', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)	    
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  		  

   -- DECLARE cur CURSOR FOR    ---- Final PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
			
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey, @v_usageclass_FinalPOReport, 'Details and Costs', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  
    
    -- individual sections
    exec dbo.get_next_key 'FBT',@v_newkey2 out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey2, windowid, 'shPODetails', 'PO Details', 'PO Details',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 9, 3, @v_newkey, '~/PageControls/PurchaseOrders/Sections/Summary/PODetails.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'    
    
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_newkey2, @v_usageclass, 'PO Details', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 9)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
   -- DECLARE cur CURSOR FOR   ---- Proforma PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
				    
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey2, @v_usageclass_ProformatPOReport, 'PO Details', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)	    
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  		  

   -- DECLARE cur CURSOR FOR    ---- Final PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
			
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey2, @v_usageclass_FinalPOReport, 'PO Details', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur     
                      
  END     
      

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
   exec dbo.get_next_key 'QSIDBA',@v_newkey out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shPOInstructions', 'PO Instructions', 'PO Instructions',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 8, 3, @v_newkey, '~/PageControls/PurchaseOrders/Sections/Summary/POInstructions.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary' 
    
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_newdetailkey output
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, position)
      VALUES
        (@v_newdetailkey, @v_newkey, @v_usageclass, 'PO Instructions', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 8)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
   -- DECLARE cur CURSOR FOR   ---- Proforma PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
				    
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey, @v_usageclass_ProformatPOReport, 'PO Instructions', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 4)	    
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur  		  

   -- DECLARE cur CURSOR FOR    ---- Final PO Report
   -- SELECT DISTINCT qsiwindowviewkey
   -- FROM qsiwindowview
   -- WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
   -- OPEN cur
		
   -- FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
   -- WHILE @@FETCH_STATUS = 0
   -- BEGIN
   --   exec get_next_key 'qsidba', @v_newdetailkey output
			
   --   INSERT INTO qsiconfigdetail
   --     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
   --     lastuserid, lastmaintdate, qsiwindowviewkey, position)
   --   VALUES
   --     (@v_newdetailkey, @v_newkey, @v_usageclass_FinalPOReport, 'PO Special Instructions', 1, 0,
   --     'QSIDBA', getdate(), @v_qsiwindowviewkey, 4)
			
	  --FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
   -- END
		
   -- CLOSE cur
   -- DEALLOCATE cur    
  END
  ELSE BEGIN
	UPDATE qsiconfigobjects SET position = 8, defaultvisibleind = 0 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 8, visibleind = 0
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	--SELECT @v_count = count(*)    ---- Proforma PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 4, visibleind = 1
	--	 WHERE usageclasscode = @v_usageclass_ProformatPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END  
	
	--SELECT @v_count = count(*)    ---- Final PO Report
	--	FROM qsiconfigdetail
	--   WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	 AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	--IF @v_count > 0 BEGIN
	--	UPDATE qsiconfigdetail
	--	   SET position = 4, visibleind = 1, labeldesc = 'PO Special Instructions'
	--	 WHERE usageclasscode = @v_usageclass_FinalPOReport
	--	   AND configobjectkey in (select configobjectkey from qsiconfigobjects
	--							 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	--END    
  END            
      
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'ProjectRelationshipsTab', 'Purchase Order Relationships Tabs', 'Purchase Order Relationships',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 8, 5, @v_newkey, '~/PageControls/ProjectRelationships/ProjectRelationships.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'
  END     
   
END
go

