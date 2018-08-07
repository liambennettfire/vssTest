-- Set up the new Home page misc sections:
DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_newkey INT,
  @v_qsiwindowviewkey INT
     
BEGIN
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'shHomeMisc1' AND itemtypecode = 0

  IF @v_count = 0 BEGIN
    SELECT @v_max_key = MAX(configobjectkey)
    FROM qsiconfigobjects
  
    SET @v_max_key = @v_max_key + 1
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, lastuserid, lastmaintdate, 
       itemtypecode, position, miscsectionind, sectioncontrolname, configobjecttype, groupkey)
    SELECT @v_max_key, windowid, 'shHomeMisc1', 'Home Miscellaneous Section 1', 'Content Services and eloquence At a Glance', 'QSIDBA', getdate(), 
       0, 0, 1, '~/PageControls/Home/Sections/HomeMisc.ascx', 3, @v_max_key
    FROM qsiwindows
    WHERE lower(windowname) = 'home'

    -- Add the new misc section to all Home window views
    DECLARE cur_winview CURSOR FOR
      SELECT DISTINCT qsiwindowviewkey
      FROM qsiwindowview
      WHERE itemtypecode = 0 AND usageclasscode = 0

    OPEN cur_winview

    FETCH NEXT FROM cur_winview INTO @v_qsiwindowviewkey

    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey)
      VALUES
        (@v_newkey, @v_max_key, 0, 'Content Services and eloquence At a Glance', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey)

    FETCH NEXT FROM cur_winview INTO @v_qsiwindowviewkey
    END

    CLOSE cur_winview
    DEALLOCATE cur_winview

  END

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'shHomeMisc2' AND itemtypecode = 0

  IF @v_count = 0 BEGIN
    SELECT @v_max_key = MAX(configobjectkey)
    FROM qsiconfigobjects
  
    SET @v_max_key = @v_max_key + 1
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, lastuserid, lastmaintdate, 
       itemtypecode, position, miscsectionind, sectioncontrolname, configobjecttype, groupkey)
    SELECT @v_max_key, windowid, 'shHomeMisc2', 'Home Miscellaneous Section 2', 'Management At a Glance', 'QSIDBA', getdate(), 
       0, 0, 1, '~/PageControls/Home/Sections/HomeMisc.ascx', 3, @v_max_key
    FROM qsiwindows
    WHERE lower(windowname) = 'home'
    
    -- Add the new misc section to all Home window views
    DECLARE cur_winview CURSOR FOR
      SELECT DISTINCT qsiwindowviewkey
      FROM qsiwindowview
      WHERE itemtypecode = 0 AND usageclasscode = 0

    OPEN cur_winview

    FETCH NEXT FROM cur_winview INTO @v_qsiwindowviewkey

    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO qsiconfigdetail
        (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
        lastuserid, lastmaintdate, qsiwindowviewkey)
      VALUES
        (@v_newkey, @v_max_key, 0, 'Management At a Glance', 0, 0,
        'QSIDBA', getdate(), @v_qsiwindowviewkey)

    FETCH NEXT FROM cur_winview INTO @v_qsiwindowviewkey
    END

    CLOSE cur_winview
    DEALLOCATE cur_winview
        
  END

END
go
