DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_newkey	INT,
  @v_objectkey  INT,
  @v_detailkey  INT,  
  @v_qsiwindowviewkey INT,					
  @v_windowid	INT
     
BEGIN
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'titlesummary'

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProdSpecs' AND windowid = @v_windowid
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out  
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    VALUES
      (@v_max_key, @v_windowid, 'shProdSpecs', 'Specifications', 'Specifications',
      'QSIDBA', getdate(), 1, 0, 1, 0, 12, 3, @v_max_key, '~/PageControls/TitleSummary/Sections/ProductionSpecification.ascx')			
		
  
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = 1 AND usageclasscode = 1
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode)
      VALUES
        (@v_newkey, @v_max_key, 1, 'Specifications', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 2)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  END
  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'printingsummary'
 
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProdSpecs' AND windowid = @v_windowid
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out  
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    VALUES
      (@v_max_key, @v_windowid, 'shProdSpecs', 'Specifications', 'Specifications',
      'QSIDBA', getdate(), 1, 0, 14, 0, 3, 3, @v_max_key, '~/PageControls/Printings/Sections/Summary/ProductionSpecification.ascx')			
		
  
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = 14 AND usageclasscode = 1
			
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
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 2, 3)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  END
   
  SELECT @v_objectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE configobjectid = 'ProjectRelationshipsTab' AND windowid = @v_windowid
  
  UPDATE qsiconfigobjects SET position = 4 WHERE configobjectkey = @v_objectkey
		
  DECLARE cur CURSOR FOR
  SELECT DISTINCT configdetailkey
  FROM qsiconfigdetail
  WHERE configobjectkey = @v_objectkey
			
  OPEN cur
		
  FETCH NEXT FROM cur INTO @v_detailkey
		
  WHILE @@FETCH_STATUS = 0
  BEGIN				
	  UPDATE qsiconfigdetail
	  SET position = 4
	  WHERE configdetailkey = @v_detailkey
			
	 FETCH NEXT FROM cur INTO @v_detailkey
  END
		
  CLOSE cur
  DEALLOCATE cur   
   
END
go