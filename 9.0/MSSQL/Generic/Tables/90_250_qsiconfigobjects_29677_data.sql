DECLARE
  @v_count  INT,
  @v_objectkey  INT,
  @v_itemtype INT,
  @v_usageclass_FinalPOReport INT,
  @v_usageclass_ProformatPOReport INT,
  @v_windowid	INT,
  @v_newkey INT,
  @v_newkey2 INT,
  @v_newkey3 INT,
  @v_newdetailkey INT,
  @v_usageclass INT,    
  @v_qsiwindowviewkey INT,
  @v_configobjectkey_Details_Costs INT  
  
     
BEGIN  
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 41  -- Purchase Orders
  SELECT @v_usageclass_ProformatPOReport = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 42  -- Proforma PO Report
  SELECT @v_usageclass_FinalPOReport = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 43  -- Final PO Report

  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'posummary'
  
	IF EXISTS (SELECT * FROM qsiconfigobjects WHERE configobjectid = 'PODetailsCosts') BEGIN
		SELECT @v_configobjectkey_Details_Costs = configobjectkey 
		FROM qsiconfigobjects 
		WHERE configobjectid = 'PODetailsCosts'
		 
		SELECT @v_count = COUNT(*)
		FROM qsiconfigobjects
		WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
		  
		IF @v_count = 0
		BEGIN  
			-- combined section
		  exec dbo.get_next_key 'FBT',@v_newkey out
		           
		  INSERT INTO qsiconfigobjects
			(configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
			lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
			position, configobjecttype, groupkey, sectioncontrolname)
		  SELECT @v_newkey, windowid, 'shPOReportCosts', 'PO Report Costs', 'PO Report Costs',
			'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, 9, 3, @v_configobjectkey_Details_Costs, '~/PageControls/PurchaseOrders/Sections/Summary/POReportCostsSection.ascx'
		  FROM qsiwindows
		  WHERE lower(windowname) = 'posummary'


		  DECLARE cur CURSOR FOR
		  SELECT DISTINCT qsiwindowviewkey
		  FROM qsiwindowview
		  WHERE itemtypecode = 15 AND usageclasscode = @v_usageclass
					
		  OPEN cur
				
		  FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
				
		  WHILE @@FETCH_STATUS = 0
		  BEGIN
			EXEC dbo.get_next_key 'QSIDBA', @v_newdetailkey OUT
					
		    INSERT INTO qsiconfigdetail
			  (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			  lastuserid, lastmaintdate, qsiwindowviewkey, position)
			VALUES
			  (@v_newdetailkey, @v_newkey, @v_usageclass, 'PO Report Costs', 0, 0,
			  'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
					
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
			EXEC dbo.get_next_key 'QSIDBA', @v_newdetailkey OUT
					
			INSERT INTO qsiconfigdetail
			  (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			  lastuserid, lastmaintdate, qsiwindowviewkey, position)
			VALUES
			  (@v_newdetailkey, @v_newkey, @v_usageclass_ProformatPOReport, 'PO Report Costs', 1, 0,
			  'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
					
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
			EXEC dbo.get_next_key 'QSIDBA', @v_newdetailkey OUT
					
			INSERT INTO qsiconfigdetail
			  (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
			  lastuserid, lastmaintdate, qsiwindowviewkey, position)
			VALUES
			  (@v_newdetailkey, @v_newkey, @v_usageclass_FinalPOReport, 'PO Report Costs', 1, 0,
			  'QSIDBA', getdate(), @v_qsiwindowviewkey, 3)
					
			FETCH NEXT FROM cur INTO @v_qsiwindowviewkey
		  END
				
		  CLOSE cur
		  DEALLOCATE cur  
		   
		END
		ELSE BEGIN
			UPDATE qsiconfigobjects SET position = 9, defaultvisibleind = 0, groupkey = @v_configobjectkey_Details_Costs WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid
			
			SELECT @v_count = count(*)
				FROM qsiconfigdetail
			   WHERE usageclasscode = @v_usageclass
				 AND configobjectkey in (select configobjectkey from qsiconfigobjects
										 WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
			   
			IF @v_count > 0 BEGIN
				UPDATE qsiconfigdetail
				   SET position = 9, visibleind = 0
				 WHERE usageclasscode = @v_usageclass
				   AND configobjectkey in (select configobjectkey from qsiconfigobjects
										 WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
			END    
			
			SELECT @v_count = count(*)    ---- Proforma PO Report
				FROM qsiconfigdetail
			   WHERE usageclasscode = @v_usageclass_ProformatPOReport
				 AND configobjectkey in (select configobjectkey from qsiconfigobjects
										 WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
			   
			IF @v_count > 0 BEGIN
				UPDATE qsiconfigdetail
				   SET position = 3, visibleind = 1
				 WHERE usageclasscode = @v_usageclass_ProformatPOReport
				   AND configobjectkey in (select configobjectkey from qsiconfigobjects
										 WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
			END  
			
			SELECT @v_count = count(*)    ---- Final PO Report
				FROM qsiconfigdetail
			   WHERE usageclasscode = @v_usageclass_FinalPOReport
				 AND configobjectkey in (select configobjectkey from qsiconfigobjects
										 WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
			   
			IF @v_count > 0 BEGIN
				UPDATE qsiconfigdetail
				   SET position = 3, visibleind = 1
				 WHERE usageclasscode = @v_usageclass_FinalPOReport
				   AND configobjectkey in (select configobjectkey from qsiconfigobjects
										 WHERE configobjectid = 'shPOReportCosts' AND itemtypecode = @v_itemtype AND windowid = @v_windowid)
			END   			
		END
	END
END	
go
  