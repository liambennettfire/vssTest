 
/******************************************************************************************
**  Execute qutl_insert_miscitemsection  procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_misckey     INT,
  @v_datacode INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000) 


exec qutl_insert_miscitemsection NULL, NULL, 'City', 56,'Event Details', 3,1, 3, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, NULL, 'Event Hour', 56,'Event Details', 3,2, 1, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, NULL, 'Event Minutes', 56,'Event Details', 3,2, 2, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, NULL, 'Event Time Period', 56,'Event Details', 3,2, 3, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, NULL, 'Major Market', 56,'Event Details', 3,1, 2, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc


END  
  
 GO