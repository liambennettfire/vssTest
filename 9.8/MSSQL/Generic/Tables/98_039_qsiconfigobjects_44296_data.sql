DECLARE 
    @v_count  INT,
    @v_max_key  INT,
    @v_max_key2  INT,
    @v_newkey   INT,
	@v_windowid INT,
	@v_qsiwindowviewkey INT,    
    @v_datacode_PO INT,
    @v_datasubcode INT,
    @v_position INT  
	
BEGIN
	
	SELECT @v_datacode_PO = dbo.qutl_get_gentables_datacode(550, 15, NULL)	
	
	SELECT @v_windowid = windowid 
	FROM qsiwindows 
	WHERE lower(windowname) = 'POSummary'	

    SET @v_count = 0
    
	SELECT @v_count = COUNT(*)
	FROM qsiconfigobjects
	WHERE configobjectid = 'FileLocations' AND windowid = @v_windowid
	
    IF @v_count = 0
    BEGIN 
	  exec dbo.get_next_key 'FBT',@v_max_key out

	  SELECT @v_position = MAX(COALESCE(position, 0)) + 1
	  FROM qsiconfigobjects
	  WHERE windowid = @v_windowid
	    AND itemtypecode = @v_datacode_PO
    
	  INSERT INTO qsiconfigobjects
	    (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc,
	    lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
	    position, configobjecttype, groupkey, sectioncontrolname)
	  VALUES
	    (@v_max_key, @v_windowid, 'FileLocations', 'File Locations', 'File Locations',
	    'QSIDBA', getdate(), 1, 0, @v_datacode_PO, 0, @v_position, 3, @v_max_key, '~/PageControls/Projects/Sections/Summary/FileLocationsSection.ascx')      
	    
	    
	  --DECLARE cur_PO CURSOR FOR
	  --SELECT datasubcode
	  --FROM subgentables
	  --WHERE tableid = 550
	  --    AND datacode = @v_datacode_PO
                    
	  --OPEN cur_PO
             
	  --FETCH NEXT FROM cur_PO INTO @v_datasubcode
             
	  --WHILE @@FETCH_STATUS = 0
	  --BEGIN
		 -- DECLARE cur_qsiwindowview CURSOR FOR
		 -- SELECT DISTINCT qsiwindowviewkey
		 -- FROM qsiwindowview
		 -- WHERE itemtypecode = @v_datacode_PO
			--  AND usageclasscode = @v_datasubcode
	                    
		 -- OPEN cur_qsiwindowview
	             
		 -- FETCH NEXT FROM cur_qsiwindowview INTO @v_qsiwindowviewkey
	             
		 -- WHILE @@FETCH_STATUS = 0
		 -- BEGIN

		 --  SELECT @v_position = MAX(COALESCE(position, 0)) + 1
		 --  FROM qsiconfigdetail
		 --  WHERE qsiwindowviewkey = @v_qsiwindowviewkey
			--	AND usageclasscode = @v_datasubcode
			--	AND configobjectkey IN (SELECT configobjectkey FROM qsiconfigobjects
			--							  WHERE windowid = @v_windowid
			--								AND itemtypecode = @v_datacode_PO)

			--EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	                         
			--INSERT INTO qsiconfigdetail
			--  (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			--  lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
			--VALUES
			--  (@v_newkey, @v_max_key, @v_datasubcode, 'File Locations', 0, 0,
			--  'QSIDBA', getdate(), @v_qsiwindowviewkey, 1, @v_position)         
	                    
			--FETCH NEXT FROM cur_qsiwindowview INTO @v_qsiwindowviewkey
		 -- END
	             
		 -- CLOSE cur_qsiwindowview
		 -- DEALLOCATE cur_qsiwindowview	  	  
	  
	  --  FETCH NEXT FROM cur_PO INTO @v_datasubcode
	  --END
             
	  --CLOSE cur_PO
	  --DEALLOCATE cur_PO	  
	  	    	   
    END	    
            
END
go
 	    