/*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    06/05/17    Colman         Case 44144 Key relationship in search is not 
**                               available for all Project item types
*******************************************************************************/
DECLARE
  @v_itemtype_projects INT,
  @v_itemtype_works INT,
  @v_itemtype_contracts INT,
  @v_itemtype_purchaseorders INT,
  @v_searchtype_projects INT,
  @v_searchtype_works INT,
  @v_searchtype_contracts INT,
  @v_searchtype_purchaseorders INT,
  @v_nextcolumn_projects INT,
  @v_nextcolumn_works INT,
  @v_nextcolumn_contracts INT,
  @v_nextcolumn_purchaseorders INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_searchtype INT,
  @v_nextcolumn INT,
  @v_projecttitle_sortorder INT,
  @v_default_sortorder INT,
  @v_rowcount  INT,
  @v_currentrow INT
  
SELECT @v_itemtype_projects = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 3

SELECT @v_itemtype_works = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 9

SELECT @v_itemtype_contracts = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 10

SELECT @v_itemtype_purchaseorders = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 15

SET @v_searchtype_projects       = 7 
SET @v_searchtype_works          = 22
SET @v_searchtype_contracts      = 25
SET @v_searchtype_purchaseorders = 29

SET @v_nextcolumn_projects       = 13
SET @v_nextcolumn_works          = 8
SET @v_nextcolumn_contracts      = 8
SET @v_nextcolumn_purchaseorders = 9

DECLARE @tbl_columns
TABLE 
(
  rowid      INTEGER NOT NULL PRIMARY KEY IDENTITY(1,1),
  itemtype   INTEGER NOT NULL,
  usageclass INTEGER NOT NULL,
  searchtype INTEGER NOT NULL,
  nextcolumn INTEGER NOT NULL
)

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
SELECT datacode, datasubcode, @v_searchtype_projects, @v_nextcolumn_projects
FROM subgentables 
WHERE tableid=550 AND datacode=@v_itemtype_projects

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
VALUES (@v_itemtype_projects, 0, @v_searchtype_projects, @v_nextcolumn_projects)

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
SELECT datacode, datasubcode, @v_searchtype_works, @v_nextcolumn_works
FROM subgentables 
WHERE tableid=550 AND datacode=@v_itemtype_works

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
VALUES (@v_itemtype_works, 0, @v_searchtype_works, @v_nextcolumn_works)

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
SELECT datacode, datasubcode, @v_searchtype_contracts, @v_nextcolumn_contracts
FROM subgentables 
WHERE tableid=550 AND datacode=@v_itemtype_contracts

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
VALUES (@v_itemtype_contracts, 0, @v_searchtype_contracts, @v_nextcolumn_contracts)

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
SELECT datacode, datasubcode, @v_searchtype_purchaseorders, @v_nextcolumn_purchaseorders
FROM subgentables 
WHERE tableid=550 AND datacode=@v_itemtype_purchaseorders

INSERT INTO @tbl_columns (itemtype, usageclass, searchtype, nextcolumn)
VALUES (@v_itemtype_purchaseorders, 0, @v_searchtype_purchaseorders, @v_nextcolumn_purchaseorders)

SELECT @v_rowcount = COUNT(*) FROM @tbl_columns

SET @v_currentrow = 0
WHILE @v_currentrow < @v_rowcount
BEGIN
    SET @v_currentrow = @v_currentrow + 1
    
    SELECT 
      @v_itemtype = itemtype,
      @v_usageclass = usageclass,
      @v_searchtype = searchtype,
      @v_nextcolumn = nextcolumn
    FROM @tbl_columns
    WHERE rowid = @v_currentrow

  -- Are there any search columns defined for this project class?
  IF NOT EXISTS (SELECT * FROM qse_searchresultscolumns WHERE searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass)
  BEGIN
    CONTINUE
  END

  -- Invisible key column
  IF NOT EXISTS (SELECT * FROM qse_searchresultscolumns 
    WHERE searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass AND tablename = 'coreprojectinfo' AND columnname = 'keyrelatedprojectkey')
  BEGIN
    INSERT INTO qse_searchresultscolumns 
      (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
    VALUES
      (@v_searchtype, @v_itemtype, @v_usageclass, @v_nextcolumn, 'KeyRelationshipKey', 'KeyRelationshipKey', NULL, 'coreprojectinfo', 'keyrelatedprojectkey', 0, 0, 0, 0, NULL, NULL)

  -- related project title column
    IF NOT EXISTS (SELECT * FROM qse_searchresultscolumns 
      WHERE searchtypecode = @v_searchtype 
        AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass
        AND tablename = 'coreprojectinfo'
        AND columnname = 'keyrelatedprojecttitle')
    BEGIN
      SELECT @v_projecttitle_sortorder = websortorder
      FROM qse_searchresultscolumns 
      WHERE searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass 
        AND columnname = 'projecttitle'

      -- Insert new column after projecttitle column. Move following columns over one place IF necessary
      IF EXISTS (SELECT * FROM qse_searchresultscolumns 
        WHERE searchtypecode = @v_searchtype 
        AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass 
        AND websortorder = @v_projecttitle_sortorder + 1)
      BEGIN
        UPDATE qse_searchresultscolumns 
        SET websortorder = websortorder + 1 
        WHERE websortorder > @v_projecttitle_sortorder 
          AND searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass 
      END

      -- This assumes that at the time this is run, keyrelatedprojecttitle is the last column in the datagrid
      SELECT @v_default_sortorder = MAX(defaultsortorder) + 1 
        FROM qse_searchresultscolumns 
        WHERE searchtypecode = @v_searchtype 
        AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass 
        
      INSERT INTO qse_searchresultscolumns 
        (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, 
        displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
      VALUES
        (@v_searchtype, @v_itemtype, @v_usageclass, @v_nextcolumn + 1, 'Key Relationship', 'Key Relationship', NULL, 'coreprojectinfo', 'keyrelatedprojecttitle', 
        1, 0, @v_default_sortorder, @v_projecttitle_sortorder + 1, 'left', NULL)
    END  
  END  
END

GO