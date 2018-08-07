-- For Authors 
DECLARE @v_count int,
@v_newkey int

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 1

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 1, 'Author', 'N', 2, 'SECCNFG', 'Author', 'QSIDBA', GETDATE(), 0, 0, 1, 0)


  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 1, 1, 0, 'QSIDBA', getdate(), 2, NULL)
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 2

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 2, 'Type', 'N', 1, 'SECCNFG', 'Type', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 2, 1, 0, 'QSIDBA', getdate(), 1, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 3

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 3, 'Report', 'N', 3, 'SECCNFG', 'Report', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 3,  1, 0, 'QSIDBA', getdate(), 3, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 4

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 4, 'Primary', 'N', 4, 'SECCNFG', 'Primary', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 4,  1, 0, 'QSIDBA', getdate(), 4, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 5

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 5, 'Order', 'N', 6, 'SECCNFG', 'Order', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 5, 1, 0, 'QSIDBA', getdate(), 5, NULL)
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 6

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 6, 'Full Author', 'N', 7, 'SECCNFG', 'Full Author', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 6, 1, 0, 'QSIDBA', getdate(), 1, NULL)
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 7

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 7, 'Email', 'N', 9, 'SECCNFG', 'Email', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 7,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 17 
   and datasubcode = 8

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 17, 8, 'Phone', 'N', 10, 'SECCNFG', 'Phone', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 17, 8,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END

