DECLARE
  @v_count  INT,
  @v_max_key  INT,
  @v_max_key2  INT,
  @v_objectkey  INT,
  @v_itemtype INT
     
BEGIN  
  SET @v_itemtype = 14  -- printing

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'printingsummary' AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN    
    exec dbo.get_next_key 'FBT',@v_max_key out  
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'PrintingSummary', 'Printing Summary', 'Printing Summary',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, null, null, null, null
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE configobjectid = 'shPrices' AND itemtypecode = @v_itemtype

  IF @v_count = 0
  BEGIN  
    exec dbo.get_next_key 'FBT',@v_max_key out  
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_max_key, windowid, 'shPrices', 'Title Prices', 'Title Prices',
      'QSIDBA', getdate(), 1, 0, @v_itemtype, 0, 9, 3, @v_max_key, '~/PageControls/Printings/Sections/Summary/TitlePrices.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'printingsummary'
  END
END
go