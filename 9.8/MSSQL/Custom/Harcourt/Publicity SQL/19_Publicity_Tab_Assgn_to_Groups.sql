/******************************************************************************************
**  HMH Marketing Campaign titles(projects) assign to custom Mktg tab group
    Publicity Campaign, author tour, and publicity project assign tabs to Main relationship tab group
    Assign Publicty Campaing titles(projects) assign to custom PUblicity tab group
**  qutl_insert_gentable_value
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_gentablesitemtypekey INT,
  @v_relateddatacode INT,
  @v_relatedtableid INT, 

  @v_error_desc   VARCHAR(2000)


exec qutl_insert_gentable_value 583,'WebRelationshipTab',NULL,'Publicity (Publ Campgn)',1,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Publicity (Publ Campgn)' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Publ (Publ Campgn)', alternatedesc1 = 'Publicity Projects', alternatedesc2 = '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx', externalcode = 'NULL' WHERE tableid = 583  and datacode = @v_datacode	SET @V_datasubcode = 0	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 54	SELECT @v_relatedtableid = itemtyperelatedtableid FROM gentablesdesc where tableid = 583	EXEC @v_relateddatacode = qutl_get_gentables_datacode @v_relatedtableid, 0 ,'Main Relationship Group'	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 583, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT, @v_gentablesitemtypekey OUTPUT, 1, @v_relateddatacode  END	update gentablesitemtype set indicator1 = NULL  where gentablesitemtypekey= @v_gentablesitemtypekey	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc
exec qutl_insert_gentable_value 583,'WebRelationshipTab',NULL,'Titles (Projects)',1,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Titles (Projects)' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Titles (Projects)', alternatedesc1 = 'Titles', alternatedesc2 = '~/PageControls/ProjectRelationships/TitlesProject.ascx', externalcode = 'NULL' WHERE tableid = 583  and datacode = @v_datacode	SET @V_datasubcode = 0	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 54	SELECT @v_relatedtableid = itemtyperelatedtableid FROM gentablesdesc where tableid = 583	EXEC @v_relateddatacode = qutl_get_gentables_datacode @v_relatedtableid, 0 ,'Publicity Tab Group'	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 583, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT, @v_gentablesitemtypekey OUTPUT, 1, @v_relateddatacode  END	update gentablesitemtype set indicator1 = NULL  where gentablesitemtypekey= @v_gentablesitemtypekey	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc
exec qutl_insert_gentable_value 583,'WebRelationshipTab',NULL,'Publicity Campaign',1,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Publicity Campaign' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Publicity Campaign', alternatedesc1 = 'Publicity Campaign', alternatedesc2 = '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx', externalcode = 'NULL' WHERE tableid = 583  and datacode = @v_datacode	SET @V_datasubcode = 0	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 56	SELECT @v_relatedtableid = itemtyperelatedtableid FROM gentablesdesc where tableid = 583	EXEC @v_relateddatacode = qutl_get_gentables_datacode @v_relatedtableid, 0 ,'Main Relationship Group'	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 583, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT, @v_gentablesitemtypekey OUTPUT, 1, @v_relateddatacode  END	update gentablesitemtype set indicator1 = NULL  where gentablesitemtypekey= @v_gentablesitemtypekey	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc
exec qutl_insert_gentable_value 583,'WebRelationshipTab',NULL,'Publicity Campaign',1,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Publicity Campaign' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Publicity Campaign', alternatedesc1 = 'Publicity Campaign', alternatedesc2 = '~/PageControls/ProjectRelationships/ProjectsGeneric.ascx', externalcode = 'NULL' WHERE tableid = 583  and datacode = @v_datacode	SET @V_datasubcode = 0	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 55	SELECT @v_relatedtableid = itemtyperelatedtableid FROM gentablesdesc where tableid = 583	EXEC @v_relateddatacode = qutl_get_gentables_datacode @v_relatedtableid, 0 ,'Main Relationship Group'	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 583, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT, @v_gentablesitemtypekey OUTPUT, 1, @v_relateddatacode  END	update gentablesitemtype set indicator1 = NULL  where gentablesitemtypekey= @v_gentablesitemtypekey	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc


END
GO


