-- setup default view for Specification Template
DECLARE
  @v_new_qsiwindowviewkey int,
  @v_new_configdetailkey int,
  @v_itemtype int,
  @v_usageclass int,
  @v_usageclassdesc varchar(255),
  @v_count int
 
BEGIN
  SELECT @v_itemtype = datacode, @v_usageclass = datasubcode  FROM subgentables where tableid = 550 and qsicode = 44
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
                                                  where lower(windowname) = 'SpecificationTemplateSummary'))
   
  IF @v_count > 0 BEGIN
    UPDATE qsiconfigdetail
       SET qsiwindowviewkey = @v_new_qsiwindowviewkey
     WHERE usageclasscode = @v_usageclass
       AND configobjectkey in (select configobjectkey from qsiconfigobjects
                                where windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'SpecificationTemplateSummary'))
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
                                where lower(configobjectid) = 'shSpecificationTemplateDetails'
                                  and windowid in (select windowid from qsiwindows
                                                    where lower(windowname) = 'SpecificationTemplateSummary'))
  END                                              
END 
go
