DECLARE
  @v_newkey	INT
  
BEGIN
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 1, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 1, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 1, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 1, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 2, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 2, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 2, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 2, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)    
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 3, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 3, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 3, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 3, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 4, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 4, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 4, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 4, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 5, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 5, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 5, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 5, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 6, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 6, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 6, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 6, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)    

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 7, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 7, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 7, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 7, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 8, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 8, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 8, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 8, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 9, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 9, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 9, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 9, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 10, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 10, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 10, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 10, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 11, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 11, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 1)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 11, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 11, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 1)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 12, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 2)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 12, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 2)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 12, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 12, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 0)
    
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 13, 0, 3, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 13, 0, 9, 0, 0, 'QSIDBA', GETDATE(), 3)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 13, 0, 1, 0, 0, 'QSIDBA', GETDATE(), 0)
  
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
  
  INSERT INTO gentablesitemtype
    (gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
    lastuserid, lastmaintdate, sortorder)
  VALUES
    (@v_newkey, 636, 4, 13, 0, 14, 0, 0, 'QSIDBA', GETDATE(), 2)
    
END
go
       