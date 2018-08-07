DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_objectkey  INT,
  @v_itemtype INT,
  @v_max_key2  INT,
  @v_max_key3  INT
     
BEGIN  
  SELECT @v_itemtype = datacode FROM gentables where tableid = 550 and qsicode = 5 -- User Admin 
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'SpecificationTemplateSummary' AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'SpecificationTemplateSummary', 'Specification Template Summary', 'Specification Template Summary',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, null, null, null, null
    FROM qsiwindows
    WHERE lower(windowname) = 'SpecificationTemplateSummary'
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'DetailsTasks' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    -- combined section
    exec dbo.get_next_key 'FBT',@v_max_key out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'DetailsTasks', 'Details/Tasks', 'Details and Tasks',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 1, 4, @v_max_key, '~/PageControls/SpecificationTemplate/Sections/Summary/DetailsTasks.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'SpecificationTemplateSummary'

    -- individual sections
    exec dbo.get_next_key 'FBT',@v_max_key2 out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key2, windowid, 'shSpecificationTemplateDetails', 'Specification Template Details', 'Specification Template Details',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 1, 3, @v_max_key, '~/PageControls/SpecificationTemplate/Sections/Summary/SpecificationTemplateDetailsSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'SpecificationTemplateSummary'    
         
         
    exec dbo.get_next_key 'FBT',@v_max_key3 out
            
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key3, windowid, 'KeyTasks', 'Key Tasks', 'Key Tasks',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 1, 3, @v_max_key, '~/PageControls/SpecificationTemplate/Sections/Summary/ProjectTasksSection.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'SpecificationTemplateSummary'              
        
  END     
  
  --SELECT @v_count = COUNT(*)
  --FROM qsiconfigobjects
  --WHERE configobjectid = 'shSpecificationTemplateDetails' AND itemtypecode = @v_itemtype

  --IF @v_count = 0
  --BEGIN  
  --  exec dbo.get_next_key 'FBT',@v_max_key out
    
  --  INSERT INTO qsiconfigobjects
  --    (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
  --    lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
  --    position, configobjecttype, groupkey, sectioncontrolname)
  --  SELECT @v_max_key, windowid, 'shSpecificationTemplateDetails', 'Specification Template Details', 'Specification Template Details',
  --    'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 1, 3, @v_max_key, '~/PageControls/SpecificationTemplate/Sections/Summary/SpecificationTemplateDetailsSection.ascx'
  --  FROM qsiwindows
  --  WHERE lower(windowname) = 'SpecificationTemplateSummary'
  --END
    
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProdSpecs' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'shProdSpecs', 'Specifications', 'Specifications',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 2, 3, @v_max_key, '~/PageControls/SpecificationTemplate/Sections/Summary/ProductionSpecification.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'SpecificationTemplateSummary'
  END 
  
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'linkDeleteProject' AND itemtypecode = @v_itemtype AND windowid = (SELECT windowid FROM qsiwindows WHERE lower(windowname) = 'DeleteSpecificationTemplate'   )

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'linkDeleteProject', 'Delete Specification Template', 'Delete Specification Template',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, NULL, NULL, NULL, NULL
    FROM qsiwindows
    WHERE lower(windowname) = 'DeleteSpecificationTemplate'   
  END 
    
    
END
go