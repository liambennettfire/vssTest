DECLARE
  @v_datacode INT,
  @v_qsicode INT,
  @v_datasubcode INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_newkey INT,
  @v_count INT

-- Titles  
SELECT @v_itemtype = datacode
FROM gentables
WHERE tableid = 550 AND qsicode = 1
SET @v_usageclass = 0 -- all title usage classes

--SELECT @v_usageclass=datasubcode FROM subgentables WHERE tableid=550 AND qsicode = 1

-- Title classification control
SET @v_datacode = 14
SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 636 AND itemtypecode = @v_itemtype AND datacode = @v_datacode

IF @v_count = 0 BEGIN

  --DELETE FROM gentablesitemtype WHERE datacode=@v_datacode -- Otherwise we end up with duplicates. There is no unique key.

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 1, 'Territory'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 1, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 2, 'Exclusivity'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 2, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 3, 'CanadianRestriction'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 3, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 4, 'Discount'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 4, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 5, 'Restrictions'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 5, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 6, 'CopyrightYear'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 6, @v_itemtype, @v_usageclass, 6, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 7, 'TitleType'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 7, @v_itemtype, @v_usageclass, 7, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 8, 'Returns'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 8, @v_itemtype, @v_usageclass, 8, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 9, 'PublishToWeb'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 9, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())    
       
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 10, 'AgeRange'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 10, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())    
       
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 11, 'GradeRange'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 11, @v_itemtype, @v_usageclass, 3, 'qsidba', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 12, 'Language'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 12, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 13, 'LegacyTerritories'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 13, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 14, 'Origin'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 14, @v_itemtype, @v_usageclass, 6, 'QSIDBA', getdate())    
       
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 15, 'Audience'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 15, @v_itemtype, @v_usageclass, 7, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 16, 'ProposedTerritory'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 16, @v_itemtype, @v_usageclass, 0, 'QSIDBA', getdate())    

END       

------- TAQ Project classification control ----------------------------------------------------------------

SELECT @v_itemtype = datacode, @v_usageclass = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1

SET @v_datacode = 15
SELECT @v_count = COUNT(*) FROM gentablesitemtype WHERE tableid = 636 AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass AND datacode = @v_datacode

IF @v_count = 0 BEGIN

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 1, 'ProposedTerritory'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 1, @v_itemtype, @v_usageclass, 0, 'QSIDBA', getdate())

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 2, 'CanadianRestriction'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 2, @v_itemtype, @v_usageclass, 2, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 3, 'Restrictions'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 3, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 4, 'CopyrightYear'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 4, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 5, 'TitleType'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 5, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 1 datasubcode 6, 'Returns'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 6, @v_itemtype, @v_usageclass, 6, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 7, 'AgeRange'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 7, @v_itemtype, @v_usageclass, 1, 'QSIDBA', getdate())    
       
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 8, 'GradeRange'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 8, @v_itemtype, @v_usageclass, 2, 'qsidba', getdate())
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 9, 'Language'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 9, @v_itemtype, @v_usageclass, 3, 'QSIDBA', getdate())    
        
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 10, 'Origin'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 10, @v_itemtype, @v_usageclass, 4, 'QSIDBA', getdate())    
       
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT

  -- Col 2 datasubcode 11, 'Audience'
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, sortorder, lastuserid, lastmaintdate)
  VALUES
    (@v_newkey, 636, @v_datacode, 11, @v_itemtype, @v_usageclass, 5, 'QSIDBA', getdate())    
END

GO