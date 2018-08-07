DECLARE
  @v_newkey INT,
  @v_itemtype INT,
	@v_windowid INT,
	@v_sortorder INT,
  @v_windowname VARCHAR(40),
  @v_availobjectid VARCHAR(50),
	@v_availobjectname VARCHAR(50),
	@v_availobjectdesc VARCHAR(50),
  @v_availobjectwholerowind INT,
  @v_availobjectcodetableid INT,
  @v_allowadmintochoosevalueind INT,
  @v_defaultaccesscode INT


DECLARE @InsertTable TABLE
(
  windowname VARCHAR(40),
  itemtypecode INT, 
  availobjectid VARCHAR(50), 
  availobjectname VARCHAR(50),
  availobjectdesc VARCHAR(50),
  availobjectwholerowind INT,
  availobjectcodetableid INT,
  allowadmintochoosevalueind INT,
  defaultaccesscode INT
)

-- Printings item type
SELECT @v_itemtype = datacode FROM gentables WHERE tableid=550 AND qsicode=14

-- Populate @InsertTable with data to be inserted

-- Title Prices - by Price Type
INSERT INTO @InsertTable
  (windowname, itemtypecode, availobjectid, availobjectname, availobjectdesc, availobjectwholerowind, availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode)
VALUES
  ('PrintingSummary', @v_itemtype, 'shPrices', NULL, 'Title Prices - by Price Type', 1, 306, 1, 2)

-- Title Prices - by Currency Type
INSERT INTO @InsertTable
  (windowname, itemtypecode, availobjectid, availobjectname, availobjectdesc, availobjectwholerowind, availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode)
VALUES
  ('PrintingSummary', @v_itemtype, 'shPrices', NULL, 'Title Prices - by Currency Type', 1, 122, 1, 2)

-- Insert items from the table

DECLARE cur_inserttable CURSOR FOR
SELECT windowname, itemtypecode, availobjectid, availobjectname, availobjectdesc, availobjectwholerowind, availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode
FROM @InsertTable

OPEN cur_inserttable

FETCH cur_inserttable INTO
  @v_windowname, @v_itemtype, @v_availobjectid, @v_availobjectname, @v_availobjectdesc, @v_availobjectwholerowind, 
  @v_availobjectcodetableid, @v_allowadmintochoosevalueind, @v_defaultaccesscode

-- For each row to insert
WHILE @@FETCH_STATUS = 0
BEGIN
  SELECT @v_windowid = windowid 
  FROM qsiwindows 
  WHERE windowname = @v_windowname	
    AND applicationind = 14 -- web apps
  
  -- Enable security
  IF NOT EXISTS (
    SELECT 1 FROM securityobjectsavailable 
    WHERE windowid = @v_windowid 
      AND availobjectid = @v_availobjectid 
      AND availobjectname = @v_availobjectname
  )
  BEGIN
    SELECT @v_sortorder = MAX(ISNULL(sortorder,0)) + 1 
    FROM securityobjectsavailable 
    WHERE windowid = @v_windowid

    exec get_next_key 'qsidba', @v_newkey output
    
    INSERT INTO securityobjectsavailable 
      (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder, availobjectwholerowind,
      availobjectcodetableid, allowadmintochoosevalueind, defaultaccesscode, lastuserid, lastmaintdate)
    VALUES 
      (@v_newkey, @v_windowid, @v_availobjectid, @v_availobjectname, @v_availobjectdesc, @v_sortorder, 0,
      @v_availobjectcodetableid, @v_allowadmintochoosevalueind, @v_defaultaccesscode, 'qsidba', GETDATE()) 
  END

  FETCH cur_inserttable INTO
    @v_windowname, @v_itemtype, @v_availobjectid, @v_availobjectname, @v_availobjectdesc, @v_availobjectwholerowind, 
    @v_availobjectcodetableid, @v_allowadmintochoosevalueind, @v_defaultaccesscode

END

CLOSE cur_inserttable
DEALLOCATE cur_inserttable

GO