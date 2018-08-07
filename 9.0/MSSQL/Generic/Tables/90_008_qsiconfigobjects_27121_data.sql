-- Delete Printing
DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_objectkey  INT,
  @v_itemtype INT
     
BEGIN  
  SET @v_itemtype = 14  -- Printing
      
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'linkDeletePrinting' AND itemtypecode = @v_itemtype
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
        
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'linkDeleteProject', 'Delete Printing', 'Delete Printing',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, NULL, NULL, NULL, NULL
    FROM qsiwindows
    WHERE lower(windowname) = 'DeletePrinting'   
  END   
END
go