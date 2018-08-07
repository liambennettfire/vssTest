-- Hide Input AND Approval Currency fields on all Project Detail sections

DECLARE
  @v_sectioncode INT,
  @v_column INT,
  @v_sortorder INT,
  @v_qsicode INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_itemtype INT,
  @v_projectitemtype INT,
  @v_poitemtype INT,
  @v_printingitemtype INT,
  @v_workitemtype INT,
  @v_journalitemtype INT,
  @v_scalesitemtype INT,
  @v_usageclass INT,
  @v_newkey INT

DECLARE @InsertTable TABLE
(
  datacode INT,
  datasubcode INT,
  numericdesc1 INT,
  sortorder INT,
  itemtype INT,
  usageclass INT
)

SET @v_sortorder = 0 -- Set all to hidden

------ TAQ Project Details -------

SELECT @v_itemtype = datacode, @v_usageclass = datasubcode
FROM subgentables
WHERE tableid = 550 AND qsicode = 1
  
INSERT INTO @InsertTable
  (datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass)
VALUES
  (12, 20, 3, @v_sortorder, @v_itemtype, @v_usageclass)
  
INSERT INTO @InsertTable
  (datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass)
VALUES
  (12, 21, 4, @v_sortorder, @v_itemtype, @v_usageclass)
  
------- Non-TAQ Project detail sections ---------------------------------------------------------

SET @v_sectioncode = 13

-- Projects  
SELECT @v_projectitemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 3
    
-- Printings  
SELECT @v_printingitemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 10
    
-- Purchase Orders  
SELECT @v_poitemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 15
    
-- Works  
SELECT @v_workitemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 9
    
-- Journals
SELECT @v_journalitemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 6
    
-- Scales
SELECT @v_scalesitemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 11
    
DECLARE cur_projecttypes CURSOR FOR
  SELECT datacode, datasubcode
  FROM subgentables s
  WHERE 
    s.tableid = 550 
    AND s.datacode IN (@v_projectitemtype, @v_printingitemtype, @v_workitemtype, @v_poitemtype, @v_journalitemtype, @v_scalesitemtype) 
    AND s.qsicode <> 1 -- Exclude Title Acquisitions

OPEN cur_projecttypes

FETCH NEXT FROM cur_projecttypes INTO @v_itemtype, @v_usageclass

WHILE @@FETCH_STATUS = 0
BEGIN
  INSERT INTO @InsertTable
    (datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass)
  VALUES
    (@v_sectioncode, 23, 2, @v_sortorder, @v_itemtype, @v_usageclass)

  INSERT INTO @InsertTable
    (datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass)
  VALUES
    (@v_sectioncode, 24, 2, @v_sortorder, @v_itemtype, @v_usageclass)

  FETCH NEXT FROM cur_projecttypes INTO @v_itemtype, @v_usageclass
END

CLOSE cur_projecttypes 
DEALLOCATE cur_projecttypes

-- Insert into gentablesitemtype

DECLARE ins_cur CURSOR FOR
SELECT datacode, datasubcode, numericdesc1, sortorder, itemtype, usageclass
FROM @InsertTable

OPEN ins_cur

FETCH ins_cur INTO
  @v_datacode, @v_datasubcode, @v_column, @v_sortorder, @v_itemtype, @v_usageclass

WHILE @@FETCH_STATUS = 0
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM gentablesitemtype 
    WHERE tableid = 636 
      AND datacode = @v_datacode AND datasubcode = @v_datasubcode 
      AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
  ) 
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM gentablesitemtype
      WHERE tableid=636 
        AND datacode = @v_datacode 
        AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass
        AND numericdesc1 IS NOT NULL
    )
    BEGIN
      -- This item type/usage class relies on the field column (numericdesc1) defaults from subgentables
      SET @v_column = NULL
    END
    
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, numericdesc1, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, @v_datasubcode, @v_itemtype, @v_usageclass, @v_sortorder, @v_column, 'QSIDBA', getdate())

    IF @@ERROR <> 0 BEGIN
      PRINT 'Insert to gentablesitemtype had an error: tableid=636, datacode=' + cast(@v_datacode AS VARCHAR) + ' datasubcode=' + cast(@v_datasubcode AS VARCHAR) 
        + ' itemtypecode=' + cast(@v_itemtype AS VARCHAR) + ' itemtypesubcode=' + cast(@v_usageclass AS VARCHAR)
      GOTO ErrorExit
    END 
  END    
  
  FETCH ins_cur INTO
    @v_datacode, @v_datasubcode, @v_column, @v_sortorder, @v_itemtype, @v_usageclass
END

ErrorExit:
CLOSE ins_cur
DEALLOCATE ins_cur

GO
