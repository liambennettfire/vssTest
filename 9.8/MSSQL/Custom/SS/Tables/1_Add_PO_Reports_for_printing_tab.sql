/******************************************************************************************
** Adds the PO Reports(for printings) tab
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_relatedtableid INT,
  @v_relateddatacode INT,
  @v_gentablesitemtypekey INT,
  @v_error_desc   VARCHAR(2000) 


														
exec qutl_insert_gentable_value 583,'WebRelationshipTab',37,'PO Reports (on Printings)',2,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'PO Reports (on Printings)' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'PO Rtp Prtg', alternatedesc1 = 'PO Reports', alternatedesc2 = '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx', externalcode = 'NULL' WHERE tableid = 583  and datacode = @v_datacode	SET @V_datasubcode = 0	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 40	SELECT @v_relatedtableid = itemtyperelatedtableid FROM gentablesdesc where tableid = 583	EXEC @v_relateddatacode = qutl_get_gentables_datacode @v_relatedtableid, 0 ,'Main Relationship Group'	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 583, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT, @v_gentablesitemtypekey OUTPUT, 2, @v_relateddatacode  END	update gentablesitemtype set indicator1 = NULL  where gentablesitemtypekey= @v_gentablesitemtypekey	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc

END
GO