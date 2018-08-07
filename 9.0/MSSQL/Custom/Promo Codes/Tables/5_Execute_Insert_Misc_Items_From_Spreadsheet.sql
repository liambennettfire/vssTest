

/******************************************************************************************
**  Executes the qutl_insert_bookmiscitems  procedure
*******************************************************************************************/

BEGIN

  DECLARE
   @v_datacode			integer,
   @v_misckey			integer,
   @v_error_code		Integer,
   @v_error_desc		varchar(2000) 
    
  
   SET @v_datacode = NULL
   SET @v_misckey = 0
   SET @v_error_code = 0
   SET @v_error_desc = ''    

   
exec  qutl_insert_bookmiscitems  'Discount Amt Cap Default (Promotion)',  2, @v_datacode, 25, NULL, @v_misckey OUTPUT, @v_error_code  OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc	UPDATE bookmiscitems SET fieldformat = '$###,##0.##', misclabel = 'Discount Amt Cap Default' WHERE misckey = @v_misckey
exec  qutl_insert_bookmiscitems  'Max Times Allowed Default (Promotion)',  2, @v_datacode, 26, NULL, @v_misckey OUTPUT, @v_error_code  OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc	UPDATE bookmiscitems SET fieldformat = '###,##0', misclabel = 'Max Times Allowed Default' WHERE misckey = @v_misckey
exec  qutl_insert_bookmiscitems  'Order Discount Amt Cap',  2, @v_datacode, 27, NULL, @v_misckey OUTPUT, @v_error_code  OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc	UPDATE bookmiscitems SET fieldformat = '$###,##0.##', misclabel = 'Order Discount Amt Cap' WHERE misckey = @v_misckey
exec  qutl_insert_bookmiscitems  'Max Times Allowed',  2, @v_datacode, 22, NULL, @v_misckey OUTPUT, @v_error_code  OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc	UPDATE bookmiscitems SET fieldformat = '###,##0', misclabel = 'Max Times Allowed' WHERE misckey = @v_misckey
exec  qutl_insert_bookmiscitems  'Discount Amount Default ',  2, @v_datacode, 23, NULL, @v_misckey OUTPUT, @v_error_code  OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print 'misckey = ' + CAST(@v_misckey AS varchar)+ ', error message =' + @v_error_desc	UPDATE bookmiscitems SET fieldformat = '$###,##0.##', misclabel = 'Discount Amount Default' WHERE misckey = @v_misckey


 
END  
  
 GO