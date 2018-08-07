
/*******************************************************************************************
**  Executes the qutl_insert_gentablesrelationshipdetail_value procedure
 -  pull sql from Spreadsheet 
*******************************************************************************************/

BEGIN

  DECLARE
  @v_gentablesrelationshipdetailkey integer,
  @v_error_code						integer,
  @v_error_desc						varchar(2000) 
    
  SET @v_gentablesrelationshipdetailkey = 0
  SET @v_error_code = 0
  SET @v_error_desc = ' '
    
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Marketing Campaign (Plan)', NULL, 'Marketing Plan',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Marketing Campaign (Projects)', NULL, 'Marketing Project',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Marketing Plan', NULL, 'Marketing Campaign (Plan)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Marketing Project', NULL, 'Marketing Campaign (Projects)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Campaign (Plan)', NULL, 'Mktg Campaigns (Mktg Plan)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Campaign (Plan)', NULL, 'Mktg Plan (Mktg Campaign)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Campaign (Projects)', NULL, 'Mktg Projects (Campaign)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Campaign (Projects)', NULL, 'Mktg Campaigns (Mktg Projects)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Plan', NULL, 'Mktg Campaigns (Mktg Plan)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Plan', NULL, 'Mktg Plan (Mktg Campaign)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Project', NULL, 'Mktg Projects (Campaign)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Marketing Project', NULL, 'Mktg Campaigns (Mktg Projects)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 8, 'Marketing Plan', NULL, 'Marketing Plan',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 8, 'Single Book ', NULL, 'Marketing Campaign (Plan)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 8, 'Single Book ', NULL, 'Marketing Campaign (Projects)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 10, 'Marketing', NULL, 'Marketing (Titles)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 10, 'Marketing', NULL, 'Titles (Projects)',  15,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 11, 'Title', 1, 'Marketing (Titles)',  NULL,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 11, 'Title', 1, 'Titles (Projects)',  15,'NULL',  NULL, 'NULL',NULL,0, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc


END  
  
 GO