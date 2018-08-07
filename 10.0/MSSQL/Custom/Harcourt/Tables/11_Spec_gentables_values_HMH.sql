
/******************************************************************************************
**  Executes the qutl_insert_gentableitem procedure for the Standard Specification Items
Adds custom specs to summary component: Other Foramt, Jacket Vendor, Print Vendor
*******************************************************************************************/

BEGIN

  DECLARE
   @v_tableid INT,
   @v_datacode INT,
   @v_datasubcode INT,
   @v_datasub2code INT,
   @v_itemtype INT,
   @v_classcode INT,   
   @v_error_code  INT,
   @v_error_desc VARCHAR(2000) 
   
SET @v_error_code = 0
SET @v_error_desc = ' ' 
 
exec qutl_insert_gentable_value 616,'SPECS',1,'Summary',1,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Summary' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Summary', gen1ind = 0, gen2ind = 0 WHERE tableid = 616  and datacode = @v_datacode	exec qutl_insert_subgentable_value 616, @v_datacode,'SPECS',22, 'Other Format',13 ,0,  @v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	UPDATE subgentables SET numericdesc1 =300, numericdesc2 =NULL, subgen1ind = 0,  subgen2ind = 0, subgen3ind = 0, subgen4ind = 1 where tableid= 616 AND datacode=@v_datacode AND datasubcode =  @v_datasubcode	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	SET @V_datasub2code = 0		IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc
exec qutl_insert_gentable_value 616,'SPECS',1,'Summary',1,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Summary' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Summary', gen1ind = 0, gen2ind = 0 WHERE tableid = 616  and datacode = @v_datacode	exec qutl_insert_subgentable_value 616, @v_datacode,'SPECS',23, 'Jacket Vendor',14 ,0,  @v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	UPDATE subgentables SET numericdesc1 =330, numericdesc2 =NULL, subgen1ind = 0,  subgen2ind = 0, subgen3ind = 0, subgen4ind = 1 where tableid= 616 AND datacode=@v_datacode AND datasubcode =  @v_datasubcode	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	SET @V_datasub2code = 0		IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc
exec qutl_insert_gentable_value 616,'SPECS',1,'Summary',1,1, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Summary' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Summary', gen1ind = 0, gen2ind = 0 WHERE tableid = 616  and datacode = @v_datacode	exec qutl_insert_subgentable_value 616, @v_datacode,'SPECS',24, 'Print Vendor',15 ,0,  @v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	UPDATE subgentables SET numericdesc1 =330, numericdesc2 =NULL, subgen1ind = 0,  subgen2ind = 0, subgen3ind = 0, subgen4ind = 1 where tableid= 616 AND datacode=@v_datacode AND datasubcode =  @v_datasubcode	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	SET @V_datasub2code = 0		IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc



END  
  
 GO