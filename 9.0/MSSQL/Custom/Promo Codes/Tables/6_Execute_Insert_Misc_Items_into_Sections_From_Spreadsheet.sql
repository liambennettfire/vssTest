
/******************************************************************************************
**  Executes the qutl_insert_miscitemsection  procedure Fom Spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE
  @v_error_code         integer,
  @v_error_desc			varchar(2000) 
    

   SET @v_error_code = 0
   SET @v_error_desc = ''    
   
exec qutl_insert_miscitemsection 25, NULL, 'Discount Amt Cap Default (Promotion)', 45,'Details', 1,1, 1, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection 26, NULL, 'Max Times Allowed Default (Promotion)', 45,'Details', 1,1, 2, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection 27, NULL, 'Order Discount Amt Cap', 46,'Details', 1,1, 1, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection 22, NULL, 'Max Times Allowed', 46,'Details', 1,1, 2, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection 23, NULL, 'Discount Amount Default ', 46,'Details', 1,1, 3, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc

END  
  
 GO