-- Participants by Role
DECLARE @subsort INT

SELECT @subsort = MAX(COALESCE(sortorder, 0))
FROM subgentables
WHERE tableid = 636
  AND datacode = 16

SET @subsort = COALESCE(@subsort, 0) + 1

IF NOT EXISTS (SELECT 1 FROM subgentables WHERE tableid = 636 AND datacode = 16 AND datasubcode = 16)
BEGIN
	INSERT INTO subgentables
	  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
	VALUES
	  (636, 16, 16, 'Generic Text', 'N', @subsort, 'SECCNFG', 'Generic Text', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
END
GO

DECLARE @v_newkey INT

IF NOT EXISTS (
  SELECT 1
  FROM gentablesitemtype
  WHERE tableid = 636 
  AND itemtypecode = 1 
  AND itemtypesubcode = 0 
  AND datacode = 16 
  AND datasubcode = 16
)
BEGIN
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 16, 16,  1, 0, 'QSIDBA', GETDATE(), 0, NULL)

	UPDATE gentablesitemtype
	set text1 = NULL
	WHERE tableid = 636
	and datacode = 16
	and datasubcode = 16
	and text1 IS NOT NULL
	and LEN(text1) = 0
END
GO

-- Participants by Role 1
DECLARE @subsort INT

SELECT @subsort = MAX(COALESCE(sortorder, 0))
FROM subgentables
WHERE tableid = 636
  AND datacode = 6

SET @subsort = COALESCE(@subsort, 0) + 1

IF NOT EXISTS (SELECT 1 FROM subgentables WHERE tableid = 636 AND datacode = 6 AND datasubcode = 16)
BEGIN
	INSERT INTO subgentables
	  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
	VALUES
	  (636, 6, 16, 'Generic Text', 'N', @subsort, 'SECCNFG', 'Generic Text', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
END
GO

DECLARE @v_newkey INT

IF NOT EXISTS (
  SELECT 1
  FROM gentablesitemtype
  WHERE tableid = 636 
  AND itemtypecode = 1 
  AND itemtypesubcode = 0 
  AND datacode = 6 
  AND datasubcode = 16
)
BEGIN
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 6, 16,  1, 0, 'QSIDBA', GETDATE(), 0, NULL)

	UPDATE gentablesitemtype
	set text1 = NULL
	WHERE tableid = 636
	and datacode = 6
	and datasubcode = 16
	and text1 IS NOT NULL
	and LEN(text1) = 0
END
GO

-- Participants by Role 2
DECLARE @subsort INT

SELECT @subsort = MAX(COALESCE(sortorder, 0))
FROM subgentables
WHERE tableid = 636
  AND datacode = 7

SET @subsort = COALESCE(@subsort, 0) + 1

IF NOT EXISTS (SELECT 1 FROM subgentables WHERE tableid = 636 AND datacode = 7 AND datasubcode = 16)
BEGIN
	INSERT INTO subgentables
	  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
	VALUES
	  (636, 7, 16, 'Generic Text', 'N', @subsort, 'SECCNFG', 'Generic Text', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
END
GO

DECLARE @v_newkey INT

IF NOT EXISTS (
  SELECT 1
  FROM gentablesitemtype
  WHERE tableid = 636 
  AND itemtypecode = 1 
  AND itemtypesubcode = 0 
  AND datacode = 7 
  AND datasubcode = 16
)
BEGIN
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 7, 16,  1, 0, 'QSIDBA', GETDATE(), 0, NULL)

	UPDATE gentablesitemtype
	set text1 = NULL
	WHERE tableid = 636
	and datacode = 7
	and datasubcode = 16
	and text1 IS NOT NULL
	and LEN(text1) = 0
END
GO

-- Participants by Role 3
DECLARE @subsort INT

SELECT @subsort = MAX(COALESCE(sortorder, 0))
FROM subgentables
WHERE tableid = 636
  AND datacode = 8

SET @subsort = COALESCE(@subsort, 0) + 1

IF NOT EXISTS (SELECT 1 FROM subgentables WHERE tableid = 636 AND datacode = 8 AND datasubcode = 16)
BEGIN
	INSERT INTO subgentables
	  (tableid, datacode, datasubcode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind)
	VALUES
	  (636, 8, 16, 'Generic Text', 'N', @subsort, 'SECCNFG', 'Generic Text', 'QSIDBA', GETDATE(), 0, 0, 1, 0)
END
GO

DECLARE @v_newkey INT

IF NOT EXISTS (
  SELECT 1
  FROM gentablesitemtype
  WHERE tableid = 636 
  AND itemtypecode = 1 
  AND itemtypesubcode = 0 
  AND datacode = 8 
  AND datasubcode = 16
)
BEGIN
  EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
	  
  INSERT INTO gentablesitemtype
  (gentablesitemtypekey, tableid, datacode, datasubcode, itemtypecode, itemtypesubcode, lastuserid, lastmaintdate, sortorder, text1)
  VALUES
  (@v_newkey, 636, 8, 16,  1, 0, 'QSIDBA', GETDATE(), 0, NULL)

	UPDATE gentablesitemtype
	set text1 = NULL
	WHERE tableid = 636
	and datacode = 8
	and datasubcode = 16
	and text1 IS NOT NULL
	and LEN(text1) = 0
END
GO