DECLARE @v_datacode	INT,
		@v_datadesc VARCHAR(40),
		@v_itemtype INT,
		@v_usageclass INT,
		@o_itemtypekey INT

SELECT @v_itemtype = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 9

SELECT @v_usageclass = datasubcode
FROM subgentables
WHERE tableid = 550
 AND datacode = @v_itemtype
 AND qsicode = 28

SELECT @v_datacode = datacode, @v_datadesc = datadesc
FROM gentables
WHERE tableid = 583
  AND qsicode = 17

IF NOT EXISTS (SELECT * FROM gentablesitemtype WHERE tableid = 583 AND datacode = @v_datacode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_usageclass)
BEGIN
	IF EXISTS (SELECT * FROM gentablesitemtype WHERE tableid = 583 AND datacode = @v_datacode AND itemtypecode = @v_itemtype)
	BEGIN
		IF EXISTS (SELECT * FROM gentablesitemtype WHERE tableid = 583 AND datacode = @v_datacode AND itemtypecode = @v_itemtype AND (itemtypesubcode = 0 OR itemtypesubcode IS NULL))
		BEGIN
			UPDATE gentablesitemtype
			SET itemtypesubcode = @v_usageclass
			WHERE tableid = 583
			  AND datacode = @v_datacode
			  AND itemtypecode = @v_itemtype
			  AND (itemtypesubcode = 0 OR itemtypesubcode IS NULL)
		END
		ELSE BEGIN
			EXEC dbo.get_next_key 'QSIDBA', @o_itemtypekey OUT

			INSERT INTO gentablesitemtype
			(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
			VALUES
			(@o_itemtypekey, 583, @v_datacode, 0, 0, @v_itemtype, @v_usageclass, 0, 'QSIDBA', GETDATE())
		END
	END
	ELSE BEGIN
		EXEC dbo.get_next_key 'QSIDBA', @o_itemtypekey OUT

		INSERT INTO gentablesitemtype
		(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, lastuserid, lastmaintdate)
		VALUES
		(@o_itemtypekey, 583, @v_datacode, 0, 0, @v_itemtype, @v_usageclass, 0, 'QSIDBA', GETDATE())
	END
END