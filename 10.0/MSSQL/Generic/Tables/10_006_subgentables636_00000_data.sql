-- For Participants 
DECLARE @v_count int,
@v_newkey int

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 1

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 1, 'Role', 'N', 1, 'SECCNFG', 'Role', 'QSIDBA', GETDATE(), 0, 0, 1, 0)


  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 1,  1, 0, 'QSIDBA', getdate(), 2, NULL)
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 2

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 2, 'Key', 'N', 2, 'SECCNFG', 'Key', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 2,  1, 0, 'QSIDBA', getdate(), 1, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 3

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 3, 'Order', 'N', 4, 'SECCNFG', 'Sort', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 3,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 4

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 4, 'Name', 'N', 5, 'SECCNFG', 'Name', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 4,  1, 0, 'QSIDBA', getdate(), 3, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 5

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 5, 'Address', 'N', 6, 'SECCNFG', 'Address', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 5,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 6

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 6, 'Contact Relationship', 'N', 7, 'SECCNFG', 'Contact Relationship', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 6,  1, 0, 'QSIDBA', getdate(), 4, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 7

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 7, 'Qty', 'N', 8, 'SECCNFG', 'Qty', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 7,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 8

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 8, 'Email', 'N', 9, 'SECCNFG', 'Email', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 8,  1, 0, 'QSIDBA', getdate(), 5, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 9

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 9, 'Phone', 'N', 10, 'SECCNFG', 'Phone', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 9,  1, 0, 'QSIDBA', getdate(), 6, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 10

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 10, 'Indicator', 'N', 11, 'SECCNFG', 'Indicator', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 10,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 11

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 11, 'Date', 'N', 12, 'SECCNFG', 'Date', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 11,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 12

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 12, 'Ship Method', 'N', 13, 'SECCNFG', 'Ship Method', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 12,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 13

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 13, 'Notes', 'N', 14, 'SECCNFG', 'Notes', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 13,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 14

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 14, 'Add button', 'N', 1, 'SECCNFG', 'Add button', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 14,  1, 0, 'QSIDBA', getdate(), 1, NULL)
END


SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 16 
   and datasubcode = 15

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
  VALUES
    (636, 16, 15, 'PO Section', 'N', 3, 'SECCNFG', 'Product', 'QSIDBA', GETDATE(), 0, 0, 1, 0)

  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 15,  1, 0, 'QSIDBA', getdate(), 0, NULL)
END

