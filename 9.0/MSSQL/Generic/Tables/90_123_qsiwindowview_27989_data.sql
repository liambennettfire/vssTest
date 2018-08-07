-- setup default views 
DECLARE
  @v_new_qsiwindowviewkey int,
  @v_new_configdetailkey int,
  @v_itemtype int,
  @v_usageclass int,
  @v_usageclassdesc varchar(255),
  @v_count int
 
BEGIN
  SET @v_itemtype = 15  -- Purchase Orders
  SET @v_usageclass = 2 -- Proforma PO Report
  SELECT @v_usageclassdesc = COALESCE(dbo.get_subgentables_desc(550,@v_itemtype,@v_usageclass,'long'),' ')

  exec get_next_key 'qsidba', @v_new_qsiwindowviewkey output

  -- create default view
  INSERT INTO qsiwindowview (qsiwindowviewkey, qsiwindowviewname, qsiwindowviewdesc, 
                             itemtypecode, usageclasscode, defaultind, userkey, 
                             lastuserid, lastmaintdate )
  VALUES (@v_new_qsiwindowviewkey, @v_usageclassdesc + ' Default View', 'Default View for ' + @v_usageclassdesc, 
          @v_itemtype, @v_usageclass, 1, -1, 'QSICONV', getdate())

  SELECT @v_count = count(*)
    FROM qsiconfigdetail
   WHERE usageclasscode = @v_usageclass
     AND configobjectkey in (select configobjectkey from qsiconfigobjects
                              where windowid in (select windowid from qsiwindows
                                                  where lower(windowname) = 'posummary'))
   
  IF @v_count > 0 BEGIN
    UPDATE qsiconfigdetail
       SET qsiwindowviewkey = @v_new_qsiwindowviewkey
     WHERE usageclasscode = @v_usageclass
       AND configobjectkey in (select configobjectkey from qsiconfigobjects
                                where windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'posummary'))
  END
  ELSE BEGIN
    -- need at least 1 row in configdetail so joins will work
    exec get_next_key 'qsidba', @v_new_configdetailkey output
   
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,labeldesc,visibleind,minimizedind, 
                                lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname,
                                qsiwindowviewkey)
    SELECT @v_new_configdetailkey,configobjectkey,defaultlabeldesc,defaultvisibleind,defaultminimizedind,'QSICONV',
           getdate(),position,path,viewcontrolname,editcontrolname,@v_new_qsiwindowviewkey
      FROM qsiconfigobjects
     WHERE configobjectkey in (select configobjectkey from qsiconfigobjects
                                where lower(configobjectid) = 'shpurchaseorderdetails'
                                  and windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'posummary'))

    -- change the Summary page title
    exec get_next_key 'qsidba', @v_new_configdetailkey output
    
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,labeldesc,visibleind,minimizedind, 
                                lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname,
                                qsiwindowviewkey,usageclasscode)
    SELECT @v_new_configdetailkey,configobjectkey,'Proforma PO Report Summary',defaultvisibleind,defaultminimizedind,'QSICONV',
           getdate(),position,path,viewcontrolname,editcontrolname,@v_new_qsiwindowviewkey,@v_usageclass
      FROM qsiconfigobjects
     WHERE configobjectkey in (select configobjectkey from qsiconfigobjects
                                where lower(configobjectid) = 'posummary'
                                  and windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'posummary'))
                
  END    
  
  SET @v_itemtype = 15  -- Purchase Orders
  SET @v_usageclass = 3 -- Final PO Report
  SELECT @v_usageclassdesc = COALESCE(dbo.get_subgentables_desc(550,@v_itemtype,@v_usageclass,'long'),' ')

  exec get_next_key 'qsidba', @v_new_qsiwindowviewkey output

  -- create default view
  INSERT INTO qsiwindowview (qsiwindowviewkey, qsiwindowviewname, qsiwindowviewdesc, 
                             itemtypecode, usageclasscode, defaultind, userkey, 
                             lastuserid, lastmaintdate )
  VALUES (@v_new_qsiwindowviewkey, @v_usageclassdesc + ' Default View', 'Default View for ' + @v_usageclassdesc, 
          @v_itemtype, @v_usageclass, 1, -1, 'QSICONV', getdate())

  SELECT @v_count = count(*)
    FROM qsiconfigdetail
   WHERE usageclasscode = @v_usageclass
     AND configobjectkey in (select configobjectkey from qsiconfigobjects
                              where windowid in (select windowid from qsiwindows
                                                  where lower(windowname) = 'posummary'))
   
  IF @v_count > 0 BEGIN
    UPDATE qsiconfigdetail
       SET qsiwindowviewkey = @v_new_qsiwindowviewkey
     WHERE usageclasscode = @v_usageclass
       AND configobjectkey in (select configobjectkey from qsiconfigobjects
                                where windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'posummary'))
  END
  ELSE BEGIN
    -- need at least 1 row in configdetail so joins will work
    exec get_next_key 'qsidba', @v_new_configdetailkey output
   
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,labeldesc,visibleind,minimizedind, 
                                lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname,
                                qsiwindowviewkey)
    SELECT @v_new_configdetailkey,configobjectkey,defaultlabeldesc,defaultvisibleind,defaultminimizedind,'QSICONV',
           getdate(),position,path,viewcontrolname,editcontrolname,@v_new_qsiwindowviewkey
      FROM qsiconfigobjects
     WHERE configobjectkey in (select configobjectkey from qsiconfigobjects
                                where lower(configobjectid) = 'shpurchaseorderdetails'
                                  and windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'posummary'))
    
    -- change the Summary page title
    exec get_next_key 'qsidba', @v_new_configdetailkey output
    
    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,labeldesc,visibleind,minimizedind, 
                                lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname,
                                qsiwindowviewkey,usageclasscode)
    SELECT @v_new_configdetailkey,configobjectkey,'Final PO Report Summary',defaultvisibleind,defaultminimizedind,'QSICONV',
           getdate(),position,path,viewcontrolname,editcontrolname,@v_new_qsiwindowviewkey,@v_usageclass
      FROM qsiconfigobjects
     WHERE configobjectkey in (select configobjectkey from qsiconfigobjects
                                where lower(configobjectid) = 'posummary'
                                  and windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'posummary'))
                
  END                                                                                          
END 
go
