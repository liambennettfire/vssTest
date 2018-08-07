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
  @v_configobjectkey INT,
  @v_configobjectkey_inner INT,
  @v_defaultvisibleind TINYINT,
  @v_defaultlabeldesc VARCHAR(100),  
  @v_configdetailkey INT,
  @v_configdetailkey_inner INT,  
  @v_usageclasscode INT,
  @v_original_position SMALLINT,
  @v_original_position_inner SMALLINT,  
  @v_newkey INT,
  @v_newkey2 INT     
  
BEGIN  	
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'posummary'  
  
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode 
      FROM subgentables WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders 
      
  SELECT @v_usageclass_ProformatPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 42   -- Purchase Orders / Proforma PO Report
	
  SELECT @v_usageclass_FinalPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 43   -- Purchase Orders / Final PO Report 
	  
	-- Set Usage Class for exiting qsiconfigdetail rows for 'TasksParticipants' of PO Summary 
	DECLARE cur CURSOR FOR
		SELECT d.qsiwindowviewkey, d.configdetailkey, d.configobjectkey, w.usageclasscode FROM qsiconfigdetail d INNER JOIN qsiwindowview w  ON d.qsiwindowviewkey = w.qsiwindowviewkey 
		WHERE d.configobjectkey IN (select configobjectkey 
								 FROM qsiconfigobjects 
								 WHERE windowid = (select windowid from qsiwindows where windowname = 'POSummary') AND 
								 configobjectid = 'TasksParticipants')				
	OPEN cur
		
	FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_configdetailkey, @v_configobjectkey, @v_usageclasscode
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
					
	    IF EXISTS (SELECT * FROM qsiconfigdetail WHERE usageclasscode = 0 AND configdetailkey = @v_configdetailkey) BEGIN			
			UPDATE qsiconfigdetail 
			SET usageclasscode = @v_usageclasscode
			WHERE configdetailkey = @v_configdetailkey
		END	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_configdetailkey, @v_configobjectkey, @v_usageclasscode
	END
		
	CLOSE cur
	DEALLOCATE cur  
	
	-- Set Usage Class for exiting qsiconfigdetail rows for 'KeyTasks' of PO Summary 
	DECLARE cur CURSOR FOR
		SELECT d.qsiwindowviewkey, d.configdetailkey, d.configobjectkey, w.usageclasscode FROM qsiconfigdetail d INNER JOIN qsiwindowview w  ON d.qsiwindowviewkey = w.qsiwindowviewkey 
		WHERE d.configobjectkey IN (select configobjectkey 
								 FROM qsiconfigobjects 
								 WHERE windowid = (select windowid from qsiwindows where windowname = 'POSummary') AND 
								 configobjectid = 'KeyTasks')				
	OPEN cur
		
	FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_configdetailkey, @v_configobjectkey, @v_usageclasscode
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
					
	    IF EXISTS (SELECT * FROM qsiconfigdetail WHERE usageclasscode = 0 AND configdetailkey = @v_configdetailkey) BEGIN			
			UPDATE qsiconfigdetail 
			SET usageclasscode = @v_usageclasscode
			WHERE configdetailkey = @v_configdetailkey
		END		
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_configdetailkey, @v_configobjectkey, @v_usageclasscode
	END
		
	CLOSE cur
	DEALLOCATE cur  	
	
	-- Set Usage Class for exiting qsiconfigdetail rows for 'ProjectParticipants' of PO Summary 
	DECLARE cur CURSOR FOR
		SELECT d.qsiwindowviewkey, d.configdetailkey, d.configobjectkey, w.usageclasscode FROM qsiconfigdetail d INNER JOIN qsiwindowview w  ON d.qsiwindowviewkey = w.qsiwindowviewkey 
		WHERE d.configobjectkey IN (select configobjectkey 
								 FROM qsiconfigobjects 
								 WHERE windowid = (select windowid from qsiwindows where windowname = 'POSummary') AND 
								 configobjectid = 'ProjectParticipants')				
	OPEN cur
		
	FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_configdetailkey, @v_configobjectkey, @v_usageclasscode
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
					
	    IF EXISTS (SELECT * FROM qsiconfigdetail WHERE usageclasscode = 0 AND configdetailkey = @v_configdetailkey) BEGIN			
			UPDATE qsiconfigdetail 
			SET usageclasscode = @v_usageclasscode
			WHERE configdetailkey = @v_configdetailkey
		END		
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_configdetailkey, @v_configobjectkey, @v_usageclasscode
	END
		
	CLOSE cur
	DEALLOCATE cur  	
	
	SELECT @v_original_position = COALESCE(position, 0), @v_configobjectkey = configobjectkey 
	FROM qsiconfigobjects 
	WHERE windowid = (select windowid from qsiwindows where windowname = 'POSummary') AND 
		  configobjectid = 'TasksParticipants'
	
	-- Insert/Update rows in qsiconfigdetail for each row of qsiwindowview of Itemtype Purchase Order		  		  		  
	DECLARE cur CURSOR FOR
		SELECT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND
			  usageclasscode = @v_usageclass
	OPEN cur
		
	FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM qsiconfigdetail 
					  WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
					  configobjectkey = @v_configobjectkey AND
					  usageclasscode = @v_usageclass) BEGIN
					  
			
		  exec get_next_key 'qsidba', @v_newdetailkey output
					    
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, position)
		  VALUES
			(@v_newdetailkey, @v_configobjectkey, @v_usageclass, 'Tasks and Participants', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_original_position)									  
		END
		ELSE BEGIN
			UPDATE qsiconfigdetail SET visibleind = 0
			WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
					  configobjectkey = @v_configobjectkey AND
					  usageclasscode = @v_usageclass 
		END
		
		DECLARE cur_inner CURSOR FOR
			SELECT configobjectkey, defaultlabeldesc, position 
			FROM qsiconfigobjects
			WHERE groupkey = @v_configobjectkey AND
				  configobjectkey <> @v_configobjectkey
		OPEN cur_inner
			
		FETCH NEXT FROM cur_inner INTO @v_configobjectkey_inner, @v_defaultlabeldesc, @v_original_position_inner
			
		WHILE @@FETCH_STATUS = 0
		BEGIN		
			IF NOT EXISTS(SELECT * FROM qsiconfigdetail 
						  WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
						  configobjectkey = @v_configobjectkey_inner AND
						  usageclasscode = @v_usageclass) BEGIN
						  
				
			  exec get_next_key 'qsidba', @v_newdetailkey output
						    
			  INSERT INTO qsiconfigdetail
				(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
				lastuserid, lastmaintdate, qsiwindowviewkey, position)
			  VALUES
				(@v_newdetailkey, @v_configobjectkey_inner, @v_usageclass, @v_defaultlabeldesc, 0, 0,
				'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_original_position_inner)									  
			END
			ELSE BEGIN
				UPDATE qsiconfigdetail SET visibleind = 0
				WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
						  configobjectkey = @v_configobjectkey_inner AND
						  usageclasscode = @v_usageclass 
			END		
		  FETCH NEXT FROM cur_inner INTO @v_configobjectkey_inner, @v_defaultlabeldesc, @v_original_position_inner
		END
			
		CLOSE cur_inner
		DEALLOCATE cur_inner 		
		
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
	END
		
	CLOSE cur
	DEALLOCATE cur  			  
		  
    		  
	-- Insert rows in qsiconfigdetail for each row of qsiwindowview of Itemtype Final PO Report   		  		  
	DECLARE cur CURSOR FOR
		SELECT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND
			  usageclasscode = @v_usageclass_ProformatPOReport
	OPEN cur
		
	FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM qsiconfigdetail 
					  WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
					  configobjectkey = @v_configobjectkey AND
					  usageclasscode = @v_usageclass_ProformatPOReport) BEGIN
					  
			
		  exec get_next_key 'qsidba', @v_newdetailkey output
					    
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, position)
		  VALUES
			(@v_newdetailkey, @v_configobjectkey, @v_usageclass_ProformatPOReport, 'Tasks and Participants', 1, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_original_position)									  
		END
		
		DECLARE cur_inner CURSOR FOR
			SELECT configobjectkey, defaultlabeldesc, position, defaultvisibleind 
			FROM qsiconfigobjects
			WHERE groupkey = @v_configobjectkey AND
				  configobjectkey <> @v_configobjectkey
		OPEN cur_inner
			
		FETCH NEXT FROM cur_inner INTO @v_configobjectkey_inner, @v_defaultlabeldesc, @v_original_position_inner, @v_defaultvisibleind
			
		WHILE @@FETCH_STATUS = 0
		BEGIN		
			IF NOT EXISTS(SELECT * FROM qsiconfigdetail 
						  WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
						  configobjectkey = @v_configobjectkey_inner AND
						  usageclasscode = @v_usageclass_ProformatPOReport) BEGIN
						  
				
			  exec get_next_key 'qsidba', @v_newdetailkey output
						    
			  INSERT INTO qsiconfigdetail
				(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
				lastuserid, lastmaintdate, qsiwindowviewkey, position)
			  VALUES
				(@v_newdetailkey, @v_configobjectkey_inner, @v_usageclass_ProformatPOReport, @v_defaultlabeldesc, @v_defaultvisibleind, 0,
				'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_original_position_inner)									  
			END
				
		  FETCH NEXT FROM cur_inner INTO @v_configobjectkey_inner, @v_defaultlabeldesc, @v_original_position_inner, @v_defaultvisibleind
		END
			
		CLOSE cur_inner
		DEALLOCATE cur_inner 		
		
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
	END
		
	CLOSE cur
	DEALLOCATE cur  
	
	-- Insert rows in qsiconfigdetail for each row of qsiwindowview of Itemtype Proforma PO Report			  		  		  
	DECLARE cur CURSOR FOR
		SELECT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND
			  usageclasscode = @v_usageclass_FinalPOReport
	OPEN cur
		
	FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM qsiconfigdetail 
					  WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
					  configobjectkey = @v_configobjectkey AND
					  usageclasscode = @v_usageclass_FinalPOReport) BEGIN
					  
			
		  exec get_next_key 'qsidba', @v_newdetailkey output
					    
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, position)
		  VALUES
			(@v_newdetailkey, @v_configobjectkey, @v_usageclass_FinalPOReport, 'Tasks and Participants', 1, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_original_position)									  
		END
		
		DECLARE cur_inner CURSOR FOR
			SELECT configobjectkey, defaultlabeldesc, position, defaultvisibleind 
			FROM qsiconfigobjects
			WHERE groupkey = @v_configobjectkey AND
				  configobjectkey <> @v_configobjectkey
		OPEN cur_inner
			
		FETCH NEXT FROM cur_inner INTO @v_configobjectkey_inner, @v_defaultlabeldesc, @v_original_position_inner, @v_defaultvisibleind
			
		WHILE @@FETCH_STATUS = 0
		BEGIN		
			IF NOT EXISTS(SELECT * FROM qsiconfigdetail 
						  WHERE qsiwindowviewkey = @v_qsiwindowviewkey AND 
						  configobjectkey = @v_configobjectkey_inner AND
						  usageclasscode = @v_usageclass_FinalPOReport) BEGIN
						  
				
			  exec get_next_key 'qsidba', @v_newdetailkey output
						    
			  INSERT INTO qsiconfigdetail
				(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
				lastuserid, lastmaintdate, qsiwindowviewkey, position)
			  VALUES
				(@v_newdetailkey, @v_configobjectkey_inner, @v_usageclass_FinalPOReport, @v_defaultlabeldesc, @v_defaultvisibleind, 0,
				'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_original_position_inner)									  
			END
				
		  FETCH NEXT FROM cur_inner INTO @v_configobjectkey_inner, @v_defaultlabeldesc, @v_original_position_inner, @v_defaultvisibleind
		END
			
		CLOSE cur_inner
		DEALLOCATE cur_inner		
		
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
	END
		
	CLOSE cur
	DEALLOCATE cur  
	

	-- SET qsiconfigobject row for 'TasksPrintingTasks' - SET visible just for usageclass PO Summary in qsiconfigdetail
	
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'TasksPrintingTasks' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    -- combined section
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'TasksPrintingTasks', 'Tasks/PrintingTasks', 'Tasks and Printing Tasks',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 7, 4, @v_newkey, '~/PageControls/PurchaseOrders/Sections/Summary/TasksPrintingTasks.ascx'
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
        (@v_newdetailkey, @v_newkey, @v_usageclass, 'Tasks and Printing Tasks', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur    

    -- individual sections
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey2 OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey2, windowid, 'KeyTasks', 'Tasks', 'Tasks',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 7, 3, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectTasksSection.ascx'
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
        
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey2 OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey2, windowid, 'shTitleTasks', 'Printing Tasks', 'Printing Tasks',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 7, 3, @v_newkey, '~/PageControls/TitleSummary/Sections/TitleTasks.ascx'
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
        (@v_newdetailkey, @v_newkey2, @v_usageclass, 'Printing Tasks', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  END	
		
  UPDATE qsiconfigobjects SET position = position + 1
  WHERE windowid = @v_windowid AND configobjectid <> 'ProjectComments' AND position > 7 		
  
  	
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND groupkey IS NULL
  
  IF @v_count = 0
  BEGIN  
   exec dbo.get_next_key 'QSIDBA',@v_newkey out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'ProjectParticipants', 'Participants', 'Additional Participants',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 8, 3, @v_newkey, '~/PageControls/Projects/Sections/Summary/ParticipantsSection.ascx'
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
        (@v_newdetailkey, @v_newkey, @v_usageclass, 'Additional Participants', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 8)	
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  	

  END		

	DELETE FROM qsiconfigdetail 
	WHERE configobjectkey IN (SELECT configobjectkey 
							  FROM qsiconfigobjects 
							  WHERE groupkey = (select groupkey from qsiconfigobjects  where itemtypecode = @v_itemtype and configobjectid = 'TasksParticipants'))
	AND usageclasscode = @v_usageclass	
	
	UPDATE qsiconfigobjects SET defaultvisibleind = 0 WHERE configobjectkey IN
	(select configobjectkey 
		  FROM qsiconfigobjects 
		  WHERE groupkey = (select groupkey from qsiconfigobjects  where itemtypecode = @v_itemtype and configobjectid = 'TasksParticipants'))	  
END

