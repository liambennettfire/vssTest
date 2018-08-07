/******************************************************************************************
**  
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


														
exec qutl_insert_gentable_value 440,'ASCTYP',2,'Author Sales Track',3,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Author Sales Track' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Same Author', alternatedesc1 = 'Author Sales Track', alternatedesc2 = 'NULL', externalcode = 'NULL' WHERE tableid = 440  and datacode = @v_datacode	SET @V_datasubcode = 0	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 1			IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 440, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT, @v_gentablesitemtypekey OUTPUT, NULL, @v_relateddatacode  END	update gentablesitemtype set indicator1 = NULL  where gentablesitemtypekey= @v_gentablesitemtypekey	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc



END
GO


update qsiconfigdetail
set visibleind = 0
where labeldesc = 'Main Relationship Group'
and qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where itemtypecode = 3 and usageclasscode = 1)
GO

update qsiconfigobjects
set defaultvisibleind = 1
where configobjectdesc like 'Main Relationship Group'
and windowid in (select windowid from qsiwindows where windowname like 'ProjectSummary')
GO

update gentables_ext
set gentext1 = 'External Comps'
where tableid = 440 
and datacode = 1
GO

update gentables_ext
set gentext1 = 'Internal Comps'
where tableid = 440 
and datacode = 2
GO

update titlerelationshiptabconfig
set hiderptind = 1, hideitemnumberind = 1, hideillustrationind = 1
where itemtypecode = 1 and usageclass = 0
GO
