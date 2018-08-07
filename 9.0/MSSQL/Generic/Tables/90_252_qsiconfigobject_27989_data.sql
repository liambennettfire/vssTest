DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_max_key3  INT,  
  @v_objectkey  INT,
  @v_itemtype INT,
  @v_new_configdetailkey INT,
  @v_qsiwindowviewkey int,
  @v_usageclass int,
  @v_visibleind int,
  @v_windowid	INT,  
  @v_usageclass_ProformatPOReport INT,
  @v_usageclass_FinalPOReport INT   

     
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
    WHERE lower(windowname) = 'posummary'
    
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_new_configdetailkey output
			
      INSERT INTO qsiconfigdetail
	    (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
	    lastuserid, lastmaintdate, qsiwindowviewkey, position)
	  VALUES
	    (@v_new_configdetailkey, @v_max_key, @v_usageclass, 'Comments', 1, 0,
	    'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur
  
    DECLARE cur CURSOR FOR   ---- Proforma PO Report
    SELECT DISTINCT qsiwindowviewkey
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype AND usageclasscode =  @v_usageclass_ProformatPOReport
			
    OPEN cur
		
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		
    WHILE @@FETCH_STATUS = 0
    BEGIN
      exec get_next_key 'qsidba', @v_new_configdetailkey output
			
	  INSERT INTO qsiconfigdetail
	    (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
	    lastuserid, lastmaintdate, qsiwindowviewkey, position)
	  VALUES
	    (@v_new_configdetailkey, @v_max_key, @v_usageclass_ProformatPOReport, 'Comments', 0, 0,
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
      exec get_next_key 'qsidba', @v_new_configdetailkey output
			
	  INSERT INTO qsiconfigdetail
	    (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
	    lastuserid, lastmaintdate, qsiwindowviewkey, position)
	  VALUES
	    (@v_new_configdetailkey, @v_max_key, @v_usageclass_FinalPOReport, 'Comments', 0, 0,
	    'QSIDBA', getdate(), @v_qsiwindowviewkey, 7)
			
	  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
    END
		
    CLOSE cur
    DEALLOCATE cur  
		     
  END
  ELSE BEGIN
	UPDATE qsiconfigobjects SET position = 7, defaultvisibleind = 1 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
	
	SELECT @v_count = count(*)
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 1
		 WHERE usageclasscode = @v_usageclass
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
	
	SELECT @v_count = count(*)    ---- Proforma PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_ProformatPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 0
		 WHERE usageclasscode = @v_usageclass_ProformatPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END  
	
	SELECT @v_count = count(*)    ---- Final PO Report
		FROM qsiconfigdetail
	   WHERE usageclasscode = @v_usageclass_FinalPOReport
		 AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	   
	IF @v_count > 0 BEGIN
		UPDATE qsiconfigdetail
		   SET position = 7, visibleind = 0
		 WHERE usageclasscode = @v_usageclass_FinalPOReport
		   AND configobjectkey in (select configobjectkey from qsiconfigobjects
								 WHERE configobjectid = 'ProjectComments' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
	END    
  END   
END
go

