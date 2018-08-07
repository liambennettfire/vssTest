/*adding Print Run Po item type filtering for copy project data groups:
comments, tasks, contacts, specs
*/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 


exec qutl_insert_gentable_value 598,'CopyProjectDataGroups',5,'Comments',5,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Comments' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Comments', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 598  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 60	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 598, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = NULL where tableid = 598 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END
exec qutl_insert_gentable_value 598,'CopyProjectDataGroups',8,'Tasks',8,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Tasks' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Tasks', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 598  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 60	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 598, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = NULL where tableid = 598 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END
exec qutl_insert_gentable_value 598,'CopyProjectDataGroups',9,'Contacts',9,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Contacts' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Contacts', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 598  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 60	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 598, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = NULL where tableid = 598 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END
exec qutl_insert_gentable_value 598,'CopyProjectDataGroups',25,'Production Specification',24,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Production Specification' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Production Spec', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 598  and datacode = @v_datacode	SET @V_datasubcode = 0		SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 60	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 598, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = NULL where tableid = 598 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END

END
GO

/*adding override labels on gentablesdesc
*/

update gentablesitemtype
set text1 = 'Copy Comments from the linked project if any exists and then add any additional Comments from the Copy From Project'
where tableid = 598
and datacode = 5
and itemtypecode = 15 and itemtypesubcode = 5
GO

update gentablesitemtype
set text1 = 'Copy Tasks from the linked project if any exists and then add any additional Tasks from the Copy From Project'
where tableid = 598
and datacode = 8
and itemtypecode = 15 and itemtypesubcode = 5
GO

update gentablesitemtype
set text1 = 'Copy Participants/Roles from the linked project if any exists and then add any additional Participants/Roles from the Copy From Project'
where tableid = 598
and datacode = 9
and itemtypecode = 15 and itemtypesubcode = 5
GO

update gentablesitemtype
set text1 = 'Copy the Specifications'
where tableid = 598
and datacode = 25
and itemtypecode = 15 and itemtypesubcode = 5
GO