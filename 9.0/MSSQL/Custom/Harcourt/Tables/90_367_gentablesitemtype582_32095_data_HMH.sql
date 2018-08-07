DECLARE
	@v_datacode INT,
	@v_itemtypecode INT,
	@v_usageclasscode INT
	
SET @v_datacode	= 0

SELECT @v_datacode = datacode FROM gentables WHERE tableid = 582 AND LTRIM(RTRIM(LOWER(datadesc))) = 'marketing project'

SELECT @v_itemtypecode = datacode, @v_usageclasscode = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 9  -- Marketing Campaign

IF @v_datacode > 0 BEGIN
	UPDATE gentablesitemtype SET indicator1 = 0 WHERE tableid = 582
	UPDATE gentablesitemtype SET indicator1 = 1 WHERE tableid = 582 AND datacode = @v_datacode AND itemtypecode = @v_itemtypecode AND itemtypesubcode =  @v_usageclasscode
END
ELSE BEGIN
	PRINT 'No entry found for Marketing Project in gentables 582'
END
GO 