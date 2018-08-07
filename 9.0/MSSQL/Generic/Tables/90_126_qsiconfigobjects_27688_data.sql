DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_newkey	INT,
  @v_objectkey  INT,
  @v_qsiwindowviewkey INT,					
  @v_windowid	INT
     
BEGIN
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'projectsummary'
 
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
      'QSIDBA', getdate(), 0, 0, 3, 0, 17, 3, @v_max_key, '~/PageControls/Printings/Sections/Summary/ProductionSpecification.ascx')			
		
  
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = 3 AND usageclasscode = 1
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
			
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode)
      VALUES
        (@v_newkey, @v_max_key, 1, 'Specifications', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 2)
			
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  END
  
END
go