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
  @v_position INT,
  @v_datacode INT
  
BEGIN
  SELECT @v_itemtype = datacode -- Printing
  FROM gentables
  WHERE tableid = 550
    AND qsicode = 14
    
    SET @v_datacode = dbo.qutl_get_gentables_datacode(638, 2, null)

  SELECT @v_printingsummary_class = datasubcode
  FROM subgentables
  WHERE tableid = 550
    AND datacode = @v_itemtype
    AND qsicode = 40
  SELECT @v_windowid = windowid FROM qsiwindows WHERE lower(windowname) = 'printingsummary'
 
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPrintingDeliveryDetails' AND windowid = @v_windowid
 
  IF @v_count > 0
  BEGIN 
	UPDATE 	qsiconfigobjects
	SET defaultvisibleind = 1, initialeditmode = @v_datacode
	WHERE configobjectid = 'shPrintingDeliveryDetails' AND windowid = @v_windowid
	
	SELECT @v_objectkey = configobjectkey
	FROM qsiconfigobjects
    WHERE configobjectid = 'shPrintingDeliveryDetails' AND windowid = @v_windowid
    
    SELECT @v_count = COUNT(*)
    FROM qsiconfigdetail
    WHERE configobjectkey =  @v_objectkey
    
      IF @v_count > 0
      BEGIN 
		UPDATE qsiconfigdetail
		SET visibleind = 1, initialeditmode = @v_datacode 
		WHERE configobjectkey =  @v_objectkey
      END
  END

END  