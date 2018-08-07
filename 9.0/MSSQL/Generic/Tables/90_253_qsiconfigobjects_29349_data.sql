DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_newkey INT,
  @v_usageclasscode INT,
  @v_qsiwindowviewkey INT,
  @v_newdetailkey INT,
  @v_configobjectid VARCHAR(100)
      
BEGIN  
  SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 and qsicode = 15 --Purchase Orders
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'additionalvendorimportinformation' AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'ProjectMisc1', 'Additional Vendor/Import Information', 'Additional Vendor/Import Information',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 1, null, 3, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectsMisc.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'posummary'
    
    --Set to visible for Purchase Order/Purchase Order
	SELECT @v_usageclasscode = datasubcode
	  FROM subgentables 
	 WHERE tableid = 550 
	   AND qsicode = 41 -- Purchase Order/Purchase Order
	    
	SELECT DISTINCT @v_qsiwindowviewkey = qsiwindowviewkey
	  FROM qsiwindowview
	 WHERE itemtypecode = 15 AND usageclasscode = @v_usageclasscode
	     
	EXEC dbo.get_next_key 'QSIDBA', @v_newdetailkey OUT
				
	INSERT INTO qsiconfigdetail
	 (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
	  lastuserid, lastmaintdate, qsiwindowviewkey)
	VALUES
	 (@v_newdetailkey, @v_newkey, @v_usageclasscode, 'Additional Vendor/Import Information', 1, 0,
	  'QSIDBA', getdate(), @v_qsiwindowviewkey)
  END
END
go