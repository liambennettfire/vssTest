DECLARE
  @v_newkey               INT,
  @v_configobjectkey      INT,
  @v_qsiwindowviewkey     INT,
  @v_itemtype             INT,
  @v_usageclass           INT,
	@v_windowid             INT,
	@v_sortorder            INT,
	@v_position             INT,
  @v_configobjecttype     INT,
  @v_windowname           VARCHAR(40),
  @v_windowtitle          VARCHAR(80),
  @v_configobjectid       VARCHAR(50),
  @v_configobjectdesc     VARCHAR(50), 
  @v_defaultlabeldesc     VARCHAR(50), 
  @v_sectioncontrolname   VARCHAR(100), 
	@v_availobjectname      VARCHAR(50),
	@v_availobjectdesc      VARCHAR(50)
	
DECLARE @InsertTable TABLE
(
  windowname VARCHAR(40),
  itemtypecode INT, 
  configobjectid VARCHAR(50), 
  configobjecttype INT,
  configobjectdesc VARCHAR(50), 
  defaultlabeldesc VARCHAR(50), 
  sectioncontrolname VARCHAR(100), 
  availobjectname VARCHAR(50),
  availobjectdesc VARCHAR(50)
)

-- Populate temp table with data to be inserted ------------------------

-- Printings item type
SELECT @v_itemtype = datacode FROM gentables WHERE tableid=550 AND qsicode=14

-- Quantity breakdown for printings
INSERT INTO @InsertTable
  (windowname, itemtypecode, configobjectid, configobjecttype, configobjectdesc, defaultlabeldesc, 
  sectioncontrolname, availobjectname, availobjectdesc)
VALUES
  ('PrintingSummary', @v_itemtype, 'shQtyBreakdown', 3, 'Quantity Breakdown Section', 'Quantity Breakdown', 
  '~/PageControls/Projects/Sections/Summary/QtyBreakdownSection.ascx', NULL, 'Quantity Breakdown - ALL')

DECLARE cur_inserttable CURSOR FOR
SELECT windowname, itemtypecode, configobjectid, configobjecttype, configobjectdesc, defaultlabeldesc, sectioncontrolname, availobjectname, availobjectdesc
FROM @InsertTable

OPEN cur_inserttable

FETCH cur_inserttable INTO
  @v_windowname, @v_itemtype, @v_configobjectid, @v_configobjecttype, @v_configobjectdesc, @v_defaultlabeldesc, @v_sectioncontrolname, @v_availobjectname, @v_availobjectdesc

-- For each row to insert in qsiconfigobjects...
WHILE @@FETCH_STATUS = 0
BEGIN
  SELECT @v_windowid = windowid 
  FROM qsiwindows 
  WHERE windowname = @v_windowname	
    AND applicationind = 14 -- web apps
  
  IF NOT EXISTS (
    SELECT 1 FROM qsiconfigobjects 
    WHERE windowid = @v_windowid 
      AND configobjectid = @v_configobjectid 
      AND itemtypecode = @v_itemtype
  )
  BEGIN
	  SELECT @v_position = MAX(COALESCE(position, 0)) + 1
	  FROM qsiconfigobjects
	  WHERE windowid = @v_windowid
	    AND itemtypecode = @v_itemtype

    exec get_next_key 'qsidba', @v_configobjectkey output

    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc,
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    VALUES
      (@v_configobjectkey, @v_windowid, @v_configobjectid, @v_configobjectdesc, @v_defaultlabeldesc,
      'qsidba', getdate(), 0, 0, @v_itemtype, 0, 
      @v_position, @v_configobjecttype, @v_configobjectkey, @v_sectioncontrolname)
  END
      
  -- Insert new section into all printing summary views
  
  -- For each Printing usage class...
  DECLARE cur_usageclasses CURSOR FOR
    SELECT datasubcode
    FROM subgentables
    WHERE tableid = 550
       AND datacode = @v_itemtype
                  
  OPEN cur_usageclasses
           
  FETCH NEXT FROM cur_usageclasses INTO @v_usageclass
           
  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- For each window view for this class...
    DECLARE cur_qsiwindowview CURSOR FOR
      SELECT DISTINCT qsiwindowviewkey
      FROM qsiwindowview
      WHERE itemtypecode = @v_itemtype
       AND usageclasscode = @v_usageclass
                    
    OPEN cur_qsiwindowview
             
    FETCH NEXT FROM cur_qsiwindowview INTO @v_qsiwindowviewkey
             
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SELECT @v_position = MAX(ISNULL(position, 0)) + 1
      FROM qsiconfigdetail
      WHERE qsiwindowviewkey = @v_qsiwindowviewkey
        AND usageclasscode = @v_usageclass
        AND configobjectkey IN (
          SELECT configobjectkey FROM qsiconfigobjects
          WHERE windowid = @v_windowid
            AND itemtypecode = @v_itemtype
        )

      EXEC dbo.get_next_key 'qsidba', @v_newkey OUT
                           
      INSERT INTO qsiconfigdetail
       (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind,
       lastuserid, lastmaintdate, qsiwindowviewkey, initialeditmode, position)
      VALUES
       (@v_newkey, @v_configobjectkey, @v_usageclass, @v_defaultlabeldesc, 0, 0,
       'qsidba', getdate(), @v_qsiwindowviewkey, 1, @v_position)         
                      
      FETCH NEXT FROM cur_qsiwindowview INTO @v_qsiwindowviewkey
    END
             
    CLOSE cur_qsiwindowview
    DEALLOCATE cur_qsiwindowview
  
   FETCH NEXT FROM cur_usageclasses INTO @v_usageclass
  END
           
  CLOSE cur_usageclasses
  DEALLOCATE cur_usageclasses	  
  
  FETCH cur_inserttable INTO
    @v_windowname, @v_itemtype, @v_configobjectid, @v_configobjecttype, @v_configobjectdesc, @v_defaultlabeldesc, @v_sectioncontrolname, @v_availobjectname, @v_availobjectdesc

  -- Enable security
  IF NOT EXISTS (
    SELECT 1 FROM securityobjectsavailable 
    WHERE windowid = @v_windowid 
      AND availobjectid = @v_configobjectid 
      AND availobjectname = @v_availobjectname
  )
  BEGIN
    SELECT @v_sortorder = MAX(ISNULL(sortorder,0)) + 1 
    FROM securityobjectsavailable 
    WHERE windowid = @v_windowid

    exec get_next_key 'qsidba', @v_newkey output
    
    INSERT INTO securityobjectsavailable 
      (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, availobjectwholerowind,
      lastuserid, lastmaintdate)
    VALUES 
      (@v_newkey, @v_windowid, @v_configobjectid, @v_availobjectname, @v_availobjectdesc, @v_sortorder, 0,
      'qsidba', GETDATE()) 
  END

END

CLOSE cur_inserttable
DEALLOCATE cur_inserttable

GO