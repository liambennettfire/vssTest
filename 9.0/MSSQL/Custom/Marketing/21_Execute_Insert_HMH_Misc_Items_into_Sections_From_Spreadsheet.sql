
/******************************************************************************************
**  Executes the qutl_insert_miscitemsection  procedure Fom Spreadsheet
*******************************************************************************************/

BEGIN

  DECLARE
  @v_error_code         integer,
  @v_error_desc			varchar(2000) 
    

   SET @v_error_code = 0
   SET @v_error_desc = ''    

exec qutl_insert_miscitemsection NULL, 136, 'Campaign Project Original Total', 9,'Total Costs', 2,2, 1, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 135, 'Campaign Budget', 9,'Total Costs', 2,1, 1, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 56, 'Total Revised', 9,'Total Costs', 2,2, 2, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 137, 'Campaign Project Variance Total', 9,'Total Costs', 2,2, 3, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 133, 'Project Original', 3,'Details', 1,1, 1, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 134, 'Project Revised', 3,'Details', 1,1, 2, 1, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 72, 'Total Variance', 3,'Details', 1,1, 3, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 73, 'Original', 10,'Original/Revised Cost Section', 9,1, 1, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 74, 'Revised', 10,'Original/Revised Cost Section', 9,2, 1, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 75, 'Variance', 10,'Original/Revised Cost Section', 9,3, 1, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 57, 'Galleys Original', 10,'Original/Revised Cost Section', 9,1, 2, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 58, 'Press Materials Original', 10,'Original/Revised Cost Section', 9,1, 3, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 59, 'Author Tours Original', 10,'Original/Revised Cost Section', 9,1, 4, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 60, 'Advertising Original', 10,'Original/Revised Cost Section', 9,1, 5, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 61, 'Coop Advertising Original', 10,'Original/Revised Cost Section', 9,1, 6, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 62, 'Promotion Original', 10,'Original/Revised Cost Section', 9,1, 7, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 63, 'Display Original', 10,'Original/Revised Cost Section', 9,1, 8, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 64, 'Total Original', 10,'Original/Revised Cost Section', 9,1, 14, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 81, 'Galleys Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 2, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 87, 'Press Materials Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 3, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 93, 'Author Tours Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 4, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 102, 'Advertising Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 5, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 103, 'Coop Advertising Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 6, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 104, 'Promotion Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 7, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 116, 'Display Revised Calculated', 10,'Original/Revised Cost Section', 9,2, 8, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 56, 'Total Revised', 10,'Original/Revised Cost Section', 9,2, 14, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 65, 'Galleys Variance', 10,'Original/Revised Cost Section', 9,3, 2, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 66, 'Press Materials Variance', 10,'Original/Revised Cost Section', 9,3, 3, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 67, 'Author Tours Variance', 10,'Original/Revised Cost Section', 9,3, 4, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 68, 'Advertising Variance', 10,'Original/Revised Cost Section', 9,3, 5, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 69, 'Coop Advertising Variance', 10,'Original/Revised Cost Section', 9,3, 6, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 70, 'Promotion Variance', 10,'Original/Revised Cost Section', 9,3, 7, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 71, 'Display Variance', 10,'Original/Revised Cost Section', 9,3, 8, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_miscitemsection NULL, 72, 'Total Variance', 10,'Original/Revised Cost Section', 9,3, 14, 0, @v_error_code output, @v_error_desc output	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
	

END  
  
 GO