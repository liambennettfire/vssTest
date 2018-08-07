DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_newkey   INT,
  @v_objectkey  INT,
  @v_detailkey  INT, 
  @v_qsiwindowviewkey INT,                            
  @v_windowid INT,
  @v_itemtype INT,
  @v_class INT,
  @v_printingsummary_class INT,
  @v_position INT

BEGIN
  SELECT @v_itemtype = datacode -- Printing
  FROM gentables
  WHERE tableid = 550
    AND qsicode = 14

  SELECT @v_printingsummary_class = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND datacode = @v_itemtype
    AND qsicode = 40


  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'printingsummary'
 
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPrintingDeliveryDetails' AND windowid = @v_windowid
 
  IF @v_count = 0
  BEGIN 
    exec dbo.get_next_key 'FBT',@v_max_key out

	SELECT @v_position = COALESCE(position, 0)
	FROM qsiconfigobjects
	WHERE windowid = @v_windowid
	  AND itemtypecode = @v_itemtype
	  AND LOWER(configobjectid) = 'projectcomments'
	  
	UPDATE qsiconfigobjects
	SET position = position + 1
	WHERE windowid = @v_windowid
	  AND itemtypecode = @v_itemtype
	  AND position > @v_position

	SET @v_position = COALESCE(@v_position, 0) + 1	
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc,
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    VALUES
      (@v_max_key, @v_windowid, 'shPrintingDeliveryDetails', 'Delivery Details Section', 'Delivery Details',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_position, 3, @v_max_key, '~/PageControls/Printings/Sections/Summary/PrintingDeliveryDetailsSection.ascx')             
             
 
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey, usageclasscode
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype
	  AND usageclasscode IN (@v_printingsummary_class)
                    
    OPEN cur
             
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_class
             
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
                    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode)
      VALUES
        (@v_newkey, @v_max_key, @v_class, 'Delivery Details', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 0)
                    
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_class
    END
             
    CLOSE cur
    DEALLOCATE cur
  END    
END
go
 