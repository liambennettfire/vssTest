DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_newkey INT,
  @v_usageclasscode INT,
  @v_qsiwindowviewkey INT,
  @v_newdetailkey INT,
  @v_configobjectid VARCHAR(100),
  @v_position INT
      
BEGIN  
  SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 and qsicode = 3
  
  SET @v_configobjectid = 'shProjectClassification'
  
  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = @v_configobjectid AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    SET @v_position = 4

    UPDATE qsiconfigobjects
    SET position = position + 1
    WHERE itemtypecode = @v_itemtype
      AND position IS NOT NULL
      AND position > @v_position
      
    -- default to not visible 
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, @v_configobjectid, 'ProjectClassification', 'ProjectClassification',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 0, @v_position, 3, @v_newkey, '~/PageControls/Projects/Sections/Summary/ProjectClassification.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'ProjectSummary'
      
    -- Default Title Acquisition View
    -- Set to visible
    SELECT @v_usageclasscode = datasubcode
    FROM subgentables 
    WHERE tableid = 550 
        AND qsicode = 1
                
    SELECT @v_qsiwindowviewkey = qsiwindowviewkey
      FROM qsiwindowview
     WHERE itemtypecode = @v_itemtype AND usageclasscode = @v_usageclasscode AND defaultind = 1
      
    UPDATE qsiconfigdetail
    SET position = position + 1
    WHERE usageclasscode = @v_usageclasscode
      AND qsiwindowviewkey = @v_qsiwindowviewkey
      AND position IS NOT NULL
      AND position > @v_position

    EXEC dbo.get_next_key 'QSIDBA', @v_newdetailkey OUT
          
    INSERT INTO qsiconfigdetail
     (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
      lastuserid, lastmaintdate, qsiwindowviewkey, position)
    VALUES
     (@v_newdetailkey, @v_newkey, @v_usageclasscode, 'Classification', 1, 0,
      'QSIDBA', getdate(), @v_qsiwindowviewkey, @v_position)
  END
END
go