DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_windowid INT,
  @v_maxpos	INT,
  @v_newkey INT,
  @v_newkey_detail INT,
  @v_qsiwindowviewkey INT,
  @v_usageclass_ProformatPOReport INT,
  @v_usageclass_FinalPOReport INT 
  
     
BEGIN  
  SELECT @v_itemtype = datacode
  FROM gentables where tableid = 550 AND qsicode = 3   -- projects
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'projectsummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'projectsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 1', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'projectsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 2', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'projectsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 3', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
    
  SELECT @v_itemtype = datacode
	  FROM gentables where tableid = 550 AND qsicode = 14   -- Printings
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'printingsummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 1', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 2', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 3', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
    
  SELECT @v_itemtype = datacode
	  FROM gentables where tableid = 550 AND qsicode = 10   -- Contracts
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'contractsummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'contractsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 1', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'contractsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 2', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'contractsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 3', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END       
  
  
  SELECT @v_itemtype = datacode
	  FROM gentables where tableid = 550 AND qsicode = 9   -- Works
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'worksummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'worksummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 1', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'worksummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 2', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	    
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'worksummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 3', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer      
  END         
  
  
  SELECT @v_itemtype = datacode
	  FROM gentables where tableid = 550 AND qsicode = 11   -- Scales
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'scalesummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'scalesummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 1', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  		
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'scalesummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 2', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	     
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'scalesummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 3', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	   
  END        
  
  SELECT @v_itemtype = datacode
	  FROM gentables where tableid = 550 AND qsicode = 6   -- Journals
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'journalsummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'journalsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 1', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	      
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'journalsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 2', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	       
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'journalsummary'
    
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0
    BEGIN    
    
		DECLARE cur CURSOR FOR
		SELECT DISTINCT qsiwindowviewkey
		FROM qsiwindowview
		WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		OPEN cur
			
		FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		WHILE @@FETCH_STATUS = 0
		BEGIN
		  EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
				
		  INSERT INTO qsiconfigdetail
			(configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
		  VALUES
			(@v_newkey_detail, @v_newkey, @v_usageclass, 'Participants By Role 3', 0, 0,
			'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		END
			
		CLOSE cur
		DEALLOCATE cur     
	  FETCH NEXT FROM cur_outer INTO @v_usageclass
	END
		
	CLOSE cur_outer
	DEALLOCATE cur_outer  	        
  END   
  
  
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 41   -- Purchase Orders / Purchase Orders 
	
  SELECT @v_usageclass_ProformatPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 42   -- Purchase Orders / Proforma PO Report
	
  SELECT @v_usageclass_FinalPOReport = datasubcode
	  FROM subgentables where tableid = 550 AND qsicode = 43   -- Purchase Orders / Final PO Report
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'posummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END		
	
	SELECT @v_count = count(*)       ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)     ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 9, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'KeyTasks' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END			
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END		
	
	SELECT @v_count = count(*)  ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)  ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 9, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END				
  END  
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1, defaultlabeldesc = 'Additional Participants' WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END		
	
	SELECT @v_count = count(*)   ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END		
	
	SELECT @v_count = count(*)   ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 9, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectParticipants' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END				
  END   
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 8, defaultvisibleind = 1 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 8, visibleind = 1 
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)  ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 8, visibleind = 1 
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END			
	
	SELECT @v_count = count(*)   ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 8, visibleind = 1 
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END							
  END  
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 9, defaultvisibleind = 0 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid

	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 0
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END		
	
	SELECT @v_count = count(*)  ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)     ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'PODetailsCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END			
  END  
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 9, defaultvisibleind = 0 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 0
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END		
	
	SELECT @v_count = count(*)   ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)     ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPODetails' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END			
  END    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
  
  IF @v_count > 0
  BEGIN    
	UPDATE qsiconfigobjects SET position = 8, defaultvisibleind = 0 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 4, visibleind = 0
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)  ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 4, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END	
	
	SELECT @v_count = count(*)     ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 4, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shPOInstructions' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END			
  END      
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype  
  
  SET @v_maxpos = 2
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole1', 'Project Participants By Role 1', 'Vendor',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 2, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole1Section.ascx'
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
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass, 'Vendor', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur    
    
    DECLARE cur CURSOR FOR  ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass_ProformatPOReport, 'Vendor', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, 2)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur    
    
    DECLARE cur CURSOR FOR      ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass_FinalPOReport, 'Vendor', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, 2)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur            
  END
  ELSE BEGIN
	UPDATE qsiconfigobjects SET position = 2, defaultvisibleind = 1 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 2, visibleind = 1
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  
	
	SELECT @v_count = count(*)  ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 2, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  
	
	SELECT @v_count = count(*)   ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 2, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole1' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  		
  END     
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = 3
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole2', 'Project Participants By Role 2', 'Shipping Locations',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole2Section.ascx'
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
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass, 'Shipping Locations', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur      
    
    DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass_ProformatPOReport, 'Shipping Locations', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, 6)
			
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
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass_FinalPOReport, 'Shipping Locations', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, 5)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur          
  END  
  ELSE BEGIN   
	UPDATE qsiconfigobjects SET position = 2, defaultvisibleind = 1 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 3, visibleind = 1
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	SELECT @v_count = count(*)    ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 6, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  
	
	SELECT @v_count = count(*)    ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 5, visibleind = 1
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole2' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  		
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = 4
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProjectParticipantsByRole3', 'Project Participants By Role 3', 'Import PO',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectParticipantsByRole3Section.ascx'
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
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass, 'Import PO', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur        
    
    DECLARE cur CURSOR FOR     ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass_ProformatPOReport, 'Import PO', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur      
    
    DECLARE cur CURSOR FOR     ---- Final PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass_FinalPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey_detail OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
        (@v_newkey_detail, @v_newkey, @v_usageclass_FinalPOReport, 'Import PO', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, NULL, @v_maxpos)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur              
  END
  ELSE BEGIN   
	UPDATE qsiconfigobjects SET position = 2, defaultvisibleind = 0 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = @v_maxpos, visibleind = 0
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	SELECT @v_count = count(*)    ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = @v_maxpos, visibleind = 0
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  
	
	SELECT @v_count = count(*)    ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = @v_maxpos, visibleind = 0
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'shProjectParticipantsByRole3' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  		
  END       
  
END
go
  