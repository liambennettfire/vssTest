DECLARE
@v_gentablesrelationshipdetailkey	integer,
@v_error_code						integer,
@v_error_desc						varchar(2000),
@o_itemtypekey						integer,
@v_datacode							integer,
@v_itemtype							integer,
@v_usageclass						integer
    
SET @v_gentablesrelationshipdetailkey = 0
SET @v_error_code = 0
SET @v_error_desc = ''

SET @v_datacode = NULL

SELECT @v_datacode = datacode --43
FROM gentables
WHERE tableid = 583
  AND datadesc = 'Master Acquisition'

IF @v_datacode IS NOT NULL
BEGIN
	exec qutl_insert_gentablesrelationshipdetail_value 6, 'Master Acquisition', 32, 'Master Work', NULL, NULL,  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

	SELECT @v_itemtype = datacode
	FROM gentables
	WHERE tableid = 550
	  AND qsicode = 9

	SELECT @v_usageclass = datasubcode
	FROM subgentables
	WHERE tableid = 550
	  AND datacode = @v_itemtype
	  AND qsicode = 53

	SET @o_itemtypekey = 0
	EXEC dbo.get_next_key 'QSIDBA', @o_itemtypekey OUT

	INSERT INTO gentablesitemtype
	(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
	VALUES
	(@o_itemtypekey, 583, @v_datacode, 0, 0, @v_itemtype, @v_usageclass, 0, 'QSIDBA', GETDATE())
END

SET @v_datacode = NULL

SELECT @v_datacode = datacode --46
FROM gentables
WHERE tableid = 583
  AND datadesc = 'Master Work'

IF @v_datacode IS NOT NULL
BEGIN
	exec qutl_insert_gentablesrelationshipdetail_value 6, 'Master Work', 34, 'Master Acquisition', NULL, NULL,  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT, @v_error_code OUTPUT, @v_error_desc OUTPUT
	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

	SELECT @v_itemtype = datacode
	FROM gentables
	WHERE tableid = 550
	  AND qsicode = 3

	SELECT @v_usageclass = datasubcode
	FROM subgentables
	WHERE tableid = 550
	  AND datacode = @v_itemtype
	  AND qsicode = 52

	SET @o_itemtypekey = 0
	EXEC dbo.get_next_key 'QSIDBA', @o_itemtypekey OUT

	INSERT INTO gentablesitemtype
	(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
	VALUES
	(@o_itemtypekey, 583, @v_datacode, 0, 0, 3, 18, 0, 'QSIDBA', GETDATE())
END