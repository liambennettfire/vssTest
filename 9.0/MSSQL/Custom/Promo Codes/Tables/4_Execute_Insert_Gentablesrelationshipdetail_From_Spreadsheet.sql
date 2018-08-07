
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
    
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Promotion', NULL, 'Promo Code',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 5, 'Promo Code', NULL, 'Promotion',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Promotion', NULL, 'Promotion',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Promo Code', NULL, 'Promotion',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Promotion', NULL, 'Promo Codes',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 6, 'Promo Code', NULL, 'Promo Codes',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 9, 'Dollar Off Products', NULL, 'Promo Code',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 10, 'Promo Code', NULL, 'Titles (Projects)',  15,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 11, 'Title (for Promo Codes)', NULL, 'Titles (Projects)',  15,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 14, 'Dollar Off Products', NULL, 'Title (for Promo Codes)',  NULL,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 10, 'Promo Code', NULL, 'Projects (Titles)',  14,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc
exec qutl_insert_gentablesrelationshipdetail_value 11, 'Title (for Promo Codes)', NULL, 'Projects (Titles)',  14,'NULL',  NULL, 'NULL',NULL,1, @v_gentablesrelationshipdetailkey OUTPUT,  @v_error_code OUTPUT, @v_error_desc OUTPUT	IF @v_error_code <> 0  print ' error message =' + @v_error_desc


END  
  
 GO