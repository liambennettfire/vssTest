-- For Title Information - Sets fields 
DECLARE @v_count int,
@v_newkey int

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 5 
   and datasubcode = 23

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, numericdesc1, alternatedesc1)
  VALUES
    (636, 5, 23, 'Num Titles in Set', 'N', 3, 'SECCNFG', '# Titles', 'QSIDBA', GETDATE(), 0, 0, 1, 0, 2, 'Number of Titles in Set')


  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 5, 23, 1, 2, 'QSIDBA', getdate(), 3, 'Number of Titles in Set')
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 5 
   and datasubcode = 24

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, numericdesc1, alternatedesc1)
  VALUES
    (636, 5, 24, 'Set Type', 'N', 4, 'SECCNFG', 'Set Type', 'QSIDBA', GETDATE(), 0, 0, 1, 0, 2, 'Set Type')


  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 5, 24, 1, 2, 'QSIDBA', getdate(), 4, null)
END

SELECT @v_count = count(*) FROM subgentables
 WHERE tableid = 636 
   and datacode = 5 
   and datasubcode = 25

IF @v_count = 0 BEGIN
  INSERT INTO subgentables
    (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, numericdesc1, alternatedesc1)
  VALUES
    (636, 5, 25, 'Discount %', 'N', 5, 'SECCNFG', 'Discount %', 'QSIDBA', GETDATE(), 0, 0, 1, 0, 2, 'Discount %')


  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 5, 25, 1, 2, 'QSIDBA', getdate(), 0, null)
END

