DECLARE
  @v_new_qsiwindowviewkey int,
  @v_new_configdetailkey int,
  @v_configobjectkey int,
  @v_usageclasscode int,
  @v_windowid int,
  @v_count int
 
BEGIN
 
  SELECT @v_usageclasscode = datasubcode FROM subgentables 
   WHERE tableid = 550 and datacode = 3
     and qsicode = 3
 
  IF @v_usageclasscode is null OR @v_usageclasscode <= 0 BEGIN
    print 'Could not find usageclasscode for qsicode 3'
    return
  END
 
 SELECT @v_count = count(*) 
   FROM qsiwindowview 
  WHERE itemtypecode = 3
    AND usageclasscode = @v_usageclasscode 
    AND defaultind = 1 
    AND userkey = -1 
 
  IF @v_count > 0 BEGIN
    print 'A default windowview already exists for itemtype 3 and usageclass ' + cast(@v_usageclasscode as varchar)
    return
  END
 
  exec get_next_key 'qsidba', @v_new_qsiwindowviewkey output
 
  -- create default view
  INSERT INTO qsiwindowview (qsiwindowviewkey, qsiwindowviewname, qsiwindowviewdesc, 
                             itemtypecode, usageclasscode, defaultind, userkey, 
                             lastuserid, lastmaintdate ) 
  VALUES (@v_new_qsiwindowviewkey, 'Mktg Project Default View','Default View for Mktg Project',
          3, @v_usageclasscode, 1, -1, 'Firebrand', getdate())
 
  -- get windowid of window
  SELECT @v_windowid = windowid 
    FROM qsiwindows 
   WHERE lower(windowname) = lower('ProjectSummary')
 
  -- insert qsiconfigdetail rows
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectDetails') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Details',
         1,0,'Firebrand',getdate(),1,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Details'
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
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Tasks',
         0,0,'Firebrand',getdate(),5,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Key Tasks'
  END
 
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
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Mktg Project Categories',
         0,0,'Firebrand',getdate(),6,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Categories'
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
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Mktg Project Comments',
         1,0,'Firebrand',getdate(),4,
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
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Mktg Project Elements',
         0,0,'Firebrand',getdate(),18,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Elements'
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
         0,0,'Firebrand',getdate(),5,
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
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Mktg Project Summary',
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
   WHERE lower(configobjectid) = lower('TasksParticipants') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Tasks and Participants',
         0,0,'Firebrand',getdate(),5,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Tasks and Participants'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('ProjectRelationshipsTab') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Project Relationships',
         1,0,'Firebrand',getdate(),2,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Project Relationships'
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
         0,0,'Firebrand',getdate(),6,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Categories and Contract Info'
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
         0,0,'Firebrand',getdate(),14,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: File Locations'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('shProjectParticipantsByRole1') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Participants By Role 1',
         0,0,'Firebrand',getdate(),20,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Participants By Role 1'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('shProjectParticipantsByRole2') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Participants By Role 2',
         0,0,'Firebrand',getdate(),21,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Participants By Role 2'
  END
 
  SET @v_configobjectkey = 0
  SELECT @v_configobjectkey = configobjectkey 
    FROM qsiconfigobjects 
   WHERE lower(configobjectid) = lower('shProjectParticipantsByRole3') 
     and windowid = @v_windowid 
 
  IF @v_configobjectkey <> 0 BEGIN
    exec get_next_key 'qsidba', @v_new_configdetailkey output
 
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, 
                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, 
                               qsiwindowviewkey,sectioncontrolname) 
    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,'Participants By Role 3',
         0,0,'Firebrand',getdate(),22,
         null,null,null,@v_new_qsiwindowviewkey,
         null)
  END
  ELSE  BEGIN
      print 'Section not found on this database: Participants By Role 3'
  END
 
END
go
