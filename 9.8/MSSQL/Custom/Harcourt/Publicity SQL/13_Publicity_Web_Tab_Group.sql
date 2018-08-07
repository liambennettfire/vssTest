
 
/******************************************************************************************
**  Creates Publicity Web Tab Group
**  Executes the qutl_insert_gentable_value  procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 
  
exec qutl_insert_gentable_value 680,'TabGroup',NULL,'Publicity Tab Group',2,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Publicity Tab Group' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Pub Tab Group', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 680  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 54	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 680, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = 2 where tableid = 680 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END

exec qutl_insert_gentable_value 680,'TabGroup',1,'Main Relationship Group',1,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Main Relationship Group' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Main Group', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 680  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 54	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 680, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = 3 where tableid = 680 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END


end
go