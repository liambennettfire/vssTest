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
  @v_posummary_class INT,
  @v_ex_posummary_class INT,
  @v_print_run_class INT,
  @v_position INT

BEGIN
  SELECT @v_itemtype = datacode -- Purchase Order
  FROM gentables
  WHERE tableid = 550
    AND qsicode = 15

  SELECT @v_posummary_class = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND datacode = @v_itemtype
    AND qsicode = 41

  SELECT @v_ex_posummary_class = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND datacode = @v_itemtype
    AND qsicode = 51

  SELECT @v_print_run_class = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND datacode = @v_itemtype
    AND qsicode = 60

  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'POSummary'
 
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPOSections' AND windowid = @v_windowid
 
  IF @v_count = 0
  BEGIN 
    exec dbo.get_next_key 'FBT',@v_max_key out

	SELECT @v_position = MAX(position)
	FROM qsiconfigobjects
	WHERE windowid = @v_windowid
	  AND itemtypecode = @v_itemtype

	SET @v_position = COALESCE(@v_position, 0) + 1
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc,
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    VALUES
      (@v_max_key, @v_windowid, 'shPOSections', 'Purchase Order Sections', 'PO Sections',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_position, 3, @v_max_key, '~/PageControls/PurchaseOrders/Sections/Summary/POSections.ascx')             
             
 
    DECLARE cur CURSOR FOR
    SELECT DISTINCT qsiwindowviewkey, usageclasscode
    FROM qsiwindowview
    WHERE itemtypecode = @v_itemtype
	  AND usageclasscode IN (@v_print_run_class)
                    
    OPEN cur
             
    FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_class
             
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
                    
      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode)
      VALUES
        (@v_newkey, @v_max_key, @v_class, 'Purchase Order Sections', 1, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey, 0)
                    
      FETCH NEXT FROM cur INTO @v_qsiwindowviewkey, @v_class
    END
             
    CLOSE cur
    DEALLOCATE cur
  END    
END
go
 