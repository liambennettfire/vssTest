
/******************************************************************************************
**  Executes the date type procedures created in the date type values excel spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE
   @v_datetypecode integer,
   @v_datasubcode integer,
   @v_error_code  integer,
   @v_classcode   integer,
   @v_itemtype    integer,
   @v_error_desc varchar(2000) 
   
   set @v_datasubcode = 0
   set @v_error_code = 0
   set @v_error_desc = ' '
   
exec qutl_insert_datetype_value 14,'Effective Date',NULL,0, @v_datetypecode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datetypecode AS varchar)+ ', description = ' + 'Effective Date' +', error message =' + @v_error_desc	UPDATE datetype SET datelabel = 'Effective Date',  eloquencefieldtag='CLD_PC_EFF_DT', milestoneind = 1 WHERE datetypecode = @v_datetypecode	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 45	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 323, @v_datetypecode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datetypecode = ' + CAST(@v_datetypecode AS varchar)+ ', error message =' + @v_error_desc	UPDATE gentablesitemtype SET relateddatacode =2, indicator1 = 1 where tableid = 323 AND datacode= @v_datetypecode AND itemtypecode = @v_itemtype and itemtypesubcode = @v_classcode
exec qutl_insert_datetype_value 15,'Expiration Date',NULL,0, @v_datetypecode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datetypecode AS varchar)+ ', description = ' + 'Expiration Date' +', error message =' + @v_error_desc	UPDATE datetype SET datelabel = 'Expiration Date',  eloquencefieldtag='CLD_PC_EXP_DT', milestoneind = 1 WHERE datetypecode = @v_datetypecode	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 45	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 323, @v_datetypecode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datetypecode = ' + CAST(@v_datetypecode AS varchar)+ ', error message =' + @v_error_desc	UPDATE gentablesitemtype SET relateddatacode =2, indicator1 = 1 where tableid = 323 AND datacode= @v_datetypecode AND itemtypecode = @v_itemtype and itemtypesubcode = @v_classcode
						
exec qutl_insert_datetype_value 14,'Effective Date',NULL,0, @v_datetypecode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datetypecode AS varchar)+ ', description = ' + 'Effective Date' +', error message =' + @v_error_desc	UPDATE datetype SET datelabel = 'Effective Date',  eloquencefieldtag='CLD_PC_EFF_DT', milestoneind = 1 WHERE datetypecode = @v_datetypecode	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 46	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 323, @v_datetypecode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datetypecode = ' + CAST(@v_datetypecode AS varchar)+ ', error message =' + @v_error_desc	UPDATE gentablesitemtype SET relateddatacode =2, indicator1 = 1 where tableid = 323 AND datacode= @v_datetypecode AND itemtypecode = @v_itemtype and itemtypesubcode = @v_classcode
exec qutl_insert_datetype_value 15,'Expiration Date',NULL,0, @v_datetypecode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datetypecode AS varchar)+ ', description = ' + 'Expiration Date' +', error message =' + @v_error_desc	UPDATE datetype SET datelabel = 'Expiration Date',  eloquencefieldtag='CLD_PC_EXP_DT', milestoneind = 1 WHERE datetypecode = @v_datetypecode	SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 46	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 323, @v_datetypecode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datetypecode = ' + CAST(@v_datetypecode AS varchar)+ ', error message =' + @v_error_desc	UPDATE gentablesitemtype SET relateddatacode =2, indicator1 = 1 where tableid = 323 AND datacode= @v_datetypecode AND itemtypecode = @v_itemtype and itemtypesubcode = @v_classcode
		

END  
  
 GO