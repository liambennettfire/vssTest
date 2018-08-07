DECLARE
  @v_count  INT,
  @v_objectkey  INT,
  @v_newkey INT
     
BEGIN  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPurchaseOrders' 
    AND windowid in (select windowid from qsiwindows
                    where lower(windowname) = 'home')
  
  IF @v_count = 0
  BEGIN  
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'shPurchaseOrders', 'My Purchase Orders', 'My Purchase Orders',
      'QSIDBA', getdate(), 1, 0, 0, 0, 7, 3, @v_newkey, '~/PageControls/Home/Sections/RecentPOs.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'home'
  END  
END
go  