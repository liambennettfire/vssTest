
/******************************************************************************************
**  Executes the insert taqspecadmin stored procedure for the Standard Specification Items
*******************************************************************************************/

BEGIN

  DECLARE
    @v_categorycode INTEGER,
    @v_itemcode INTEGER,
    @v_error_code  INT,
    @v_error_desc varchar(2000) 
    
EXEC qutl_get_subgentables_codes_by_qsi_or_desc 616,  1, 'Summary',22,'Other Format',  @v_categorycode output,  @v_itemcode output,  @v_error_code output,  @v_error_desc output	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_categorycode AS varchar)+ ', datasubcode = ' + CAST(@v_itemcode AS varchar) +', error message =' + @v_error_desc   SET @v_error_code = 0   SET  @v_error_desc = ' ' 	EXEC qutl_insert_taqspecadmin_value 1,@v_categorycode, @v_itemcode, 1, 0, '',0,'', 0,'',3,0,0,0,0,0, '', 13, @v_error_code output, @v_error_desc output 	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_categorycode AS varchar)+ ', datasubcode = ' + CAST(@v_itemcode AS varchar) +', error message =' + @v_error_desc
EXEC qutl_get_subgentables_codes_by_qsi_or_desc 616,  1, 'Summary',23,'Jacket Vendor',  @v_categorycode output,  @v_itemcode output,  @v_error_code output,  @v_error_desc output	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_categorycode AS varchar)+ ', datasubcode = ' + CAST(@v_itemcode AS varchar) +', error message =' + @v_error_desc   SET @v_error_code = 0   SET  @v_error_desc = ' ' 	EXEC qutl_insert_taqspecadmin_value 1,@v_categorycode, @v_itemcode, 1, 0, '',0,'', 0,'',3,0,0,0,0,0, '', 14, @v_error_code output, @v_error_desc output 	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_categorycode AS varchar)+ ', datasubcode = ' + CAST(@v_itemcode AS varchar) +', error message =' + @v_error_desc
EXEC qutl_get_subgentables_codes_by_qsi_or_desc 616,  1, 'Summary',24,'Print Vendor',  @v_categorycode output,  @v_itemcode output,  @v_error_code output,  @v_error_desc output	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_categorycode AS varchar)+ ', datasubcode = ' + CAST(@v_itemcode AS varchar) +', error message =' + @v_error_desc   SET @v_error_code = 0   SET  @v_error_desc = ' ' 	EXEC qutl_insert_taqspecadmin_value 1,@v_categorycode, @v_itemcode, 1, 0, '',0,'', 0,'',3,0,0,0,0,0, '', 15, @v_error_code output, @v_error_desc output 	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_categorycode AS varchar)+ ', datasubcode = ' + CAST(@v_itemcode AS varchar) +', error message =' + @v_error_desc

END  
  
 GO