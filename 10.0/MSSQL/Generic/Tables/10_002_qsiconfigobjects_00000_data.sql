DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_windowid INT,
  @v_maxpos	INT,
  @v_newkey INT,
  @v_newkey_detail INT,
  @v_qsiwindowviewkey INT
  
BEGIN  
  SELECT @v_itemtype = datacode
  FROM gentables where tableid = 550 AND qsicode = 1   -- products
	  
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'productsummary'    
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shProductParticipantsByRole1' AND itemtypecode = @v_itemtype
  
	select @v_maxpos = max(COALESCE(position, 0)) + 1 from qsiconfigobjects WHERE windowid = @v_windowid 
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProductParticipantsByRole1', 'Product Participants By Role 1', 'Participants By Role 1',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, ''
    FROM qsiwindows
    WHERE lower(windowname) = 'productsummary'  

    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0 BEGIN    
		  DECLARE cur CURSOR FOR
		  SELECT DISTINCT qsiwindowviewkey
		  FROM qsiwindowview
		  WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		  OPEN cur
			
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		  WHILE @@FETCH_STATUS = 0 BEGIN
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
  WHERE configobjectid = 'shProductParticipantsByRole2' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProductParticipantsByRole2', 'Product Participants By Role 2', 'Participants By Role 2',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, ''
    FROM qsiwindows
    WHERE lower(windowname) = 'productsummary'	  
      
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0 BEGIN    
		  DECLARE cur CURSOR FOR
		  SELECT DISTINCT qsiwindowviewkey
		  FROM qsiwindowview
		  WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		  OPEN cur
			
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		  WHILE @@FETCH_STATUS = 0 BEGIN
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
  WHERE configobjectid = 'shProductParticipantsByRole3' AND itemtypecode = @v_itemtype
  
	SET @v_maxpos = @v_maxpos + 1
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'QSIDBA',@v_newkey out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shProductParticipantsByRole3', 'Product Participants By Role 3', 'Participants By Role 3',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_maxpos, 5, @v_newkey, ''
    FROM qsiwindows
    WHERE lower(windowname) = 'productsummary'	 
       
    DECLARE cur_outer CURSOR FOR
	  SELECT datasubcode
		  FROM subgentables where tableid = 550 AND datacode = @v_itemtype
			
    OPEN cur_outer
		
    FETCH NEXT FROM cur_outer INTO @v_usageclass
		
    WHILE @@FETCH_STATUS = 0 BEGIN    
		  DECLARE cur CURSOR FOR
		  SELECT DISTINCT qsiwindowviewkey
		  FROM qsiwindowview
		  WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclass
				
		  OPEN cur
			
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
			
		  WHILE @@FETCH_STATUS = 0 BEGIN
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
END
go