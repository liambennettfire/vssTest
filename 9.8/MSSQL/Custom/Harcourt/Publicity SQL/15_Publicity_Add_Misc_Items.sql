 
/******************************************************************************************
**  Execute qutl_insert_bookmiscitems  procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_misckey     INT,
  @v_datacode INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 

SET @v_datacode = NULL	exec  qutl_insert_bookmiscitems  'City',  3, @v_datacode, NULL, NULL, @v_misckey OUTPUT, @v_error_code  OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc	 	 	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc


END  
  
 GO