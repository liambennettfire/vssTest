DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_max_key3  INT,  
  @v_objectkey  INT,
  @v_itemtype INT
     
BEGIN  
  SET @v_itemtype = 14  -- printing

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'printingsummary' AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN
    exec dbo.get_next_key 'FBT',@v_max_key out
        
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'PrintingSummary', 'Printing Summary', 'Printing Summary',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, null, null, null, null
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPrintingDetails' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'shPrintingDetails', 'Printing Details', 'Printing Details',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 1, 3, @v_max_key, '~/PageControls/Printings/Sections/Summary/PrintingDetailsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END
    
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'TasksParticipants' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    -- combined section
    exec dbo.get_next_key 'FBT',@v_max_key out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'TasksParticipants', 'Tasks/Participants', 'Tasks and Participants',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 2, 4, @v_max_key, '~/PageControls/Printings/Sections/Summary/TasksParticipants.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'

    -- individual sections
    exec dbo.get_next_key 'FBT',@v_max_key2 out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key2, windowid, 'shTitleTasks', 'Printing Tasks', 'Printing Tasks',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 2, 3, @v_max_key, '~/PageControls/TitleSummary/Sections/TitleTasks.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
    
    exec dbo.get_next_key 'FBT',@v_max_key2 out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key2, windowid, 'ProjectParticipants', 'Participants', 'Participants',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 2, 3, @v_max_key, '~/PageControls/Projects/Sections/Summary/ParticipantsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'    
    
    exec dbo.get_next_key 'FBT',@v_max_key3 out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key3, windowid, 'shKeyDates', 'Key Dates', 'Key Dates',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 2, 3, @v_max_key3, NULL
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'        
  END   
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'ProjectComments', 'Comments', 'Comments',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 7, 3, @v_max_key, '~/PageControls/Projects/Sections/Summary/ProjectCommentsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END   

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shTitleElements' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'shTitleElements', 'Printing Elements', 'Printing Elements',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 8, 3, @v_max_key, '~/PageControls/TitleSummary/Sections/TitleElements.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'    
  END   

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'FileLocations' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'FileLocations', 'File Locations', 'File Locations',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 10, 3, @v_max_key, '~/PageControls/Projects/Sections/Summary/FileLocationsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END   
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'ProjectRelationshipsTab', 'Printing Relationships Tabs', 'Printing Relationships',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 3, 5, @v_max_key, '~/PageControls/ProjectRelationships/ProjectRelationships.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END     
  
END
go
