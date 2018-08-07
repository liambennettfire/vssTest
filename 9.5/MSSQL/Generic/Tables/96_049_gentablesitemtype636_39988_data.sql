DECLARE
  @v_datacode INT,
  @v_qsicode INT,
  @v_datasubcode INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_newkey INT

-- Non-TAQ project detail section
SET @v_datacode = 13

-- Printings --------------------------------------------------------------------------------------

SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid=550 AND qsicode = 40

DELETE FROM gentablesitemtype WHERE tableid = 636 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass AND datacode = @v_datacode -- Otherwise we end up with duplicates. There is no unique key.

EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 1 datasubcode 1, 'Name'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 1, @v_itemtype, @v_usageclass, 1, 1, 'QSIDBA', getdate())

EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 2 datasubcode 19, 'Title'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 19, @v_itemtype, @v_usageclass, 1, 2, 'QSIDBA', getdate())
  
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 1 datasubcode 20, 'Printing'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 20, @v_itemtype, @v_usageclass, 1, 3, 'QSIDBA', getdate())
  
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 1 datasubcode 4, 'DivisionImprint'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 4, @v_itemtype, @v_usageclass, 1, 4, 'QSIDBA', getdate())
  
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 1 datasubcode 5, 'Imprint'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 5, @v_itemtype, @v_usageclass, 1, 5, 'QSIDBA', getdate())
  
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 2 datasubcode 6, 'Auto'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, text1, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 6, @v_itemtype, @v_usageclass, 2, 1, 'Auto Update', 'QSIDBA', getdate())
  
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 2 datasubcode 2, 'Status'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 2, @v_itemtype, @v_usageclass, 2, 2, 'QSIDBA', getdate())

EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 2 datasubcode 7, 'Misc 1'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 7, @v_itemtype, @v_usageclass, 2, 3, 'QSIDBA', getdate())    
      
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 2 datasubcode 9, 'Misc 3'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 9, @v_itemtype, @v_usageclass, 2, 4, 'QSIDBA', getdate())    
      
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 3 datasubcode 3, 'Type'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 3, @v_itemtype, @v_usageclass, 3, 1, 'QSIDBA', getdate())    
     
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 3 datasubcode 8, 'Misc 2'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 8, @v_itemtype, @v_usageclass, 3, 2, 'QSIDBA', getdate())    
      
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 3 datasubcode 10, 'Misc 4'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 10, @v_itemtype, @v_usageclass, 3, 3, 'QSIDBA', getdate())    
      
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 3 datasubcode 11, 'Misc 5'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 11, @v_itemtype, @v_usageclass, 3, 4, 'QSIDBA', getdate())    
      
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 4 datasubcode 12, 'Template'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 12, @v_itemtype, @v_usageclass, 4, 1, 'QSIDBA', getdate())    
      
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 4 datasubcode 13, 'Class'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 13, @v_itemtype, @v_usageclass, 4, 2, 'QSIDBA', getdate())
  
EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 4 datasubcode 15, 'Owner'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 15, @v_itemtype, @v_usageclass, 4, 3, 'QSIDBA', getdate())    

EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 4 datasubcode 16, 'Prod 1'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 16, @v_itemtype, @v_usageclass, 4, 4, 'QSIDBA', getdate())    

EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

-- Col 4 datasubcode 17, 'Prod 2'
INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
VALUES
  (@v_newkey, 636, @v_datacode, 17, @v_itemtype, @v_usageclass, 4, 5, 'QSIDBA', getdate())    

-- Purchase Orders --------------------------------------------------------------------------------------

SELECT @v_itemtype = datacode FROM gentables WHERE tableid=550 AND qsicode = 15
SET @v_usageclass = 0 -- All purchase order classes have same layout

-- DECLARE cur_potypes CURSOR FOR
-- SELECT datasubcode, qsicode FROM subgentables WHERE tableid=550 AND datacode=@v_itemtype AND qsicode <> 1

-- OPEN cur_potypes

-- FETCH NEXT FROM cur_potypes INTO @v_usageclass, @v_qsicode

-- WHILE (@@FETCH_STATUS <> -1)
-- BEGIN
  DELETE FROM gentablesitemtype WHERE tableid = 636 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass AND datacode = @v_datacode -- Otherwise we end up with duplicates. There is no unique key.

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 1, 'Name'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 1, @v_itemtype, @v_usageclass, 1, 1, 'QSIDBA', getdate())

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 2, 'Status'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 2, @v_itemtype, @v_usageclass, 1, 2, 'QSIDBA', getdate())

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 4, 'DivisionImprint'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 4, @v_itemtype, @v_usageclass, 1, 3, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 5, 'Imprint'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 5, @v_itemtype, @v_usageclass, 1, 4, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 6, 'Auto'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, text1, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 6, @v_itemtype, @v_usageclass, 2, 1, 'Auto Update', 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 7, 'Misc 1'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 7, @v_itemtype, @v_usageclass, 2, 2, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 9, 'Misc 3'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 9, @v_itemtype, @v_usageclass, 2, 3, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 11, 'Misc 5'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 11, @v_itemtype, @v_usageclass, 2, 4, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 3, 'Type'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 3, @v_itemtype, @v_usageclass, 3, 1, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 8, 'Misc 2'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 8, @v_itemtype, @v_usageclass, 3, 2, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 10, 'Misc 4'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 10, @v_itemtype, @v_usageclass, 3, 3, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 12, 'Template'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 12, @v_itemtype, @v_usageclass, 4, 1, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 13, 'Class'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 13, @v_itemtype, @v_usageclass, 4, 2, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 15, 'Owner'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 15, @v_itemtype, @v_usageclass, 4, 3, 'QSIDBA', getdate())    

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 16, 'Prod 1'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 16, @v_itemtype, @v_usageclass, 4, 4, 'QSIDBA', getdate())    

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 17, 'Prod 2'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, numericdesc1, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 17, @v_itemtype, @v_usageclass, 4, 5, 'QSIDBA', getdate())    
  
  -- FETCH NEXT FROM cur_potypes INTO @v_usageclass, @v_qsicode
-- END

-- CLOSE cur_potypes 
-- DEALLOCATE cur_potypes
GO