DECLARE
@v_tableid INT,
@v_datacode INT,
@v_datasubcode INT,
@v_itemtypecode INT

SET @v_tableid = 636
SET @v_datacode = 4
SET @v_datasubcode = 14
SET @v_itemtypecode = dbo.qutl_get_gentables_datacode(550, 14, '')

UPDATE gentablesitemtype 
SET text1 = 'PO'
WHERE tableid = @v_tableid and datacode = @v_datacode and datasubcode  = @v_datasubcode
and itemtypecode = @v_itemtypecode
