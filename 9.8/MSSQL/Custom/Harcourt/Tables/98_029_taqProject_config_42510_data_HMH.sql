--CASE 42510
--Add project status of delete with qsiCode

BEGIN

DECLARE
  @v_itemtype INT,
  @v_usageclass INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code INT ,
  @v_error_desc VARCHAR(2000) 

BEGIN
	--Add subgentables entry
	exec qutl_insert_gentable_value 522,'ProjectStatus',22,'Delete',NULL,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Delete' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Delete', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 522  and datacode = @v_datacode	SET @V_datasubcode = 0		SET @v_classcode =  0  SET @v_itemtype = 0	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 522, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = NULL where tableid = 522 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END
	--Add itemTypeFiltering to marketing projects
	exec qutl_insert_gentable_value 522,'ProjectStatus',22,'Delete',NULL,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Delete' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Delete', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 522  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 3	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 522, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = 1 where tableid = 522 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END
END

END

