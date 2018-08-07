DECLARE
  @v_new_qsiwindowviewkey int,
  @v_new_configdetailkey int,
  @v_configobjectkey int,
  @v_usageclasscode int,
  @v_windowid int,
  @v_relationshiptabcode int,
  @v_sortorder int,
  @v_titletabind tinyint
 
BEGIN
 
  SELECT @v_usageclasscode = datasubcode FROM subgentables 
   WHERE tableid = 550 and datacode = 3
     and qsicode = 54
 
  IF @v_usageclasscode is null OR @v_usageclasscode <= 0 BEGIN
    print 'Could not find usageclasscode for qsicode 54'
    return
  END
 
 IF EXISTS (SELECT 1 
   FROM qsiwindowview 
   WHERE itemtypecode = 3
     AND usageclasscode = @v_usageclasscode 
     AND defaultind = 1 
     AND userkey = -1)
  BEGIN
    print 'A default windowview already exists for itemtype 3 and usageclass ' + cast(@v_usageclasscode as varchar)
    return
  END
 
  exec get_next_key 'qsidba', @v_new_qsiwindowviewkey output
 
  -- create default view
  INSERT INTO qsiwindowview (qsiwindowviewkey, qsiwindowviewname, qsiwindowviewdesc, 
                             itemtypecode, usageclasscode, defaultind, userkey, 
                             lastuserid, lastmaintdate ) 
  VALUES (@v_new_qsiwindowviewkey, 'Publicity Campaign','Publicity Campaign',
          3, @v_usageclasscode, 1, -1, 'Firebrand', getdate())
 
  -- get windowid of window
  SELECT @v_windowid = windowid 
    FROM qsiwindows 
   WHERE lower(windowname) = lower('ProjectSummary')
 
  -- insert qsiconfigdetail rows
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectSubjects') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Categories',
         0,0,'Firebrand',getdate(),7,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Categories'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('CategoriesContractInfo') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Categories and Contract Info',
         0,0,'Firebrand',getdate(),7,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Categories and Contract Info'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectComments') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Comments',
         1,0,'Firebrand',getdate(),3,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Comments'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('shProjectElements') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Elements',
         0,0,'Firebrand',getdate(),19,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Elements'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('FileLocations') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'File Locations',
         0,0,'Firebrand',getdate(),15,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: File Locations'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('KeyTasks') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Key Tasks',
         0,0,'Firebrand',getdate(),2,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Key Tasks'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectsTabgroup1') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Main Relationship Group',
         1,0,'Firebrand',getdate(),2,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
 
    DECLARE tab_cur CURSOR FOR
     SELECT relationshiptabcode, sortorder
     FROM qsiconfigdetailtabs
     WHERE configdetailkey = 45848422
 
    OPEN tab_cur
    FETCH NEXT FROM tab_cur INTO @v_relationshiptabcode, @v_sortorder
 
    WHILE @@FETCH_STATUS = 0 BEGIN
      INSERT INTO qsiconfigdetailtabs (configdetailkey, relationshiptabcode, sortorder, lastuserid, lastmaintdate)
      VALUES (@v_new_configdetailkey, @v_relationshiptabcode, @v_sortorder, 'Firebrand', getdate())
 
      FETCH NEXT FROM tab_cur INTO @v_relationshiptabcode, @v_sortorder
    END
    CLOSE tab_cur
    DEALLOCATE tab_cur
  END
  ELSE  BEGIN
      print 'Section not found on this database: Main Relationship Group'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectsTabgroup2') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Marketing Tab Group',
         0,0,'Firebrand',getdate(),2,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
 
    DECLARE tab_cur CURSOR FOR
     SELECT relationshiptabcode, sortorder
     FROM qsiconfigdetailtabs
     WHERE configdetailkey = 45848450
 
    OPEN tab_cur
    FETCH NEXT FROM tab_cur INTO @v_relationshiptabcode, @v_sortorder
 
    WHILE @@FETCH_STATUS = 0 BEGIN
      INSERT INTO qsiconfigdetailtabs (configdetailkey, relationshiptabcode, sortorder, lastuserid, lastmaintdate)
      VALUES (@v_new_configdetailkey, @v_relationshiptabcode, @v_sortorder, 'Firebrand', getdate())
 
      FETCH NEXT FROM tab_cur INTO @v_relationshiptabcode, @v_sortorder
    END
    CLOSE tab_cur
    DEALLOCATE tab_cur
  END
  ELSE  BEGIN
      print 'Section not found on this database: Marketing Tab Group'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectParticipants') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Participants',
         0,0,'Firebrand',getdate(),2,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Participants'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectSummary') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Publicity Campaign',
         1,0,'Firebrand',getdate(),null,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Project Summary'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectsTabgroup3') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Publicity Tab Group',
         1,0,'Firebrand',getdate(),4,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
 
    DECLARE tab_cur CURSOR FOR
     SELECT relationshiptabcode, sortorder
     FROM qsiconfigdetailtabs
     WHERE configdetailkey = 45848420
 
    OPEN tab_cur
    FETCH NEXT FROM tab_cur INTO @v_relationshiptabcode, @v_sortorder
 
    WHILE @@FETCH_STATUS = 0 BEGIN
      INSERT INTO qsiconfigdetailtabs (configdetailkey, relationshiptabcode, sortorder, lastuserid, lastmaintdate)
      VALUES (@v_new_configdetailkey, @v_relationshiptabcode, @v_sortorder, 'Firebrand', getdate())
 
      FETCH NEXT FROM tab_cur INTO @v_relationshiptabcode, @v_sortorder
    END
    CLOSE tab_cur
    DEALLOCATE tab_cur
  END
  ELSE  BEGIN
      print 'Section not found on this database: Publicity Tab Group'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('TasksParticipants') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Tasks and Participants',
         0,0,'Firebrand',getdate(),2,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Tasks and Participants'
  END
 
END
go
