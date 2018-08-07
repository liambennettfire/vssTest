/******************************************************************************************
**  Change History
*******************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*   03/22/17     Colman      Case 44001 - Series project uses same detail section as a TAQ
******************************************************************************************/

DECLARE
  @v_datacode INT,
  @v_qsicode INT,
  @v_datasubcode INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_newkey INT

-- Projects  
SELECT @v_itemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 3

-- Title Acquisition/Series Project detail section
SET @v_datacode = 12

-- TAQ and Series projects only
DECLARE cur_projecttypes CURSOR FOR
SELECT datasubcode, qsicode FROM subgentables WHERE tableid=550 AND datacode=@v_itemtype AND qsicode IN (1, 47)

OPEN cur_projecttypes

FETCH NEXT FROM cur_projecttypes INTO @v_usageclass, @v_qsicode

WHILE (@@FETCH_STATUS <> -1)
BEGIN

  IF NOT EXISTS (SELECT 1 FROM gentablesitemtype WHERE tableid = 636 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass AND datacode = @v_datacode) -- Otherwise we end up with duplicates. There is no unique key.
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 1 datasubcode 1, 'Prefix'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 1, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 1 datasubcode 2, 'Title'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 2, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 1 datasubcode 3, 'Subtitle'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 3, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 1 datasubcode 4, 'Status'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 4, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 1 datasubcode 5, 'DivisionImprint'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 5, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 2 datasubcode 6, 'Class'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 6, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 2 datasubcode 7, 'Edition'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 7, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 2 datasubcode 8, 'Series'
    -- Includes Volume in a second row below
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 8, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 3 datasubcode 9, 'Type'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 9, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())    
         
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 3 datasubcode 10, 'Prod 1'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 10, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())    
         
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 3 datasubcode 11, 'Prod 2' (Included with Prod 1 now)
    -- INSERT INTO gentablesitemtype
      -- (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    -- VALUES
      -- (@v_newkey, 636, @v_datacode, 11, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 3 datasubcode 12, 'Misc 1'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 12, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 3 datasubcode 13, 'Misc 2'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 13, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 4 datasubcode 14, 'Template'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 14, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())    
         
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 4 datasubcode 15, 'Owner'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 15, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 2 datasubcode 16, 'CreateWork'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 16, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())    
         
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 2 datasubcode 17, 'WorkClass'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 17, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

    -- Col 2 datasubcode 18, 'CreateFrom'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 18, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())    
  END
  
  FETCH NEXT FROM cur_projecttypes INTO @v_usageclass, @v_qsicode
END

CLOSE cur_projecttypes 
DEALLOCATE cur_projecttypes
      
    
------- Non-TAQ Project detail controls ----------------------------------------------------------------

SET @v_datacode = 13

DECLARE cur_projecttypes CURSOR FOR
SELECT datasubcode, qsicode FROM subgentables WHERE tableid=550 AND datacode=@v_itemtype AND qsicode NOT IN (1, 47)

OPEN cur_projecttypes

FETCH NEXT FROM cur_projecttypes INTO @v_usageclass, @v_qsicode

WHILE (@@FETCH_STATUS <> -1)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM gentablesitemtype WHERE tableid = 636 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass AND datacode = @v_datacode) -- Otherwise we end up with duplicates. There is no unique key.
  BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 1, 'Name'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 1, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 2, 'Status'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 2, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 3, 'Type'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 3, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 4, 'DivisionImprint'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 4, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 5, 'Imprint'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 5, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 6, 'Auto'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 6, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())
      
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 7, 'Misc 1'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 7, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 8, 'Misc 2'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 8, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 9, 'Misc 3'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 9, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 10, 'Misc 4'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 10, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 3 datasubcode 11, 'Misc 5'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 11, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 12, 'Template'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 12, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 13, 'Class'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 13, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())    
          
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 15, 'Owner'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 15, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())    

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 16, 'Prod 1'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 16, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())    

    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 4 datasubcode 17, 'Prod 2'
    INSERT INTO gentablesitemtype
      (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_newkey, 636, @v_datacode, 17, @v_itemtype, @v_usageclass, 6, 'QSIDBA', getdate())    
  END
  
  FETCH NEXT FROM cur_projecttypes INTO @v_usageclass, @v_qsicode
END

CLOSE cur_projecttypes 
DEALLOCATE cur_projecttypes

GO