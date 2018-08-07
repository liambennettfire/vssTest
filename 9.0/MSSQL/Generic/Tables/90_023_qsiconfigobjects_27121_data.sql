DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_objectkey  INT
     
BEGIN  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPrintings' 
    AND windowid in (select windowid from qsiwindows
                    where lower(windowname) = 'home')
  
  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'shPrintings', 'My Printings', 'My Printings',
      'QSIDBA', getdate(), 1, 0, 0, 0, 7, 3, @v_max_key, '~/PageControls/Home/Sections/RecentPrintings.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'home'
  END  
END
go  