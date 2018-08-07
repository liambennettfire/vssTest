-- Delete Purchase Order
DECLARE
  @v_count  INT,
  @v_objectkey  INT,
  @v_itemtype INT,
  @v_newkey INT
     
BEGIN  
  SET @v_itemtype = 15  -- Purchase Order
      
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'linkDeletePurchaseOrder' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    -- combined section
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
        
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'linkDeleteProject', 'Delete Purchase Order', 'Delete Purchase Order',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, NULL, NULL, NULL, NULL
    FROM qsiwindows
    WHERE lower(windowname) = 'DeletePurchaseOrder'   
  END   
END
go